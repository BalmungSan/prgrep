section .data
hola_palabra: db    "Hello World",64,10,13
hola_tamano:  equ   $-hola_palabra

section .text
;;  Define variables que pueden ser accedidas desde C
global _start

sart:
mov   eax,4 	; Call system write id 4
mov   ebx,1 	; Input file = screen
mov   ecx,hola_palabra ; Save the string
mov   edx,hola_tamano ; save the string size
int   80h 	; Kernel interruption

				    ;Final del programa
mov   eax,1	    ; Call system exit
mov   ebx,0	    ; Exit code 0
int   80h		    ; Kernel interruption
