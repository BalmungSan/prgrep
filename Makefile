prgrep: prgrep.o
	mv a.out ./prgrep
	./prgrep "Hello" "He"

bm: BoyerMoore.java
	javac $<
	java BoyerMoore "jhjhjahshelllskHellolosjsme" "Hello"

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
	rm -f prgrep
	rm -f hello
	rm -f read
	rm -rf *.o
	rm -rf *.class
