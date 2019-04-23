;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2018/2019
;--------------------------------------------------------------
; Demonstração de algumas rotinas :
;  - Como desenhar um tabuleiro com cores aleatorias 
;  - Como criar numeros aleatórios  
;  - Rotinha goto_xy para colocar o cursor numa posição do ecran
;  - Uma variante de DELAY (paragem durante alguns milisegundos)	
;  - Criação e movimento dum objecto no exran (rotina cursor)
;  - Rotinha para apagar o ecran
;	
;
;--------------------------------------------------------------


.8086
.MODEL SMALL
.STACK 2048

DADOS	SEGMENT PARA 'DATA'
		ultimo_num_aleat dw 0

		str_num db 5 dup(?),'$'
	
		linha		db	0	; Define o número da linha que está a ser desenhada
		nlinhas		db	0

		string	db	"Teste prático de T.A.C.",0
		Car		db	32	; Guarda um caracter do Ecran 
		Cor		db	7	; Guarda os atributos de cor do caracter
		Car2		db	32	; Guarda um caracter do Ecran 
		Cor2		db	7	; Guarda os atributos de cor do caracter
		POSy		db	12	; a linha pode ir de [1 .. 25]
		POSx		db	40	; POSx pode ir [1..80]	
		POSya		db	5	; Posição anterior de y
		POSxa		db	10	; Posição anterior de x	
	
DADOS	ENDS

CODIGO	SEGMENT PARA 'CODE'
	ASSUME CS:CODIGO, DS:DADOS

	
;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm




;------------------------------------------------------
;CalcAleat - calcula um numero aleatorio de 16 bits
;Parametros passados pela pilha
;entrada:
;não tem parametros de entrada
;saida:
;param1 - 16 bits - numero aleatorio calculado
;notas adicionais:
; deve estar definida uma variavel => ultimo_num_aleat dw 0
; assume-se que DS esta a apontar para o segmento onde esta armazenada ultimo_num_aleat
CalcAleat proc near

	sub	sp,2		; 
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	push	dx	
	mov	ax,[bp+4]
	mov	[bp+2],ax

	mov	ah,00h
	int	1ah

	add	dx,ultimo_num_aleat	; vai buscar o aleatório anterior
	add	cx,dx	
	mov	ax,65521
	push	dx
	mul	cx			
	pop	dx			 
	xchg	dl,dh
	add	dx,32749
	add	dx,ax

	mov	ultimo_num_aleat,dx	; guarda o novo numero aleatório  

	mov	[BP+4],dx		; o aleatório é passado por pilha

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
CalcAleat endp




;recebe em di o número de milisegundos a esperar
delay proc
	pushf
	push	ax
	push	cx
	push	dx
	push	si
	
	mov	ah,2Ch
	int	21h
	mov	al,100
	mul	dh
	xor	dh,dh
	add	ax,dx
	mov	si,ax


ciclo:	mov	ah,2Ch
	int	21h
	mov	al,100
	mul	dh
	xor	dh,dh
	add	ax,dx

	cmp	ax,si 
	jnb	naoajusta
	add	ax,6000 ; 60 segundos
naoajusta:
	sub	ax,si
	cmp	ax,di
	jb	ciclo

	pop	si
	pop	dx
	pop	cx
	pop	ax
	popf
	ret
delay endp



;########################################################################
;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
		xor	bx,bx
		mov	cx,25*80
		
apaga:		mov	byte ptr es:[bx],' '
		mov	byte ptr es:[bx+1],7
		inc	bx
		inc 	bx
		loop	apaga
		ret
apaga_ecran	endp




;########################################################################
;ROTINA PARA cursor



cursor		proc
		mov		ax,0B800h
		mov		es,ax
	
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor	
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possição2
		mov 		ah, 08h		; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		mov		Car2, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor2, ah	; Guarda a cor que está na posição do Cursor	
		dec		POSx
	

