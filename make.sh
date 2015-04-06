nasm -f elf64 TaylorCompute.asm -o tay.o
g++ -m64 -Wall Driver.cpp -c -o driv.o
g++ -m64 -Wall driv.o tay.o -o exec.out
./exec.out
