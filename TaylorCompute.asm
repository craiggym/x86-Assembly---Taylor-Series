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

compReqA: db "The computation required 	", 0
compReqB: db " tics, which equals ", 0
compReqC: db " nanoseconds = ", 0
compReqD: db " seconds.", 10, 0

sinxResult: db "Sin(x) =  ", 0
lastTaylor: db "The last term in the Taylor series was ", 0

ticsconvert: db "which equals ", 0
seconds: db " seconds.", 10, 0

newline: db 10, 0
newline2: db 10, 10, 0

string: db "%s", 0
longg: db "%ld", 0
double: db "%lf", 0
lastformat: db "%1.80lf", 0
time: db "%lu", 0
convTime: db "%.0lf", 0

GHz: dq 2.40, 0
secConv: dq 0.000000001, 0						;The amount needed to multiply with nanoseconds to obtain seconds.

segment .bss

segment .text

TaylorCompute:
mov r15, rdi								;r15 holds the address of rax so that it can be returned to the driver

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
mov rdi, time								;time format being "%lu" for unsigned long
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

;\\ STACK \\
;[ X ] <--- The X value which is taken from user input [rsp]

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, enterTerms							;"Enter the number of terms to be included in the computation: "
call printf								;Calls printf function from the C library

push qword 0								;Reserving space on the stack for this input
mov rax, 0								;SSE will not be used
mov rdi, time								;Recycling the format from time since number of terms will not be float: "%lu"
mov rsi, rsp								;stack area
call scanf								;Call scanf function from the C library.

