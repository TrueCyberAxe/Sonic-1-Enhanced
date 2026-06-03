; ---------------------------------------------------------------------------
; Subroutine to update the HUD
; ---------------------------------------------------------------------------

HUD_Update:
	if EnhancedDebug
		tst.w	(v_debuguse).w				; is debug mode	on?
	else
		tst.w	(f_debugmode).w				; is debug mode	on?
	endif

		bne.w	HudDebug	; if yes, branch
		tst.b	(f_scorecount).w ; does the score need updating?
		beq.s	.chkrings	; if not, branch

		clr.b	(f_scorecount).w
		locVRAM	(ArtTile_HUD+$1A)*tile_size,d0	; set VRAM address
		move.l	(v_score).w,d1	; load score
		bsr.w	Hud_Score

.chkrings:
		tst.b	(f_ringcount).w	; does the ring counter need updating?
		beq.s	.chktime	; if not, branch
		bpl.s	.notzero
		bsr.w	Hud_LoadZero	; reset rings to 0 if Sonic is hit

.notzero:
		clr.b	(f_ringcount).w
		locVRAM	(ArtTile_HUD+$30)*tile_size,d0	; set VRAM address
		moveq	#0,d1
		move.w	(v_rings).w,d1	; load number of rings
		bsr.w	Hud_Rings

.chktime:
		tst.b	(f_timecount).w	; does the time need updating?
		beq.s	.chklives	; if not, branch
		tst.w	(f_pause).w	; is the game paused?
		bne.s	.chklives	; if yes, branch
		lea	(v_time).w,a1
		cmpi.l	#(9*$10000)+(59*$100)+59,(a1)+ ; is the time 9:59:59?
		beq.s	TimeOver	; if yes, branch

		addq.b	#1,-(a1)	; increment 1/60s counter
		cmpi.b	#60,(a1)	; check if passed 60
		blo.s	.chklives
		move.b	#0,(a1)
		addq.b	#1,-(a1)	; increment second counter
		cmpi.b	#60,(a1)	; check if passed 60
		blo.s	.updatetime
		move.b	#0,(a1)
		addq.b	#1,-(a1)	; increment minute counter
		cmpi.b	#9,(a1)		; check if passed 9
		blo.s	.updatetime
		move.b	#9,(a1)		; keep as 9

.updatetime:
		locVRAM	(ArtTile_HUD+$28)*tile_size,d0
		moveq	#0,d1
		move.b	(v_timemin).w,d1 ; load minutes
		bsr.w	Hud_Mins
		locVRAM	(ArtTile_HUD+$2C)*tile_size,d0
		moveq	#0,d1
		move.b	(v_timesec).w,d1 ; load seconds
		bsr.w	Hud_Secs

.chklives:
		tst.b	(f_lifecount).w ; does the lives counter need updating?
		beq.s	.chkbonus	; if not, branch
		clr.b	(f_lifecount).w
		bsr.w	Hud_Lives

.chkbonus:
		tst.b	(f_endactbonus).w ; do time/ring bonus counters need updating?
		beq.s	.finish		; if not, branch
		clr.b	(f_endactbonus).w
		locVRAM	ArtTile_Bonuses*tile_size
		moveq	#0,d1
		move.w	(v_timebonus).w,d1 ; load time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(v_ringbonus).w,d1 ; load ring bonus
		bsr.w	Hud_TimeRingBonus

.finish:
		rts
; ===========================================================================

TimeOver:
		clr.b	(f_timecount).w
		lea	(v_player).w,a0
		movea.l	a0,a2
		bsr.w	KillSonic
		move.b	#1,(f_timeover).w
		rts
; ===========================================================================

HudDebug:
	if EnhancedDebug
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		bne.w	HudDebugSonicSprite		; if yes, show sprite calibration values
	endif ; if EnhancedDebug
		bsr.w	HudDb_XY
		tst.b	(f_ringcount).w	; does the ring counter need updating?
		beq.s	.objcounter	; if not, branch
		bpl.s	.notzero
		bsr.w	Hud_LoadZero	; reset rings to 0 if Sonic is hit

