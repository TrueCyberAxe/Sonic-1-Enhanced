;---------------------------------------------------------------------------
;Subroutine to make Sonic perform a Peelout
;---------------------------------------------------------------------------

Sonic_Peelout:
		btst	#1,f_superpeelout(a0)
		bne.s	Sonic_DashLaunch

		cmpi.b	#id_LookUp,obAnim(a0)			; check to see if you're looking up
		bne.s	.return

		bclr	#bitPushing,obStatus(a0)		; clear pushing flag

		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	.return

		move.b	#id_Run,obAnim(a0)

		move.w	#$00,v_charging(a0)
		; move.w	#$82,d0
		sfx	#sfx_Roll,snd_jsr			; play peelout charge sound
		addq.l	#4,sp				; skip Sonic_Jump when returning to Obj01_MdNormal

		bset	#1,f_superpeelout(a0)
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos

.return:
		rts

Sonic_DashLaunch:
		move.b	#id_PeeloutCharge,obAnim(a0)
	if FeatureSuperPeelout>1
		move.w	#$0F00,obInertia(a0)			; Set sonic's speed to Sonic CD Peelout Speed
	else
		move.w	#$A00,obInertia(a0)			; Set Sonic's speed to Maximum Run Speed
		; move.w	#$760,obInertia(a0)		; Set Sonic's speed to Maximum Run Speed
	endif

		move.b	(v_jpadhold2).w,d0
		btst	#bitUp,d0
		bne.w	Sonic_DashCharge

		bclr	#1,f_superpeelout(a0)			; stop Dashing
		cmpi.b	#obTimeFrame,v_charging(a0)		; have we been charging long enough?
		move.b	#id_Dash,obAnim(a0)			; launches here (peelout sprites)

		move.w	#$01,obVelX(a0)			; force X speed to nonzero for camera lag's benefit

		move.w	obInertia(a0),d0
		subi.w	#$800,d0
		add.w	d0,d0
		andi.w	#$1F00,d0
		neg.w	d0
		addi.w	#$2000,d0
		;move.w	d0,(v_cameralag).w
		btst	#bitHorizontal,obStatus(a0)
		beq.s	.dontflip
		neg.w	obInertia(a0)

.dontflip:
		;bset	#2,obStatus(a0)				; apparently with this commented out, it won't cause extreme camera lag. weird that it's even here.
		bclr	#bitObjectFlag,obStatus(a0)
		move.w	#$D3,d0
		;play_queued_music snd_jsr
		move.w	#$D4,d0
		;play_queued_music snd_jsr
		bra.w	Sonic_DashResetScr
; ---------------------------------------------------------------------------
Sonic_DashCharge:						; If still charging the dash...
		cmpi.b	#obTimeFrame,v_charging(a0)
		beq.s	Sonic_DashResetScr
		addi.b	#$01,v_charging(a0)
		jmp	Sonic_DashResetScr

Sonic_Dash_Stop_Sound:
		move.w	#$D3,d0
		;play_queued_music snd_jsr

Sonic_DashResetScr:
		addq.l	#4,sp					; skip Sonic_Jump when returning to Obj01_MdNormal
		cmpi.w	#$60,(v_lookshift).w
		beq.s	.finish
		bcc.s	.skip
		addq.w	#4,(v_lookshift).w

.skip:
		subq.w	#2,(v_lookshift).w

.finish:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		rts
