org 0
ljmp init

org 0003h	;Extern Power
lcall power
reti

org 000Bh	;Timer Frequenz
lcall frequenz
reti

org 001Bh	;Timer Takt
lcall takt
reti

power:	jb P0.1, stopp
	setb P0.1
	mov R1, #0
	lcall getTime
	lcall getNote
	mov TL1, #0B0h
	mov TH0, #3Ch
	setb P0.0
	setb TR0
	setb TR1
	ret
	stopp:	clr P0.1
		clr TR0
		clr TR1
		clr P0.0
		ret

frequenz:	cpl P0.0	;Lautsprecher An/Aus
		lcall getNote	;Startwerte Timer laden
		ret

takt:	djnz R0, laden
	inc R1
	cjne R1, #18, nextNote
	mov R1, #0
	nextNote:	clr TR0	;Timer stoppen
			clr TR1
			lcall pause	;kurze Pause
			lcall getTime	;Startwerte naechste Note laden
			lcall getNote
			setb TR0	;Timer wieder starten
			setb TR1
			setb P0.0
	laden:	mov TL1, #0B0h
		mov TH0, #3Ch
	ret

pause:	mov R3, #250	;Pause entspricht neues Anspielen der Note
	S1: mov R2, #50	;Pausenzeit = 2*250*50 = 25.000
	S0: djnz R2, S0
	    djnz R3, S1
	ret

init:	setb EA		;globale Freigabe
	setb ET0	;Timer 0 Frequenz
	setb ET1	;Timer 1 Dauer
	mov TMOD, #00010001b	;2 16 Bit Timer
	setb IT0	;fallende Taktflanke
	setb EX0	;lokale Freigabe Externer Interrupt 0
	mov P3, #0	;P3.2 fuer Interrupt
	mov P0, #0	;Ausgabe
	mov R0, #0	;Taktzaehler
	mov R1, #0	;Notenzaehler
	mov R2, #0	;Pause
	mov R3, #0	;Pause

haupt:	sjmp haupt	;Endlosprogramm

getNote:	mov dptr, #freqLow
		mov A, R1
		movc A, @A+dptr
		mov TL0, A
		mov dptr, #freqHigh
		mov A, R1
		movc A, @A+dptr
		mov TH0, A
		ret

getTime:	mov dptr, #time
		mov A, R1
		movc A, @A+dptr
		mov R0, A
		ret

freqHigh: db 0FBh, 0FBh, 0FBh, 0FAh, 0FBh, 0FBh, 0FAh, 0FBh, 0FBh, 0FDh, 0FDh, 0FDh, 0FDh, 0FBh, 0FBh, 0FAh
freqLow:  db 90h, 90h, 90h, 68h, 0E9h, 90h, 68h, 0E9h, 90h, 0Ah, 0Ah, 0Ah, 34h, 0E9h, 4Ch, 68h, 0E9h, 4Ch
time:	  db 20, 20, 20, 4, 1, 20, 4, 1, 40, 20, 20, 20, 4, 1, 20, 4, 1, 40

end