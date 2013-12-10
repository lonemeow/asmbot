#include "common.S"

.text
.global		main

// %rdi = server (string)
// %rsi = port (string)
connect_to_server:
        sub     $16, %rsp
        push    %r14
        push    %r15

        // r14 = socket
        mov     $-1, %r14

        mov     $0, %rdx
        lea     8(%rsp), %rcx
        call    getaddrinfo
        cmp     $0x0, %eax
        jl      1f

        mov     8(%rsp), %r15
        mov     4(%r15), %edi   // 4 = offsetof(addrinfo.ai_family)
        mov     8(%r15), %esi   // 8 = offsetof(addrinfo.ai_socktype)
        mov     12(%r15), %edx  // 12 = offsetof(addrinfo.ai_protocol)
        call    socket
        cmp     $0, %eax
        jl      2f

        mov     %rax, %r14
        mov     %eax, %edi
        mov     24(%r15), %rsi   // 24 = offsetof(addrinfo.ai_addr)
        mov     16(%r15), %edx   // 16 = offsetof(addrinfo.ai_addrlen)
        call    connect
        cmp     $0, %eax
        jge     2f

        mov     %r14, %rdi
        call    close

2:
        mov     8(%rsp), %rdi
        call    freeaddrinfo

1:
        mov     %r14, %rax
        pop     %r15
        pop     %r14
        add     $16, %rsp
        ret


// %rdi = string to parse (modified)
parse_serverport:
        mov     %rdi, servername(%rip)

        mov     $':', %rsi
        call    rindex
        test    %rax, %rax
        jne     1f

        // not found
        mov     $-1, %rax
        jmp     2f

1:
        movb    $0, (%rax)
        inc     %rax
        mov     %rax, serverport(%rip)

        // return success
        xor     %rax, %rax

2:
        ret 


// %rdi = argc
// %rsi = argv
parse_args:
        push    %r14
        push    %r15

        // copy argc, argv to r14, r15
        mov     %rdi, %r14
        mov     %rsi, %r15

        cmp     $2, %r14d
        jl      2f

        mov     8(%r15), %rax
        mov     %rax, %rdi
        call    parse_serverport
        cmp     $0x0, %rax
        jl      2f

        mov     16(%r15), %rax
        mov     %rax, nickname(%rip)

        // success
        xor     %rax, %rax
        jmp     1f

2:
        mov     $-1, %rax

1:
        pop     %r15
        pop     %r14
        ret


// %rdi = argc
// %rsi = argv
main:
        push    %r15

        // save argv[0]
        mov     (%rsi), %r15

        call    parse_args
        cmp     $0, %rax
        je      1f

        lea     usagemsg(%rip), %rdi
        mov     %r15, %rsi
        xor     %rax, %rax
        call    printf
        jmp     2f

1:
        lea     connectmsg(%rip), %rdi
        mov     servername(%rip), %rsi
        mov     serverport(%rip), %rdx
        xor     %rax,%rax
        call    printf

        mov     servername(%rip), %rdi
        mov     serverport(%rip), %rsi
        call    connect_to_server
        cmp     $0, %eax
        jl      2f

        mov     %eax, serversocket(%rip)

        call    bot_mainloop

2:
        pop     %r15
        xor     %rax, %rax
        ret

.data
connectmsg:     .asciz  "Connecting to %s:%s ...\n"
usagemsg:       .asciz  "Usage: %s <server:port> <nickname>\n"

// vim: expandtab:
