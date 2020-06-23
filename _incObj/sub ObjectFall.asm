; ---------------------------------------------------------------------------
; Subroutine to	make an	object fall downwards, increasingly fast
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectFall:
	if TweakFasterObjectMove=0
		move.l	obX(a0),d2
		move.l	obY(a0),d3
	endc
		move.w	obVelX(a0),d0
		ext.l	d0
	if TweakFasterObjectMove=0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a0),d0
	else
		lsl.l	#8,d0
		add.l	d0,obX(a0)
		move.w	obVelY(a0),d0
	endc
		addi.w	#$38,obVelY(a0)	; increase vertical speed
		ext.l	d0
	if TweakFasterObjectMove=0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,obX(a0)
		move.l	d3,obY(a0)
	else
		lsl.l	#8,d0
		add.l	d0,obY(a0)
	endc
		rts

; End of function ObjectFall
