section .data
  ;found message
  msg: db "Found pattern in file ",10,0
  msgsize: equ $-msg

section .bbs

section .text
  ;fet the length of a string in ecx to edx -------------------------
  getlen:
    xor edx, edx ;edx = 0 -> length = 0 
    getlenloop:              ;for every char in the string
      cmp byte[ecx + edx], 0 ;if the char is the null ...
      jz gotlen              ;... we have the length
      inc edx                ;... if not, length++ 
      jmp getlenloop         ;loop for the next char
    gotlen: ;now ecx -> string, edx = lengt
    ret ;return
  ;------------------------------------------------------------------ 
 
  ;bool search (String text, String pattern) ------------------------
  ;Boyer Moore string matching algorithm
  global search
  search: 
    ;create the stack frame
    push ebp
    mov ebp, esp

    ;create local variables by reserving space on the stack
    sub esp, 0x24 ;reserve space of 36 bytes -> 6 int and 3 int*

    ;here we have these variables
    ;[ebp-4] = boolean result = false (0)
    ;[ebp-8] = int i = 0
    ;[ebp-12] = int j = 0

    ;[ebp-16] = int n = text.length
    mov ecx, [ebp+8]        ;get text from the stack
    call getlen             ;get the length of the string
    mov dword [ebp-16], edx ;edx = text.length

    ;[ebp-20] = int m = text.length
    mov ecx, [ebp+12]       ;get pattern from the stack
    call getlen             ;get the length of the string
    mov dword [ebp-20], edx ;edx = pattern.length 

    ;Precompute -------------------------------------------
    ;prebmbc --------------------------
    ;[edp-24] = int[] bmbc = new int[256]
    mov ebx, 256      ;256 elements
    shl ebx, 1        ;double word
    sub ecx, ebx      ;ecx points to the array
    mov [ebp-24], ecx ;save the pointer in the stack

    ;Arrays.fill(bmbc, m)
    mov edi, [ebp-24] ;put in edi the pointer to bmbc
    xor ecx, ecx     ;clear the iterator -> ecx = 0
    loopbmbcfill:
      mov eax, [ebp-20]
      mov [edi + ecx * 2], eax ;bmbc[ecx] = m
      inc ecx                       ;ecx++
      cmp ecx, 256                  ;if ecx != 256 ...
      jne loopbmbcfill              ;... continue loop

    ;for(int i = 0; i < m - 1; i++) bmbc[text[i]] = m-i-1;
    mov esi, [ebp+12]  ;put in esi the pointer to text
    xor ecx, ecx       ;clear the iterator -> ecx = 0
    mov eax, [ebp-20]  ;eax = m
    dec eax            ;eax = m -1
    mov [ebp-36], eax  ;[ebp-36] = int aux = m -1
    forbmbc:
      ;eax = text[ecx]
      mov eax, [esi + ecx * 2]      

      ;ebx = m-i-1
      mov ebx, eax ;ebx = m - 1
      sub ebx, ecx ;ebx = ebx - i

      ;bmbc[eax] = ebx
      mov [edi + eax * 2], ebx      

      inc ecx           ;ecx++
      cmp ecx, [ebp-36] ;if ecx == m - 1 ...
      jne loopbmbcfill  ;... continue loop
    ;----------------------------------

    ;prebmgs --------------------------
    ;[ebp-28] = int[] suff = new int [m]
    mov ebx, [ebp-20] ;m elements
    shl ebx, 1        ;double word
    sub ecx, ebx      ;ecx points to the array
    mov [ebp-28], ecx ;save the pointer in the stack 

    ;[edp-32] = int[] bmgs =new int [m]
    mov ebx, [ebp-20] ;m elements
    shl ebx, 1        ;double word
    sub ecx, ebx      ;ecx points to the array
    mov [ebp-32], ecx ;save the pointer in the stack

;------------------------------------------------------

    ;Searching --------------------------------------------
    ;while (j <= n - m && !result)
    whilesearching:
      ;for (i = m - 1; i >= 0 && text[i] == pattern[i+j]; i--);
      forsearching:
      endforsearching:      

      mov eax,[ebp-8]   ;eax = i
      cmp eax, 0        ;Compare with zero
      jae elsesearching ;Jump if above or equal
      ;if (i < 0) ... 
        ;.. result = true (1)      
        mov dword [ebp-4], 1
        jmp endwhilesearching ;break while loop
      ;else ...
      elsesearching:
        ;... j += max(bmgs[i], bmbc[pattern[i+j]] - m+i+1)
        jmp whilesearching ;continue the while
    
    endwhilesearching:
    ;------------------------------------------------------

    ;return result
    mov eax, dword [ebp-4]
    leave
    ret 
  ;------------------------------------------------------------------

  ;void toLowerCase (char* string) ----------------------------------
  ;Take a string to lower case
  global toLowerCase
  toLowerCase:
    ;Create the stack frame
    push ebp
    mov ebp, esp

    ;for (; string != '\0'; string++) string->toLower();

    ;return
    ret
  ;------------------------------------------------------------------ 

  ;int main (int argc, char** argv) --------------------------------- 
  ;Program entry point
  global _start
  _start: 
    ;Create the stack frame
    push ebp
    mov ebp, esp    

    pop ecx ;Get the number of arguments (argc)

    pop ecx ;Get the program name (argv[0])

    ;Call the search function
    call search ;search(argv[1], argv[2])

    ;Check the result value of search
    add esp,0x10 ;Get the retrun value in eax
    test eax,eax ;if eax == 0 ...
    je exit      ;.. exit 
    mov eax,4    ;.. if not print a message
    mov ebx,1    
    mov ecx,msg
    mov edx,msgsize
    int 80h

  exit:
    mov eax, 0x1  ;Syscall 1 (exit)
    mov ebx, 0x0  ;Exit code 0 (No errors)
    int 80h       ;Call system
  ;------------------------------------------------------------------
