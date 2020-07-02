; ---------------------------------------------------------------------------
; Object 25 - rings
; ---------------------------------------------------------------------------

Rings:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Ring_Index(pc,d0.w),d1
		jmp	Ring_Index(pc,d1.w)

; ===========================================================================
Ring_Index:
ptr_Ring_Main:		dc.w Ring_Main-Ring_Index
ptr_Ring_Animate:	dc.w Ring_Animate-Ring_Index
ptr_Ring_Collect:	dc.w Ring_Collect-Ring_Index
ptr_Ring_Sparkle:	dc.w Ring_Sparkle-Ring_Index
ptr_Ring_Delete:	dc.w Ring_Delete-Ring_Index

id_Ring_Main:		equ ptr_Ring_Main-Ring_Index	; 0
id_Ring_Animate:		equ ptr_Ring_Animate-Ring_Index	; 2
id_Ring_Collect:		equ ptr_Ring_Collect-Ring_Index	; 4
id_Ring_Sparkle:		equ ptr_Ring_Sparkle-Ring_Index	; 6
id_Ring_Delete:		equ ptr_Ring_Delete-Ring_Index	; 8
; ---------------------------------------------------------------------------
; Distances between rings (format: horizontal, vertical)
; ---------------------------------------------------------------------------
Ring_PosData:	dc.b $10, 0										; horizontal tight
		dc.b $18, 0															; horizontal normal
		dc.b $20, 0															; horizontal wide
		dc.b 0,	$10															; vertical tight
		dc.b 0,	$18															; vertical normal
		dc.b 0,	$20															; vertical wide
		dc.b $10, $10														; diagonal
		dc.b $18, $18
		dc.b $20, $20
		dc.b $F0, $10
		dc.b $E8, $18
		dc.b $E0, $20
		dc.b $10, 8
		dc.b $18, $10
		dc.b $F0, 8
		dc.b $E8, $10
; ===========================================================================

Ring_Main:	; Routine 0
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		lea	2(a2,d0.w),a2
		move.b	(a2),d4
		move.b	obSubtype(a0),d1
		move.b	d1,d0
		andi.w	#7,d1
		cmpi.w	#7,d1
		bne.s	loc_9B80
		moveq	#6,d1

	loc_9B80:
		swap	d1
		move.w	#0,d1
		lsr.b	#4,d0
		add.w	d0,d0
		move.b	Ring_PosData(pc,d0.w),d5 				; load ring spacing data
		ext.w	d5
		move.b	Ring_PosData+1(pc,d0.w),d6
		ext.w	d6
		movea.l	a0,a1
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		lsr.b	#1,d4
		bcs.s	loc_9C02
		bclr	#7,(a2)
		bra.s	loc_9BBA
; ===========================================================================

Ring_MakeRings:
		swap	d1
		lsr.b	#1,d4
		bcs.s	loc_9C02
		bclr	#7,(a2)
		bsr.w	FindFreeObj
		bne.s	loc_9C0E

loc_9BBA:
		move.b	#id_Rings,0(a1)									; load ring object
		addq.b	#2,obRoutine(a1)
		move.w	d2,obX(a1)											; set x-axis position based on d2
		move.w	obX(a0),$32(a1)
		move.w	d3,obY(a1)											; set y-axis position based on d3
		move.l	#Map_Ring,obMap(a1)
		move.w	#$27B2,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#2,obPriority(a1)
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
		move.b	obRespawnNo(a0),obRespawnNo(a1)
		move.b	d1,$34(a1)

loc_9C02:
		addq.w	#1,d1
		add.w	d5,d2															; add ring spacing value to d2
		add.w	d6,d3															; add ring spacing value to d3
		swap	d1
		dbf	d1,Ring_MakeRings 									; repeat for	number of rings

loc_9C0E:
		btst	#0,(a2)
		bne.w	DeleteObject

Ring_Animate:	; Routine 2
		move.b	(v_ani1_frame).w,obFrame(a0) 		; set frame
	if BugFixRenderBeforeInit=0 ; Bug 1
		bsr.w	DisplaySprite
	endc
		out_of_range.s	Ring_Delete,$32(a0)
	if BugFixRenderBeforeInit=0 ; Bug 1
		rts
	else
		bra.w	DisplaySprite
	endc
; ===========================================================================

Ring_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		move.b	#1,obPriority(a0)
		bsr.w	CollectRing
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		move.b	$34(a0),d1
		bset	d1,2(a2,d0.w)

Ring_Sparkle:	; Routine 6
		lea	(Ani_Ring).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Ring_Delete:	; Routine 8
		bra.w	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CollectRing:
		addq.w	#1,(v_rings).w									; add 1 to rings
		ori.b	#1,(f_ringcount).w 								; update the rings counter
		move.w	#sfx_Ring,d0										; play ring sound
		cmpi.w	#100,(v_rings).w 								; do you have < 100 rings?
		bcs.s	@playsnd													; if yes, branch
		bset	#1,(v_lifecount).w 								; update lives counter
		beq.s	@got100
		cmpi.w	#200,(v_rings).w 								; do you have < 200 rings?
		bcs.s	@playsnd													; if yes, branch
		bset	#2,(v_lifecount).w 								; update lives counter
		bne.s	@playsnd

	@got100:
		addq.b	#1,(v_lives).w									; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w 							; update the lives counter
		move.w	#bgm_ExtraLife,d0 							; play extra life music

	@playsnd:
		jmp	(PlaySound_Special).l
