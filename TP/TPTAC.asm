.8086
.model small
.stack 2048

goto_xy		macro	posx,posy
	mov     al, posy
    mov     bl, 160
    mul     bl
    mov     di, ax

    mov     al, posx
    mov     bl, 2
    mul     bl
    add     di, ax
endm

dados segment
	num_aleat 		dw 	0

	pontos			dw	0
	vidas			db 	3
    texto1   		BYTE    'Pontos:', 0
    texto2	 		BYTE    'Vidas:', 0
	texto_pontos	db	5	dup('0'), '$'

	maca_x			db	0
	maca_y			db	0
	maca_tipo		db	0

	rato_x			db	0
	rato_y			db  0
	rato_seg		dw 	0

	menu_begin 		db  'SNAKE - ISEC', 13, 10
            		db  '1 - Start game', 13, 10
            		db  '2 - Game history', 13, 10
            		db  '3 - Exit game$'

	menu_vel 		db  'SELECT SPEED', 13, 10
            		db  '1 - Snail', 13, 10
            		db  '2 - Hare', 13, 10
            		db  '3 - Cheetah$'

    posy  			db	10	; a linha pode ir de [1 .. 25]
    posx  			db	40	; posx pode ir [1..80]
    posya 			db	5	; posição anterior de y
    posxa   		db	10	; posição anterior de x

	tamanho			dw 	0
	cauda_x			db	200	dup(0), '$'
	cauda_y			db	200	dup(0), '$'

    passa_t			dw	0
    passa_t_ant		dw	0
    direccao		db	3

    centesimos		dw 	0
    factor			db	50
    metade_factor	db	?
    resto			db	0

    erro_open       db	'Erro ao tentar abrir o ficheiro$'
    erro_ler_msg    db  'Erro ao tentar ler do ficheiro$'
    erro_close      db  'Erro ao tentar fechar o ficheiro$'
    fich         	db  'moldura.txt', 0
	
    fich_historico  db  'hist.txt',	0
    handlefich      dw  0
    car_fich        db	?

	newline			db	13, 10

    

dados ends

codigo	segment	para	public	'code'
		assume	cs:codigo, ds:dados

main proc
    mov     ax, dados
    mov     ds, ax

	mov     ax, 0b800h
    mov     es, ax

start_menu:

    call 	clear_screen
    call 	display_menu

    mov  	ah, 7
    int  	21h

    cmp     al, '1'
    je      inicio_jogo

    cmp     al, '2'
    je      stats

    cmp     al, '3'
    je      fim

    jmp     start_menu

inicio_jogo:

    call    clear_screen
	call	display_vel

	mov  	ah, 7
    int  	21h

	mov		factor, 50

    cmp     al, '1'
    je      jogo

	mov		factor, 25

    cmp     al, '2'
    je      jogo

	mov		factor, 10

    cmp     al, '3'
    je      jogo

jogo:

	call	clear_screen

    call    imp_fich
    call    move_snake

	mov 	factor, 50
	mov		pontos, 0
	mov		tamanho, 0
	mov		vidas, 3

	lea 	dx,	fich_historico
	mov 	al,	02h
	mov 	ah,	3dh
	int 	21h
	
	mov 	bx,	ax
	mov 	ah, 42h
	mov 	al, 2
	mov 	cx, 0
	mov 	dx, 0
	int 	21h

	mov 	cx,	5
	lea 	dx,	texto_pontos
	mov 	ah,	40h
	int 	21h
	
	mov 	cx,	2
	lea 	dx,	newline
	mov 	ah,	40h
	int 	21h

	mov 	ah,	3eh
	int 	21h

	mov		cx, 5
	mov		si, 0

reset_pontos:

	mov		texto_pontos[si], '0'
	inc		si
	loop	reset_pontos

	jmp     start_menu

stats:

	call	clear_screen

	call	mostra_historico

	mov		ah, 7
	int		21h

	call	clear_screen

    jmp     start_menu