.notzero:
		clr.b	(f_ringcount).w
		locVRAM	(ArtTile_HUD+$30)*tile_size,d0	; set VRAM address
		moveq	#0,d1
		move.w	(v_rings).w,d1	; load number of rings
		bsr.w	Hud_Rings

.objcounter:
		locVRAM	(ArtTile_HUD+$2C)*tile_size,d0	; set VRAM address
		moveq	#0,d1
		move.b	(v_spritecount).w,d1 ; load "number of objects" counter
		bsr.w	Hud_Secs
		tst.b	(f_lifecount).w ; does the lives counter need updating?
		beq.s	.chkbonus	; if not, branch
		clr.b	(f_lifecount).w
		bsr.w	Hud_Lives

.chkbonus:
		tst.b	(f_endactbonus).w ; does the ring/time bonus counter need updating?
		beq.s	.finish		; if not, branch
		clr.b	(f_endactbonus).w
		locVRAM	ArtTile_Bonuses*tile_size		; set VRAM address
		moveq	#0,d1
		move.w	(v_timebonus).w,d1 ; load time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(v_ringbonus).w,d1 ; load ring bonus
		bsr.w	Hud_TimeRingBonus

.finish:
		rts
; End of function HUD_Update

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load "0" on the HUD
; ---------------------------------------------------------------------------

Hud_LoadZero:
		locVRAM	(ArtTile_HUD+$30)*tile_size
		lea	Hud_TilesZero(pc),a2
		move.w	#2,d2
		bra.s	loc_1C83E
; End of function Hud_LoadZero

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load uncompressed HUD patterns ("E", "0", colon)
; ---------------------------------------------------------------------------

Hud_Base:
		lea	(vdp_data_port).l,a6
		bsr.w	Hud_Lives
		locVRAM	(ArtTile_HUD+$18)*tile_size
		lea	Hud_TilesBase(pc),a2
		move.w	#$E,d2

loc_1C83E:
		lea	Art_Hud(pc),a1

loc_1C842:
		move.w	#$F,d1
		move.b	(a2)+,d0
		bmi.s	loc_1C85E
		ext.w	d0
		lsl.w	#5,d0
		lea	(a1,d0.w),a3

loc_1C852:
		move.l	(a3)+,(a6)
		dbf	d1,loc_1C852

loc_1C858:
		dbf	d2,loc_1C842

		rts
; ===========================================================================

loc_1C85E:
		move.l	#0,(a6)
		dbf	d1,loc_1C85E

		bra.s	loc_1C858
; End of function Hud_Base

; ===========================================================================
Hud_TilesBase:	dc.b $16, $FF, $FF, $FF, $FF, $FF, $FF,	0, 0, $14, 0, 0
Hud_TilesZero:	dc.b $FF, $FF, 0, 0
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to load debug mode numbers patterns
; ---------------------------------------------------------------------------

HudDb_XY:
		locVRAM	(ArtTile_HUD+$18)*tile_size		; set VRAM address
		move.w	(v_screenposx).w,d1 ; load camera x-position
		swap	d1
		move.w	(v_player+obX).w,d1 ; load Sonic's x-position
		bsr.s	HudDb_XY2
		move.w	(v_screenposy).w,d1 ; load camera y-position
		swap	d1
		move.w	(v_player+obY).w,d1 ; load Sonic's y-position
; End of function HudDb_XY
; ===========================================================================

HudDb_XY2:
		moveq	#7,d6
		lea	(Art_Text).l,a1

HudDb_XYLoop:
		rol.w	#4,d1
		move.w	d1,d2
		andi.w	#$F,d2
		cmpi.w	#$A,d2
		blo.s	loc_1C8B2
		addq.w	#7,d2

loc_1C8B2:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		swap	d1
		dbf	d6,HudDb_XYLoop	; repeat 7 more times

		rts
; End of function HudDb_XY2

; ===========================================================================

	if EnhancedDebug
; ---------------------------------------------------------------------------
; Debug HUD for Sonic sprite/goggles calibration.
; Score area: Sonic frame category and subtype. Time area: X/Y offsets.
; Rings: goggles art and flip mode.
; ---------------------------------------------------------------------------

