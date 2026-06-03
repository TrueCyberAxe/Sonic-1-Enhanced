; ---------------------------------------------------------------------------
; Object 54 - invisible lava tag (MZ)
; ---------------------------------------------------------------------------

LavaTag:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	LTag_Index(pc,d0.w),d1
		jmp	LTag_Index(pc,d1.w)
; ===========================================================================
LTag_Index:	dc.w LTag_Main-LTag_Index
		dc.w LTag_ChkDel-LTag_Index

LTag_ColTypes:	dc.b $96, $94, $95
		even
; ===========================================================================

LTag_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.b	LTag_ColTypes(pc,d0.w),obColType(a0)
		move.l	#Map_LTag,obMap(a0)
		move.b	#$84,obRender(a0)

LTag_ChkDel:	; Routine 2
		move.w	obX(a0),d0
		andi.w	#$FF80,d0

	if TweakS2OffscreenDelete
		; Use the object manager's cached rounded camera X like Sonic 2.
		sub.w	(v_opl_screen).w,d0
		addi.w	#$80,d0					; approx distance between object and screen
	else
		move.w	(v_screenposx).w,d1 		; get screen position
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0						; approx distance between object and screen
	endif

		bmi.w	DeleteObject				; this branch isn't in the common out_of_range macro
		cmpi.w	#$280,d0		; $280 = 128+320+192
		bhi.w	DeleteObject
	if FeatureLavaSplash
		bsr.s	LTag_UpdateSplashTouch		; clear splash debounce once Sonic leaves this lava tag
	endif ; if FeatureLavaSplash
		rts

	if FeatureLavaSplash
; ---------------------------------------------------------------------------
; Clear the lava splash contact latch once Sonic is no longer touching the
; same lava surface. This keeps the splash to one impact instead of one per
; frame while standing on the lava tag.
; ---------------------------------------------------------------------------

LTag_UpdateSplashTouch:
		btst	#bitObjectFlag,obStatus(a0)	; did this lava tag already splash?
		beq.s	.return				; if not, branch
		lea	(v_player).w,a1			; load Sonic object
		move.w	obY(a0),d1			; get lava tag centre
		subi.w	#$20,d1				; get lava surface
		move.w	obY(a1),d0			; get Sonic Y
		sub.w	d1,d0				; compare against lava surface
		addi.w	#$10,d0				; allow Sonic to be slightly above the surface
		bmi.s	.clear				; if he is no longer touching, clear latch
		cmpi.w	#$34,d0				; allow Sonic's middle/body contact range
		bls.s	.return				; if still touching, keep latch

.clear:
		bclr	#bitObjectFlag,obStatus(a0)	; allow the next fresh lava contact to splash

.return:
		rts
	endif ; if FeatureLavaSplash
