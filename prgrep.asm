section .data
msg: db "Found",10,0
msgsize: equ $-msg

section .bbs

section .text
  ;Get the length of a string in ecx
  getlen:
    xor edx, edx ;edx = 0 -> length = 0 
    loop: ;For every char in the string
      cmp byte[ecx + edx], 0 ;If the char is the null ...
      jz gotlen              ;... we have the length
      inc edx                ;... if not, length++ 
      jmp loop               ;Loop for the next char
    gotlen: ;Now ecx -> string, edx = lengt
    ret ;return

  ;Search function, algorithm Boyer-Moore
  global search
  search: ;public boolean search (String text, String pattern) 
    ;Create the stack frame
    push ebp
    mov ebp, esp

    ;Create local variables by reserving space on the stack
    sub esp, 0x14 ;Reserve space of 20 bytes -> 5 integers

    ;Here we have these variables
    ;[ebp-4] = boolean result = false (0)
    ;[ebp-8] = int i = 0
    ;[ebp-12] = int j = 0

    ;[ebp-16] = int n
    mov ecx, [ebp+8]        ;Get text from the stack
    call getlen             ;Get the length of the string
    mov dword [ebp-16], edx ;n = edx = text.length

    mov eax,4
    mov ebx,1
    int 80h 

    ;[ebp-20] = int m
    mov ecx, [ebp+12]       ;Get pattern from the stack
    call getlen             ;Get the length of the string
    mov dword [ebp-20], edx ;m = edx = pattern.length 

    mov eax,4
    mov ebx,1
    int 80h

    ;return result
    mov eax, dword [ebp-4]
    leave
    ret 

  ;Main 
  global _start
  _start: 
    pop ecx ;Get the number of arguments (argc)

    pop ecx ;Get the program name (argv[0])

    ;Call the search function
    call search

    ;Check the result value of search
    add esp,0x10 ;Get the retrun value in eax
    test eax,eax ;Check if eax == 0 ...
    jne exit     ;.. if not exit 
    mov eax,4    ;.. if ture print a message
    mov ebx,1    
    mov ecx,msg
    mov edx,msgsize
    int 80h

  ;Exit function
  exit:
    mov eax, 0x1  ;Syscall 1 (exit)
    mov ebx, 0x0  ;Exit code 0 (No errors)
    int 80h       ;Call system
