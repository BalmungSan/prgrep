section .data
  ;bmbc = new int [256] (ascii table)
  bmbc times 256 dd 0 ;create an arry 4bytes -> doble word

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
    sub esp, 0x1c ;reserve space of 28 bytes -> 7 int and

    ;[ebp-4] = int result = -1
    mov dword [ebp-4], -1

    ;[ebp-8] = int i = 0
    ;[ebp-12] = int j = 0
 
    ;[ebp-16] = int n = text.length
    mov ecx, dword [ebp+8]  ;get text from the stack
    call getlen             ;get the length of the string
    mov dword [ebp-16], edx ;edx = text.length

    ;[ebp-20] = int m = text.length
    mov ecx, dword [ebp+12] ;get pattern from the stack
    call getlen             ;get the length of the string
    mov dword [ebp-20], edx ;edx = pattern.length 

    ;[ebp-24] = int last = m - 1
    mov ecx, [ebp-20] ;ecx = m
    dec ecx           ;ecx--
    mov [ebp-24], ecx ;last = ecx

    ;[ebp-28] = int end = n - m
    mov ecx, [ebp-16] ;ecx = n
    sub ecx, [ebp-20] ;ecx = ecx - m
    mov [ebp-28], ecx ;end = ecx
    ;-------------------------------------------------------

    ;Precompute --------------------------------------------
    ;for(i = 0; i < 256; i++) bmbc[i] = m
    xor ecx, ecx             ;clear the iterator -> ecx = 0
    lea edi, [bmbc]          ;edi = *bmbc
    loopbmbcfill:
      mov eax, [ebp-20]      ;eax = m
      mov [edi + ecx*4], eax ;*(edi + ecx*4) = eax
      inc ecx                ;ecx++
      cmp ecx, 256           ;if ecx != 256 ...
      jne loopbmbcfill       ;... continue loop

    ;for(int i = 0; i < last; i++) bmbc[text[i]] = last-i;
    mov eax, dword [ebp+12] ;put in eax the pointer to text
    xor edx, edx            ;clear the iterator -> edx = 0
    forbmbc:
      ;ebx = text[edx]
      movzx ebx, byte [eax + edx]      

      ;ecx = last - i
      mov ecx, [ebp-24] ;ecx = last
      sub ecx, edx      ;ecx = ecx - edx

      ;bmbc[ebx] = ecx
      mov [edi + ebx*4], ecx      

      inc edx           ;edx++
      cmp edx, [ebp-24] ;if edx != last...
      jne forbmbc       ;... continue loop
    ;-------------------------------------------------------

    ;Searching ---------------------------------------------
    ;while (j <= end)
    whilesearching:
    ;Condition
    mov eax, [ebp-12]      ;eax = j
    mov ebx, [ebp-28]      ;ebx = end
    ;cmp [ebp-12], [ebp-28] ;if eax == ebx ...
    je endwhilesearching   ;... end while

      ;for (i = last; text[i] == pattern[i+j]; i--);
      ;i = last
      ;mov [ebp-8], [ebp-36]
      forsearching:
      ;condition
      ;eax = text[i]
      ;mov   
      ;mov ebx, [];ebx = pattern[i+j]
      ;cmp eax, ebx        ;if eax != ebx ...
      ;jne endforsearching ;... break loop

        ;if (i == 0) return j
        cmp dword [ebp-8], 0  ;if i == 0 ...
        
      endforsearching:      

      ;j += bmbc[pattern[j+last]]
      jmp whilesearching ;continue the while

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

  exit:
    mov eax, 0x1  ;Syscall 1 (exit)
    mov ebx, 0x0  ;Exit code 0 (No errors)
    int 80h       ;Call system
  ;-------------------------------------------------------------------
