; ---------------------------------------------------------------------------
; Object 28 - animals
; ---------------------------------------------------------------------------

Animals:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Anml_Index(pc,d0.w),d1
		jmp	Anml_Index(pc,d1.w)
; ===========================================================================
Anml_Index:	dc.w Anml_Main-Anml_Index
		dc.w Anml_ChkFloor-Anml_Index
		dc.w Anml_Type0-Anml_Index
		dc.w Anml_Type1-Anml_Index
		dc.w Anml_Type0-Anml_Index
		dc.w Anml_Type0-Anml_Index
		dc.w Anml_Type0-Anml_Index
		dc.w Anml_Type1-Anml_Index
		dc.w Anml_Type0-Anml_Index
		dc.w Anml_FromPrison-Anml_Index
		dc.w Anml_End_0A-Anml_Index
		dc.w Anml_End_0A-Anml_Index
		dc.w Anml_End_0C-Anml_Index
		dc.w Anml_End_0D-Anml_Index
		dc.w Anml_End_0E-Anml_Index
		dc.w Anml_End_0F-Anml_Index
		dc.w Anml_End_0E-Anml_Index
		dc.w Anml_End_0F-Anml_Index
		dc.w Anml_End_0E-Anml_Index
		dc.w Anml_End_13-Anml_Index
		dc.w Anml_End_14-Anml_Index
; ===========================================================================

Anml_VarIndex:	; two index IDs for Anml_Variables
		dc.b 0,	5 ; Green Hill Zone
		dc.b 2, 3 ; Labyrinth Zone
		dc.b 6, 3 ; Marble Zone
		dc.b 4, 5 ; Star Light Zone
		dc.b 4, 1 ; Spring Yard Zone
		dc.b 0, 1 ; Scrap Brain Zone
		zonewarning Anml_VarIndex,2

Anml_Variables:	; horizontal speed, vertical speed, mappings
		dc.w -$200, -$400	; type 0 - GHZ/SBZ
		dc.l Map_Animal1
		dc.w -$200, -$300	; type 1 - SYZ/SBZ
		dc.l Map_Animal2 
		dc.w -$180, -$300	; type 2 - LZ
		dc.l Map_Animal1
		dc.w -$140, -$180	; type 3 - MZ/LZ
		dc.l Map_Animal2
		dc.w -$1C0, -$300	; type 4 - SYZ/SLZ
		dc.l Map_Animal3
		dc.w -$300, -$400	; type 5 - GHZ/SLZ
		dc.l Map_Animal2
		dc.w -$280, -$380	; type 6 - MZ
		dc.l Map_Animal3

; ---------------------------------------------------------------------------

; Each entry corresponds to one ending sequence animal,
; using subtype ID as index, starting at $A

Anml_EndSpeed:	; horizontal speed, vertical speed
		dc.w -$440, -$400		; $A
		dc.w -$440, -$400		; $B - unused
		dc.w -$440, -$400		; $C
		dc.w -$300, -$400		; $D
		dc.w -$300, -$400		; $E
		dc.w -$180, -$300		; $F
		dc.w -$180, -$300		; $10 - unused
		dc.w -$140, -$180		; $11 - unused
		dc.w -$1C0, -$300		; $12 - unused
		dc.w -$200, -$300		; $13
		dc.w -$280, -$380		; $14

Anml_EndMap:	dc.l Map_Animal2		; $A
		dc.l Map_Animal2		; $B - unused
		dc.l Map_Animal2		; $C
		dc.l Map_Animal1		; $D
		dc.l Map_Animal1		; $E
		dc.l Map_Animal1		; $F
		dc.l Map_Animal1		; $10 - unused
		dc.l Map_Animal2		; $11 - unused
		dc.l Map_Animal3		; $12 - unused
		dc.l Map_Animal2		; $13
		dc.l Map_Animal3		; $14

