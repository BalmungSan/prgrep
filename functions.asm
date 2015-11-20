sys_exit    equ     1
sys_read    equ     3
sys_write   equ     4
stdin       equ     0
stdout      equ     1
stderr      equ     3

;------------------------------------------
; int size(String message)
; String length calculation function
size:
    push    ebx             ;Arguments of the function
    mov     ebx, eax
 
nextchar:
    cmp     byte [eax], 0   ; IF BYTE[EAX] == 0{
    jz      end             ;   GOTO END }
    inc     eax             ;   EAX++ To change byte
    jmp     nextchar        ; 
 
end:
    sub     eax, ebx
    pop     ebx
    ret
 
;------------------------------------------
; void sprint(String message)
; String printing function
print_aux:
    ;We call the general purpose flags
    push    edx
    push    ecx
    push    ebx
    push    eax

    ;We call the size function to get the size of the string
    call    size
    mov     edx, eax
    pop     eax         ;EAX = size of string
    
    ;We call the system interruption to print
    mov     ecx, eax    ; ecx = eax = size of the string
    mov     ebx, 1      ; print on the screen
    mov     eax, sys_write
    int     80h
 
    pop     ebx
    pop     ecx
    pop     edx
    ret
 
print_line:
    call    print_aux
 
    push    eax         ; push eax onto the stack to preserve it while we use the eax register in this function
    mov     eax, 0Ah    ; move 0Ah into eax - 0Ah is the ascii character for a linefeed
    push    eax         ; push the linefeed onto the stack so we can get the address
    mov     eax, esp    ; move the address of the current stack pointer into eax for sprint
    call    print_aux      ; call our print_aux function
    pop     eax         ; remove our linefeed character from the stack
    pop     eax         ; restore the original value of eax before our function was called
    ret                 
;------------------------------------------
; void to_lower_case(String text)
; String to lower_case
to_lower_case:
    mov     edx,0
process_char:
    cmp     byte[ebx+edx],0
    je      done
    cmp     byte[ebx+edx],'A'; if char < 'a'
    jl      lower_case
    cmp     byte[ebx+edx],'Z'; if char > 'z'
    ja      lower_case 
not_lower_case:
    add     byte[ebx+edx], 32
lower_case:
    inc     edx
    jmp     process_char
done:
    ret

;------------------------------------------
; Exit the program
exit:
    mov     ebx, 0
    mov     eax, sys_exit
    int     80h
    ret