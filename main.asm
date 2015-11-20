;-----------------------------------------------
; Include auxiliary functions coded in other file
%include        'functions.asm'

SECTION .bss
;-----------------------------------------------
; Flags and pattern variables
pattern_b:      resb  255
flag_i_b:       resb  255
flag_e_b:       resb  255
;-----------------------------------------------
;Auxiliar variables
aux:            resb  255
buffer:         resb 1024
;-----------------------------------------------
SECTION .data
;-----------------------------------------------
; Messages variables
no_arguments_msg:               db      'Nothing to do', 0h
syntax_error_msg:   db      'syntax_error', 0h
;-----------------------------------------------
; Auxiliar variables
cero: db '0',0h
one:  db  '1',0h
; Buffer Lenght
len equ 65536

SECTION .text
global  _start
 
_start:
    ;-----------------------------------------------
    ;0-> OFF 1--> ON
    ;Flags initialization
    mov dword[flag_i_b], cero
    mov dword[flag_e_b], cero
    ;-----------------------------------------------

    pop ecx             ; ecx = first value of the stack
    cmp ecx,1           ; ecx == 1?
    je no_arguments      ; if equals go to no_arguments tag

    pop eax             ; eax = name of the program argument

;-----------------------------------------------
; flag_i function review the sintax of the argument -i
flag_i:
    ;-----------------------------------------------
    
    pop eax;            ; eax = first argument
    mov ecx, eax        ; ecx = eax

    cmp byte[ecx],'0'   ; compare if byte of ecx == 0
    je flag_e           ; if equals goto flag_e tag

    cmp byte[ecx],"-"   ; compare if byte of ecx == -
    jne syntax_error    ; if not equals goto syntax_error

    cmp byte[ecx+1],"-" ; compare if byte of ecx == -
    je next_i           ; if equals goto next_i

    cmp byte[ecx+1],"i" ; compare if byte of ecx == i
    jne syntax_error    ; if not equals goto syntax_error

    mov dword[flag_i_b], one  ; compare if byte of ecx == 1
    jmp flag_e                ; if equals goto flag_e

;-----------------------------------------------
; next_i function review the syntax of --ignore-case
next_i:
    cmp byte[ecx+2],"i" ; compare if byte of ecx == i
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+3],"g" ; compare if byte of ecx == g
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+4],"n" ; compare if byte of ecx == n
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+5],"o" ; compare if byte of ecx == o
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+6],"r" ; compare if byte of ecx == r
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+7],"e" ; compare if byte of ecx == e
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+8],"-" ; compare if byte of ecx == -
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+9],"c" ; compare if byte of ecx == c
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+10],"a" ; compare if byte of ecx == a
    jne syntax_error     ; if not equals goto syntax_error
    cmp byte[ecx+11],"s" ; compare if byte of ecx == s
    jne syntax_error     ; if not equals goto syntax_error
    cmp byte[ecx+12],"e" ; compare if byte of ecx == s
    jne syntax_error     ; if not equals goto syntax_error

    mov dword[flag_i_b], one ; If no syntax_error, flag_i_b = 1
 
;-----------------------------------------------
; next_i function review the syntax of -e
flag_e:
    pop eax;            ; eax = second argument
    mov ecx, eax        ; ecx = eax

    cmp byte[ecx],'0'   ; compare if byte of ecx == 0
    je pattern          ; if equals goto patter tag

    cmp byte[ecx],"-"   ; compare if byte of ecx == -
    jne syntax_error    ; if not equals goto syntax_error

    cmp byte[ecx+1],"-" ; compare if byte of ecx == -
    je next_e           ; if equals goto next_e tag

    cmp byte[ecx+1],"e" ; compare if byte of ecx == e
    jne syntax_error    ; if not equals goto syntax_error

    mov dword[flag_e_b], one ; If no syntax_error, flag_e_b = 1
    jmp pattern              ; goto pattern tag

