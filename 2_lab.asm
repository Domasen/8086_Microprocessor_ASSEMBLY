;4.Programa išveda tik tas eilutes, kuriose pirmas laukas turi tik dvi raides ‘Z’, 
;o trečio, ketvirto ir penkto laukų suma yra teigiamas pirminis skaičius.
;pavadinomo eilute
%include 'yasmmac.inc'

org 100h

section .text

	startas
	
	macPutString 'Domas Nemanius 1 kursas 2 grupe', crlf, '$'
	macNewLine
	;;;;;;;;;;; input failo atidarymas
	mov bl, [ds:80h]
	add bx, 81h
	
	mov dx, 82h
	mov cl, 0x0
	mov [ds:bx], cl
	
	mov ah, 0x3D
	mov al, 0
	int 0x21
	
	mov [inputFileHandle], ax
	
	macPutString 'Iveskite rezultatu failo varda', crlf, '$'
	mov ah, 0x0A
	mov dx, outputFileName
	int 0x21
	macNewLine
	
	;;;;;;;;;;;failo vardo gale irasome 0
	
	mov bx, 0
	mov cl, 0x0
	mov bl, [outputFileName + 1]
	mov [outputFileName + bx + 2], cl
	
	
	;;;;;;;;;;;;;;;output failo atidarymas
	
	mov dx, outputFileName + 2
	mov ah, 0x3D
	mov al, 1
	int 0x21
	mov [outputFileHandle], ax
	
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; skaitoma tik pirma eilute
	mov bx, [inputFileHandle]
	mov dx, inputBuffer
	mov di, 0 ;baitas inputBufferyje
	;mov si, 0 ;baitas fieldBufferyje
	mov cx, 0 ; dabartinis laukas
	mov ax, 0

	.loop1:
		push cx
		mov cx, 01	
		mov ah, 0x3F
		int 0x21
		pop cx
		cmp ax, 0
		je .next
		push dx
		mov dl, [inputBuffer+di]
		;mov byte [fieldBuffer+si], dl
		pop dx
		
		
		cmp byte [inputBuffer+di], 0x0A
		je .irasymas
		cmp ax, 0 ;;;failo pabaiga
		je .irasymas
		inc dx
		inc di
		inc si
		jmp .loop1
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;Skaitome faila	
	.skaitymas
	mov bx, [inputFileHandle]
	mov dx, inputBuffer
	mov di, 0 ;baitas inputBufferyje
	mov si, 0 ;baitas fieldBufferyje
	mov cx, 0 ; dabartinis laukas
	mov ax, 0
	mov [sum], cx
	
	.loop:
		push cx
		mov cx, 01	
		mov ah, 0x3F
		int 0x21
		pop cx
		cmp ax, 0
		je .next
		push dx
		mov dl, [inputBuffer+di]
		mov byte [fieldBuffer+si], dl
		pop dx
		
		cmp byte [inputBuffer+di], ';'
		je .kitasLaukas
		
		cmp byte [inputBuffer+di], 0x0A
		je .getIntegerFieldSum
		cmp ax, 0 ;;;failo pabaiga
		je .getIntegerFieldSum
		inc dx
		inc di
		inc si
		jmp .loop
		
		
		.kitasLaukas
		cmp cl, 2
		jge .getIntegerFieldSum
		
			.contKitasLaukas
			mov si, 0
			inc cl
			inc dx
			inc di
			jmp .loop
	
		.naujaEil
		;jmp .skaitymas
	
	;ar pirmas laukas turi tik 'ZZ;'
	.arZZ
	mov ax, [sum]
	;call procPutInt16
	;macNewLine
	cmp ax, 0
	jle .skaitymas
	
	cmp byte[inputBuffer], 'Z'
	jne .skaitymas
	cmp byte[inputBuffer+1], 'Z'
	jne .skaitymas
	cmp byte[inputBuffer+2], ';'
	je .arPirminis
	jmp .skaitymas
	
	.arPirminis
	
	mov ax, 0
	cmp ax, [sum] ;0 ne pirminis
	je .skaitymas
	inc ax
	cmp ax, [sum]; 1 ne pirminis
	je .skaitymas
	
		
	mov cx, 2
	
	.l
		mov dx, 0x0000
		cmp cx, [sum]
		je .irasymas
		
		mov ax, [sum]
		div cx
		
		cmp dx, 0
		je .skaitymas
		inc cx
		jmp .l	
	
	
	
	.irasymas
	
	mov di, 0
	mov dx, inputBuffer
	
	.kartok:
		mov bx, [outputFileHandle]
		mov cx, 1
		mov ah, 0x40
		int 0x21
		cmp byte [inputBuffer+di], 0x0A
		je .skaitymas
		inc dx
		inc di
		jmp .kartok
		
	.next
	
	
	
	;;;;;;;failu uzdarymas
	mov ah, 0x3E
	mov bx, [inputFileHandle]
	int 0x21
	
	mov bx, [outputFileHandle]
	int 0x21
	jmp .end
	
	.getIntegerFieldSum
		
		push cx
		mov cl, '$'
		mov byte [fieldBuffer + si], cl
		
		push ax
		push bx
		push dx
		
		mov dx, fieldBuffer
		call procParseInt16
		mov cx, [sum]
		add cx, ax
		mov [sum], cx
		
		pop dx
		pop bx
		pop ax
		pop cx
		
		cmp cl, 4
		jne .contKitasLaukas
		
		jmp .arZZ
	
	.end
	
	%include 'yasmlib.asm'
	
	exit
	
	
	
	
	
section .data
	inputFileHandle
		dw 0
		
	outputFileName
		db 0x82, 0x0
		times 100 db 0x0
		
	outputFileHandle
		dw 0
	
	fieldBuffer
		times 100 db '*'
	
	inputBuffer
		times 100 db '$'
	
	sum
		dw 0x00
section .bss