HudDebugSonicSprite:
		lea	(vdp_data_port).l,a6		; use direct plane text for the overlay debugger
		move.w	#HudDebugBlankTile,d7		; blank cells use a known empty tile
		bsr.w	HudDebug_ClearTextRows		; remove normal HUD and stale debug text
		move.w	#HudDebugTextBase,d3		; text tile attributes

		locVRAM	vram_fg+($80*1)+2,4(a6)
		moveq	#0,d0
		move.b	(v_debug_sonic_frame).w,d0	; get selected Sonic frame
		cmpi.b	#fr_WaterSlide+1,d0		; is it a valid Sonic frame?
		blo.s	.gotcategory			; if yes, branch
		moveq	#0,d0				; otherwise show the blank entry

.gotcategory:
		lsl.w	#3,d0				; frame index * 8
		lea	(HudDebugSonicFrameNames).l,a2
		adda.w	d0,a2
		moveq	#8-1,d6				; draw eight characters
		bsr.w	HudDebug_WriteFixedText
		move.b	#' ',d0
		bsr.w	HudDebug_WriteChar
		moveq	#0,d1
		move.b	(v_debug_sonic_frame).w,d1	; show the raw frame index
		bsr.w	HudDebug_WriteByteDecimal

		locVRAM	vram_fg+($80*2)+2,4(a6)
		lea	(HudDebugGoggleIndex).l,a1
		bsr.w	HudDebug_WriteString
		move.b	(v_debug_goggle_art).w,d1	; get selected goggles art
		bmi.s	.nogoggletext			; if none selected, show NULL
		addq.b	#1,d1				; user-facing goggles index starts at 1
		bsr.w	HudDebug_WriteByteDecimal
		bra.s	.drawmode

.nogoggletext:
		lea	(HudDebugNull).l,a1
		bsr.w	HudDebug_WriteString

.drawmode:
		locVRAM	vram_fg+($80*3)+2,4(a6)
		lea	(HudDebugModeIndex).l,a1
		bsr.w	HudDebug_WriteString
		moveq	#0,d1
		move.b	(v_debug_goggle_flip).w,d1	; show flip/rotation mode
		bsr.w	HudDebug_WriteByteDecimal

		locVRAM	vram_fg+($80*4)+2,4(a6)
		lea	(HudDebugOffsetX).l,a1
		bsr.w	HudDebug_WriteString
		move.b	(v_debug_goggle_x).w,d1		; show signed X adjustment
		ext.w	d1
		bsr.w	HudDebug_WriteSignedDecimal

		locVRAM	vram_fg+($80*5)+2,4(a6)
		lea	(HudDebugOffsetY).l,a1
		bsr.w	HudDebug_WriteString
		move.b	(v_debug_goggle_y).w,d1		; show signed Y adjustment
		ext.w	d1
		bsr.w	HudDebug_WriteSignedDecimal

		locVRAM	vram_fg+($80*24)+2,4(a6)
		lea	(HudDebugHelp1).l,a1
		bsr.w	HudDebug_WriteString
		locVRAM	vram_fg+($80*25)+2,4(a6)
		lea	(HudDebugHelp2).l,a1
		bsr.w	HudDebug_WriteString
		locVRAM	vram_fg+($80*26)+2,4(a6)
		lea	(HudDebugHelp3).l,a1
		bsr.w	HudDebug_WriteString
		rts

HudDebug_ClearTextRows:
		locVRAM	vram_fg+($80*0),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*1),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*2),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*3),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*4),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*5),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*6),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*7),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*8),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*9),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*10),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*11),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*12),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*24),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*25),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*26),4(a6)
		bsr.w	HudDebug_ClearLine
		locVRAM	vram_fg+($80*27),4(a6)
		bra.w	HudDebug_ClearLine

HudDebug_ClearLine:
		moveq	#40-1,d0

.loop:
		move.w	d7,(a6)
		dbf	d0,.loop
		rts

HudDebug_WriteString:
		moveq	#0,d0
		move.b	(a1)+,d0
		beq.s	.done
		bsr.w	HudDebug_WriteChar
		bra.s	HudDebug_WriteString

