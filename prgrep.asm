; Include auxiliary functions coded in other file
%include 'functions.asm'

section .data
  ;bmbc = new int [256] (ascii table)
  bmbc: times 256 dd 0 ;create an arry 4bytes -> doble word
  
  ;arr= new int [4] arr array to fill bmbc in parallel
  arr: times 4 dd 0;

section .bss

section .text
  ;int  broyer_moore ([ebp+8] String text, [ebp+12] String pattern) ---------
  ;Boyer Moore string matching algorithm
  ;return the position where is found the pattern in text, or -1 if not found
  global broyer_moore
  broyer_moore: 
    ;create the stack frame
    push ebp
    mov ebp, esp

    ;local variables ---------------------------------------
    ;create local variables by reserving space on the stack
    sub esp, 0x14 ;reserve space of 36 bytes -> 5 int

    ;[ebp-4] = int result = -1
    mov dword [ebp-4], -1

    ;[ebp-8] = int n = text.length
    mov ecx, dword [ebp+8]  ;get text from the stack
    call getlen             ;get the length of the string
    mov dword [ebp-8], edx  ;edx = text.length

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
    ;arr = {m, m, m, m}
    xor ecx, ecx    ;clear the iterator -> ecx = 0
    lea edi, [bmbc] ;edi = *bmbc

    mov eax, [ebp-12] ;eax = m
    lea esi, [arr]    ;esi = *arr
    mov [esi], eax    ;arr[0] = m
    mov [esi+4], eax  ;arr[1] = m
    mov [esi+8], eax  ;arr[2] = m
    mov [esi+12], eax ;arr[3] = m

    ;fill bmbc in parallel using movups and the xmm registers
    ;fill 32 (4 * 8) values per iteration
    loopbmbcfill:
      ;fill xmm with arr
      movups xmm0, [arr] ;xmm0 = arr
      movups xmm1, [arr] ;xmm1 = arr
      movups xmm2, [arr] ;xmm2 = arr
      movups xmm3, [arr] ;xmm3 = arr
      movups xmm4, [arr] ;xmm4 = arr
      movups xmm5, [arr] ;xmm5 = arr
      movups xmm6, [arr] ;xmm6 = arr
      movups xmm7, [arr] ;xmm7 = arr

      ;eax = ecx * 8
      mov eax, ecx ;eax = ecx
      imul eax, 8  ;eax = eax * 8
      mov edx, eax ;edx = eax

      ;fill bmbc with xmm, 4 positios per mov
      ;bmbc[eax -> eax+4] = xmm0
      imul eax, 4 ;eax = eax * 4
      movups [edi + eax*4], xmm0 

      ;bmbc[eax+4 -> eax+8] = xmm1
      inc edx      ;edx++
      mov eax, edx ;eax = edx
      imul eax, 4  ;eax = eax * 4
      movups [edi + eax*4], xmm1

      ;bmbc[eax+8 -> eax+12] = xmm2
      inc edx      ;edx++
      mov eax, edx ;eax = edx
      imul eax, 4  ;eax = eax * 4
      movups [edi + eax*4], xmm2

      ;bmbc[eax+12 -> eax+16] = xmm3
      inc edx      ;edx++
      mov eax, edx ;eax = edx
      imul eax, 4  ;eax = eax * 4
      movups [edi + eax*4], xmm3

      ;bmbc[eax+16 -> eax+20] = xmm4
      inc edx      ;edx++
      mov eax, edx ;eax = edx
      imul eax, 4  ;eax = eax * 4
      movups [edi + eax*4], xmm4

      ;bmbc[eax+20 -> eax+24] = xmm5
      inc edx      ;edx++
      mov eax, edx ;eax = edx
      imul eax, 4  ;eax = eax * 4
      movups [edi + eax*4], xmm5

      ;bmbc[eax+24 -> eax+28] = xmm6
      inc edx      ;edx++
      mov eax, edx ;eax = edx
      imul eax, 4  ;eax = eax * 4
      movups [edi + eax*4], xmm6

      ;bmbc[eax+28 -> eax+32] = xmm7
      inc edx      ;edx++
      mov eax, edx ;eax = edx
      imul eax, 4  ;eax = eax * 4
      movups [edi + eax*4], xmm7

      inc ecx                ;ecx++
      cmp ecx, 8             ;if ecx != 8 ...
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

    ;destroy the stack frame
    mov esp, ebp
    pop ebp
    ret 
  ;-------------------------------------------------------------------