;-----------------------------------------------
; next_e function review the syntax of --regexp
next_e:
    cmp byte[ecx+2],"r" ; compare if byte of ecx == r
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+3],"e" ; compare if byte of ecx == e
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+4],"g" ; compare if byte of ecx == g
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+5],"e" ; compare if byte of ecx == e
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+6],"x" ; compare if byte of ecx == x
    jne syntax_error    ; if not equals goto syntax_error
    cmp byte[ecx+7],"p" ; compare if byte of ecx == p
    jne syntax_error    ; if not equals goto syntax_error

    mov dword[flag_e_b], one ; If no syntax_error, flag_e_b = 1
;-----------------------------------------------
; pattern function takes the pattern argument from the stack
pattern:
    pop eax             ; eax = third argument    
    mov dword[pattern_b], eax       ; pattern_b = eax = pattern argument
    
    mov eax, dword[flag_i_b]        ; eax = flag_i_b
    cmp byte[eax], "1"              ; if eax == 1
    jne nextFile                    ; if not equals go to nextFile tag

    ;-----------------------------------------------
    ;lower case case function
    mov ebx, dword[pattern_b]       ; ebx = pattern_b
    call to_lower_case              ; we call the to_lower_case function (functions.asm)
    mov dword[pattern_b], ebx       ; pattern_b = ebx (return of the function)

;-----------------------------------------------
; nextFile function takes the files arguments from the stack
nextFile:
    pop     eax             ; eax = next argument  
    cmp     eax, 0          ; if eax == 0 (check to see if we have any arguments left)
    je      no_more_args      ; if eaquals goto no_more_args tag(jumping over the end of the loop)
    mov dword[buffer],0

    mov ebx, eax            ; ebx = eax (file name)  
    mov eax, 5              ; eax = 5 (sys_open)
    mov ecx, 0              ; ecx = 0
    int 80h                 ; system interruption

    mov eax, 3              ; eax = 3
    mov ebx, eax            ; ebx = eax
    mov ecx, buffer         ; ecx = buffer
    mov edx, len            ; edx = len (buffer len)
    int 80h                 ; system interruption

;imprime el valor (para pruebas borrar esto)
    mov ecx, buffer         
    mov eax, ecx
    call    print_line         
;----------------------------------------

    mov eax, 6              ; eax = 6 (sys_close_file)
    int 80h                 ; system interruption

    mov eax, dword[flag_i_b]    ; eax = flag_i_b
    cmp byte[eax], "1"          ; if eax == 1
    jne nextFile                ; if equals goto nextFile tag else goto lowercase function

    ;-----------------------------------------------
    ;lower case case function
    mov ecx, buffer             ; ecx = buffer
    mov ebx, ecx                ; ebx = ecx (Function arguments)
    call to_lower_case          ; we call the to_lower_case function (functions.asm) 

    ;-----------------------------------------------
    ; en esta parte es donde se debe mandar todo a la función
    ; las variales necesarias son buffer -> contenido del archivo y pattern_b -> contenido del patron

    ;-----------------------------------------------

    jmp     nextFile            ; goto nextFile tag (end of while)

;----------------------------------------
; syntax_error function 
syntax_error:
    mov eax, syntax_error_msg   ; eax = syntax_error_msg 
    push eax                    ; push eax onto the stack (function arguments)
    call print_line             ; we call the print_line function (functions.asm) 
    call exit                   ; we call the exit function (functions.asm) 

;----------------------------------------
; no_arguments function
no_arguments:
    mov eax, no_arguments_msg   ; eax = no_arguments_msg
    call print_line             ; we call the print_line function (functions.asm) 
    call exit                   ; we call the exit function (functions.asm) 

;----------------------------------------
; no_more_args function
no_more_args:
    ;--------------------------------------
    ; imprime valores, prueba, borrar al final
    mov eax, dword[flag_i_b]
    call    print_line
    mov eax, dword[flag_e_b]
    call    print_line
    mov eax, dword[pattern_b]
    call    print_line
    mov ecx, buffer 
    mov eax, ecx
    call    print_line 
    ;----------------------------------------------  


    call    exit                ; we call the exit function (functions.asm) 