.done:
		rts

HudDebug_WriteFixedText:
		moveq	#0,d0
		move.b	(a2)+,d0
		bsr.w	HudDebug_WriteChar
		dbf	d6,HudDebug_WriteFixedText
		rts

HudDebug_WriteChar:
		cmpi.b	#$20,d0				; is it a space?
		beq.s	.blank				; if yes, branch
		cmpi.b	#'-',d0				; is it a minus sign?
		bne.s	.notminus			; if not, branch
		moveq	#$B,d0				; menu font minus tile
		bra.s	.draw

.notminus:
	if ExtendedMenu
		cmpi.b	#$40,d0				; is it an ASCII text character?
		blo.s	.nottext			; if not, branch
		subi.w	#3,d0				; compensate for missing characters in the font

.nottext:
		subi.w	#$30,d0				; convert ASCII to font index
		bpl.s	.draw
		bra.s	.blank
	else
		cmpi.b	#$30,d0				; is it below "0"?
		blo.s	.blank				; if yes, branch
		cmpi.b	#$39,d0				; is it a digit?
		bls.s	.digit				; if yes, branch
		cmpi.b	#$41,d0				; is it below "A"?
		blo.s	.blank				; if yes, branch
		cmpi.b	#$58,d0				; is it A-X?
		bls.s	.letterax			; if yes, branch
		cmpi.b	#$59,d0				; is it Y?
		beq.s	.lettery			; if yes, branch
		cmpi.b	#$5A,d0				; is it Z?
		bne.s	.blank				; if not, branch
		moveq	#$10,d0				; Z
		bra.s	.draw

.lettery:
		moveq	#$F,d0				; Y
		bra.s	.draw

.letterax:
		subi.w	#$30,d0				; convert A-X to old font range
		bra.s	.draw

.digit:
		subi.w	#$30,d0				; convert digit to font index
	endif ; if ExtendedMenu

.draw:
		add.w	d3,d0				; combine tile index with text attributes
		move.w	d0,(a6)
		rts

.blank:
		move.w	d7,(a6)
		rts

HudDebug_WriteSignedDecimal:
		tst.w	d1				; is the value negative?
		bpl.s	HudDebug_WriteByteDecimal	; if not, draw magnitude
		move.b	#'-',d0
		bsr.w	HudDebug_WriteChar
		neg.w	d1

HudDebug_WriteByteDecimal:
		andi.w	#$FF,d1
		moveq	#0,d2				; hundreds digit
		moveq	#0,d5				; non-zero digit flag

.hundreds:
		cmpi.w	#100,d1
		blo.s	.drawhundreds
		subi.w	#100,d1
		addq.w	#1,d2
		bra.s	.hundreds

.drawhundreds:
		tst.w	d2
		beq.s	.tens
		move.w	d2,d0
		addi.b	#'0',d0
		bsr.w	HudDebug_WriteChar
		moveq	#1,d5

.tens:
		moveq	#0,d2

.counttens:
		cmpi.w	#10,d1
		blo.s	.drawtens
		subi.w	#10,d1
		addq.w	#1,d2
		bra.s	.counttens

.drawtens:
		tst.w	d2
		bne.s	.showtens
		tst.w	d5
		beq.s	.ones

.showtens:
		move.w	d2,d0
		addi.b	#'0',d0
		bsr.w	HudDebug_WriteChar

.ones:
		move.w	d1,d0
		addi.b	#'0',d0
		bra.w	HudDebug_WriteChar

HudDebugTextBase:	equ ArtTile_Level_Select_Font|Tile_Pal4|Tile_Prio
HudDebugBlankTile:	equ ArtTile_Sonic-1
HudDebugBlankLong:	equ (HudDebugBlankTile<<16)|HudDebugBlankTile