fim:

	call	clear_screen

    mov     ax, 4c00h
    int     21h

main	endp

imp_fich	proc
    mov     ah, 3dh			; vamos abrir ficheiro para leitura
    mov     al, 0			; tipo de ficheiro
    lea     dx, fich		; nome do ficheiro
    int     21h			    ; abre para leitura
    jc      erro_abrir		; pode aconter erro a abrir o ficheiro
    mov     handlefich, ax	; ax devolve o handle para o ficheiro
    jmp     ler_ciclo		; depois de abero vamos ler o ficheiro

erro_abrir:
    mov     ah, 09h
    lea     dx, erro_open
    int     21h
    jmp     sai

ler_ciclo:
    mov     ah, 3fh			; indica que vai ser lido um ficheiro
    mov     bx, handlefich	; bx deve conter o handle do ficheiro previamente aberto
    mov     cx, 1			; numero de bytes a ler
    lea     dx, car_fich    ; vai ler para o local de memoria apontado por dx (car_fich)
    int     21h			    ; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax, 0		    ;eof?	verifica se já estamos no fim do ficheiro
	je	    fecha_ficheiro	; se eof fecha o ficheiro
    mov     ah, 02h			; coloca o caracter no ecran
	mov	    dl, car_fich	; este é o caracter a enviar para o ecran
	int	    21h			    ; imprime no ecran
	jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
    mov     ah, 09h
    lea     dx, erro_ler_msg
    int     21h

fecha_ficheiro:				; vamos fechar o ficheiro
    mov     ah, 3eh
    mov     bx, handlefich
    int     21h
    jnc     sai

    mov     ah, 09h			; o ficheiro pode não fechar correctamente
    lea     dx, erro_close
    int     21h
sai:
    ret
imp_fich	endp

mostra_historico	proc
    mov     ah, 3dh			
    mov     al, 0
    lea     dx, fich_historico
    int     21h	
    jc      erro_abrir
    mov     handlefich, ax
    jmp     ler_ciclo

erro_abrir:
    mov     ah, 09h
    lea     dx, erro_open
    int     21h
    jmp     sai

ler_ciclo:
    mov     ah, 3fh			; indica que vai ser lido um ficheiro
    mov     bx, handlefich	; bx deve conter o handle do ficheiro previamente aberto
    mov     cx, 1			; numero de bytes a ler
    lea     dx, car_fich    ; vai ler para o local de memoria apontado por dx (car_fich)
    int     21h			    ; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax, 0		    ;eof?	verifica se já estamos no fim do ficheiro
	je	    fecha_ficheiro	; se eof fecha o ficheiro
    mov     ah, 02h			; coloca o caracter no ecran
	mov	    dl, car_fich	; este é o caracter a enviar para o ecran
	int	    21h			    ; imprime no ecran
	jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
    mov     ah, 09h
    lea     dx, erro_ler_msg
    int     21h

fecha_ficheiro:				; vamos fechar o ficheiro
    mov     ah, 3eh
    mov     bx, handlefich
    int     21h
    jnc     sai

    mov     ah, 09h			; o ficheiro pode não fechar correctamente
    lea     dx, erro_close
    int     21h
sai:
    ret

mostra_historico	endp

le_tecla_0	proc

	;	call 	trata_horas
	mov		ah,	0bh
	int 	21h
	cmp 	al,0
	jne		com_tecla
	mov		ah, 0
	mov		al, 0
	jmp		sai_tecla

com_tecla:

	mov		ah,	08h
	int		21h
	mov		ah,	0
	cmp		al,	0
	jne		sai_tecla
	mov		ah, 08h
	int		21h
	mov		ah,1

sai_tecla:

	ret

le_tecla_0	endp