Anml_EndVram:	dc.w ArtTile_Ending_Flicky	; $A
		dc.w ArtTile_Ending_Flicky      ; $B - unused
		dc.w ArtTile_Ending_Flicky      ; $C
		dc.w ArtTile_Ending_Rabbit      ; $D
		dc.w ArtTile_Ending_Rabbit      ; $E
		dc.w ArtTile_Ending_Penguin     ; $F
		dc.w ArtTile_Ending_Penguin     ; $10 - unused
		dc.w ArtTile_Ending_Seal        ; $11 - unused
		dc.w ArtTile_Ending_Pig         ; $12 - unused
		dc.w ArtTile_Ending_Chicken     ; $13
		dc.w ArtTile_Ending_Squirrel    ; $14
; ===========================================================================

; Anml_Ending: <- old misnomer!
Anml_Main:	; Routine 0
		tst.b	obSubtype(a0)	; did animal come from a destroyed enemy?
		beq.w	Anml_FromEnemy	; if yes, branch
		moveq	#0,d0
		move.b	obSubtype(a0),d0 ; move object type to d0
		add.w	d0,d0		; multiply d0 by 2
		move.b	d0,obRoutine(a0) ; move d0 to routine counter
		subi.w	#$14,d0
		move.w	Anml_EndVram(pc,d0.w),obGfx(a0)
		add.w	d0,d0
		move.l	Anml_EndMap(pc,d0.w),obMap(a0)
		lea	Anml_EndSpeed(pc),a1
		move.w	(a1,d0.w),objoff_32(a0) ; load horizontal speed
		move.w	(a1,d0.w),obVelX(a0)
		move.w	2(a1,d0.w),objoff_34(a0) ; load vertical speed
		move.w	2(a1,d0.w),obVelY(a0)
		move.b	#$C,obHeight(a0)
		move.b	#4,obRender(a0)
		bset	#0,obRender(a0)
		move.b	#6,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		bra.w	DisplaySprite
; ===========================================================================

Anml_FromEnemy:
		addq.b	#2,obRoutine(a0)
		bsr.w	RandomNumber
		andi.w	#1,d0
		moveq	#0,d1
		move.b	(v_zone).w,d1
		add.w	d1,d1
		add.w	d0,d1
		lea	Anml_VarIndex(pc),a1
		move.b	(a1,d1.w),d0
		move.b	d0,objoff_30(a0)
		lsl.w	#3,d0
		lea	Anml_Variables(pc),a1
		adda.w	d0,a1
		move.w	(a1)+,objoff_32(a0)	; load horizontal speed
		move.w	(a1)+,objoff_34(a0)	; load vertical speed
		move.l	(a1)+,obMap(a0)	; load mappings
		move.w	#ArtTile_Animal_1,obGfx(a0)	; VRAM setting for 1st animal
		btst	#0,objoff_30(a0)	; is 1st animal used?
		beq.s	loc_90C0	; if yes, branch
		move.w	#ArtTile_Animal_2,obGfx(a0)	; VRAM setting for 2nd animal

loc_90C0:
		move.b	#$C,obHeight(a0)
		move.b	#4,obRender(a0)
		bset	#0,obRender(a0)
		move.b	#6,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#2,obFrame(a0)
		move.w	#-$400,obVelY(a0)
		tst.b	(v_bossstatus).w
		bne.s	loc_911C
		bsr.w	FindFreeObj
		bne.s	Anml_Display
		_move.b	#id_Points,obID(a1) ; load points object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	objoff_3E(a0),d0
		lsr.w	#1,d0
		move.b	d0,obFrame(a1)

Anml_Display:
	if FixBugAnimalBounce
		bsr.w	Anml_CheckSonicBounce
	endif ; if FixBugAnimalBounce
		bra.w	DisplaySprite
; ===========================================================================

loc_911C:
		move.b	#$12,obRoutine(a0)
		clr.w	obVelX(a0)
		bra.w	DisplaySprite
; ===========================================================================