HudDebugGoggleIndex:	dc.b	"GOGGLE INDEX ",0
HudDebugNull:		dc.b	"NULL",0
HudDebugModeIndex:	dc.b	"MODE INDEX ",0
HudDebugOffsetX:	dc.b	"OBJECT OFFSET X ",0
HudDebugOffsetY:	dc.b	"OBJECT OFFSET Y ",0
HudDebugHelp1:		dc.b	"X Z CYCLE FRAMES",0
HudDebugHelp2:		dc.b	"A C CYCLE GOGGLES  MODE FLIP",0
HudDebugHelp3:		dc.b	"Y RETURN DEBUG",0
		even

Hud_LoadAsciiText:
		lea	(Art_Text).l,a1

Hud_LoadAsciiText_Loop:
		moveq	#0,d0
		move.b	(a2)+,d0			; get ASCII character
		bsr.s	Hud_DrawAsciiChar
		dbf	d6,Hud_LoadAsciiText_Loop
		rts

Hud_DrawAsciiChar:
		cmpi.b	#$20,d0				; is it a space?
		beq.s	Hud_LoadTextBlank		; if yes, branch
		cmpi.b	#'-',d0				; is it a minus sign?
		bne.s	.notminus			; if not, branch
		moveq	#$B,d0				; use the menu font's minus tile
		bra.s	.draw

.notminus:
		cmpi.b	#'+',d0				; is it a plus sign?
		beq.w	Hud_LoadPlusTile		; if yes, branch
		cmpi.b	#':',d0				; is it a colon separator?
		beq.w	Hud_LoadColonTile		; if yes, branch
	if ExtendedMenu
		cmpi.b	#$40,d0				; is it an ASCII text character?
		blo.s	.nottext			; if not, branch
		subi.w	#3,d0				; compensate for missing characters in the font

.nottext:
		subi.w	#$30,d0				; convert ASCII to font index
	else
		cmpi.b	#$30,d0				; is it below "0"?
		blo.s	Hud_LoadTextBlank		; if yes, branch
		cmpi.b	#$39,d0				; is it a digit?
		bls.s	.digit				; if yes, branch
		cmpi.b	#$41,d0				; is it below "A"?
		blo.s	Hud_LoadTextBlank		; if yes, branch
		cmpi.b	#$58,d0				; is it A-X?
		bls.s	.letterax			; if yes, branch
		cmpi.b	#$59,d0				; is it Y?
		beq.s	.lettery			; if yes, branch
		cmpi.b	#$5A,d0				; is it Z?
		bne.s	Hud_LoadTextBlank		; if not, branch
		moveq	#$F,d0				; Z
		bra.s	.draw

.lettery:
		moveq	#$E,d0				; Y
		bra.s	.draw

.letterax:
		subi.w	#$30,d0				; convert A-X to old font range
		bra.s	.draw

.digit:
		subi.w	#$30,d0				; convert digit to font index
	endif ; if ExtendedMenu

.draw:
		bsr.w	Hud_LoadTextTile
		rts

Hud_LoadTextBlank:
		moveq	#16-1,d5

.loop:
		move.l	#0,(a6)
		dbf	d5,.loop
		rts

Hud_LoadDebugOffsets:
		lea	(Art_Text).l,a1
		move.b	(v_debug_goggle_x).w,d1		; get X offset adjustment
		bsr.w	Hud_DrawSignedByte
		move.b	#':',d0				; separator
		bsr.w	Hud_DrawAsciiChar
		move.b	(v_debug_goggle_y).w,d1		; get Y offset adjustment
		bsr.w	Hud_DrawSignedByte
		move.b	#' ',d0
		bra.w	Hud_DrawAsciiChar

Hud_DrawSignedByte:
		move.b	#'+',d0				; default to plus for positive offsets
		tst.b	d1				; is the offset negative?
		bpl.s	.getmagnitude			; if not, branch
		move.b	#'-',d0				; show negative offsets
		neg.b	d1

.getmagnitude:
		bsr.w	Hud_DrawAsciiChar
		andi.w	#$FF,d1
		moveq	#0,d2				; tens digit

.counttens:
		cmpi.w	#10,d1				; is there another ten?
		blo.s	.drawtens			; if not, branch
		subi.w	#10,d1
		addq.w	#1,d2
		bra.s	.counttens

.drawtens:
		move.w	d2,d0
		addi.b	#'0',d0

