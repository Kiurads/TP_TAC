.8086
.MODEL SMALL
.STACK 2048

DADOS SEGMENT
    menu1   db  'Welcome to snake!', 13, 10
            db  '1 - Start Game', 13, 10
            db  '2 - Stats', 13, 10
            db  '3 - Exit Game', 13, 10

    press1  db  'Premiu 1', 0
    press2  db  'Premiu 2', 0
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

    mov     ah, 09h
    mov     cx, 20
    lea     dx, press1
    int     21h

    mov  ah, 7
    int  21h

    jmp     START_MENU

STATS:

    call    CLEAR_SCREEN

    mov     ah, 40
    mov     cx, 20
    lea     dx, press2
    int     21h

    mov  ah, 7
    int  21h

    jmp     START_MENU

FIM:

    mov     ax, 4c00h
    int     21h

main	endp

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
