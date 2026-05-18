; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

ShieldItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Shi_Index(pc,d0.w),d1
		jmp	Shi_Index(pc,d1.w)
; ===========================================================================
Shi_Index:	dc.w Shi_Main-Shi_Index
		dc.w Shi_Shield-Shi_Index
		dc.w Shi_Stars-Shi_Index
	if FeatureRestoreMonitorScubaGear
		dc.w Shi_Goggles-Shi_Index
	endif ; if FeatureRestoreMonitorScubaGear
; ===========================================================================

Shi_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Shield,obMap(a0)
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$10,obActWid(a0)
	if FeatureRestoreMonitorScubaGear
		cmpi.b	#5,obAnim(a0)	; is this the goggles overlay?
		beq.s	.goggles	; if yes, branch
	endif ; if FeatureRestoreMonitorScubaGear
		tst.b	obAnim(a0)	; is object a shield?
		bne.s	.stars		; if not, branch
		move.w	#ArtTile_Shield,obGfx(a0)	; shield specific code
		rts
; ===========================================================================

	if FeatureRestoreMonitorScubaGear
.goggles:
		addq.b	#4,obRoutine(a0) ; goto Shi_Goggles next
		move.w	#ArtTile_Goggles|Tile_Pal2,obGfx(a0)
		move.b	#8,obFrame(a0)
		rts
; ===========================================================================
	endif ; if FeatureRestoreMonitorScubaGear

.stars:
		addq.b	#2,obRoutine(a0) ; goto Shi_Stars next
		move.w	#ArtTile_Invincibility,obGfx(a0)
		rts
; ===========================================================================

Shi_Shield:	; Routine 2
		tst.b	(v_invinc).w	; does Sonic have invincibility?
		bne.s	.remove		; if yes, branch
		tst.b	(v_shield).w	; does Sonic have shield?
		beq.s	.delete		; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		lea	(Ani_Shield).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l

.remove:
		rts

.delete:
		jmp	(DeleteObject).l
; ===========================================================================

Shi_Stars:	; Routine 4
		tst.b	(v_invinc).w	; does Sonic have invincibility?
	if FeatureRestoreMonitorScubaGear
		beq.w	Shi_Start_Delete		; if not, branch
	else
		beq.s	Shi_Start_Delete		; if not, branch
	endif ; if FeatureRestoreMonitorScubaGear
		move.w	(v_trackpos).w,d0 ; get index value for tracking data
		move.b	obAnim(a0),d1
		subq.b	#1,d1
		bra.s	.trail
; ===========================================================================

.trail_unused:	;	unused older trailing code that makes a much shorter trail
		lsl.b	#4,d1		; multiply animation number by 16
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	objoff_30(a0),d1
		sub.b	d1,d0		; use earlier tracking data to create trail
		addq.b	#4,d1
		andi.b	#$F,d1
		move.b	d1,objoff_30(a0)
		bra.s	.b
; ===========================================================================

.trail:
		lsl.b	#3,d1		; multiply animation number by 8
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1		; multiply by 3
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	objoff_30(a0),d1
		sub.b	d1,d0		; use earlier tracking data to create trail
		addq.b	#4,d1
		cmpi.b	#$18,d1
		blo.s	.a
		moveq	#0,d1

.a:
		move.b	d1,objoff_30(a0)

.b:
		lea	(v_tracksonic).w,a1
		lea	(a1,d0.w),a1
		move.w	(a1)+,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		lea	(Ani_Shield).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ===========================================================================

	if FeatureRestoreMonitorScubaGear
Shi_Goggles:	; Routine 6
		tst.b	(v_goggles).w	; does Sonic have goggles?
		beq.w	DeleteObject	; if not, branch
		btst	#2,(v_player+obStatus).w ; is Sonic rolling or spin-jumping?
		bne.s	.hide		; if yes, don't draw goggles over ball frames
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		move.b	(v_player+obRender).w,d0
		andi.b	#3,d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp	(DisplaySprite).l

.hide:
		rts
; ===========================================================================
	endif ; if FeatureRestoreMonitorScubaGear

Shi_Start_Delete:
	if Enhanced
		cmpi.b	#1,obAnim(a0)	; only the first star restores music
		bne.s	.delete		; if this is another star, branch
		bsr.s	Shi_RestoreMusic
.delete:
	endif ; if Enhanced
		jmp	(DeleteObject).l

	if FixBugInvincibleMusic
; ---------------------------------------------------------------------------
; Subroutine to restore level music when invincibility stars disappear after
; something other than Sonic_Display cleared the invincibility flag.
; ---------------------------------------------------------------------------

Shi_RestoreMusic:
		cmpi.b	#id_Level,(v_gamemode).w	; is the game in a normal level?
		bne.s	.return				; if not, branch
		cmpi.b	#6,(v_player+obRoutine).w	; is Sonic dead or dying?
		bhs.s	.return				; if yes, branch
		tst.b	(f_bigring).w			; is Sonic entering the special stage?
		bne.s	.return				; if yes, branch
		tst.b	(f_lockscreen).w		; is a boss fight active?
		bne.s	.return				; if yes, branch
		cmpi.w	#12,(v_air).w			; is drowning countdown active?
		blo.s	.return				; if yes, branch

		moveq	#0,d0				; clear d0
		move.b	(v_zone).w,d0			; get current zone ID
		cmpi.w	#id_LZ_act4,(v_zone).w		; check if level is SBZ3 (LZ4)
		bne.s	.music				; if not, branch
		moveq	#5,d0				; play SBZ music instead of LZ

.music:
		lea	(MusicList2).l,a1		; load music list for post-invincibility
		move.b	(a1,d0.w),d0			; get entry for current zone
		play_queued_music snd_jsr		; resume normal level music

.return:
		rts
	endif ; if FixBugInvincibleMusic
