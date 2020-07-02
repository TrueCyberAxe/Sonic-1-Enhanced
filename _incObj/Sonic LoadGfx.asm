; ---------------------------------------------------------------------------
; Sonic	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LoadGfx: ; LoadSonicDynPLC
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	(v_sonframenum).w,d0 ; has frame changed?
		beq.s	@nochange	; if not, branch

		move.b	d0,(v_sonframenum).w
		lea	(SonicDynPLC).l,a2 ; load PLC script
		add.w	d0,d0
		adda.w	(a2,d0.w),a2

	if FeatureEnhancedPLCQueue=0
		moveq	#0,d1
		move.b	(a2)+,d1	; read "number of entries" value
		subq.b	#1,d1
	else
		moveq	#0,d5
		move.b	(a2)+,d5	; read "number of entries" value
		subq.b	#1,d5
	endc ; if FeatureEnhancedPLCQueue=0

		bmi.s	@nochange	; if zero, branch
	if FeatureEnhancedPLCQueue=0
		lea	(v_sgfx_buffer).w,a3
		move.b	#1,(f_sonframechg).w ; set flag for Sonic graphics DMA
	else
		move.w	#$F000,d4
		move.l	#Art_Sonic,d6
	endc ; if FeatureEnhancedPLCQueue=0

	@readentry:
	if FeatureEnhancedPLCQueue=0
		moveq	#0,d2
		move.b	(a2)+,d2
		move.w	d2,d0
		lsr.b	#4,d0
		lsl.w	#8,d2
		move.b	(a2)+,d2
		lsl.w	#5,d2
		lea	(Art_Sonic).l,a1
		adda.l	d2,a1

	@loadtile:
		movem.l	(a1)+,d2-d6/a4-a6
		movem.l	d2-d6/a4-a6,(a3)
		lea	$20(a3),a3	; next tile
		dbf	d0,@loadtile	; repeat for number of tiles

		dbf	d1,@readentry	; repeat for number of entries
	else
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,@readentry	; repeat for number of entries
	endc ; if FeatureEnhancedPLCQueue=0

	@nochange:
		rts

; End of function Sonic_LoadGfx
