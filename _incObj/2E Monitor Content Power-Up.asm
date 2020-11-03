; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------
PowerUp:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pow_Index(pc,d0.w),d1
		jsr	Pow_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Pow_Index:
		dc.w Pow_Main-Pow_Index
		dc.w Pow_Move-Pow_Index
		dc.w Pow_Delete-Pow_Index
; ===========================================================================
Pow_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$680,obGfx(a0)
		move.b	#$24,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.w	#-$300,obVelY(a0)
		moveq	#0,d0
		move.b	obAnim(a0),d0	; get subtype
		addq.b	#2,d0
		move.b	d0,obFrame(a0)	; use correct frame
		movea.l	#Map_Monitor,a1
		add.b	d0,d0
		adda.w	(a1,d0.w),a1
		addq.w	#1,a1
		move.l	a1,obMap(a0)

Pow_Move:	; Routine 2
		tst.w	obVelY(a0)	; is object moving?
		bpl.w	Pow_Checks	; if not, branch
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)	; reduce object	speed
		rts
; ===========================================================================
Pow_Checks:
		addq.b	#2,obRoutine(a0)
		move.w	#29,obTimeFrame(a0) ; display icon for half a second
		move.b	obAnim(a0),d0

	if OptimizeMonitorOrder=0
		include	"_incObj/2E Monitor Content Power-Up (Original).asm"
	else
		include	"_incObj/2E Monitor Content Power-Up (Optimised).asm"
	endc
; ===========================================================================
Pow_Delete:	; Routine 4
		subq.w	#1,obTimeFrame(a0)

	if BugFixRenderBeforeInit=0 ; Bug 6
		bmi.w	DeleteObject			; delete after half a second
	else
    bpl.s   @locret
    addq.l  #4,sp
    bra.w   DeleteObject    ; delete after half a second

    @locret:
  endc
    rts
