5.
a) muda o valor de ax para bx (todos os 16 bits)
 ax=FF05H
 
b) muda o valor de cl(8 menos significativos) para 37H

c) muda o conteudo de 246BH para cx
  cx= FFH
  
d)muda o cx para 246BH

e)move conteudo de bx para ax
ax=0DH
f)
 cx=1FF5H
g) multiplica BX
 
 6.
 a) adiciona al a bl
    move bl para o registo de memoria de 0004H
	[0004]=FAH
 b)
 muda valor de bx para 0004H
 al=FFH
 subtrai a al, cl
 al= 1AH
 incrementa bx
 bx=0005H
 [bx]=1AH


7.

a)
 first DB 25H
second DB 31H
greater DB ?
b)
1Byte
c)
first=
 
8.

.8086
.model	small
.stack	2048

dseg    segment para public 'data'
	Address1 BYTE 20
	Address2 BYTE 38
	Address3 WORD ?

dseg    ends

cseg	segment para public 'code'
	assume  cs:cseg, ds:dseg
main	proc
	mov	ax, dseg
	mov	ds, ax
	mov al, Address1
	add al, Address2
	xor ah,ah
	mov Address3,ax
	mov	ah,4ch
	int	21h
main	endp
cseg    ends
end     main