; loc_912A:
Anml_ChkFloor:
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bsr.w	ObjectFall
		tst.w	obVelY(a0)
		bmi.s	loc_9180
	if FixBugAnimalBridge
		bsr.w	Anml_ChkFloorOrBridge
	else
		jsr	(ObjFloorDist).l
	endif ; if FixBugAnimalBridge
		tst.w	d1
		bpl.s	loc_9180
		add.w	d1,obY(a0)
		move.w	objoff_32(a0),obVelX(a0)
		move.w	objoff_34(a0),obVelY(a0)
		move.b	#1,obFrame(a0)
		move.b	objoff_30(a0),d0
		add.b	d0,d0
		addq.b	#4,d0
		move.b	d0,obRoutine(a0)
		tst.b	(v_bossstatus).w
		beq.s	loc_9180
		btst	#4,(v_vblank_byte).w
		beq.s	loc_9180
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)

loc_9180:
		bra.w	DisplaySprite
; ===========================================================================

; loc_9184:
Anml_Type0:
		bsr.w	ObjectFall
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_91AE
		move.b	#0,obFrame(a0)
	if FixBugAnimalBridge
		bsr.w	Anml_ChkFloorOrBridge
	else
		jsr	(ObjFloorDist).l
	endif ; if FixBugAnimalBridge
		tst.w	d1
		bpl.s	loc_91AE
		add.w	d1,obY(a0)
		move.w	objoff_34(a0),obVelY(a0)

loc_91AE:
		tst.b	obSubtype(a0)
		bne.s	loc_9224
		tst.b	obRender(a0)
		bpl.w	DeleteObject
	if FixBugAnimalBounce
		bra.w	Anml_Display
	else
		bra.w	DisplaySprite
	endif ; if FixBugAnimalBounce
; ===========================================================================

; loc_91C0:
Anml_Type1:
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_91FC
	if FixBugAnimalBridge
		bsr.w	Anml_ChkFloorOrBridge
	else
		jsr	(ObjFloorDist).l
	endif ; if FixBugAnimalBridge
		tst.w	d1
		bpl.s	loc_91FC
		add.w	d1,obY(a0)
		move.w	objoff_34(a0),obVelY(a0)
		tst.b	obSubtype(a0)
		beq.s	loc_91FC
		cmpi.b	#$A,obSubtype(a0)
		beq.s	loc_91FC
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)

loc_91FC:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_9212
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		andi.b	#1,obFrame(a0)

loc_9212:
		tst.b	obSubtype(a0)
		bne.s	loc_9224
		tst.b	obRender(a0)
		bpl.w	DeleteObject
	if FixBugAnimalBounce
		bra.w	Anml_Display
	else
		bra.w	DisplaySprite
	endif ; if FixBugAnimalBounce
; ===========================================================================

loc_9224:
		move.w	obX(a0),d0
		sub.w	(v_player+obX).w,d0
		bcs.s	loc_923C
		subi.w	#$180,d0
		bpl.s	loc_923C
		tst.b	obRender(a0)
		bpl.w	DeleteObject

loc_923C:
		bra.w	DisplaySprite
; ===========================================================================

; loc_9240:
Anml_FromPrison:
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		subq.w	#1,objoff_36(a0)
		bne.w	loc_925C
		move.b	#2,obRoutine(a0)
		move.b	#3,obPriority(a0)

loc_925C:
		bra.w	DisplaySprite
; ===========================================================================

; loc_9260:
Anml_End_0A:
		bsr.w	sub_9404
		bcc.s	loc_927C
		move.w	objoff_32(a0),obVelX(a0)
		move.w	objoff_34(a0),obVelY(a0)
		move.b	#$E,obRoutine(a0)
		bra.w	Anml_Type1
; ===========================================================================

loc_927C:
		bra.w	loc_9224
; ===========================================================================

; loc_9280:
Anml_End_0C:
		bsr.w	sub_9404
		bpl.s	loc_92B6
		clr.w	obVelX(a0)
		clr.w	objoff_32(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)
		bsr.w	loc_93C4
		bsr.w	loc_93EC
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_92B6
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		andi.b	#1,obFrame(a0)

loc_92B6:
		bra.w	loc_9224
; ===========================================================================

; loc_92BA:
Anml_End_0D:
		bsr.w	sub_9404
		bpl.s	loc_9310
		move.w	objoff_32(a0),obVelX(a0)
		move.w	objoff_34(a0),obVelY(a0)
		move.b	#4,obRoutine(a0)
		bra.w	Anml_Type0