passa_tempo proc

	mov		ah, 2ch         ; buscar a horas
	int   	21h

 	xor   	ax, ax
	mov   	al, dl          ; centesimos de segundo para ax
	mov   	centesimos, ax

	mov   	bl, factor		; define velocidade da snake (100; 50; 33; 25; 20; 10)
	div   	bl
	mov   	resto, ah
	mov   	al, factor
	mov   	ah, 0
	mov   	bl, 2
	div   	bl
	mov   	metade_factor, al
	mov   	al, resto
	mov   	ah, 0
	mov   	bl, metade_factor	; deve ficar sempre com metade do valor inicial
	mov   	ah, 0
	cmp   	ax, bx
	jbe   	menor
	mov   	ax, 1
	mov   	passa_t, ax
	jmp   	fim_passa

menor:

	mov   	ax, 0
	mov   	passa_t, ax

fim_passa:

	cmp		rato_seg, 0
	je		fim

	dec		rato_seg

fim:

 	ret

passa_tempo   endp

move_snake proc

	call	imprime_maca

posicao:

	call	calc_aleat
	pop		ax
	xor		ah, ah

	mov		bl, 60
	div		bl
	mov		posx, ah
	add		posx, 4

	call	calc_aleat
	pop		ax
	xor		ah, ah

	mov		bl, 20
	div		bl
	mov		posy, ah
	add		posy, 2

	goto_xy	posx, posy
	mov		al, es:[di]
	cmp		al, '#'
	je		posicao

ciclo:

	goto_xy	posx,posy	; vai para nova posição
	mov 	al, es:[di]	; guarda o caracter que está na posição do cursor
	
	cmp 	al, '#'		;  na posição do cursor
	jne		perde_cauda	
	
	call 	limpa_tudo

	cmp		vidas, 0
	je		fim

	dec		vidas
	mov		tamanho, 0
	jmp		posicao

perde_cauda:

	mov		ah, es:[di + 1]

	cmp		al, 254
	jne		maca

    cmp		ah, 00001001b
	jne		maca

	call 	limpa_tudo

	cmp		vidas, 0
	je		fim

	dec		vidas
	mov		tamanho, 0
	jmp		posicao

maca:

	call 	limpa_tudo

	goto_xy	posx,posy	; vai para nova posição
	mov 	al, es:[di]	; guarda o caracter que está na posição do cursor

	cmp		al, 254
	jne		rato

	mov		ah, es:[di + 1]
	cmp		ah, 00000100b
	jne		ponto
	
	inc		pontos
	inc		tamanho

ponto:
	
	cmp		factor, 10
	jbe		minimo_factor_maca

	sub		factor, 1
	jmp		muda_tamanho_maca

minimo_factor_maca:

	mov		factor, 10

muda_tamanho_maca:

	inc 	pontos
	inc		tamanho

	call 	imprime_maca

rato:

	cmp		rato_seg, 0
	jne		verifica_rato

	goto_xy	rato_x, rato_y
	mov		al, ' '
	mov		es:[di], al

	mov		al, 00000000b
	mov		es:[di + 1], al

	jmp		atualiza

verifica_rato:

	mov		al, es:[di]

	cmp		al, 157
	jne		imprime

	goto_xy	rato_x, rato_y
	mov		al, ' '
	mov		es:[di], al

	mov		al, 00000000b
	mov		es:[di + 1], al

	add		pontos, 3
	
	cmp		factor, 12
	jbe		minimo_factor_rato

	sub		factor, 3
	jmp		muda_tamanho_rato

minimo_factor_rato:

	mov		factor, 10

muda_tamanho_rato:

	cmp		tamanho, 5
	jbe		reset_tamanho

	sub		tamanho, 5
	jmp		atualiza

reset_tamanho:

	mov		tamanho, 0

atualiza:

	call	imprime_rato

imprime:

	call 	mexe_cauda
	call	imprime_pontos_vidas

	mov     si, 0

ciclo_imprime:

    goto_xy cauda_x[si], cauda_y[si]

	mov		al, 254
    
	cmp		si, 0
	jne		continua

    mov     al, 219

continua:

    mov     ah, 00001001b

    mov     es:[di], al
    mov     es:[di + 1], ah

    cmp     si, tamanho
    je      ler_seta

    inc     si
    jmp     ciclo_imprime

