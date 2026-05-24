; ---------------------------------------------------------------------------
; Sonic Jam title-screen mode select hook
;
; Controls on title screen:
;   Start = normal disassembly/original REV01 data
;   A     = Sonic Jam Easy data where unique; otherwise REV01 fallback
;   B     = Sonic Jam Original data where unique; otherwise REV01 fallback
;   C     = Sonic Jam Hard data where unique; otherwise REV01 fallback
;
; Return:
;   d0.b = 0    no start/mode button pressed
;   d0.b = $FF  Start pressed, use vanilla title path
;   d0.b = 1    A/B/C selected Sonic Jam mode, start PlayLevel directly
; ---------------------------------------------------------------------------

SonicJam_TitleModeSelect:
	move.b	(v_jpadpress1).w,d1
	btst	#bitStart,d1
	bne.s	.vanilla_start
	btst	#bitA,d1
	bne.s	.easy
	btst	#bitB,d1
	bne.s	.original
	btst	#bitC,d1
	bne.s	.hard
	moveq	#0,d0
	rts

.vanilla_start:
	clr.b	(v_sonicjam_mode).w	; Start always means normal repo/original REV01 data
	moveq	#-1,d0
	rts

.easy:
	move.b	#SonicJamMode_Easy,(v_sonicjam_mode).w
	bra.s	.selected

.original:
	move.b	#SonicJamMode_Original,(v_sonicjam_mode).w
	bra.s	.selected

.hard:
	move.b	#SonicJamMode_Hard,(v_sonicjam_mode).w

.selected:
	music	#bgm_Emerald,snd_jsr,snd_load_b,QueueSound2	; play emerald jingle for Sonic Jam mode select
	moveq	#1,d0
	rts

; ---------------------------------------------------------------------------
; Call once when entering GM_Title so the selected Jam mode only lasts until
; the title screen is reached again.
; ---------------------------------------------------------------------------

SonicJam_ResetModeOnTitle:
	clr.b	(v_sonicjam_mode).w
	rts

; ---------------------------------------------------------------------------
; Resolve object placement pointers with REV01 fallback.
;
; Input:
;   d0.w = same zone/act table offset used by ObjPosLoad: ((zone/act) * 4)
;
; Output:
;   a0 = primary object list
;   a1 = secondary object list
;
; Behaviour:
;   First resolves the normal ObjPos_Index pair. If no Sonic Jam mode is
;   active, or if the selected mode has no unique file for this level, the
;   normal REV01 pointer is returned unchanged.
; ---------------------------------------------------------------------------

SonicJam_GetObjPosPtrs:
	lea	(ObjPos_Index).l,a0
	movea.l	a0,a1
	adda.w	(a0,d0.w),a0
	adda.w	2(a1,d0.w),a1

	moveq	#0,d1
	move.b	(v_sonicjam_mode).w,d1
	beq.s	.done			; mode 0 = vanilla REV01 data
	cmpi.b	#3,d1			; modes 1-3 are valid Sonic Jam selections
	bhi.s	.done			; invalid scratch values fall back to upstream data
	subq.w	#1,d1			; mode 1..3 -> table 0..2
	lsl.w	#2,d1
	lea	(SonicJam_ObjPosModeTables).l,a2
	movea.l	(a2,d1.w),a2
	move.w	d0,d2
	add.w	d2,d2			; original table entry is 4 bytes, override pair is 8 bytes
	move.l	(a2,d2.w),d3		; primary override pointer, or 0
	beq.s	.no_primary
	movea.l	d3,a0
.no_primary:
	move.l	4(a2,d2.w),d3		; secondary override pointer, or 0
	beq.s	.done
	movea.l	d3,a1
.done:
	rts
