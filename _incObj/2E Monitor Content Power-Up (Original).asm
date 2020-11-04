; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------
Pow_ChkEggman:
		cmpi.b	#1,d0																; does monitor contain Eggman?
		bne.s	Pow_ChkSonic

	if FeatureRestoreMonitorEggman=0
		rts																					; Eggman monitor does nothing
	else
		bra		Spik_Hurt 														; Eggman monitor hits Sonic
	endc
; ===========================================================================
Pow_ChkSonic:
		cmpi.b	#2,d0																; does monitor contain Sonic?
		bne.s	Pow_ChkShoes

	ExtraLife:
		addq.b	#1,(v_lives).w											; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w 									; update the lives counter
		music	bgm_ExtraLife,1,0,0										; play extra life music
; ===========================================================================
Pow_ChkShoes:
		cmpi.b	#3,d0																; does monitor contain speed shoes?
		bne.s	Pow_ChkShield

Pow_ShoesActivate:
		move.b	#1,(v_shoes).w											; Set Sonic Super Speed Flag
		move.w	#$4B0,(v_player+$34).w							; time limit for the power-up
		move.w	#$C00,(v_sonspeedmax).w 						; change Sonic's top speed
		move.w	#$18,(v_sonspeedacc).w							; change Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w							; change Sonic's deceleration
		music	bgm_Speedup,1,0,0											; Speed	up the music
; ===========================================================================
Pow_ChkShield:
		cmpi.b	#4,d0																; does monitor contain a shield?
		bne.s	Pow_ChkInvinc

		move.b	#1,(v_shield).w											; give Sonic a shield
		move.b	#id_ShieldItem,(v_objspace+$180).w 	; load shield object ($38)
		music	sfx_Shield,1,0,0											; play shield sound
; ===========================================================================
Pow_ChkInvinc:
		cmpi.b	#5,d0																; does monitor contain invincibility?
		bne.s Pow_ChkRings													; if not, branch to S Monitor Code

Pow_InvincibleActivate:
		move.b	#1,(v_invinc).w										 	; make Sonic invincible
		move.w	#$4B0,(v_player+$32).w 						 	; time limit for the power-up
		
		move.b	#id_ShieldItem,(v_objspace+$200).w 	; load stars object ($3801)
		move.b	#1,(v_objspace+$200+obAnim).w
		move.b	#id_ShieldItem,(v_objspace+$240).w 	; load stars object ($3802)
		move.b	#2,(v_objspace+$240+obAnim).w
		move.b	#id_ShieldItem,(v_objspace+$280).w 	; load stars object ($3803)
		move.b	#3,(v_objspace+$280+obAnim).w
		move.b	#id_ShieldItem,(v_objspace+$2C0).w 	; load stars object ($3804)
		move.b	#4,(v_objspace+$2C0+obAnim).w

		tst.b	(f_lockscreen).w 											; is boss mode on?
		bne.w	Pow_NoMusic													  ; if yes, branch

	if Revision>0
		cmpi.w	#$C,(v_air).w
		bls.w	Pow_NoMusic
	endc

		music	bgm_Invincible,1,0,0

Pow_NoMusic:
		rts
; ===========================================================================
Pow_ChkRings:
		cmpi.b	#6,d0																; does monitor contain 10 rings?
		bne.s	Pow_ChkS

		addi.w	#10,(v_rings).w											; add 10 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w 										; update the ring counter
		cmpi.w	#100,(v_rings).w 										; check if you have 100 rings
		bcs.s	Pow_RingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w 										; check if you have 200 rings
		bcs.s	Pow_RingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife

	Pow_RingSound:
		music	sfx_Ring,1,0,0												; play ring sound
; ===========================================================================
Pow_ChkS:
		cmpi.b	#7,d0																; does monitor contain 'S'?
		bne.s	Pow_ChkGoggles												; if not, branch to Goggle code
	if FeatureRestoreMonitorSuper=0
		nop
	else
		bsr.w Pow_ShoesActivate
		jsr	(PlaySound_Special).l										; Ensure Music is Sped Up
		jmp Pow_InvincibleActivate
	endc
; ===========================================================================
Pow_ChkGoggles:
	if FeatureRestoreMonitorScubaGear>0
		cmpi.b	#8,d0															; does monitor contain Goggles?
		bne.s	Pow_ChkEnd													; if not, branch to Pow_ChkEnd
		move.b	#1,(f_gogglecheck).w 							; move 1 to the goggle check
	endc
; ===========================================================================
Pow_ChkEnd:
		rts																				; 'S' and goggles monitors do nothing
