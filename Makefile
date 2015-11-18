Boyer-Moore: Boyer-Moore.o
	mv a.out ./Boyer-Moore
	./Boyer-Moore "Hello"

hello: helloworld.o
	mv a.out ./hello
	./hello

read: fileRead.o
	mv a.out ./read
	./read hello.txt

%.o:
	nasm -f elf32 $*.asm
	ld -m elf_i386 -s $@

clean: 
	rm -f Boyer-Moore
	rm -f hello
	rm -f read
	rm -rf *.o
