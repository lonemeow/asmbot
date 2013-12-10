SRCS=main.s bot.s

asmbot: $(SRCS)
	gcc $(SRCS) -o $@
