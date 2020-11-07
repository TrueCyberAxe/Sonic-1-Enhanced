; ---------------------------------------------------------------------------
; Subroutine controlling Sonic's jump height/duration
; ---------------------------------------------------------------------------

Sonic_JumpHeight:
	if FeatureBetaVictoryAnimation>0
		; This cancels in air roll when hitting the spinning sign at the end
		; Also has a cool "bug" that causes the leap during the GHZ high jump
		tst.b (f_victory).w 							; Has the victory animation flag been set?
		bne.s AirVictory 									; If so, branch
	endc

		tst.b	$3C(a0)
		beq.s	loc_134C4
		move.w	#-$400,d1
		btst	#6,obStatus(a0)
		beq.s	loc_134AE
		move.w	#-$200,d1

loc_134AE:
		cmp.w	obVelY(a0),d1
		ble.s	locret_134C2
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		bne.s	locret_134C2	; if yes, branch
		move.w	d1,obVelY(a0)

locret_134C2:
		rts

	if FeatureAirRoll>0
Sonic_AirRoll:
    move.b (v_jpadpress2).w,d0 				; Move v_jpadpress2 to d0
    andi.b #btnABC,d0 								; Has A/B/C been pressed?
    bne.w AirRoll_Checks 							; If so, branch.
		rts

AirRoll_Checks:
	if FeatureAirRoll=1
		cmpi.b #id_Spring,obAnim(a0) 			; Is Spring Jump Active?
		beq.s locret_134D2 								; If so, branch.
	endc

    cmpi.b #id_roll,obAnim(a0) 				; Is animation 2 active?
    bne.s AirRoll_Set 								; If not, branch.

    btst #1,obStatus(a0) 							; Is bit 1 in the status bitfield enabled?
    bne.s AirRoll_Set 								; If so, branch.
    rts

AirRoll_Set:
    move.b #id_roll,obAnim(a0) 				; Set Sonic's animation to the rolling animation.
	endc ; if FeatureAirRoll>0

loc_134C4:
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	locret_134D2
		move.w	#-$FC0,obVelY(a0)

AirVictory:
	if FeatureBetaVictoryAnimation>0
		cmpi.b #id_roll,obAnim(a0) 				; Is animation 2 active?
		bne.s locret_134D2 								; If not, branch.

		move.b #id_leap2,obAnim(a0)
	endc

locret_134D2:
		rts
; End of function Sonic_JumpHeight
