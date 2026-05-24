; ---------------------------------------------------------------------------
; Object 25 - rings
; ---------------------------------------------------------------------------

Rings:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Ring_Index(pc,d0.w),d1
		jmp	Ring_Index(pc,d1.w)

; ===========================================================================
Ring_Index:	dc.w Ring_Main-Ring_Index
		dc.w Ring_Animate-Ring_Index
		dc.w Ring_Collect-Ring_Index
		dc.w Ring_Sparkle-Ring_Index
		dc.w Ring_Delete-Ring_Index
; ===========================================================================

; ---------------------------------------------------------------------------
; Distances between rings (format: horizontal, vertical)
; ---------------------------------------------------------------------------
Ring_PosData:	dc.b $10, 0		; horizontal tight
		dc.b $18, 0				; horizontal normal
		dc.b $20, 0				; horizontal wide
		dc.b 0,	$10				; vertical tight
		dc.b 0,	$18				; vertical normal
		dc.b 0,	$20				; vertical wide
		dc.b $10, $10			; diagonal
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
		move.b	Ring_PosData(pc,d0.w),d5 ; load ring spacing data
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
		_move.b	#id_Rings,obID(a1)	; load ring object
		addq.b	#2,obRoutine(a1)
		move.w	d2,obX(a1)	; set x-axis position based on d2
		move.w	obX(a0),objoff_32(a1)
		move.w	d3,obY(a1)	; set y-axis position based on d3
		move.l	#Map_Ring,obMap(a1)
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#2,obPriority(a1)
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
		move.b	obRespawnNo(a0),obRespawnNo(a1)
		move.b	d1,objoff_34(a1)

loc_9C02:
		addq.w	#1,d1
		add.w	d5,d2		; add ring spacing value to d2
		add.w	d6,d3		; add ring spacing value to d3
		swap	d1
		dbf	d1,Ring_MakeRings ; repeat for number of rings

loc_9C0E:
		btst	#0,(a2)
		bne.w	DeleteObject

Ring_Animate:	; Routine 2
		move.b	(v_ani1_frame).w,obFrame(a0) ; set frame
	if (FixBugRenderBeforeInit|FixBugs) ; Bug 1
		; Objects shouldn't call DisplaySprite and DeleteObject in
		; the same frame or else cause a null-pointer dereference.
		out_of_range.s	Ring_Delete,objoff_32(a0)
		bra.w	DisplaySprite
	else
		bsr.w	DisplaySprite
		out_of_range.s	Ring_Delete,objoff_32(a0)
		rts
	endif
; ===========================================================================

Ring_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		move.b	#1,obPriority(a0)
		bsr.w	CollectRing
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		move.b	objoff_34(a0),d1
		bset	d1,2(a2,d0.w)

Ring_Sparkle:	; Routine 6
		lea	(Ani_Ring).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Ring_Delete:	; Routine 8
		bra.w	DeleteObject

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add 1 ring, update ring HUD, and maybe add an extra life
; ---------------------------------------------------------------------------

CollectRing:
		addq.w	#1,(v_rings).w	; add 1 to rings
		ori.b	#1,(f_ringcount).w ; update the rings counter
		move.w	#sfx_Ring,d0	; play ring sound
		cmpi.w	#100,(v_rings).w ; do you have < 100 rings?
		blo.s	.playsnd	; if yes, branch
		bset	#1,(v_lifecount).w ; update lives counter
		beq.s	.got100
		cmpi.w	#200,(v_rings).w ; do you have < 200 rings?
		blo.s	.playsnd	; if yes, branch
		bset	#2,(v_lifecount).w ; update lives counter
		bne.s	.playsnd

.got100:
		addq.b	#1,(v_lives).w	; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w ; update the lives counter
		move.w	#bgm_ExtraLife,d0 ; play extra life music

.playsnd:
		play_queued_sfx	snd_jmp
; End of function CollectRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic when he's hit
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
	if TweakFasterRingScatter
		if TweakFasterUnderwaterRings
			lea (v_objspace).w,a2    					; a2=character
			btst #6,status(a2)       					; is Sonic underwater?
			bne.s .underwater_Scatter					; if so, branch
		endif ; if TweakFasterUnderwaterRings

		lea	SpillRingData32(pc),a3						; use normal fast scatter table
	endif ; if TweakFasterRingScatter
		moveq	#max_ring_scatter,d0					; scatter a max of 32 rings

	if (TweakFasterRingScatter)&(TweakFasterUnderwaterRings)
		bra.s	.continue_scatter

