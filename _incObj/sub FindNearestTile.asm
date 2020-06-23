; ---------------------------------------------------------------------------
; Subroutine to	find which tile	the object is standing on

; input:
;	d2 = y-position of object's bottom edge
;	d3 = x-position of object

; output:
;	a1 = address within 256x256 mappings where object is standing
;	     (refers to a 16x16 tile number)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

	if TweakUncompressedChunkMapping=0
FindNearestTile:
		move.w	d2,d0					; get y-pos. of bottom edge of object
		lsr.w	#1,d0
		andi.w	#$380,d0
		move.w	d3,d1					; get x-pos. of object
		lsr.w	#8,d1
		andi.w	#$7F,d1
		add.w	d1,d0						; combine
		moveq	#-1,d1
	else
Floor_ChkTile_LocateBlock:
	endc
		lea	(v_lvllayout).w,a1
		move.b	(a1,d0.w),d1	; get 256x256 tile number
		beq.s	@blanktile			; branch if 0
		bmi.s	@specialtile		; branch if >$7F
		subq.b	#1,d1					; the empty chunk is not included in the chunk mappings, subtract 1 to read the correct data
		ext.w	d1
		ror.w	#7,d1
		move.w	d2,d0
		add.w	d0,d0
		andi.w	#$1E0,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		add.w	d0,d1

	if TweakUncompressedChunkMapping=0
	@blanktile:
		movea.l	d1,a1
	endc
		rts

; ===========================================================================

@specialtile:
		andi.w	#$7F,d1
		btst	#6,obRender(a0) ; is object "behind a loop"?
		beq.s	@treatasnormal	; if not, branch
		addq.w	#1,d1
		cmpi.w	#$29,d1
		bne.s	@treatasnormal
		move.w	#$51,d1

	@treatasnormal:
		subq.b	#1,d1
		ror.w	#7,d1
		move.w	d2,d0
		add.w	d0,d0
		andi.w	#$1E0,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		add.w	d0,d1
	if TweakUncompressedChunkMapping>0 ; @TODO Double check this is correct

; ===========================================================================

@blanktile:
		lea	($FFFFFF00).w,a1	; override a1
		addq.w	#4,sp					; pop a stack frame to avoid adding the address of the chunk mappings to a1
		rts
; End of function FindNearestTile

; ---------------------------------------------------------------------------
; Subroutine to	find which tile	the object is standing on
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

FindNearestTile: ; XREF: FindFloor; et al
		move.w	d2,d0							; get y-pos. of bottom edge of object
		lsr.w	#1,d0
		andi.w	#$380,d0
		move.w	d3,d1							; get x-pos. of object
		lsr.w	#8,d1
		andi.w	#$7F,d1
		add.w	d1,d0								; combine

		tst.b	(v_zone).w					; are we in Green Hill Zone?
		beq.s	@ghz								; if yes, branch
		cmpi.b	#6,(v_zone).w 		; are we in the ending sequence?
		beq.s	@ghz								; if yes, branch

		moveq	#-1,d1
		bsr.w	Floor_ChkTile_LocateBlock
		movea.l	d1,a1
		rts
; ---------------------------------------------------------------------------

	@ghz:
		moveq	#0,d1
		bsr.w	Floor_ChkTile_LocateBlock
		add.l	#Blk256_GHZ,d1
	endc ; if TweakUncompressedChunkMapping>0

		movea.l	d1,a1
		rts

; End of function Floor_ChkTile
