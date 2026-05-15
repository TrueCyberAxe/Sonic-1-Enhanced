; ---------------------------------------------------------------------------
; Subroutine to play music for LZ/SBZ3 after a countdown
; ---------------------------------------------------------------------------

ResumeMusic:
		cmpi.w	#12,(v_air).w	; more than 12 seconds of air left?
		bhi.s	.over12		; if yes, branch
		QueueMusic	#bgm_LZ	; play LZ music
		cmpi.w	#id_LZ_act4,(v_zone).w ; check if level is SBZ3 (LZ4)
		bne.s	.notsbz
		QueueMusic	#bgm_SBZ	; play SBZ music

.notsbz:
	if Revision<>0
		tst.b	(v_invinc).w ; is Sonic invincible?
		beq.s	.notinvinc ; if not, branch
		QueueMusic	#bgm_Invincible
.notinvinc:
		tst.b	(f_lockscreen).w ; is Sonic at a boss?
		beq.s	.playselected ; if not, branch
		QueueMusic	#bgm_Boss
.playselected:
	endif

		PlayMusic	d0

.over12:
		move.w	#30,(v_air).w	; reset air to 30 seconds
		clr.b	(v_sonicbubbles+objoff_32).w
		rts
; End of function ResumeMusic
