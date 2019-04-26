.8086
.MODEL SMalL
.STACK 2048

GOTO_XY		MACRO	POSX,POSY
	MOV	   ah,02H
	MOV	   bh,0
	MOV	   DL,POSX
	MOV    DH,POSY
	INT	   10H
ENDM

DADOS SEGMENT
    menu1           db  'Welcome to snake!', 13, 10
                    db  '1 - Start Game', 13, 10
                    db  '2 - Stats', 13, 10
                    db  '3 - Exit Game', 13, 10
    POSy  	        db	10	; a linha pode ir de [1 .. 25]
    POSx  	        db	40	; POSx pode ir [1..80]
    POSya       	db	5	; Posição anterior de y
    POSxa           db	10	; Posição anterior de x

    PASSA_T		    dw	0
    PASSA_T_ant	    dw	0
    direccao	    db	3

    Centesimos	    dw 	0
    FACTOR		    db	100
    metade_FACTOR	db	?
    resto		    db	0

    Erro_Open       db  'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    db  'Erro ao tentar ler do ficheiro$'
    Erro_Close      db  'Erro ao tentar fechar o ficheiro$'
    Fich         	db  'moldura.TXT', 0
    HandleFich      dw  0
    car_fich        db  ?

DADOS ENDS

CODIGO	SEGMENT	para	public	'code'
		ASSUME	CS:CODIGO, DS:DADOS

MAIN PROC
    mov     ax, DADOS
    mov     ds, ax

START_MENU:

    call CLEAR_SCREEN
    call DISPLAY_MENU

    mov  ah, 7
    int  21h

    cmp     al, '1'
    je      INICIO_JOGO

    cmp     al, '2'
    je      STATS

    cmp     al, '3'
    je      FIM

    jmp     START_MENU

INICIO_JOGO:

    call    CLEAR_SCREEN
    call    Imp_Fich
    call    move_snake

    jmp     START_MENU

STATS:

    jmp     START_MENU

FIM:

    mov     ax, 4c00h
    int     21h

main	endp

Imp_Fich	proc
    mov     ah,3dh			; vamos abrir ficheiro para leitura
    mov     al,0			; tipo de ficheiro
    lea     dx,Fich			; nome do ficheiro
    int     21h			    ; abre para leitura
    jc      erro_abrir		; pode aconter erro a abrir o ficheiro
    mov     HandleFich,ax	; ax devolve o Handle para o ficheiro
    jmp     ler_ciclo		; depois de abero vamos ler o ficheiro

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai

ler_ciclo:
    mov     ah, 3fh			; indica que vai ser lido um ficheiro
    mov     bx, HandleFich	; bx deve conter o Handle do ficheiro previamente aberto
    mov     cx, 1			; numero de bytes a ler
    lea     dx, car_fich    ; vai ler para o local de memoria apontado por dx (car_fich)
    int     21h			    ; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax, 0		    ;EOF?	verifica se já estamos no fim do ficheiro
	je	    fecha_ficheiro	; se EOF fecha o ficheiro
    mov     ah, 02h			; coloca o caracter no ecran
	mov	    dl, car_fich	; este é o caracter a enviar para o ecran
	int	    21h			    ; imprime no ecran
	jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
    mov     ah,09h
    lea     dx,Erro_Ler_Msg
    int     21h

fecha_ficheiro:				; vamos fechar o ficheiro
    mov     ah,3eh
    mov     bx,HandleFich
    int     21h
    jnc     sai

    mov     ah,09h			; o ficheiro pode não fechar correctamente
    lea     dx,Erro_Close
    int     21h
sai:
    ret
Imp_Fich	endp

LE_TECLA_0	PROC
	;	call 	Trata_Horas
	MOV	ah,0bh
	INT 	21h
	cmp 	al,0
	jne	com_tecla
	mov	ah, 0
	mov	al, 0
	jmp	SAI_TECLA
com_tecla:
	MOV	   ah,08H
	INT	   21H
	MOV	   ah,0
	CMP	   al,0
	JNE	   SAI_TECLA
	MOV	   ah, 08H
	INT	   21H
	MOV	   ah,1
SAI_TECLA:
	RET
LE_TECLA_0	ENDP

