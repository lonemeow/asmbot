.include "common.s"

.text
.global		bot_mainloop

# ssize_t write(int fd, const void *buf, size_t count);
writeall:
        mov     %rdx, %r11

1:
	push    %rdi
	push    %rsi

        call    write
        cmp     $0, %rax
        jl      1f

        sub     %rax, %r11
        jz      1f

        pop     %rdi
        pop     %rsi
        jmp     1b

1:
        pop     %rdi
        pop     %rsi
        ret

writestring:
        push    %rdi
        call    strlen
        pop     %rsi
        mov     serversocket(%rip), %rdi
        mov     %rax, %rdx
        call    writeall
        ret

write_space:
        lea     space(%rip), %rdi
        call    writestring
        ret

write_colon:
        lea     colon(%rip), %rdi
        call    writestring
        ret

write_crlf:
        lea     crlf(%rip), %rdi
        call    writestring
        ret

# %rdi = nickname
cmd_nick:
        push    %rdi

        # NICK
        lea     nick(%rip), %rdi
        call    writestring
        call    write_space

        # nickname
        pop     %rdi
        call    writestring

        call    write_crlf
        ret

# %rdi = username
# %rsi = realname
cmd_user:
        push    %rsi
        push    %rdi

        # USER
        lea     user(%rip), %rdi
        call    writestring
        call    write_space

        # username
        pop     %rdi # %rdi = username
        call    writestring
        call    write_space

        # mode
        lea     defaultmode(%rip), %rdi
        call    writestring
        call    write_space

        # unused
        lea     defaultmode(%rip), %rdi
        call    writestring
        call    write_space

        # :realname
        call    write_colon
        pop     %rdi # %rdi = realname
        call    writestring

        call    write_crlf
        ret

bot_mainloop:
        mov     nickname(%rip), %rdi
        call    cmd_nick

        lea     username(%rip), %rdi
        lea     realname(%rip), %rsi
        call    cmd_user
1:
        nop
        jmp     1b
        ret

.data
user:   .asciz  "USER"
nick:   .asciz  "NICK"

colon:  .asciz  ":"
space:  .asciz  " "
crlf:   .asciz  "\r\n"

username: .asciz "asmbot"
realname: .asciz "The one and only, ASMBot (x64)"
defaultmode: .asciz "8"

# vim: expandtab:
