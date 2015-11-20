section .data
  ;bmbc = new int [256] (ascii table)
  bmbc times 256 dd 0 ;create an arry 4bytes -> doble word

msg1 dd "Found",10,0
len1 equ $-msg1
msg2 dd "Not Found",10,0
len2 equ $-msg2

section .bbs

section .text
  ;get the length of a string in ecx to edx --------------------------
  getlen:
    xor edx, edx             ;edx = 0 -> length = 0 
    getlenloop:              ;for every char in the string
      cmp byte[ecx + edx], 0 ;if the char is the null ...
      jz gotlen              ;... we have the length
      inc edx                ;... if not, length++ 
      jmp getlenloop         ;loop for the next char
    gotlen:                  ;now ecx -> string, edx = lengt
    ret                      ;return
  ;-------------------------------------------------------------------
 
  ;-------------------------------------------------------------------

  ;int search ([ebp+8] String text, [ebp+12] String pattern) ---------
  ;Boyer Moore string matching algorithm
  ;return the position where is found the pattern in text, or -1 if not found
  global search
  search: 
    ;create the stack frame
    push ebp
    mov ebp, esp

    ;local variables ---------------------------------------
    ;create local variables by reserving space on the stack
    sub esp, 0x14 ;reserve space of 20 bytes -> 5 int

    ;[ebp-4] = int result = -1
    mov dword [ebp-4], -1

    ;[ebp-8] = int n = text.length
    mov ecx, dword [ebp+8]  ;get text from the stack
    call getlen             ;get the length of the string
    mov dword [ebp-8], edx ;edx = text.length

    ;[ebp-12] = int m = pattern.length
    mov ecx, dword [ebp+12] ;get pattern from the stack
    call getlen             ;get the length of the string
    mov dword [ebp-12], edx ;edx = pattern.length 

    ;[ebp-16] = int last = m - 1
    mov ecx, [ebp-12] ;ecx = m
    dec ecx           ;ecx--
    mov [ebp-16], ecx ;last = ecx

    ;[ebp-20] = int end = n - m
    mov ecx, [ebp-8] ;ecx = n
    sub ecx, [ebp-12] ;ecx = ecx - m
    mov [ebp-20], ecx ;end = ecx
    ;-------------------------------------------------------

    ;Precompute --------------------------------------------
    ;for(i = 0; i < 256; i++) bmbc[i] = m
    xor ecx, ecx             ;clear the iterator -> ecx = 0
    lea edi, [bmbc]          ;edi = *bmbc
    loopbmbcfill:
      mov eax, [ebp-12]      ;eax = m
      mov [edi + ecx*4], eax ;*(edi + ecx*4) = eax
      inc ecx                ;ecx++
      cmp ecx, 256           ;if ecx != 256 ...
      jne loopbmbcfill       ;... continue loop

    ;for(int i = 0; i < last; i++) bmbc[pattern[i]] = last-i;
    mov esi, dword [ebp+12] ;esi = *pattern
    xor edx, edx            ;clear the iterator -> edx = 0
    forbmbc:
      ;ebx = pattern[edx]
      movzx ebx, byte [esi + edx]      

      ;ecx = last - i
      mov ecx, [ebp-16] ;ecx = last
      sub ecx, edx      ;ecx = ecx - edx

      ;bmbc[ebx] = ecx
      mov [edi + ebx*4], ecx      

      inc edx           ;edx++
      cmp edx, [ebp-16] ;if edx != last...
      jne forbmbc       ;... continue loop
    ;-------------------------------------------------------

    ;Searching ---------------------------------------------
    ; > j = edx
    xor edx, edx ;edx = j = 0
    ; > i = ecx
    ; > *bmbc = edi
    ; > *text = ebx
    mov ebx, dword[ebp+8]
    ; > *pattern = esi
    ;while (j <= end)
    whilesearching:
    ;Condition
    mov eax, [ebp-20]      ;eax = end
    cmp edx, eax           ;if edx (j) > ebx (end)  ...
    ja endwhilesearching   ;... end while
      ;for (i = last; text[i] == pattern[i+j]; i--);
      ;i = last
      mov ecx, [ebp-16] 
      forsearching:
      ;condition
      mov eax, ecx            ;eax = i
      add eax, edx            ;eax = eax + j
      mov al, byte[ebx + eax] ;cl = text[eax]
      cmp al, byte[esi + ecx] ;if cl != patter[i] ...
      jne endforsearching     ;... break loop

        ;if (i == 0) return j
        cmp ecx, 0       ;if i != 0 ...
        jne loop         ;... continue loop
        mov [ebp-4], edx ;if equals return j
        jmp endwhilesearching

        ;loop
        loop:
        dec ecx ;i--
        jmp forsearching ;continue for 
      endforsearching:     

      ;j += bmbc[text[j+last]
      mov eax, [ebp-16]             ;eax = last
      add eax, edx                  ;eax = eax + j
      movzx eax, byte [ebx + eax]   ;eax = text[eax]
      movzx eax, byte [edi + eax*4] ;eax = bmbc[eax]
      add edx, eax                  ;j += eax
      jmp whilesearching            ;continue the while

    endwhilesearching:
    ;-------------------------------------------------------

    ;return result
    mov eax, dword [ebp-4]
    leave
    ret 
  ;-------------------------------------------------------------------

  ;void toLowerCase ([ebp+8] char* string) ---------------------------
  ;take a string to lower case
  global toLowerCase
  toLowerCase:
    ;Create the stack frame
    push ebp
    mov ebp, esp

    ;for (; string != '\0'; string++) string->toLower();

    ;return
    ret
  ;------------------------------------------------------------------- 

  ;int main (int argc, char** argv) ---------------------------------- 
  ;Program entry point
  global _start
  _start: 
    ;Create the stack frame
    push ebp
    mov ebp, esp    

    pop ecx ;pop a zero
    pop ecx ;Get the number of arguments (argc)
    pop ecx ;Get the program name (argv[0])

    ;Call the search function
    call search ;search(argv[1], argv[2])

    ;return value
    add esp, 0x10 ;eax = searach(argv[1],[argv[2])
    cmp eax, -1   ;check if return -1
    jne printfound
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2   
    mov edx, len2
    int 80h
    jmp exit    

    printfound:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1   
    mov edx, len1
    int 80h

  exit:
    mov eax, 0x1  ;Syscall 1 (exit)
    mov ebx, 0x0  ;Exit code 0 (No errors)
    int 80h       ;Call system
  ;-------------------------------------------------------------------
