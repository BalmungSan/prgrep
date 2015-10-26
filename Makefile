hello: helloworld.asm
	nasm -f elf64 $<
	ld -o $@ helloworld.o
	./hello

clean: 
	rm -f hello
	rm -rf *.o
