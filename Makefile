SRCS=main.S bot.S

asmbot: $(SRCS)
	gcc $(SRCS) -o $@
