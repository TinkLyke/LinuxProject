all: lynarr

lynarr: lynarr.o asm_io.o
	gcc -m32 -o lynarr lynarr.o driver.c asm_io.o
asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm
lynarr.o:
	nasm -f elf32 -o lynarr.o lynarr.asm
clean:
	rm lynarr.o lynarr
