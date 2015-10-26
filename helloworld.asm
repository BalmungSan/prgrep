	      section .data
hola_palabra: db    "Hello World",64,10,13
hola_tamano:  equ   $-hola_palabra

	      section .text
	      global _start

_start:
	      mov   eax,4
	      mov   ebx,1
	      mov   ecx,hola_palabra
	      mov   edx,hola_tamano
	      int   80h

				    ;Final del programa
	      mov   eax,1
	      mov   ebx,0
	      int   80h