ler_seta:

	call 	le_tecla_0
	cmp		ah, 1
	je		estend
	cmp 	al, 27	; escape
	je		fim

teste:

	call	passa_tempo
	mov		ax, passa_t_ant
	cmp		ax, passa_t
	je		ler_seta
	mov		ax, passa_t
	mov		passa_t_ant, ax

verifica_0:

	mov		al, direccao
	cmp 	al, 0
	jne		verifica_1
	inc		posx		;direita

	cmp		posx, 66
	jne		ciclo
	
	mov		posx, 4
	
	jmp		ciclo

verifica_1:

	mov 	al, direccao
	cmp		al, 1
	jne		verifica_2
	dec		posy		;cima

	cmp		posy, 1
	jne		ciclo
	
	mov		posy, 21
	
	jmp		ciclo

verifica_2:

    mov 	al, direccao
	cmp		al, 2
	jne		verifica_3
	dec		posx		;esquerda

	cmp		posx, 3
	jne		ciclo
	
	mov		posx, 65

	jmp		ciclo

verifica_3:

    mov 	al, direccao
	cmp		al, 3
	jne		ciclo
	inc		posy		;baixo

	cmp		posy, 22
	jne		ciclo
	
	mov		posy, 2
	
	jmp		ciclo

estend:

	cmp 	al, 48h
	jne		baixo
	mov		direccao, 1
	jmp		ciclo

baixo:

	cmp		al, 50h
	jne		esquerda
	mov		direccao, 3
	jmp		ciclo

esquerda:

	cmp		al, 4bh
	jne		direita
	mov		direccao, 2
	jmp		ciclo

direita:

	cmp		al, 4dh
	jne		ler_seta
	mov		direccao, 0
	jmp		ciclo

fim:

	ret

move_snake endp

clear_screen proc
    mov     ah, 0
    mov     al, 3
    int     10h
    ret
clear_screen endp

display_menu proc
    mov		ah, 9
    lea		dx, menu_begin
    int		21h
    ret
display_menu endp

display_vel proc
    mov		ah, 9
    lea		dx, menu_vel
    int		21h
    ret
display_vel endp

imprime_maca proc

	call	calc_aleat
	pop		ax
	xor		ah, ah

	mov		bl, 2
	div		bl
	mov		maca_tipo, ah

posicao:

	call	calc_aleat
	pop		ax
	xor		ah, ah

	mov		bl, 60
	div		bl
	mov		maca_x, ah
	add		maca_x, 4

	call	calc_aleat
	pop		ax
	xor		ah, ah

	mov		bl, 20
	div		bl
	mov		maca_y, ah
	add		maca_y, 2

	goto_xy	maca_x, maca_y
	mov		al, es:[di]
	cmp		al, '#'
	je		posicao
	mov		al, 254
	mov		es:[di], al

maca1:

	cmp		maca_tipo, 1
	jne		maca2

	mov		al, 00000010b
	jmp		aplica

maca2:

	mov 	al, 00000100b

aplica:	
	mov		es:[di + 1], al

	ret

imprime_maca endp

imprime_rato proc

	call	calc_aleat
	pop		ax
	xor		ah, ah

	mov		bl, 20
	div		bl

	cmp		ah, 0
	jne 	fim

posicao:

	call	calc_aleat
	pop		ax
	xor		ah, ah

	mov		bl, 60
	div		bl
	mov		rato_x, ah
	add		rato_x, 4

	call	calc_aleat
	pop		ax
	xor		ah, ah

	mov		bl, 20
	div		bl
	mov		rato_y, ah
	add		rato_y, 2

	mov 	rato_seg, 20000

	goto_xy	rato_x, rato_y
	mov		al, es:[di]
	cmp		al, '#'
	je		posicao
	mov		al, 157
	mov		es:[di], al

	mov		al, 00001000b
	mov		es:[di + 1], al

fim:
	ret

imprime_rato endp

