.model small

.stack 100h

.data

menu 
    db "SNAKE 2D:",13,10
    db "1. Iniciar Jogo",13,10
    db "2. Ver estatisticas do jogo",13,10
   
    db "3. Exit",13,10,'$'
.code
start:

;INITIALIZE DATA SEGMENT.
    mov  ax, @data
    mov  ds, ax

    call clear_screen      
    call display_menu    

;WAIT FOR ANY KEY.    
    mov  ah, 7
    int  21h

;FINISH PROGRAM.
    mov  ax, 4c00h
    int  21h

;---------------------------------------------

display_menu proc
    mov  dx, offset menu
    mov  ah, 9
    int  21h
    ret
display_menu endp

clear_screen proc
    mov  ah, 0
    mov  al, 3
    int  10H
    ret
clear_screen endp

end start