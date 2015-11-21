prgrep: main.o
	mv ./main ./prgrep

%.o:
	nasm -f elf -F dwarf -g $*.asm
	ld -m elf_i386 -o $* $@

clean: 
	rm -f prgrep
	rm -rf *.o