imprime_pontos_vidas proc
 	
	mov     si, 0
	mov		di, 0

ciclo:
    mov     al, texto1[si]
    cmp     al, 0
    je      fim_ciclo

    mov     ah, 00001000b
    mov     es:[di], al
    mov     es:[di + 1], ah
    
    add     di, 2
    inc     si
    jmp     ciclo

fim_ciclo:

    mov     bx, 10
    mov     si, 4
	mov 	ax, pontos

ciclo_pontos:
    mov     dx, 0
    div     bx
    add     dl, 48
    mov     texto_pontos[si], dl
    dec     si
    
    cmp     ax, 0
    jne     ciclo_pontos

	mov     si, 0

imprime:

    mov     al, texto_pontos[si]
    cmp     al, '$'
    je      trata_vidas

    mov     ah, 00000001b   ;Nao pisca (0), branco (111), azul (0001)
    mov     es:[di], al
    mov     es:[di + 1], ah
    
    add     di, 2
    inc     si
    jmp     imprime

trata_vidas:

	mov		si, 0
	add		di, 4

ciclo_vidas:

    mov     al, texto2[si]
    cmp     al, 0
    je      fim_ciclo_vidas

    mov     ah, 00001000b
    mov     es:[di], al
    mov     es:[di + 1], ah
    
    add     di, 2
    inc     si
    jmp     ciclo_vidas

fim_ciclo_vidas:
	
	mov		ah, 00000001b

	cmp		vidas, 0
	jne		continua

	mov		ah, 10000001b

continua:

	mov		al, vidas
	add		al, 48

	mov		es:[di], al
	mov		es:[di + 1], ah

fim:
	ret

imprime_pontos_vidas endp

mexe_cauda proc

	mov		si, tamanho

ciclo_cauda:

	mov		al, cauda_x[si]
	mov		cauda_x[si + 1], al

	mov		al, cauda_y[si]
	mov		cauda_y[si + 1], al

	cmp		si, 0
	je		fim_ciclo_cauda

	dec 	si
	jmp 	ciclo_cauda

fim_ciclo_cauda:

	mov		al, posx	; guarda a posição do cursor
	mov		cauda_x[0], al
	mov		al, posy	; guarda a posição do cursor
	mov 	cauda_y[0], al

    ret

mexe_cauda endp

limpa_tudo proc

    mov     si, 0

ciclo_limpa:

    goto_xy cauda_x[si], cauda_y[si]

    mov		al, 32
	mov		ah, 00000000b

	mov     es:[di], al
    mov     es:[di + 1], ah

	cmp		si, tamanho
	je		fim_ciclo_limpa

	inc  	si
	jmp 	ciclo_limpa

fim_ciclo_limpa:

	ret

limpa_tudo endp

imprime_cobra proc

    mov     si, 0
    mov     al, 178
    mov     ah, 00000010b

ciclo_imprime:

    goto_xy cauda_x[si], cauda_y[si]

    mov     es:[di], al
    mov     es:[di + 1], ah

    mov     al, 220

    cmp     si, tamanho
    je      fim_ciclo_imprime

    inc     si
    jmp     ciclo_imprime

fim_ciclo_imprime:

    ret

imprime_cobra endp

calc_aleat proc near

	sub		sp, 2		; 
	push	bp
	mov		bp, sp
	push	ax
	push	cx
	push	dx	
	mov		ax, [bp + 4]
	mov		[bp + 2], ax

	mov		ah, 00h
	int		1ah

	add		dx, num_aleat	; vai buscar o aleat�rio anterior
	add		cx, dx	
	mov		ax, 65521
	push	dx
	mul		cx			
	pop		dx			 
	xchg	dl, dh
	add		dx, 32749
	add		dx, ax

	mov		num_aleat, dx	; guarda o novo numero aleat�rio  

	mov		[bp + 4], dx		; o aleat�rio � passado por pilha

	pop		dx
	pop		cx
	pop		ax
	pop		bp
	ret
calc_aleat endp

codigo ends

end	main

