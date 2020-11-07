; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------
Sonic_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0										; is A, B or C pressed?
		beq.w	Jump_End												; if not, branch

		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48

		cmpi.w	#6,d1
		blt.w	Jump_End

		move.w	#$680,d2
		btst	#6,obStatus(a0)
		beq.s	loc_1341C
		move.w	#$380,d2

loc_1341C:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)										; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)										; make Sonic jump
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,$3C(a0)
		clr.b	$38(a0)
		sfx	sfx_Jump,0,0,0										; play jumping sound
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)

	if FeatureBetaVictoryAnimation>0
    tst.b   (f_victory).w 								; Has the victory animation flag been set?
    bne.s   Jump_Victory									; If yes, branch
	endc ; if FeatureBetaVictoryAnimation>0

		btst	#2,obStatus(a0)									; Is Sonic Rolling?
		bne.s	Jump_Rolling										; If yes, branch

Jump_Regular:
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)

		move.b	#id_Roll,obAnim(a0) 					; use "jumping" animation

		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)

Jump_End: ; locret_1348E
		rts

; ===========================================================================
Jump_Victory:
	if FeatureBetaVictoryAnimation>0
		move.b  #id_Leap2,obAnim(a0) 					; Play the victory animation
		rts
	endc ; if FeatureBetaVictoryAnimation>0

; ===========================================================================
Jump_Rolling: ; loc_13490
		bset	#4,obStatus(a0)
		rts

; End of function Sonic_Jump
