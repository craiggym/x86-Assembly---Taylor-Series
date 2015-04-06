;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**
;Author information
;  Author name: Craig Marroquin
;  Author email: craigmarroquin@yahoo.com
;  Author location: Irvine, California
;Course information
;  Course number: CPSC240
;  Assignment number: 
;  Due date: 04-11-15
;Project information
;  Project title: TaylorCompute.asm
;  Purpose:  
;  Status: No known errors.
;  Project files: ArrayProcess.asm, geloength.cpp, inputqarray.asm, outputarray.cpp, sumarray.asm
;  Background: To understand how arrays work in assembly. Also to learn how to call on multiple functions and separate files to mimic assembly in the work environment.
;  Project references: 
;  This module's call name: ArrayProcess
;  Language: X86-64
;  Syntax: Intel
;  History: 
;   2015-03-28 Completed the macro portion of the assignment
;   2015-04-06 Completed the nextterm.cpp function
;  Date last modified: 2015-03-20(source code)
;  Purpose: This program will call on numerous files for their functions.
;  File name: ArrayProcess.asm
;  Status: No known errors.
;  Future enhancements: None as of now but willing to take recommendations.
;  Linux: nasm -f elf64 ArrayProcess.asm -o OutputFiles/arrayPrompt.o
;References and credits: 
;
;
;Format information
;  Page width: 172 columns
;  Begin comments: 61
;  Optimal print specification: Landscape, 7 points or smaller, monospace, 8½x11 paper
;Permissions
;  The source code is free for use by members of the 240 programming course.
;  instructions are free to use, but the borrower must create his or her own comments.  The comments belong to the author.
;===== Begin area for source code==========================================================================================================================================
global TaylorCompute
%include "utilities.inc"

extern nextterm
extern printf
extern scanf

segment .data
doWhat: db "This program will compute Sin(x) with high accuracy.", 10, 0
theTics: db "The CPU time is now ", 0
tics: db " tics.", 10, 10, 0

enterRad: db "Please enter a radian value for x and sin(x) will be computed:  ", 0
enterTerms: db "Enter the number of terms to be included in the computation: ", 0
sinx: db "The value for sin(x) has been computed.", 0

clockafter: db "The clock after the computation was   ", 0
clockbefore: db "The clock before the computation was   ", 0

compReqA: db "The computation required 	 	", 0
comReqB: db " tics, which equals ", 0
comReqC: db " nanoseconds = ", 0
compReqD: db " seconds.", 10, 0

sinxResult: db "Sin(x) =  ", 10, 0
lastTaylor: db "The last term in the Taylor series was ", 0

newline: db 10, 0
newline2: db 10, 10, 0

string: db "%s", 0
double: db "%lf", 0
int: db "%u", 0

segment .bss

segment .text

TaylorCompute:

saveGPRs

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, doWhat								;"This program will compute Sin(x) with high accuracy."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, theTics							;"The CPU time is now "
call printf								;Calls printf function from the C library

mov rax, 0								;clear the rax register as rdtsc uses this register
mov rdx, 0								;clear the rdx register as rdtsc uses this register
rdtsc									;Places the time in tics in rdx:rax

shl rdx, 32								;Shift the lower half of rdx into the higher half so that the higher half of rax and 
									;be combined with it
or rdx, rax								;Combine the higher half of rax into the lower half of rdx
push rdx								;Preserve the information by placing it onto the stack

mov rax, 0								;SSE will not be used
mov rdi, int								;"%u" for unsigned
mov rsi, [rsp]								;The time in tics that was pushed onto the stack earlier
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, tics								;" tics."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, enterRad							;Please enter a radian value for x and sin(x) will be computed:  "
call printf								;Calls printf function from the C library

push qword 0								;Reserving space on the stack for this input
mov rax, 0								;SSE will not be used
mov rdi, double								;"%lf"
mov rsi, rsp								;stack area
call scanf								;Call scanf function from the C library.

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, enterTerms							;"Enter the number of terms to be included in the computation: "
call printf								;Calls printf function from the C library

push qword 0								;Reserving space on the stack for this input
mov rax, 0								;SSE will not be used
mov rdi, double								;"%lf"
mov rsi, rsp								;stack area
call scanf								;Call scanf function from the C library.

mov rax, 0								;SSE will not be used
mov rsi, string								;"%s"
mov rdi, sinx								;"The value for sin(x) has been computed."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rsi, string								;"%s"
mov rdi, clockafter							;"The clock after the computation was   "
call printf								;Calls printf function from the C library

mov rax, 0
mov rdx, 0
rdtsc


;------------------ Popping
pop rax
pop rax
pop rax

restoreGPRs

ret

