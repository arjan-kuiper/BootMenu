CD /D D:\Program Files\NASM
nasm -f bin C:\Users\Arjan\CLionProjects\assembly\bootloader.asm -o C:\Users\Arjan\CLionProjects\assembly\bootloader.bin
CD D:\Program Files\qemu 
qemu-system-x86_64.exe C:\Users\Arjan\CLionProjects\assembly\bootloader.bin