; ===========================================================================

; loc_92D6:
Anml_End_14:
		bsr.w	ObjectFall
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_9310
		move.b	#0,obFrame(a0)
	if FixBugAnimalBridge
		bsr.w	Anml_ChkFloorOrBridge
	else
		jsr	(ObjFloorDist).l
	endif ; if FixBugAnimalBridge
		tst.w	d1
		bpl.s	loc_9310
		not.b	objoff_29(a0)
		bne.s	loc_9306
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)

loc_9306:
		add.w	d1,obY(a0)
		move.w	objoff_34(a0),obVelY(a0)

loc_9310:
		bra.w	loc_9224
; ===========================================================================

; loc_9314:
Anml_End_0E:
		bsr.w	sub_9404
		bpl.s	loc_932E
		clr.w	obVelX(a0)
		clr.w	objoff_32(a0)
		bsr.w	ObjectFall
		bsr.w	loc_93C4
		bsr.w	loc_93EC

loc_932E:
		bra.w	loc_9224
; ===========================================================================

; loc_9332:
Anml_End_0F:
		bsr.w	sub_9404
		bpl.s	loc_936C
		bsr.w	ObjectFall
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_936C
		move.b	#0,obFrame(a0)
	if FixBugAnimalBridge
		bsr.w	Anml_ChkFloorOrBridge
	else
		jsr	(ObjFloorDist).l
	endif ; if FixBugAnimalBridge
		tst.w	d1
		bpl.s	loc_936C
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)
		add.w	d1,obY(a0)
		move.w	objoff_34(a0),obVelY(a0)

loc_936C:
		bra.w	loc_9224
; ===========================================================================

; loc_9370:
Anml_End_13:
		bsr.w	sub_9404
		bpl.s	loc_93C0
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_93AA
	if FixBugAnimalBridge
		bsr.w	Anml_ChkFloorOrBridge
	else
		jsr	(ObjFloorDist).l
	endif ; if FixBugAnimalBridge
		tst.w	d1
		bpl.s	loc_93AA
		not.b	objoff_29(a0)
		bne.s	loc_93A0
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)

loc_93A0:
		add.w	d1,obY(a0)
		move.w	objoff_34(a0),obVelY(a0)

loc_93AA:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_93C0
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		andi.b	#1,obFrame(a0)

loc_93C0:
		bra.w	loc_9224
; ===========================================================================

loc_93C4:
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	locret_93EA
		move.b	#0,obFrame(a0)
	if FixBugAnimalBridge
		bsr.w	Anml_ChkFloorOrBridge
	else
		jsr	(ObjFloorDist).l
	endif ; if FixBugAnimalBridge
		tst.w	d1
		bpl.s	locret_93EA
		add.w	d1,obY(a0)
		move.w	objoff_34(a0),obVelY(a0)

locret_93EA:
		rts
; ===========================================================================

loc_93EC:
		bset	#0,obRender(a0)
		move.w	obX(a0),d0
		sub.w	(v_player+obX).w,d0
		bcc.s	locret_9402
		bclr	#0,obRender(a0)

locret_9402:
		rts
; ===========================================================================

sub_9404:
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		subi.w	#$B8,d0
		rts
; End of function sub_9404

	if FixBugAnimalBridge
; ---------------------------------------------------------------------------
; Check level floor first, then GHZ bridge logs as object floors for animals.
; ---------------------------------------------------------------------------

Anml_ChkFloorOrBridge:
		jsr	(ObjFloorDist).l			; check normal level collision first
		tst.w	d1				; did the animal hit level floor?
		bmi.s	.return				; if yes, branch
		movem.l	d0/d2-d3/a2,-(sp)
		move.w	obY(a0),d0			; get animal centre Y
		moveq	#0,d3
		move.b	obHeight(a0),d3			; get animal half-height
		add.w	d3,d0				; get animal bottom Y
		lea	(v_lvlobjspace).w,a2		; check level object slots
		moveq	#96-1,d2			; number of level object slots

