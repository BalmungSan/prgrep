hello: helloworld.asm
	nasm -f elf64 $<
	ld -o $@ helloworld.o

clean: 
	rm -f hello
	rm -rf *.o