PASSA_TEMPO PROC
	MOV   ah, 2CH         ; Buscar a hORAS
	INT   21H

	XOR   ax,ax
	MOV   al, dl          ; centesimos de segundo para ax
	mov   Centesimos, ax

	mov   bl, factor		; define velocidade da snake (100; 50; 33; 25; 20; 10)
	div   bl
	mov   resto, ah
	mov   al, FACTOR
	mov   ah, 0
	mov   bl, 2
	div   bl
	mov   metade_FACTOR, al
	mov   al, resto
	mov   ah, 0
	mov   bl, metade_FACTOR	; deve ficar sempre com metade do valor inicial
	mov   ah, 0
	cmp   ax, bx
	jbe   Menor
	mov   ax, 1
	mov   PASSA_T, ax
	jmp   fim_passa

Menor:
	mov   ax,0
	mov   PASSA_T, ax

fim_passa:
 		ret
PASSA_TEMPO   ENDP

move_snake PROC

CICLO:
	goto_xy	POSx,POSy	; Vai para nova possição
	mov 	ah, 08h	    ; Guarda o Caracter que está na posição do Cursor
	mov		bh,0		; numero da página
	int		10h
	cmp 	al, '#'	    ;  na posição do Cursor
	je		fim

	goto_xy	POSxa,POSya		; Vai para a posição anterior do cursor
	mov		ah, 02h
	mov		dl, ' ' 	; Coloca ESPAÇO
	int		21H

	inc		POSxa
	goto_xy	POSxa,POSya
	mov		ah, 02h
	mov		dl, ' '		;  Coloca ESPAÇO
	int		21H
	dec 	POSxa

	goto_xy	POSx,POSy	; Vai para posição do cursor

IMPRIME:
    mov		ah, 02h
	mov		dl, '('	    ; Coloca AVATAR1
	int		21H

	inc		POSx
	goto_xy	POSx,POSy
	mov		ah, 02h
	mov		dl, ')'	    ; Coloca AVATAR2
	int		21H
	dec		POSx

	goto_xy	POSx,POSy	; Vai para posição do cursor

	mov		al, POSx	; Guarda a posição do cursor
	mov		POSxa, al
	mov		al, POSy	; Guarda a posição do cursor
	mov 	POSya, al

LER_SETA:
	call 	LE_TECLA_0
	cmp		ah, 1
	je		ESTEND
	cmp 	al, 27	; ESCAPE
	je		FIM
	cmp		al, '1'
	jne		TESTE_2
	mov		FACTOR, 100

TESTE_2:
	CMP		al, '2'
	JNE		TESTE_3
	MOV		FACTOR, 50

TESTE_3:
	CMP		al, '3'
	JNE		TESTE_4
	MOV		FACTOR, 25

TESTE_4:
	CMP		al, '4'
	JNE		TESTE_END
	MOV		FACTOR, 10

TESTE_END:
	call	PASSA_TEMPO
	mov		ax, PASSA_T_ant
	cmp		ax, PASSA_T
	je		LER_SETA
	mov		ax, PASSA_T
	mov		PASSA_T_ant, ax

verifica_0:
	mov		al, direccao
	cmp 	al, 0
	jne		verifica_1
	inc		POSx		;Direita
	inc		POSx		;Direita
	jmp		CICLO

verifica_1:
	mov 	al, direccao
	cmp		al, 1
	jne		verifica_2
	dec		POSy		;cima
	jmp		CICLO

verifica_2:
    mov 	al, direccao
	cmp		al, 2
	jne		verifica_3
	dec		POSx		;Esquerda
	dec		POSx		;Esquerda
	jmp		CICLO

verifica_3:
    mov 	al, direccao
	cmp		al, 3
	jne		CICLO
	inc		POSy		;BAIXO
	jmp		CICLO

ESTEND:
	cmp 	al, 48h
	jne		BAIXO
	mov		direccao, 1
	jmp		CICLO

BAIXO:
	cmp		al, 50h
	jne		ESQUERDA
	mov		direccao, 3
	jmp		CICLO

ESQUERDA:
	cmp		al, 4Bh
	jne		DIREITA
	mov		direccao, 2
	jmp		CICLO

DIREITA:
	cmp		al, 4Dh
	jne		LER_SETA
	mov		direccao, 0
	jmp		CICLO

FIM:
	ret

move_snake ENDP

CLEAR_SCREEN PROC
    mov     ah, 0
    mov     al, 3
    int     10H
    ret
CLEAR_SCREEN ENDP

DISPLAY_MENU PROC
    mov		ah, 40h
    lea		dx, menu1
    mov     cx, 60
    int		21h
    ret
DISPLAY_MENU ENDP

CODIGO ENDS

END	MAIN
