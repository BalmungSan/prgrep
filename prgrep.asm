section .data
  ;Messages for printf
  msg1 db "The string %s has a length of $d",10,0 ;String and size

section .bbs

section .text
  extern printf ;Use th C function printf

  ;Get the length of a string in ecx
  getlen:
    xor edx, edx ;edx = 0 -> length = 0 
    loop: ;For every char in the string
      cmp byte [ecx + edx], 0 ;If the char is the null ...
      jz gotlen               ;... we have the length
      inc edx                 ;... if not, length++ 
      jmp loop                ;Loop for the next char
    gotlen: ;Now ecx -> string, edx = lengt
    ret ;return

  ;Search function, algorithm Boyer-Moore
  global search
  search: ;public boolean search (String text, String pattern) 
    ;Create the stack frame
    push ebp
    mov ebp, esp

    ;Create local variables by reserving space on the stack
    sub esp, 0x14 ;Reserve space of 20 bytes-- 5 integers

    ;First variable (boolean result)
    mov DWORD [edp-4], 0 ;result = 0 = false

    ;Second variable (int i)
    mov DWORD [edp-8], 0 ;i = 0

    ;Third variable (int j)
    mov DWORD [edp-12], 0 ;j = 0

    ;Fourth variable (int n)
    pop ecx ;Get text from the stack
    call getlen ;Get the length of the string
    mov DWORD [edp-16], edx ;n = edx = text.length

    push DWORD [edp-16]
    push ecx 
    call printf

    ;Fifth variable (int m)
    pop ecx ;Get pattern from the stack
    call getlen ;Get the length of the string
    mov DWORD [edp-20], edx ;m = edx = pattern.length 

    push DWORD [edp-20]
    push ecx
    call printf

    ;Destroy the stack frame and return
    mov esp, ebp
    pop ebp
    ret 

  ;Main 
  global _start
  _start: 
    pop ecx ;Get the number of arguments
    pop ecx ;Get the program name

    pop ecx ;Get pointer to a new arg (String)
    cmp ecx, 0 ;If we popped a zero, there isn't more args
    jz exit

    push  

  ;Exit function
  exit:
    mov eax, 1  ;Syscall 1 (exit)
    mov ebx, 0  ;Exit code 0 (No errors)
    int 80h     ;Call system
