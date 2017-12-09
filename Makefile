UNAME := $(shell uname)
STAT := stat

all: bootloader.img

bootloader.img: bootloader.asm Makefile
	nasm -d DEBUG -f bin bootloader.asm -o bootloader.img
	@echo "size is" `$(STAT) -c "%s" bootloader.img`
	nasm -f bin bootloader.asm -o bootloader.img

run: bootloader.img
	@qemu-system-i386 -net none -drive file=bootloader.img,index=0,media=disk,format=raw

dump: bootloader.img
	@hexdump bootloader.img

debug: bootloader.img
	@qemu-system-i386 -net none -s -S -boot a -drive file=bootloader.img,index=0,media=disk,format=raw & gdb -q

clean:
	rm -f bootloader.img