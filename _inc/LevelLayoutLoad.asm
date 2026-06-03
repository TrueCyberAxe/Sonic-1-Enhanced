; ---------------------------------------------------------------------------
; Subroutine to load basic level data
; ---------------------------------------------------------------------------

LevelDataLoad:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		lea	(LevelHeaders).l,a2
		lea	(a2,d0.w),a2
		move.l	a2,-(sp)
		addq.l	#4,a2
		movea.l	(a2)+,a0
		lea	(v_16x16).w,a1	; RAM address for 16x16 mappings
		move.w	#ArtTile_Level,d0
		bsr.w	EniDec
		movea.l	(a2)+,a0
		lea	(v_256x256).l,a1 ; RAM address for 256x256 mappings
		bsr.w	KosDec
		bsr.w	LevelLayoutLoad
		move.w	(a2)+,d0
		move.w	(a2),d0
		andi.w	#$FF,d0
		cmpi.w	#id_LZ_act4,(v_zone).w ; is level SBZ3 (LZ4)?
		bne.s	.notSBZ3	; if not, branch
		moveq	#palid_SBZ3,d0	; use SB3 palette

.notSBZ3:
		cmpi.w	#id_SBZ_act2,(v_zone).w ; is level SBZ2?
		beq.s	.isSBZorFZ	; if yes, branch
		cmpi.w	#id_FZ,(v_zone).w ; is level FZ?
		bne.s	.normalpal	; if not, branch

.isSBZorFZ:
		moveq	#palid_SBZ2,d0	; use SBZ2/FZ palette

.normalpal:
		bsr.w	PalLoad_Fade	; load palette (based on d0)
		movea.l	(sp)+,a2
		addq.w	#4,a2		; read number for 2nd PLC
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	.skipPLC	; if 2nd PLC is 0 (i.e. the ending sequence), branch
	if FeatureEnhancedLevelFadeIn
		disable_ints
		bsr.w	QuickPLC	; load secondary level art before the enhanced fade starts
		enable_ints
	else
		bsr.w	AddPLC		; load pattern load cues
	endif ; if FeatureEnhancedLevelFadeIn

.skipPLC:
	if FeatureLavaSplash
		bsr.w	LoadLavaSplashArt	; preload Marble lava splash art before gameplay can spawn it
	endif ; if FeatureLavaSplash
		rts
; End of function LevelDataLoad

	if FeatureLavaSplash
; ---------------------------------------------------------------------------
; Load just the splash frames into an enhanced-mode free slot for MZ lava.
; The LZ PLC includes waterfalls too, so loading the whole PLC would overwrite
; Marble's stage art.
; ---------------------------------------------------------------------------

LoadLavaSplashArt:
		cmpi.b	#id_MZ,(v_zone).w	; is Marble Zone loaded?
		bne.s	.return			; if not, branch
		locVRAM	ArtTile_MZ_Lava_Splash*tile_size ; set VRAM target for lava splash tiles
		lea	(Art_LavaSplash).l,a0	; load extracted splash-only art
		move.w	#((Art_LavaSplash_End-Art_LavaSplash)/tile_size)-1,d0 ; length in tiles
		jsr	(LoadUncArt).l		; load uncompressed splash art

.return:
		rts
	endif ; if FeatureLavaSplash

	if FixBugTitleCardSonicPaletteArtifacts
; ---------------------------------------------------------------------------
; Remove foreground subtile entries that use Sonic/title-card palette line.
; Stage art is kept black until the enhanced fade starts, but line 1 remains
; live for title cards, so Sonic-palette foreground junk can otherwise show.
; ---------------------------------------------------------------------------

ClearTitleCardSonicPaletteArtifacts:
		cmpi.b	#id_SYZ,(v_zone).w	; Spring Yard has Sonic-palette bars hidden behind sprites
		bne.s	.return			; other stages can use palette line 1 for valid blocks
		lea	(v_16x16).w,a1		; RAM address for 16x16 mappings
		move.w	#$1800/2-1,d0		; number of words in 16x16 mappings

.loop:
		move.w	(a1),d1			; get 8x8 tile entry
		beq.s	.next			; ignore already blank entries
		move.w	d1,d2			; copy tile attributes
		andi.w	#$6000,d2		; keep only palette bits
		bne.s	.next			; if not palette line 1, branch
		clr.w	(a1)			; remove Sonic-palette foreground junk

.next:
		addq.w	#2,a1			; next subtile entry
		dbf	d0,.loop		; repeat for all 16x16 mappings

.return:
		rts
	endif ; if FixBugTitleCardSonicPaletteArtifacts

; ===========================================================================
; ---------------------------------------------------------------------------
; Level layout loading subroutine
; ---------------------------------------------------------------------------

LevelLayoutLoad:
		lea	(v_lvllayout).w,a3
	if FixBugs
		move.w	#(v_lvllayout_end-v_lvllayout)/4-1,d1
	else
		; ; v_lvllayout is only $400 bytes, but this clears $800...
		; In Sonic 2, this function was corrected to only clear the
		; layout buffer.
		move.w	#(v_lvllayout_end-v_lvllayout)/2-1,d1
	endif
		moveq	#0,d0

LevLoad_ClrRam:
		move.l	d0,(a3)+
		dbf	d1,LevLoad_ClrRam ; clear the RAM ($A400-A7FF)

		lea	(v_lvllayout_fg).w,a3 ; RAM address for level foreground layout
		moveq	#0,d1
		bsr.w	LevelLayoutLoad2 ; load level layout into RAM

		lea	(v_lvllayout_bg).w,a3 ; RAM address for background layout
		moveq	#2,d1
		; fall-through for second run...
; ---------------------------------------------------------------------------

; "LevelLayoutLoad2" is run twice - for the level and the background
LevelLayoutLoad2:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0
		add.w	d1,d0
		lea	(Level_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1	; load level width (in tiles)
		move.b	(a1)+,d2	; load level height (in tiles)

LevLoad_NumRows:
		move.w	d1,d0
		movea.l	a3,a0

LevLoad_Row:
		move.b	(a1)+,(a0)+
		dbf	d0,LevLoad_Row	; load 1 row
		lea	layout_row(a3),a3 ; do next row (skip over other plane)
		dbf	d2,LevLoad_NumRows ; repeat for number of rows
		rts
; End of function LevelLayoutLoad
