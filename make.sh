nasm -f elf64 TaylorCompute.asm -o tay.o
g++ -m64 -Wall nextterm.cpp -c -o nterm.o
g++ -m64 -Wall Driver.cpp -c -o driv.o
g++ -m64 -Wall debug.o driv.o tay.o nterm.o -o exec.out
./exec.out