.underwater_Scatter:
		lea	SpillRingData16(pc),a3						; load the UNDERWATER address of the array in a3
		moveq	#(max_ring_scatter/2),d0       			; lose a max of half the rings when underwater

.continue_scatter:
	endif ; if (TweakFasterRingScatter)&(TweakFasterUnderwaterRings)

		cmp.w	d0,d5		; do you have 32 or more?
		blo.s	.belowmax	; if not, branch
		move.w	d0,d5		; if yes, set d5 to 32

; loc_120AA
.belowmax:
		subq.w	#1,d5

	if TweakFasterRingScatter=0
		move.w	#$288,d4
	endif ; if TweakFasterRingScatter=0

		bra.s	.makerings
; ===========================================================================

.loop:
		bsr.w	FindFreeObj
		bne.w	.resetcounter

.makerings:
		_move.b	#id_RingLoss,obID(a1) ; load bouncing ring object
		addq.b	#2,obRoutine(a1)
		move.b	#8,obHeight(a1)
		move.b	#8,obWidth(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a1)
		move.b	#4,obRender(a1)
	if TweakFasterRingScatter=0
		move.b	#3,obPriority(a1)
	endif
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
	if FixBugs=0
		; This resets the timer for all spilled rings,
		; even if they were already close to getting deleted
		; https://info.sonicretro.org/SCHG_How-to:Fix_Ring_Timers
		move.b	#-1,(v_ani3_time).w
	endif

	if TweakFasterRingScatter
		move.w	(a3)+,obVelX(a1)	; move the data contained in the array to the x velocity and increment the address in a3
		move.w	(a3)+,obVelY(a1)	; move the data contained in the array to the y velocity and increment the address in a3
	else
		tst.w	d4
		bmi.s	.loc_9D62
		move.w	d4,d0
		bsr.w	CalcSine
		move.w	d4,d2
		lsr.w	#8,d2

		if TweakFixUnderwaterRingPhysics
			tst.b	(f_water).w				; Does the level have water?
			beq.s	.skiphalvingvel			; If not, branch and skip underwater checks
			move.w	(v_waterpos1).w,d6		; Move water level to d6
			cmp.w	$C(a0),d6				; Is the ring object underneath the water level?
			bgt.s	.skiphalvingvel			; if the ring is above the water, skip underwater physics
			asr.w	d0						; Half d0. Makes the ring's x_vel bounce to the left/right slower
			asr.w	d1						; Half d1. Makes the ring's y_vel bounce up/down slower
.skiphalvingvel:
		endif ; if TweakFixUnderwaterRingPhysics

		asl.w	d2,d0
		asl.w	d2,d1
		move.w	d0,d2
		move.w	d1,d3
		addi.b	#$10,d4
		bcc.s	.loc_9D62
		subi.w	#$80,d4
		bcc.s	.loc_9D62
		move.w	#$288,d4

.loc_9D62:
		move.w	d2,obVelX(a1)
		move.w	d3,obVelY(a1)
		neg.w	d2
		neg.w	d4
	endif ; if TweakFasterRingScatter
		dbf	d5,.loop	; repeat for number of rings (max 31)

.resetcounter:
		move.w	#0,(v_rings).w	; reset number of rings to zero
		move.b	#$80,(f_ringcount).w ; update ring counter
		move.b	#0,(v_lifecount).w

	if (FixBugScatteredRingsTimer)|(FixBugs)
		; Fix Ring Timers
		; https://info.sonicretro.org/SCHG_How-to:Fix_Ring_Timers
		moveq	#-1,d0			; Move 255 to d0
		move.b	d0,obDelayAni(a0)	; Move d0 to new timer
		move.b	d0,(v_ani3_time).w	; Move d0 to old timer (for animated purposes)
	endif

		sfx	#sfx_RingLoss,snd_jsr	; play ring loss sound

RLoss_Bounce:	; Routine 2
		move.b	(v_ani3_frame).w,obFrame(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)

	if TweakFixUnderwaterRingPhysics
		tst.b	(f_water).w												; Does the level have water?
		beq.s	.skipbounceslow										; If not, branch and skip underwater checks
		move.w	(v_waterpos1).w,d6							; Move water level to d6
		cmp.w	obY(a0),d6												; Is the ring object underneath the water level?
		bgt.s	.skipbounceslow										; If not, branch and skip underwater commands
		subi.w	#$E,obVelY(a0)									; Reduce gravity by $E ($18-$E=$A), giving the underwater effect
