;65536 ---> 64KB
sys_exit    equ     1
sys_read    equ     3
sys_write   equ     4
stdin       equ     0
stdout      equ     1
stderr      equ     3



section .data
file: db "", 0
;************* PREGREP MESSAGES ******************
;exit
msg_main: db "main",10,0
msg_main_size: equ $-msg_out
;exit
msg_out: db "Exit",10,0
msg_out_size: equ $-msg_out
;No arguments
msg_no_arguments: db "No Arguments",10,0
msg_no_arguments_size: equ $-msg_no_arguments
;i_case
msg_i_case: db "i_case",10,0
msg_i_case_size: equ $-msg_i_case
;************************************************
;************* PREGREP ARGUMENTS *****************
;-i Minusculas or -.ignore-case
i_arg: db "-i",10,0
;-e Expresiones or --regexp
;-f Especificar archivos or --file
;************************************************

section .bss 
buffer: resb 1024

section .text
global _start


getlen:
    xor edx, edx ;edx = 0 -> length = 0 
    getlenloop:              ;for every char in the string
      cmp byte[ecx + edx], 0 ;if the char is the null ...
      jz gotlen              ;... we have the length
      inc edx                ;... if not, length++ 
      jmp getlenloop         ;loop for the next char
    gotlen: ;now ecx -> string, edx = lengt
    ret ;return

i_case:
;No Arguments message
    mov eax, sys_write
    mov ebx, 1
    mov ecx, msg_i_case
    mov edx, msg_i_case_size
    int 80H

nextArg:
    cmp     ecx, 0h         ; check to see if we have any arguments left
    jz      noArguments      ; if zero flag is set jump to noMoreArgs label (jumping over the end of the loop)
    pop     eax             ; pop the next argument off the stack
    call    getlen
    mov     eax, 4
    mov     ebx, 1
    int     80H    
    dec     ecx             ; decrease ecx (number of arguments left) by 1
    jmp     nextArg         ; jump to nextArg label

noArguments:
    ;No Arguments message
    mov eax, sys_write
    mov ebx, 1
    mov ecx, msg_no_arguments
    mov edx, msg_no_arguments_size
    int 80H

    jmp exit

exit:
    ;Exit message
    mov eax, sys_write
    mov ebx, 1
    mov ecx, msg_out
    mov edx, msg_out_size
    int 80H

    mov eax, sys_exit
    xor ebx, ebx
    int 80H

global _start
_start:
    nop
    push ebp
    mov ebp, esp
    mov ecx, dword [ebp + 4]
    
    cmp ecx, 1;nrArguments
    je noArguments



    jmp exit

