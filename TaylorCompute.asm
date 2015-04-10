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
%include "debug.inc"

extern nextterm
extern printf
extern scanf

segment .data
doWhat: db "This program will compute Sin(x) with high accuracy.", 10, 0
theTics: db "The CPU time is now ", 0
tics: db " tics", 10, 0
ticscomma: db " tics, ", 0

enterRad: db "Please enter a radian value for x and sin(x) will be computed:  ", 0
enterTerms: db "Enter the number of terms to be included in the computation: ", 0
sinx: db "The value for sin(x) has been computed.", 10, 0

clockafter: db "The clock after the computation was    ", 0
clockbefore: db "The clock before the computation was   ", 0

compReqA: db "The computation required 	 	", 0
comReqB: db " tics, which equals ", 0
comReqC: db " nanoseconds = ", 0
compReqD: db " seconds.", 10, 0

sinxResult: db "Sin(x) =  ", 0
lastTaylor: db "The last term in the Taylor series was ", 0

ticsconvert: db "which equals ", 0

nano: db " nanoseconds = ", 0
seconds: db " seconds.", 10, 0

newline: db 10, 0
newline2: db 10, 10, 0

string: db "%s", 0
longg: db "%ld", 0
double: db "%lf", 0
double2: db "%.25lf", 0
time: db "%lu", 0

GHz: dq 2.40, 0
secConv: dq 0.000000001, 0

segment .bss

segment .text

TaylorCompute:
mov r15, rax

saveGPRs

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, doWhat								;"This program will compute Sin(x) with high accuracy."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, theTics							;"The CPU time is now "
call printf								;Calls printf function from the C library

clockTime r8								;Takes the current time in tics and places it in r8

mov rax, 0								;SSE will not be used
mov rdi, time								;"%lu" for unsigned
mov rsi, r8								;The time in tics that was pushed onto the stack earlier
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, tics								;" tics."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, enterRad							;Please enter a radian value for x and sin(x) will be computed:  "
call printf								;Calls printf function from the C library

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
mov rdi, time								;"%l"
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

clockTime r9								;Takes the current time in tics and places it in r9. This will be used for computing
									;the amount of time from the function call.

push r9

;=============================================== Pre-conditions before entering loop ===============================================================================
;Before going into loop I will be using:
;  r14: Will hold the number of terms for the computation
;  r13: Will be the counter
;  xmm0: Will hold the old(and initial) term which will change every time nextterm is called. The result will be added to the sum (xmm15).
;  xmm1: Will hold the fixed value of x which was taken from user input
;  xmm7: Will hold the accumulated sum
;===================================================================================================================================================================
movsd xmm0, [rsp+16]							;Holds old(and initial) term from user input
movsd xmm1, [rsp+16]							;Holds fixed value of x from user input
movsd xmm7, [rsp+16]							;Holds the accumulated sum
mov r14, [rsp+8]								;Holds the number of terms for the computation
mov r13, 1

topofloop:								;BEGIN LOOP
cmp r13, r14								;Compare the counter with the number of terms for the computation
jge outofloop								;If greater or equal then jump out of the loop

mov rdi, r13								;Move the current iteration number into rdi to use as n for the computation
movsd xmm1, [rsp+16]							;Needed to refresh the fixed x value per loop. Without this, xmm1's data was corrupted.
call nextterm								;Calls the user-defined C++ function which computes the sin(x) using Taylor series method

inc r13									;Increment the counter after the computation has completed
addsd xmm7, xmm0							;Add the result from the computation to xmm7, the register accumulating the sum
jmp topofloop								;Jump back to the top and re-iterate

;========================= OUT OF LOOP
outofloop:
saveSC 7								;Backing up the xmm registers. Keeping xmm0(last term) and xmm7(accumulator = sin(x))
clockTime r10
push r10

mov rax, 0								;SSE will not be used
mov rdi, time								;"%lu" for unsigned
mov rsi, [rsp]								;The time in tics that was pushed onto the stack earlier
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, tics								;" tics."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rsi, string								;"%s"
mov rdi, clockbefore							;"The clock before the computation was   "
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, time								;"%lu" for unsigned
mov rsi, [rsp+8]								;The time in tics that was pushed onto the stack earlier
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, tics								;" tics."
call printf								;Calls printf function from the C library

mov rax, 0
mov rsi, string
mov rdi, compReqA
call printf

;-----** START Time computation
pop r10
pop r9

restoreSC 7	;xmm0 xmm7 keep...
movsd xmm4, xmm0 ;backing it up...

cvtsi2sd xmm5, r9 ;Holds the time before
cvtsi2sd xmm6, r10 ;Holds the time after

subsd xmm6, xmm5
movsd xmm0, xmm6
;movsd xmm3, xmm0 ;xmm3 backs up the nanoseconds which will be outputted at the end
saveSC 7; xmm0(time total), xmm4(last term), xmm5(time before), xmm6(time after->subtracted = time total), xmm7(accumulator)

push qword 0
mov qword rax, 1
mov rdi, double
call printf
pop rax

mov rax, 0
mov rsi, string
mov rdi, ticscomma
call printf
;-----** END Time computation

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, ticsconvert							;
call printf								;Calls printf function from the C library

restoreSC 7
movsd xmm2, [GHz]
divsd xmm0, xmm2
movsd xmm3, xmm0

saveSC 7

push qword 0
mov qword rax, 1
mov rdi, double
call printf 
pop rax

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, nano								;
call printf								;Calls printf function from the C library

restoreSC 7
movsd xmm2, [secConv]
mulsd xmm0, xmm2
saveSC 7


push qword 0
mov qword rax, 1
mov rdi, double
call printf 
pop rax

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, seconds							;
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, sinxResult							;
call printf								;Calls printf function from the C library

restoreSC 7
movsd xmm6, xmm0 ;back up the seconds
movsd xmm0, xmm7
saveSC 7

push qword 0
mov qword rax, 1
mov rdi, double
call printf 
pop rax

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, newline							;
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, lastTaylor							;
call printf								;Calls printf function from the C library

restoreSC 7
movsd xmm0, xmm4
push qword 0
mov qword rax, 1
mov rdi, double
call printf 
pop rax

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, newline							;
call printf								;Calls printf function from the C library
;------------------ Popping
pop rax

;before restore, push onto stack to preserve

;mov the last term into xmm0


restoreGPRs
restoreSC 7

movsd [r15], xmm3


ret