.skipbounceslow:
	endif ; if TweakFixUnderwaterRingPhysics

		bmi.s	.chkdel
		move.b	(v_vblank_byte).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	.chkdel
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	.chkdel
		add.w	d1,obY(a0)
		move.w	obVelY(a0),d0
		asr.w	#2,d0
		sub.w	d0,obVelY(a0)
		neg.w	obVelY(a0)

.chkdel:
	if (FixBugScatteredRingsTimer)|(FixBugs)
		; Fix Ring Timers
		; https://info.sonicretro.org/SCHG_How-to:Fix_Ring_Timers
		subq.b	#1,obDelayAni(a0)	; Subtract 1
		beq.w	DeleteObject		; If 0, delete
	else
		tst.b	(v_ani3_time).w
		beq.s	RLoss_Delete
	endif

	if (FixBugDeleteScatteredRings)|(FixBugs)
		; Fix Accidental Deletion of Scattered Rings
		; https://info.sonicretro.org/SCHG_How-to:Fix_Accidental_Deletion_of_Scattered_Rings
		tst.w	(v_limittop2).w		; is vertical wrapping enabled?
		bmi.w	DisplaySprite		; if so, don't delete rings by boundary
	endif

		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0	; has object moved below level boundary?
		blo.s	RLoss_Delete	; if yes, branch

	if TweakFasterRingScatter
		lea	(v_spritequeue+$180).w,a1
		cmpi.w	#$7E,(a1)								; is this part of the queue full?
		bcc.s	.rtn_bounce								; if yes, branch
		addq.w	#2,(a1)									; increment sprite count
		adda.w	(a1),a1									; jump to empty position
		move.w	a0,(a1)									; insert RAM address for object
.rtn_bounce:
		rts
	else
		bra.w	DisplaySprite
	endif ; if TweakFasterRingScatter
; ===========================================================================

RLoss_Collect:	; Routine 4 ; Obj_37_sub_4
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
	if TweakFasterRingScatter=0
		move.b	#1,obPriority(a0)
	endif ; if TweakFasterRingScatter=0
		bsr.w	CollectRing

RLoss_Sparkle:	; Routine 6 ; Obj_37_sub_6
		lea	(Ani_Ring).l,a1
		bsr.w	AnimateSprite
	if TweakFasterRingScatter
		lea	(v_spritequeue+$80).w,a1
		cmpi.w	#$7E,(a1)								; is this part of the queue full?
		bcc.s	.rtn_sparkle							; if yes, branch
		addq.w	#2,(a1)									; increment sprite count
		adda.w	(a1),a1									; jump to empty position
		move.w	a0,(a1)									; insert RAM address for object
.rtn_sparkle:
		rts
	else
		bra.w	DisplaySprite
	endif ; if TweakFasterRingScatter
; ===========================================================================

RLoss_Delete:	; Routine 8
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Ring Spawn Array
; ---------------------------------------------------------------------------
	if TweakFasterRingScatter
SpillRingData32:
	  dc.w    $00C4,$FC14, $FF3C,$FC14, $0238,$FCB0, $FDC8,$FCB0 ; 4
		dc.w    $0350,$FDC8, $FCB0,$FDC8, $03EC,$FF3C, $FC14,$FF3C ; 8
		dc.w    $03EC,$00C4, $FC14,$00C4, $0350,$0238, $FCB0,$0238 ; 12
		dc.w    $0238,$0350, $FDC8,$0350, $00C4,$03EC, $FF3C,$03EC ; 16
		even
	endif ; if TweakFasterRingScatter

	if (TweakFasterRingScatter)&(TweakFasterUnderwaterRings)
SpillRingData16:
		dc.w    $0064,$FE08, $FF9C,$FC08, $011C,$FE58, $FEE4,$FE58 ; 4
		dc.w    $01A8,$FEE4, $FE58,$FEE4, $01F8,$FF9C, $FE08,$FF9C ; 8
		dc.w    $01F8,$0060, $FE08,$0060, $01A8,$011C, $FE58,$011C ; 12
		dc.w    $011C,$01A8, $FEE4,$01A8, $0064,$01F4, $FF9C,$01F4 ; 16
		even
	endif ; if (TweakFasterRingScatter)&(TweakFasterUnderwaterRings)