.drawones:
		bsr.w	Hud_DrawAsciiChar
		move.w	d1,d0
		addi.b	#'0',d0
		bra.w	Hud_DrawAsciiChar

Hud_LoadGoggleDebugText:
		lea	(Art_Text).l,a1
		move.b	#'G',d0
		bsr.w	Hud_DrawAsciiChar
		move.b	(v_debug_goggle_art).w,d1	; get selected goggles art
		bmi.s	.nogoggles			; if none selected, branch
		addq.b	#1,d1				; show user-facing art number 1-9
		bsr.s	Hud_DrawByte2Digits
		bra.s	.drawflip

.nogoggles:
		move.b	#'-',d0
		bsr.w	Hud_DrawAsciiChar
		move.b	#'-',d0

.drawflip:
		bsr.w	Hud_DrawAsciiChar
		move.b	#' ',d0
		bsr.w	Hud_DrawAsciiChar
		move.b	#'F',d0
		bsr.w	Hud_DrawAsciiChar
		move.b	(v_debug_goggle_flip).w,d1	; get flip mode
		bsr.s	Hud_DrawByte2Digits
		move.b	#' ',d0
		bra.w	Hud_DrawAsciiChar

Hud_DrawByte2Digits:
		andi.w	#$FF,d1
		moveq	#0,d2

.counttens:
		cmpi.w	#10,d1				; is there another ten?
		blo.s	.drawtens			; if not, branch
		subi.w	#10,d1
		addq.w	#1,d2
		bra.s	.counttens

.drawtens:
		move.w	d2,d0
		addi.b	#'0',d0
		bsr.w	Hud_DrawAsciiChar
		move.w	d1,d0
		addi.b	#'0',d0
		bra.w	Hud_DrawAsciiChar

Hud_LoadTextTile:
		lsl.w	#5,d0
		lea	(a1,d0.w),a3
		moveq	#8-1,d5

.loop:
		move.l	(a3)+,(a6)
		dbf	d5,.loop
		moveq	#8-1,d5

.clearbottom:
		move.l	#0,(a6)			; HUD counters are 8x16, clear the lower half
		dbf	d5,.clearbottom
		rts

Hud_LoadPlusTile:
		move.l	#0,(a6)
		move.l	#$00011000,(a6)
		move.l	#$00011000,(a6)
		move.l	#$01111100,(a6)
		move.l	#$01111100,(a6)
		move.l	#$00011000,(a6)
		move.l	#$00011000,(a6)
		move.l	#0,(a6)
		moveq	#8-1,d5

.clearbottom:
		move.l	#0,(a6)
		dbf	d5,.clearbottom
		rts

Hud_LoadColonTile:
		move.l	#0,(a6)
		move.l	#0,(a6)
		move.l	#$00011000,(a6)
		move.l	#$00011000,(a6)
		move.l	#0,(a6)
		move.l	#$00011000,(a6)
		move.l	#$00011000,(a6)
		move.l	#0,(a6)
		moveq	#8-1,d5

.clearbottom:
		move.l	#0,(a6)
		dbf	d5,.clearbottom
		rts