;\\ STACK \\
;[ # of terms ] <--- The # of terms which is taken from user input [rsp]
;[ X ] <--- The X value which is taken from user input [rsp+8]

mov rax, 0								;SSE will not be used
mov rsi, string								;"%s"
mov rdi, sinx								;"The value for sin(x) has been computed."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rsi, string								;"%s"
mov rdi, clockafter							;"The clock after the computation was   "
call printf								;Calls printf function from the C library

clockTime r9								;Takes the current time in tics and places it in r9.

push r9									;Save the recorded time onto the stack so that we can compute the duration afterwards.
;\\ STACK \\
;[ r9 ] <--- r9 is holding the number of tics before the Taylor computation to compute the duration [rsp]
;[ # of terms ] <--- The # of terms which is taken from user input [rsp+8]
;[ X ] <--- The X value which is taken from user input [rsp+16]

;=============================================== Pre-conditions before entering loop ===============================================================================
;Before going into loop I will be using:
;  r14: Will hold the number of terms for the computation
;  r13: Will be the counter
;  xmm0: Will hold the old(and initial) term which will change every time nextterm is called. The result will be added to the accumulator (xmm7).
;  xmm1: Will hold the fixed value of x which was taken from user input
;  xmm7: Will hold the accumulated sum
;===================================================================================================================================================================
movsd xmm0, [rsp+16]							;Holds old(and initial) term from user input
movsd xmm1, [rsp+16]							;Holds fixed value of x from user input
movsd xmm7, [rsp+16]							;Holds the accumulated sum
mov r14, [rsp+8]							;Holds the number of terms for the computation
mov r13, 1								;Start from 1

;======================= TOP OF LOOP ========================================================================================================
topofloop:								;BEGIN LOOP
cmp r13, r14								;Compare the counter with the number of terms for the computation
jge outofloop								;If greater or equal then jump out of the loop

mov rdi, r13								;Move the current iteration number into rdi to use as n for the computation
movsd xmm1, [rsp+16]							;Needed to refresh the fixed x value per loop. Without this, xmm1's data was corrupted.
call nextterm								;Calls the user-defined C++ function which computes the sin(x) using Taylor series method

inc r13									;Increment the counter after the computation has completed
addsd xmm7, xmm0							;Add the result from the computation to xmm7, the register accumulating the sum
jmp topofloop								;Jump back to the top and re-iterate

;========================= OUT OF LOOP =======================================================================================================
outofloop:
saveSC 7								;Backing up the xmm registers. Keeping xmm0(last term) and xmm7(accumulator = sin(x))
clockTime r10								;Takes the current time in tics and places it in r10. 
push r10								;Save the time in tics on the stack.

;\\ STACK \\
;[ r10 ] <--- r10 is holding the number of tics after the Taylor computation [rsp]
;[ r9 ] <--- r9 is holding the number of tics before the Taylor computation [rsp+8]
;[ # of terms ] <--- The # of terms which is taken from user input [rsp+16]
;[ X ] <--- The X value which is taken from user input [rsp+24]

mov rax, 0								;SSE will not be used
mov rdi, time								;"%lu" for unsigned
mov rsi, [rsp]								;The time in tics from after the computation
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, tics								;" tics.\n"
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rsi, string								;"%s"
mov rdi, clockbefore							;"The clock before the computation was   "
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, time								;time format: "%lu" for unsigned
mov rsi, [rsp+8]							;The time in tics that was pushed onto the stack before Taylor computation
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, tics								;" tics."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rsi, string								;"%s"
mov rdi, compReqA							;"The computation required 	"
call printf								;Calls printf function from the C library

;============================ Math for Taylor Computation Duration ======================================================================
pop r10									;r10 holds the value after the Taylor computation
pop r9									;r9 holds the value before the Taylor computation

;\\ STACK \\
;[ # of terms ] <--- The # of terms which is taken from user input [rsp]
;[ X ] <--- The X value which is taken from user input [rsp+8]

restoreSC 7								;Restore the xmm registers for some arithmetic
movsd xmm4, xmm0 							;Backing up the last number in the Taylor series into xmm4

cvtsi2sd xmm5, r9							;Convert the time before Taylor computation to a float value for xmm5 to hold
cvtsi2sd xmm6, r10 							;Convert the time after Taylor computation to a float value for xmm6 to hold

subsd xmm6, xmm5							;Since the time after is of greater value (time increases in tics),
									;we subtract before from after to obtain the total computation time.
movsd xmm0, xmm6							;Move the result into xmm0 so that we can print it

saveSC 7								;Save the components
									;xmm0(time total), xmm4(last term), xmm5(time before), xmm6(time total), xmm7(accumulator)

push qword 0								;Make room in the stack for this print
mov qword rax, 1							;We will be using only one xmm register
mov rdi, convTime							;".0lf" We don't want a decimal for tics
call printf								;Calls the printf function from the C library
pop rax									;Done using the stack space so reverting back by popping
;============================END Math for Taylor Computation Duration END======================================================================

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, compReqB							;" tics, which equals "
call printf								;Calls printf function from the C library

restoreSC 7								;Restore the xmm components
									;xmm0(time total), xmm4(last term), xmm5(time before), xmm6(time total), xmm7(accumulator)

movsd xmm2, [GHz]							;xmm2 will hold my computer's clockspeed (2.40 GHz)					
divsd xmm0, xmm2							;time total in tics divided by 2.4 to equal nanoseconds. Store result in xmm0 register.
movsd xmm3, xmm0							;back up the nanoseconds in xmm3

saveSC 7								;Save the components
									;xmm0(time total in nanoseconds), xmm2(GHz), xmm3(time total in nanoseconds backed up),
									;xmm4(last term), xmm5(time before), xmm6(time total), xmm7(accumulator)

push qword 0								;Make room in the stack for this print
mov qword rax, 1							;We will be using only one xmm register
mov rdi, convTime							;"%.0lf"
call printf 								;Call printf function from the C library
pop rax									;Done using the stack space so reverting back by popping

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, compReqC							;" nanoseconds = "
call printf								;Calls printf function from the C library

restoreSC 7								;Restore the components
									;xmm0(time total in nanoseconds), xmm2(GHz), xmm3(time total in nanoseconds backed up),
									;xmm4(last term), xmm5(time before), xmm6(time total), xmm7(accumulator)

movsd xmm2, [secConv]							;Since we're done using xmm2's GHz for multiplication, we'll re-use it to hold the number
									;for converting nanoseconds into seconds (0.000000001)
mulsd xmm0, xmm2							;Multiply total nanoseconds with conversion number to get total in seconds		

saveSC 7								;Save the components
									;xmm0(time total in seconds), xmm2(0.000000001), xmm3(time total in nanoseconds),
									;xmm4(last term), xmm5(time before), xmm6(time total), xmm7(accumulator)


push qword 0								;Make room in the stack for this print
mov qword rax, 1							;We will be using only one xmm register
mov rdi, double								;"%lf"
call printf 								;Calls printf function from the C library
pop rax									;Done with using the stack space so reverting back by popping

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, seconds							;" seconds."
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, sinxResult							;"Sin(x) =  "
call printf								;Calls printf function from the C library

restoreSC 7								;Restore the components
									;xmm0(time total in seconds), xmm2(0.000000001), xmm3(time total in nanoseconds),
									;xmm4(last term), xmm5(time before), xmm6(time total), xmm7(accumulator)

movsd xmm6, xmm0 							;Backing up the time total in seconds into xmm6
movsd xmm0, xmm7							;Moving the accumulator into xmm0 for printing

saveSC 7 								;Save the components
									;xmm0(Accumulator), xmm2(0.000000001), xmm3(time total in nanoseconds),
									;xmm4(last term), xmm5(time before), xmm6(Time total in seconds), xmm7(accumulator)

push qword 0								;Make room in the stack for this print
mov qword rax, 1							;We will be using only one xmm register
mov rdi, double								;"%lf"
call printf 								;Calls printf function from the C library
pop rax									;Done with using the stack space so reverting back by popping

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, newline							;"\n"
call printf								;Calls printf function from the C library

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, lastTaylor							;"The last term in the Taylor series was "
call printf								;Calls printf function from the C library

restoreSC 7								;Restore the components
									;xmm0(Accumulator), xmm2(0.000000001), xmm3(time total in nanoseconds),
									;xmm4(last term), xmm5(time before), xmm6(Time total in seconds), xmm7(accumulator)

movsd xmm0, xmm4							;Move the last term from the Taylor Series into xmm0 for printing

saveSC 7								;Save the components
									;xmm0(last term), xmm2(0.000000001), xmm3(time total in nanoseconds),
									;xmm4(last term), xmm5(time before), xmm6(Time total in seconds), xmm7(accumulator)

push qword 0								;Make room in the stack for this print
mov qword rax, 1							;We will be using only one xmm register
mov rdi, lastformat							;"%1.80lf" so that we can retain the data from very large Term #'s
call printf 								;Calls printf function from the C library
pop rax									;Done with using the stack space so reverting back by popping

mov rax, 0								;SSE will not be used
mov rdi, string								;"%s"
mov rsi, newline							;"\n"
call printf								;Calls printf function from the C library

;------------------ Popping the remaining stack data -------------------------------------------------------------------------
;\\ STACK \\
;[ # of terms ] <--- The # of terms which is taken from user input [rsp]
;[ X ] <--- The X value which is taken from user input [rsp+8]

pop rax

;\\ STACK \\
;[ X ] <--- The X value which is taken from user input [rsp+8]

restoreGPRs								;Get our registers back to their original state

restoreSC 7								;Restore the xmm registers
									;xmm0(last term), xmm2(0.000000001), xmm3(time total in nanoseconds),
									;xmm4(last term), xmm5(time before), xmm6(Time total in seconds), xmm7(accumulator)

movsd [r15], xmm3							;Total time in nanoseconds will be returned via rax. xmm0 will return the last term.
xorps xmm1, xmm1
xorps xmm2, xmm2
xorps xmm3, xmm3
xorps xmm4, xmm4
xorps xmm5, xmm5
xorps xmm6, xmm6
xorps xmm7, xmm7

ret

