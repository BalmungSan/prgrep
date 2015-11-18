section .data
string1: db "Test",64,0 

section .text

global _search

search:

  pop ecx      ;Get the number of arguments
  add ecx, '0' ;Convert to a ascii number
  push ecx     ;Push the result into memory using the stack
  mov ecx, esp ;Move the address of the stack pointer to ecx for sys_write
  mov eax, 4   ;Function 4 - write
  mov ebx, 1   ;To stdout
  mov edx, 1   ;Buffer size
  int 80h

  pop ecx      ;Dump number of args from stack
   
nextarg:
   pop ecx ; get pointer to string

; we could have kept "argc", and used it as a loop counter
; but args pointers are terminated with zero (dword),
; so if we popped a zero, we're done (environment variables follow this)

   test ecx, ecx ; or "cmp ecx, 0"
   jz exit

; now we need to find the length of our (zero-terminated) string

   xor edx, edx ; or "mov edx, 0"
getlen:
   cmp byte [ecx + edx], 0
   jz gotlen
   inc edx
   jmp getlen
gotlen:

; now ecx -> string, edx = length
   mov   eax,4    ; Function 4 - write"
   mov   ebx,1    ; to stdout
   int   80h

; probably want to print a newline here, "for looks"

   jmp nextarg ; cook until done  

;Exit function
exit:
  mov eax, 1  ;Syscall 1 (exit)
  mov ebx, 0  ;Exit code 0 (No errors)
  int 80h     ;Call system
