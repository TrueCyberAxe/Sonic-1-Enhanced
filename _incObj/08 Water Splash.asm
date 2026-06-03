; ---------------------------------------------------------------------------
; Object 08 - water splash (LZ)
; ---------------------------------------------------------------------------

Splash:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Spla_Index(pc,d0.w),d1
		jmp	Spla_Index(pc,d1.w)
; ===========================================================================
Spla_Index:	dc.w Spla_Main-Spla_Index
		dc.w Spla_Display-Spla_Index
		dc.w Spla_Delete-Spla_Index
; ===========================================================================

Spla_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Splash,obMap(a0)
		ori.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.w	#ArtTile_LZ_Splash|Tile_Pal3,obGfx(a0)
	if FeatureLavaSplash
		tst.b	obSubtype(a0)			; is this a lava splash?
		beq.s	.watergfx			; if not, branch
		move.l	#Map_LavaSplash,obMap(a0)	; lava art is packed from tile 0
		move.w	#ArtTile_MZ_Lava_Splash|Tile_Pal4,obGfx(a0) ; use lava palette for lava splashes

.watergfx:
	endif ; if FeatureLavaSplash
	if FeatureLavaSplash
		tst.b	obSubtype(a0)			; is this a lava splash?
		bne.s	Spla_Display			; if yes, keep its impact X position
	endif ; if FeatureLavaSplash
		move.w	(v_player+obX).w,obX(a0) ; copy x-position from Sonic

Spla_Display:	; Routine 2
	if FeatureLavaSplash
		tst.b	obSubtype(a0)			; is this a lava splash?
		bne.s	.animate			; if yes, keep the fixed impact Y position
	endif ; if FeatureLavaSplash
		move.w	(v_waterpos1).w,obY(a0) ; copy y-position from water height
	if FeatureLavaSplash
.animate:
	endif ; if FeatureLavaSplash
		lea	(Ani_Splash).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ===========================================================================

Spla_Delete:	; Routine 4
		jmp	(DeleteObject).l	; delete when animation is complete