HudDebugSonicFrameNames:
		dc.b	"        ", "STAND 1 ", "WAIT 1  ", "WAIT 2  ", "WAIT 3  ", "LOOK UP1"
		dc.b	"WALK 1  ", "WALK 2  ", "WALK 3  ", "WALK 4  ", "WALK 5  ", "WALK 6  "
		dc.b	"WALKUR1 ", "WALKUR2 ", "WALKUR3 ", "WALKUR4 ", "WALKUR5 ", "WALKUR6 "
		dc.b	"WALKUP1 ", "WALKUP2 ", "WALKUP3 ", "WALKUP4 ", "WALKUP5 ", "WALKUP6 "
		dc.b	"WALKUL1 ", "WALKUL2 ", "WALKUL3 ", "WALKUL4 ", "WALKUL5 ", "WALKUL6 "
		dc.b	"RUN 1   ", "RUN 2   ", "RUN 3   ", "RUN 4   "
		dc.b	"RUNUR 1 ", "RUNUR 2 ", "RUNUR 3 ", "RUNUR 4 "
		dc.b	"RUNUP 1 ", "RUNUP 2 ", "RUNUP 3 ", "RUNUP 4 "
		dc.b	"RUNUL 1 ", "RUNUL 2 ", "RUNUL 3 ", "RUNUL 4 "
		dc.b	"ROLL 1  ", "ROLL 2  ", "ROLL 3  ", "ROLL 4  ", "ROLL 5  "
		dc.b	"SPIN 1  ", "SPIN 2  ", "SPIN 3  ", "SPIN 4  "
		dc.b	"BREAK 1 ", "BREAK 2 ", "DUCK 1  ", "BAL 1   ", "BAL 2   "
		dc.b	"GLIDE 1 ", "GLIDE 2 ", "GLIDE 3 ", "GLIDE 4 "
		dc.b	"SPRING 1", "LEDGE 1 ", "LEDGE 2 ", "VICTRY 1", "VICTRY 2"
		dc.b	"PUSH 1  ", "PUSH 2  ", "PUSH 3  ", "PUSH 4  ", "BREAK 1 ", "AIRGAS 1"
		dc.b	"BURN 1  ", "DROWN 1 ", "DEATH 1 ", "SHRK 1  ", "SHRK 2  ", "SHRK 3  "
		dc.b	"SHRK 4  ", "SHRK 5  ", "GLIDE 5 ", "GLIDE 6 ", "INJUR 1 ", "AIRGAS 1", "SLIDE 1 "
HudDebugSonicSubNames:
		dc.b	"        ", "        ", "        ", "        ", "        ", "        "
		dc.b	"UPRIGHT ", "UPRIGHT ", "UPRIGHT ", "UPRIGHT ", "UPRIGHT ", "UPRIGHT "
		dc.b	"UP RIGHT", "UP RIGHT", "UP RIGHT", "UP RIGHT", "UP RIGHT", "UP RIGHT"
		dc.b	"UP      ", "UP      ", "UP      ", "UP      ", "UP      ", "UP      "
		dc.b	"UP LEFT ", "UP LEFT ", "UP LEFT ", "UP LEFT ", "UP LEFT ", "UP LEFT "
		dc.b	"UPRIGHT ", "UPRIGHT ", "UPRIGHT ", "UPRIGHT "
		dc.b	"UP RIGHT", "UP RIGHT", "UP RIGHT", "UP RIGHT"
		dc.b	"UP      ", "UP      ", "UP      ", "UP      "
		dc.b	"UP LEFT ", "UP LEFT ", "UP LEFT ", "UP LEFT "
		dc.b	"        ", "        ", "        ", "        ", "        "
		dc.b	"CHARGE  ", "CHARGE  ", "CHARGE  ", "CHARGE  "
		dc.b	"HARD    ", "HARD    ", "        ", "        ", "        "
		dc.b	"WATER   ", "WATER   ", "WATER   ", "WATER   "
		dc.b	"JUMP    ", "HANG    ", "HANG    ", "POSE    ", "POSE    "
		dc.b	"        ", "        ", "        ", "        ", "DECEL   ", "BUBBLE  "
		dc.b	"        ", "WATER   ", "        ", "        ", "        ", "        "
		dc.b	"        ", "        ", "WATER   ", "WATER   ", "        ", "BUBBLE  ", "WATER   "
		even
	endif ; if EnhancedDebug

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load rings numbers patterns
; ---------------------------------------------------------------------------

Hud_Rings:
		lea	(Hud_100).l,a2
		moveq	#2,d6
		bra.s	Hud_LoadArt
; End of function Hud_Rings

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load score numbers patterns
; ---------------------------------------------------------------------------

Hud_Score:
		lea	(Hud_100000).l,a2
		moveq	#5,d6

Hud_LoadArt:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_ScoreLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C8EC:
		sub.l	d3,d1
		bcs.s	loc_1C8F4
		addq.w	#1,d2
		bra.s	loc_1C8EC
; ===========================================================================

loc_1C8F4:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C8FE
		move.w	#1,d4