; End of function CollectRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic	when he's hit
; ---------------------------------------------------------------------------

RingLoss:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	RLoss_Index(pc,d0.w),d1
		jmp	RLoss_Index(pc,d1.w)
; ===========================================================================
RLoss_Index:	dc.w RLoss_Count-RLoss_Index
		dc.w RLoss_Bounce-RLoss_Index
		dc.w RLoss_Collect-RLoss_Index
		dc.w RLoss_Sparkle-RLoss_Index
		dc.w RLoss_Delete-RLoss_Index
; ===========================================================================

RLoss_Count:	; Routine 0
		movea.l	a0,a1
		moveq	#0,d5
		move.w	(v_rings).w,d5									; check number of rings you have

	loc_120A2:
	if TweakFasterRingScatter>0
		if TweakFasterUnderwaterRings>0
			lea (v_objspace).w,a2    							; a2=character
			btst #6,status(a2)       							; is Sonic underwater?
			bne.s @underwater_Scatter							; if so, branch
		endc ; if TweakFasterUnderwaterRings>0
		lea SpillRingData32,a3    							; load the address of the array in a3
	endc ; if TweakFasterRingScatter>0
		moveq	#max_ring_scatter,d0							; scatter a max of 32 rings

	if TweakFasterUnderwaterRings>0
		bra.s @decrease_max
	@underwater_Scatter:
		lea SpillRingData16,a3									; load the UNDERWATER address of the array in a3
		moveq   #(max_ring_scatter/2),d0        ; lose a max of half the rings when underwater
	@decrease_max:
	endc ; if TweakFasterUnderwaterRings>0

		cmp.w	d0,d5															; do you have 32 or more?
		bcs.s	@belowmax													; if not, branch
		move.w	d0,d5														; if yes, set d5 to 32

	@belowmax: ; loc_120AA
		subq.w	#1,d5
	if TweakFasterRingScatter=0
		move.w	#$288,d4
	endc ; if TweakFasterRingScatter=0
	; if TweakFasterUnderwaterRings>0 					; Needed to display code in ram to create tables
	; 	lea (v_ngfx_buffer).l,a4    						; Load v_ngfx_buffer to a4
	; endc
		bra.s	@makerings
; ===========================================================================

	@loop:
		bsr.w	FindFreeObj
		bne.w	@resetcounter

@makerings: ; loc_120BA
		move.b	#id_RingLoss,0(a1) 							; load bouncing ring object
		addq.b	#2,obRoutine(a1)
		move.b	#8,obHeight(a1)
		move.b	#8,obWidth(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#$27B2,obGfx(a1)
		move.b	#4,obRender(a1)
	if TweakFasterRingScatter=0
		move.b	#3,obPriority(a1)
	endc
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
		move.b	#-1,(v_ani3_time).w
	if TweakFasterRingScatter=0
		tst.w	d4
		bmi.s	@loc_9D62
		move.w	d4,d0
		bsr.w	CalcSine
		move.w	d4,d2
		lsr.w	#8,d2

		if TweakFixUnderwaterRingPhysics>0
			tst.b	(f_water).w												; Does the level have water?
			beq.s	@skiphalvingvel										; If not, branch and skip underwater checks
			move.w	(v_waterpos1).w,d6							; Move water level to d6
			cmp.w	$C(a0),d6													; Is the ring object underneath the water level?
			bgt.s	@skiphalvingvel										; If not, branch and skip underwater commands
			asr.w	d0																; Half d0. Makes the ring's x_vel bounce to the left/right slower
			asr.w	d1																; Half d1. Makes the ring's y_vel bounce up/down slower
		@skiphalvingvel:
		endc ; if TweakFixUnderwaterRingPhysics>0

		asl.w	d2,d0
		asl.w	d2,d1
		move.w	d0,d2
		move.w	d1,d3
		addi.b	#$10,d4
		bcc.s	@loc_9D62
		subi.w	#$80,d4
		bcc.s	@loc_9D62
		move.w	#$288,d4

	@loc_9D62: ; loc_12132
		move.w	d2,obVelX(a1)
		move.w	d3,obVelY(a1)
		neg.w	d2
		neg.w	d4
	; if TweakFasterRingScatter>0 							; Needed to display code in ram to create tables
	; 	move.w  d2,(a4)+    										; Move d2 to a4 then increment a4 by a word
	; 	move.w  d3,(a4)+    										; Move d3 to a4 then increment a4 by a word
	; endc
	else
		move.w  (a3)+,x_vel(a1)     						; move the data contained in the array to the x velocity and increment the address in a3
		move.w  (a3)+,y_vel(a1)     						; move the data contained in the array to the y velocity and increment the address in a3
	endc ; if TweakFasterRingScatter=0
		dbf	d5,@loop														; repeat for number of rings (max 31)