.checkbridge:
		cmpi.b	#id_Bridge,obID(a2)		; is this a bridge object?
		bne.s	.next				; if not, branch
		cmpi.b	#$A,obRoutine(a2)		; is this an individual bridge log?
		beq.s	.checkx				; if yes, branch
		cmpi.b	#2,obRoutine(a2)		; is this the leftmost bridge log?
		beq.s	.checkx				; if yes, branch
		cmpi.b	#4,obRoutine(a2)		; is this the leftmost bridge log being stood on?
		bne.s	.next				; if not, branch

.checkx:
		move.w	obX(a0),d3			; get animal X position
		sub.w	obX(a2),d3			; compare with log X position
		addi.w	#8,d3				; shift to unsigned log bounds
		cmpi.w	#$10,d3				; is animal within the log width?
		bhs.s	.next				; if not, branch
		move.w	obY(a2),d3			; get bridge log Y position
		subi.w	#8,d3				; get bridge log top
		move.w	d0,d1				; get animal bottom Y
		sub.w	d3,d1				; compare with bridge top
		bmi.s	.next				; if animal is above the bridge, branch
		cmpi.w	#$10,d1				; is animal close enough to land?
		bhs.s	.next				; if not, branch
		neg.w	d1				; return negative floor distance
		bra.s	.done

.next:
		lea	object_size(a2),a2		; check next object slot
		dbf	d2,.checkbridge			; repeat for all level objects
		moveq	#1,d1				; no bridge floor found

.done:
		movem.l	(sp)+,d0/d2-d3/a2

.return:
		rts
	endif ; if FixBugAnimalBridge

	if FixBugAnimalBounce
; ---------------------------------------------------------------------------
; Bounce Sonic when he spin-jumps into a freed animal.
; ---------------------------------------------------------------------------

Anml_CheckSonicBounce:
		tst.w	(v_debuguse).w				; is debug mode active?
		bne.s	.return				; if yes, branch
		lea	(v_player).w,a1			; load Sonic object
		cmpi.b	#6,obRoutine(a1)			; is Sonic dead or dying?
		bhs.s	.return				; if yes, branch
		btst	#1,obStatus(a1)			; is Sonic airborne?
		beq.s	.return				; if not, branch
		tst.w	obVelY(a1)			; is Sonic moving down?
		bmi.s	.return				; if not, branch
		btst	#2,obStatus(a1)			; is Sonic rolling?
		bne.s	.checkrange			; if yes, branch
		btst	#4,obStatus(a1)			; is Sonic roll-jumping?
		beq.s	.return				; if not, branch

.checkrange:
		move.w	obY(a1),d0			; get Sonic's Y position
		moveq	#0,d1
		move.b	obHeight(a1),d1			; get Sonic's half-height
		add.w	d1,d0				; get Sonic's bottom Y
		move.w	obY(a0),d1			; get animal Y position
		moveq	#0,d2
		move.b	obHeight(a0),d2			; get animal half-height
		sub.w	d2,d1				; get animal top Y
		sub.w	d1,d0				; compare Sonic's bottom to animal top
		bmi.s	.return				; if Sonic is too high above the animal, branch
		cmpi.w	#$C,d0				; is Sonic too deep into/under the animal?
		bhi.s	.return				; if yes, branch
		move.w	obX(a1),d0			; get Sonic's X position
		sub.w	obX(a0),d0			; compare with animal
		bpl.s	.checkx
		neg.w	d0

.checkx:
		cmpi.w	#$14,d0				; is Sonic close enough horizontally?
		bhs.s	.return				; if not, branch
		move.w	obY(a1),d0			; get Sonic's Y position
		sub.w	obY(a0),d0			; compare with animal
		bpl.s	.checky
		neg.w	d0

.checky:
		cmpi.w	#$18,d0				; is Sonic close enough vertically?
		bhs.s	.return				; if not, branch
		neg.w	obVelY(a1)			; bounce like a monitor

.return:
		rts
	endif ; if FixBugAnimalBounce
