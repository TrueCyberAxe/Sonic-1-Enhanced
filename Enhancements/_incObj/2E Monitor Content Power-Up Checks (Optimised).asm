; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------
Pow_ChkInvinc:
		cmpi.b	#5,d0					; does monitor contain invincibility?
		bne.s	Pow_ChkS				; if not, branch to S Monitor Code

Pow_InvincibleActivate:
		move.b	#1,(v_invinc).w				; make Sonic invincible
		move.w	#$4B0,(v_player+invtime).w		; time limit for the power-up
		move.b	#id_ShieldItem,(v_starsobj1).w		; load stars object ($3801)
		move.b	#1,(v_starsobj1+obAnim).w
		move.b	#id_ShieldItem,(v_starsobj2).w		; load stars object ($3802)
		move.b	#2,(v_starsobj2+obAnim).w
		move.b	#id_ShieldItem,(v_starsobj3).w		; load stars object ($3803)
		move.b	#3,(v_starsobj3+obAnim).w
		move.b	#id_ShieldItem,(v_starsobj4).w		; load stars object ($3804)
		move.b	#4,(v_starsobj4+obAnim).w
		tst.b	(f_lockscreen).w			; is boss mode on?
		bne.s	Pow_NoMusic				; if yes, branch
	if Revision<>0
		cmpi.w	#$C,(v_air).w
		bls.s	Pow_NoMusic
	endif
		music	#bgm_Invincible,snd_jmp   		; play invincibility music

; ===========================================================================

Pow_NoMusic:
		rts
    
; ===========================================================================

Pow_ChkS:
		cmpi.b	#7,d0					; does monitor contain 'S'?
		bne.w	Pow_ChkEggman				; if not, branch to Eggman Monitor Code
    
	if FeatureRestoreMonitorSuper
		; The S monitor combines speed shoes and invincibility.
		bsr.w	Pow_ShoesActivate
		play_queued_sfx					; ensure music is sped up
		jmp	Pow_InvincibleActivate
	else
		nop
	endif ; if FeatureRestoreMonitorSuper
  
; ===========================================================================

Pow_ChkEggman:
		cmpi.b	#1,d0					; does monitor contain Eggman?
		bne.s	Pow_ChkSonic				; if not, branch to Sonic Monitor Code

	if (FeatureRestoreMonitorEggman)|(FixBugs)
		; Fix the Eggman monitor
		; https://info.sonicretro.org/SCHG_How-to:Have_a_functional_Eggman_monitor_in_Sonic_1
		move.w	obX(a0),spik_origX(a0)			; needed to display the icon properly
		bra	Spik_Hurt				; Eggman monitor hits Sonic
	else
		rts						; Eggman monitor does nothing
	endif
  
; ===========================================================================

Pow_ChkSonic:
		cmpi.b	#2,d0					; does monitor contain Sonic?
		bne.s	Pow_ChkShoes

ExtraLife:
		addq.b	#1,(v_lives).w				; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w			; update the lives counter
		music	#bgm_ExtraLife,snd_jmp			; Speed up the music

; ===========================================================================

Pow_ChkShoes:
		cmpi.b	#3,d0					; does monitor contain speed shoes?
		bne.s	Pow_ChkShield				; if not, branch to Shield Monitor Code

Pow_ShoesActivate:
		move.b	#1,(v_shoes).w				; speed up the BG music
		move.w	#$4B0,(v_player+shoetime).w		; time limit for the power-up
		move.w	#$C00,(v_sonspeedmax).w			; change Sonic's top speed
		move.w	#$18,(v_sonspeedacc).w			; change Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w			; change Sonic's deceleration
		music	#bgm_Speedup,snd_jmp			; Speed up the music

; ===========================================================================

Pow_ChkShield:
		cmpi.b	#4,d0					; does monitor contain a shield?
		bne.s	Pow_ChkRings				; if not, branch to Ring Monitor Code

		move.b	#1,(v_shield).w				; give Sonic a shield
		move.b	#id_ShieldItem,(v_shieldobj).w		; load shield object ($38)
		sfx	#sfx_Shield,snd_jmp			; play shield sound		@NOTE was using music queue?

; ===========================================================================

Pow_ChkRings:
		cmpi.b	#6,d0					; does monitor contain 10 rings?
		bne.s	Pow_ChkGoggles				; if not, branch to Goggle Monitor Code

		addi.w	#10,(v_rings).w				; add 10 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w			; update the ring counter
		cmpi.w	#100,(v_rings).w			; check if you have 100 rings
		blo.s	Pow_RingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w			; check if you have 200 rings
		blo.s	Pow_RingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife

Pow_RingSound:
		sfx	#sfx_Ring,snd_jmp			; play ring sound		@NOTE was using music queue?

; ===========================================================================

Pow_ChkGoggles:
	if FeatureRestoreMonitorScubaGear
		cmpi.b	#8,d0					; does monitor contain Goggles?
		bne.s	Pow_ChkEnd				; if not, branch to Pow_ChkEnd
		move.b	#1,(v_goggles).w			; mark goggles as active
		lea	(v_gogglesobj).w,a1			; load the fixed goggles overlay object
		clr.b	obRoutine(a1)				; initialize it from the start
		_move.b	#id_ShieldItem,obID(a1)		; load shield object handler
		move.b	#5,obAnim(a1)				; use goggles overlay mode
	endif
  
; ===========================================================================

Pow_ChkEnd:
		rts																				  ; 'S' and goggles monitors do nothing
