; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LevelBound:
		move.l	obX(a0),d1
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bhi.s	@sides		; if yes, branch
		move.w	(v_limitright2).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	@screenlocked
		addi.w	#$40,d0

	@screenlocked:
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bls.s	@sides		; if yes, branch

	@chkbottom: ; KoH: Recoded to suit my own preference. Allow Sonic to outrun camera, ALSO prevent sudden deaths. (REV C Edit)
		move.w	(v_limitbtm2).w,d0				; current bottom boundary=d0
	if BugFixTooFastToLive>0
		cmp.w   (v_limitbtm1).w,d0 				; is the intended bottom boundary lower than the current one?
		bcc.s   @notlower          				; if not, branch
		move.w  (v_limitbtm1).w,d0 				; intended bottom boundary=d0
	@notlower:
	endc
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0									; has Sonic touched the	bottom boundary?
		blt.s	@bottom											; if yes, branch
		rts
; ===========================================================================

@bottom:
	if FeatureSpindash>0
		move.w (v_limitbtm1).w,d0
		move.w (v_limitbtm2).w,d1
		cmp.w d0,d1 								; screen still scrolling down?
		blt.s @dontkill							; if so, don't kill Sonic
	endc
	if BugFixFallOffFinalZone>0
		cmpi.w  #(id_SBZ<<8)+2,(v_zone).w ; is level FZ ?
		beq.s   @next
	endc
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w ; is level SBZ2 ?
		bne.w	KillSonic	; if not, kill Sonic
		cmpi.w	#$2000,(v_player+obX).w
		bcs.w	KillSonic
		clr.b	(v_lastlamp).w	; clear	lamppost counter
		move.w	#1,(f_restart).w ; restart the level
		move.w	#(id_LZ<<8)+3,(v_zone).w ; set level to SBZ3 (LZ4)
	if BugFixFallOffFinalZone>0 || FeatureSpindash>0
	@dontkill:
		rts
	endc

	if BugFixFallOffFinalZone>0
	@next:
		move.b  #id_Ending,(v_gamemode).w
		rts
	endc


; ===========================================================================

@sides:
		move.w	d0,obX(a0)
		move.w	#0,obX+2(a0)
		move.w	#0,obVelX(a0)	; stop Sonic moving
		move.w	#0,obInertia(a0)
		bra.s	@chkbottom
; End of function Sonic_LevelBound