loc_1C8FE:
		tst.w	d4
		beq.s	loc_1C92C
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1C92C:
		addi.l	#$400000,d0
		dbf	d6,Hud_ScoreLoop
		rts
; End of function Hud_Score

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load countdown numbers on the continue screen
; ---------------------------------------------------------------------------

ContScrCounter:
		locVRAM	ArtTile_Continue_Number*tile_size
		lea	(vdp_data_port).l,a6
		lea	(Hud_10).l,a2
		moveq	#2-1,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1 ; load numbers patterns

ContScr_Loop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C95A:
		sub.l	d3,d1
		blo.s	loc_1C962
		addq.w	#1,d2
		bra.s	loc_1C95A
; ===========================================================================

loc_1C962:
		add.l	d3,d1
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		dbf	d6,ContScr_Loop	; repeat 1 more time
		rts
; End of function ContScrCounter

; ===========================================================================
; ---------------------------------------------------------------------------
; HUD counter sizes
; ---------------------------------------------------------------------------
Hud_100000:	dc.l 100000
Hud_10000:	dc.l 10000
Hud_1000:	dc.l 1000
Hud_100:	dc.l 100
Hud_10:		dc.l 10
Hud_1:		dc.l 1

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load time numbers patterns
; ---------------------------------------------------------------------------

Hud_Mins:
		lea	(Hud_1).l,a2
		moveq	#0,d6
		bra.s	Hud_DrawDigits
; ===========================================================================

Hud_Secs:
		lea	(Hud_10).l,a2
		moveq	#1,d6

; loc_1C9BA:
Hud_DrawDigits:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_TimeLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C9C4:
		sub.l	d3,d1
		bcs.s	loc_1C9CC
		addq.w	#1,d2
		bra.s	loc_1C9C4
; ===========================================================================

loc_1C9CC:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C9D6
		move.w	#1,d4

loc_1C9D6:
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		addi.l	#$400000,d0
		dbf	d6,Hud_TimeLoop

		rts
; End of function Hud_Secs

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load time/ring bonus numbers patterns
; ---------------------------------------------------------------------------

Hud_TimeRingBonus:
		lea	(Hud_1000).l,a2
		moveq	#3,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_BonusLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1CA1E:
		sub.l	d3,d1
		bcs.s	loc_1CA26
		addq.w	#1,d2
		bra.s	loc_1CA1E
; ===========================================================================

loc_1CA26:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1CA30
		move.w	#1,d4

loc_1CA30:
		tst.w	d4
		beq.s	Hud_ClrBonus
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1CA5A:
		dbf	d6,Hud_BonusLoop ; repeat 3 more times

		rts
; ===========================================================================

Hud_ClrBonus:
		moveq	#$F,d5

Hud_ClrBonusLoop:
		move.l	#0,(a6)
		dbf	d5,Hud_ClrBonusLoop

		bra.s	loc_1CA5A
; End of function Hud_TimeRingBonus

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load uncompressed lives counter patterns
; ---------------------------------------------------------------------------

Hud_Lives:
		locVRAM	(ArtTile_Lives_Counter+9)*tile_size,d0	; set VRAM address
		moveq	#0,d1
		move.b	(v_lives).w,d1	; load number of lives
		lea	(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_LivesNums(pc),a1

Hud_LivesLoop:
		move.l	d0,4(a6)
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1CA90:
		sub.l	d3,d1
		bcs.s	loc_1CA98
		addq.w	#1,d2
		bra.s	loc_1CA90
; ===========================================================================

loc_1CA98:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1CAA2
		move.w	#1,d4

loc_1CAA2:
		tst.w	d4
		beq.s	Hud_ClrLives

loc_1CAA6:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1CABC:
		addi.l	#$400000,d0
		dbf	d6,Hud_LivesLoop ; repeat 1 more time

		rts
; ===========================================================================

Hud_ClrLives:
		tst.w	d6
		beq.s	loc_1CAA6
		moveq	#7,d5

Hud_ClrLivesLoop:
		move.l	#0,(a6)
		dbf	d5,Hud_ClrLivesLoop
		bra.s	loc_1CABC
; End of function Hud_Lives