CICLO:		goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado 
		int		21H	

		inc		POSxa
		goto_xy		POSxa,POSya	
		mov		ah, 02h
		mov		dl, Car2	; Repoe Caracter2 guardado 
		int		21H	
		dec 		POSxa
		
		goto_xy	POSx,POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car2, al	; Guarda o Caracter2 que está na posição do Cursor2
		mov		Cor2, ah	; Guarda a cor que está na posição do Cursor2
		dec		POSx
		
		
		goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posição no canto
		mov		dl, Car	
		int		21H			
		
		goto_xy		78,0		; Mostra o caractr2 que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter2 da posição no canto
		mov		dl, Car2	
		int		21H			
		
	
		goto_xy		POSx,POSy	; Vai para posição do cursor
IMPRIME:	mov		ah, 02h
		mov		dl, '('	; Coloca AVATAR1
		int		21H
		
		inc		POSx
		goto_xy		POSx,POSy		
		mov		ah, 02h
		mov		dl, ')'	; Coloca AVATAR2
		int		21H	
		dec		POSx
		
		goto_xy		POSx,POSy	; Vai para posição do cursor
		
		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 		POSya, al
		
LER_SETA:	call 		LE_TECLA
		cmp		ah, 1
		je		ESTEND
		CMP 		AL, 27	; ESCAPE
		JE		FIM
		jmp		LER_SETA
		
ESTEND:		cmp 		al,48h
		jne		BAIXO
		dec		POSy		;cima
		jmp		CICLO

BAIXO:		cmp		al,50h
		jne		ESQUERDA
		inc 		POSy		;Baixo
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec		POSx		;Esquerda
		dec		POSx		;Esquerda

		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		inc		POSx		;Direita
		inc		POSx		;Direita
		
		jmp		CICLO

fim:		ret


cursor		endp



;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp
;########################################################################

	
PRINC PROC
	MOV	AX, DADOS
	MOV	DS, AX

		
		mov   	ax, 0b800h	; Segmento de memória de vídeo onde vai ser desenhado o tabuleiro
		mov   	es, ax	
		mov	linha, 	8	; O Tabuleiro vai começar a ser desenhado na linha 8 
		mov	nlinhas, 6	; O Tabuleiro vai ter 6 linhas
		
	
		
ciclo2:		mov	al, 160		
		mov	ah, linha
		mul	ah
		add	ax, 60
		mov 	bx, ax		; Determina Endereço onde começa a "linha". bx = 160*linha + 60

		mov	cx, 9		; São 9 colunas 
ciclo:  	
		; mov 	dh,	car	; vai imprimir o caracter "SAPCE"
		; mov	es:[bx],dh	;
	
novacor:	
		call	CalcAleat	; Calcula próximo aleatório que é colocado na pinha 
		pop	ax ; 		; Vai buscar 'a pilha o número aleatório
		and 	al,01110000b	; posição do ecran com cor de fundo aleatório e caracter a preto
		cmp	al, 0		; Se o fundo de ecran é preto
		je	novacor		; vai buscar outra cor 

		; mov 	dh,	   car	; Repete mais uma vez porque cada peça do tabuleiro ocupa dois carecteres de ecran
		; mov	es:[bx],   dh		
		mov	es:[bx+1], al	; Coloca as características de cor da posição atual 
		inc	bx		
		inc	bx		; próxima posição e ecran dois bytes à frente 

		; mov 	dh,	   car	; Repete mais uma vez porque cada peça do tabuleiro ocupa dois carecteres de ecran
		; mov	es:[bx],   dh
		mov	es:[bx+1], al
		inc	bx
		inc	bx
		
		mov	di,1 		;delay de 1 centesimo de segundo
		call	delay
		loop	ciclo		; continua até fazer as 9 colunas que correspondem a uma liha completa
		
		inc	linha		; Vai desenhar a próxima linha
		dec	nlinhas		; contador de linhas
		mov	al, nlinhas
		cmp	al, 0		; verifica se já desenhou todas as linhas 
		jne	ciclo2		; se ainda há linhas a desenhar continua 
		
		
		call cursor
FIM:
	MOV	AH,4Ch
	INT	21h
PRINC ENDP


CODIGO	ENDS
END	PRINC