@resetcounter:
		move.w	#0,(v_rings).w									; reset number of rings to zero
		move.b	#$80,(f_ringcount).w 						; update ring counter
		move.b	#0,(v_lifecount).w
	if BugFixScatteredRingsTimer>0
		moveq   #-1,d0                  				; Move #-1 to d0
		move.b  d0,obDelayAni(a0)       				; Move d0 to new timer
		move.b  d0,(v_ani3_time).w      				; Move d0 to old timer (for animated purposes)
	endc
		sfx	sfx_RingLoss,0,0,0									; play ring loss sound

RLoss_Bounce:	; Routine 2
		move.b	(v_ani3_frame).w,obFrame(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)

	if TweakFixUnderwaterRingPhysics>0
		tst.b	(f_water).w												; Does the level have water?
		beq.s	@skipbounceslow										; If not, branch and skip underwater checks
		move.w	(v_waterpos1).w,d6							; Move water level to d6
		cmp.w	obY(a0),d6												; Is the ring object underneath the water level?
		bgt.s	@skipbounceslow										; If not, branch and skip underwater commands
		subi.w	#$E,obVelY(a0)									; Reduce gravity by $E ($18-$E=$A), giving the underwater effect
	@skipbounceslow:
	endc ; if TweakFixUnderwaterRingPhysics>0

		bmi.s	@chkdel
		move.b	(v_vbla_byte).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	@chkdel
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	@chkdel
		add.w	d1,obY(a0)
		move.w	obVelY(a0),d0
		asr.w	#2,d0
		sub.w	d0,obVelY(a0)
		neg.w	obVelY(a0)

	@chkdel: ; loc_121B8
	if BugFixScatteredRingsTimer=0
		tst.b	(v_ani3_time).w
		beq.s	RLoss_Delete
	else
		subq.b  #1,obDelayAni(a0)       ; Subtract 1
		beq.w   DeleteObject            ; If 0, delete
	endc
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0								; has object moved below level boundary?
		bcs.s	RLoss_Delete							; if yes, branch
	if BugFixDeleteScatteredRings>0   ; @TODO Check this value below is correct
		cmpi.w	#$FF00,(v_limittop2).w	; is vertical wrapping enabled?
	endc

	if TweakFasterRingScatter=0
		bra.w	DisplaySprite
	else
		lea	(v_spritequeue+$180).w,a1
		cmpi.w	#$7E,(a1)								; is this part of the queue full?
		bcc.s	@rtn											; if yes, branch
		addq.w	#2,(a1)									; increment sprite count
		adda.w	(a1),a1									; jump to empty position
		move.w	a0,(a1)									; insert RAM address for object
	@rtn:
		rts
	endc ; if TweakFasterRingScatter=0
; ===========================================================================

RLoss_Collect:	; Routine 4 ; Obj_37_sub_4
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
	if TweakFasterRingScatter=0
		move.b	#1,obPriority(a0)
	endc ; if TweakFasterRingScatter=0
		bsr.w	CollectRing

RLoss_Sparkle:	; Routine 6 ; Obj_37_sub_6
		lea	(Ani_Ring).l,a1
		bsr.w	AnimateSprite
	if TweakFasterRingScatter=0
		bra.w	DisplaySprite
	else
		lea	(v_spritequeue+$80).w,a1
		cmpi.w	#$7E,(a1)								; is this part of the queue full?
		bcc.s	@rtn											; if yes, branch
		addq.w	#2,(a1)									; increment sprite count
		adda.w	(a1),a1									; jump to empty position
		move.w	a0,(a1)									; insert RAM address for object
	@rtn:
		rts
	endc ; if TweakFasterRingScatter=0
; ===========================================================================

RLoss_Delete:	; Routine 8
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Ring Spawn Array
; ---------------------------------------------------------------------------
	if TweakFasterRingScatter>0
SpillRingData32:
	  dc.w    $00C4,$FC14, $FF3C,$FC14, $0238,$FCB0, $FDC8,$FCB0 ; 4
		dc.w    $0350,$FDC8, $FCB0,$FDC8, $03EC,$FF3C, $FC14,$FF3C ; 8
		dc.w    $03EC,$00C4, $FC14,$00C4, $0350,$0238, $FCB0,$0238 ; 12
		dc.w    $0238,$0350, $FDC8,$0350, $00C4,$03EC, $FF3C,$03EC ; 16
		even
	endc ; if TweakFasterRingScatter>0

	if TweakFasterUnderwaterRings>0
SpillRingData16:
		dc.w    $0064,$FE08, $FF9C,$FC08, $011C,$FE58, $FEE4,$FE58 ; 4
		dc.w    $01A8,$FEE4, $FE58,$FEE4, $01F8,$FF9C, $FE08,$FF9C ; 8
		dc.w    $01F8,$0060, $FE08,$0060, $01A8,$011C, $FE58,$011C ; 12
		dc.w    $011C,$01A8, $FEE4,$01A8, $0064,$01F4, $FF9C,$01F4 ; 16
		even
	endc ; if TweakFasterUnderwaterRings>0
