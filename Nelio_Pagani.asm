.define
	Valor0 77h	      ; Valor hex para o display mostrar o digito 0
	Valor1 44h		; Valor hex para o display mostrar o digito 1
	Valor2 3Eh		; Valor hex para o display mostrar o digito 2
	Valor3 6Eh		; Valor hex para o display mostrar o digito 3
	Valor4 4Dh		; Valor hex para o display mostrar o digito 4
	Valor5 6Bh		; Valor hex para o display mostrar o digito 5
	Valor6 7Bh		; Valor hex para o display mostrar o digito 6
	Valor7 46h		; Valor hex para o display mostrar o digito 7
	Valor8 7Fh		; Valor hex para o display mostrar o digito 8
	Valor9 4Fh		; Valor hex para o display mostrar o digito 9
	Segundo1 03h
	Segundo2 02h
	Minuto1 01h
	Minuto2 00h
;;quando o cronometro progressivo chega em 59:59 ele comeca a contar do zero novamente 
.org 1000h	
ei
start:ei
	lxi b, 0
	lxi d, 0
	lxi h, 0	
	mvi a, Valor0
	out Segundo1
	out Segundo2
	out Minuto1
	out Minuto2
	jmp update_segundo1
update_minuto2:
	ei
	mvi d, 0h
	mvi a, Valor0
	out Minuto1
	inr e
	mov a, e
	cpi 06h
	jz start
	call comparison
	out Minuto2
	jmp update_segundo1
update_minuto1:
	ei
	mvi c, 0h
	mvi a, Valor0
	out Segundo2
	inr d
	mov a, d
	cpi 0ah
	jz update_minuto2
	call comparison
	out Minuto1
	jmp update_segundo1
update_segundo2:
	ei
	mvi b, 0h
	mvi a, Valor0
	out Segundo1
	inr c
	mov a, c
	cpi 06h
	jz update_minuto1
	call comparison
	out Segundo2
	jmp update_segundo1
update_segundo1:
	ei
	mvi h,00h
	call delay 
	inr b
	mov a, b
	cpi 0ah
	jz update_segundo2
	call comparison
	out Segundo1
	jmp update_segundo1
		
comparison:
digito0:	cpi 00h
	      jnz digito1
		mvi a, Valor0
		ret
digito1:	cpi 01h
		jnz digito2
		mvi a, Valor1
		ret
digito2: 	cpi 02h
		jnz digito3
		mvi a, Valor2
		ret
digito3:	cpi 03h
		jnz digito4
		mvi a, Valor3
		ret
digito4:	cpi 04h
		jnz digito5
		mvi a, Valor4
		ret
digito5:	cpi 05h
		jnz digito6
		mvi a, Valor5
		ret
digito6:	cpi 06h
		jnz digito7
		mvi a, Valor6
		ret
digito7:	cpi 07h
		jnz digito8
		mvi a, Valor7
		ret
digito8:	cpi 08h
		jnz digito9
		mvi a, Valor8
		ret
digito9:	cpi 09h
		jnz digito0
		mvi a, Valor9
		ret
;;------delay de 1ms-----
;; 7+ N*(4+10)-3= 2*10^3 (quantidade de T-states total, baseada no clock de 2Mhz) -> N=143(decimal) = 8F (hex) 	 	 
delay:		 
     mvi l, 8Fh
loop:dcr l
     jnz loop
     ret
.org 002ch
jmp 1500h
.org 1500h
;;zerando tudo
ei
zerar:
	lxi b, 0
	lxi d, 0
	lxi h, 0	
	mvi a, Valor0
	out Segundo1
	out Segundo2
	out Minuto1
	out Minuto2
	mvi h,01h ;; (h=1, sinaliza que o cronometro ta parado) 
stop:	jmp stop
.org 0034h
jmp 0500h
.org 0500h
;; isolando a partir do IN o Segundo1 e Segundo2 atraves de AND e rotacao de A
;;dps dando out com o numero inserido
;;dps o cronometro segue a contagem progressiva a partir do numero inserido
ei
in 00h
aqui:ani 0fh
mov b,a
call comparison
out Segundo1
seg2:in 00h
ani f0h
rrc
rrc
rrc
rrc
mov c,a
call comparison
out Segundo2
;;isolando a partir do IN o Minuto1 e Minuto2 atraves de AND e rotacao de A
;;dps dando out com o numero inserido
in 01h
ani 0fh
mov d,a
call comparison
out Minuto1
in 01h
ani f0h
rrc
rrc
rrc
rrc
mov e,a
call comparison
out Minuto2
jmp update_segundo1
.org 0024h
jmp 1800h
.org 1800h
ei
mov a,h
cpi 00h
jnz update_segundo1 ;;significa que esta parado, ent agr vai voltar a contar (h=1 parado, h=0 rodando)
mvi a,01h ;;se h diferente de 0 significa que ta contando, ent agr vai parar
mov h,a
parar: ei
jmp parar
.org 003ch
jmp 2000h
.org 2000h
ei
mov a,h
cpi 00h
jnz update_segundo1_inv ;;significa que esta parado, ent agr vai contar de forma regressiva
mvi h,01h ;;se h diferente de 0 significa que ta contando, ent agr vai parar
jmp parar
;;fazendo contagem regressiva e definindo que após o Minuto2 diminuir em 1, o Minuto1 terá o valor 9 (ex: 40 -> 39)
update_minuto2_inv:
	mvi d, 9h 
	mvi a, Valor9
	out Minuto1
	dcr e
	mov a, e
	cpi FFh 
	jz update_minuto1_inv
	call comparison
	out Minuto2
	jmp update_segundo1_inv
;;fazendo contagem regressiva e definindo que após o Minuto1 diminuir em 1, o Segundo2 terá o valor 5 (ex: 2:00 -> 1:59)
update_minuto1_inv:
	ei
	mvi c, 5h
	mvi a, Valor5
	out Segundo2
	dcr d
	mov a, d
	cpi FFh 
	jz update_minuto2_inv
	call comparison
	out Minuto1
	jmp update_segundo1_inv
;;fazendo contagem regressiva e definindo que após o Segundo2 diminuir em 1, o Segundo1 terá o valor 9 (ex: 0:40 -> 0:39)
update_segundo2_inv:
	ei
	mvi b, 9h 
	mvi a, Valor9
	out Segundo1
	dcr c
	mov a, c
	cpi FFh 
	jz update_minuto1_inv
	call comparison
	out Segundo2
	jmp update_segundo1_inv
;;contagem regressiva normal com chamada de delay
update_segundo1_inv:
	ei
	mvi h,00h
	call delay 
	mov a,e
	cpi 0h
	mov a, b
	jz final ;;verifica a possibilidade de o cronometro estar totalmente zerado
continue:
	dcr b
	mov a,b
	cpi FFh 
	jz update_segundo2_inv
	call comparison
	out Segundo1
	jmp update_segundo1_inv
	;;fazendo comparacoes sucessivas parar verificar se o cronometro foi totalmente zerado
	;;se foi totalmente zerado, o programa ficará em standby
	final: 
		mov a,d
		cpi 0h
		jnz continue
		mov a,c
		cpi 00h
		jnz continue
		mov a,b
		cpi 00h
		jnz continue
		mvi h,01h
		jmp parar
