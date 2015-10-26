hello: helloworld.asm
	nasm -f elf64 $<
	ld -o $@ helloworld.o
	./hello

read: fileRead.asm
	nasm -f elf64 $<
	ld -o $@ fileRead.o
	./read hello.txt
	./read hello.txt

clean: 
	rm -f hello
	rm -f read
	rm -rf *.o
