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
		cmpi.b	#$80,obAnim(a0)				; is object the goggles?
		beq.s	.goggles				; if yes, branch
	endif ; if FeatureRestoreMonitorScubaGear
		tst.b	obAnim(a0)	; is object a shield?
		bne.s	.stars		; if not, branch
		move.w	#ArtTile_Shield,obGfx(a0)	; shield specific code
		rts
; ===========================================================================

.stars:
		addq.b	#2,obRoutine(a0) ; goto Shi_Stars next
		move.w	#ArtTile_Invincibility,obGfx(a0)
		rts
; ===========================================================================

	if FeatureRestoreMonitorScubaGear
.goggles:
		addq.b	#4,obRoutine(a0)			; goto Shi_Goggles next
		move.l	#Map_GogglesItem,obMap(a0)		; use the unused goggles art as Sonic's overlay
		move.w	#ArtTile_Goggles|Tile_Pal2,obGfx(a0) ; use the ring palette for yellow lenses
		move.b	#1,obPriority(a0)			; draw over Sonic like the shield
		move.b	#$18,obActWid(a0)
		move.b	#$FF,objoff_30(a0)			; force the first goggles frame upload
		rts
; ===========================================================================
	endif ; if FeatureRestoreMonitorScubaGear

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
		beq.s	Shi_Start_Delete		; if not, branch
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

Shi_Start_Delete:
	if FixBugInvincibleMusic
		cmpi.b	#1,obAnim(a0)	; only the first star restores music
		bne.s	.delete		; if this is another star, branch
		bsr.w	Shi_RestoreMusic
.delete:
	endif ; if FixBugInvincibleMusic
		jmp	(DeleteObject).l

	if FeatureRestoreMonitorScubaGear
; ---------------------------------------------------------------------------
; Display the unused goggles graphics over compatible Sonic poses.
; ---------------------------------------------------------------------------

Shi_Goggles:	; Routine 6
		tst.b	(v_goggles).w				; does Sonic have goggles?
		beq.s	.delete				; if not, branch
		cmpi.b	#6,(v_player+obRoutine).w		; is Sonic dead or dying?
		bhs.s	.delete				; if yes, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obRender).w,d0		; copy Sonic's current flip flags
		andi.b	#3,d0
		ori.b	#4,d0					; use level-space coordinates
		move.b	d0,obRender(a0)
		moveq	#0,d0
		move.b	(v_player+obFrame).w,d0		; get Sonic's current frame
		cmpi.b	#Goggles_FrameMap_End-Goggles_FrameMap,d0 ; is this frame in the goggles map?
		bhs.s	.return				; if not, don't show goggles
		lea	(Goggles_FrameMap).l,a1		; load frame conversion table
		move.b	(a1,d0.w),d0			; get goggles frame
		bmi.s	.return				; if frame is incompatible, don't show goggles
		move.b	d0,d1				; keep mapping frame for DisplaySprite
		lea	(Goggles_ArtFrameMap).l,a1	; load art-frame conversion table
		move.b	(a1,d0.w),d0			; get 2x2 goggles art frame
		cmp.b	objoff_30(a0),d0			; is the current 2x2 overlay already in VRAM?
		beq.s	.loaded				; if yes, branch
		move.b	d0,objoff_30(a0)			; remember which frame was uploaded
		bsr.s	Goggles_LoadFrame			; upload the four tiles used by this pose
.loaded:
		move.b	d1,obFrame(a0)			; use matching goggles overlay frame
		jmp	(DisplaySprite).l

.delete:
		jmp	(DeleteObject).l

.return:
		rts

Goggles_LoadFrame:
		movem.l	d0-d1/a1/a6,-(sp)
		lsl.w	#7,d0					; 4 tiles per goggles overlay frame
		lea	(Art_Goggles).l,a1
		adda.w	d0,a1
		disable_ints
		locVRAM	ArtTile_Goggles*tile_size
		lea	(vdp_data_port).l,a6
		moveq	#3,d1					; four 8x8 tiles
		jsr	(LoadTiles).l
		enable_ints
		movem.l	(sp)+,d0-d1/a1/a6
		rts

Map_GogglesItem:	mappingsTable
	mappingsTableEntry.w	.stand
	mappingsTableEntry.w	.lookup
	mappingsTableEntry.w	.walkupright1
	mappingsTableEntry.w	.walkupright2
	mappingsTableEntry.w	.walkupright3
	mappingsTableEntry.w	.walkupright4
	mappingsTableEntry.w	.walkupright5
	mappingsTableEntry.w	.walkupright6
	mappingsTableEntry.w	.runupright
	mappingsTableEntry.w	.walkside
	mappingsTableEntry.w	.walkinvert
	mappingsTableEntry.w	.walkside2
	mappingsTableEntry.w	.balance1
	mappingsTableEntry.w	.balance2
	mappingsTableEntry.w	.spring
	mappingsTableEntry.w	.hang
	mappingsTableEntry.w	.leap
	mappingsTableEntry.w	.push1
	mappingsTableEntry.w	.push2
	mappingsTableEntry.w	.surf
	mappingsTableEntry.w	.bubstand

Goggles_Stand_X:	equ -4				; Looks Correct
Goggles_Stand_Y:	equ -11				; Looks Correct
Goggles_LookUp_X:	equ Goggles_Stand_X-1		; Looks Correct
Goggles_LookUp_Y:	equ Goggles_Stand_Y-3		; Looks Correct
Goggles_WalkUpright1_X:	equ Goggles_Stand_X+2
Goggles_WalkUpright1_Y:	equ Goggles_Stand_Y+2
Goggles_WalkUpright2_X:	equ Goggles_WalkUpright1_X+1
Goggles_WalkUpright2_Y:	equ Goggles_WalkUpright1_Y-2
Goggles_WalkUpright3_X:	equ Goggles_WalkUpright2_X+1
Goggles_WalkUpright3_Y:	equ Goggles_WalkUpright2_Y+1
Goggles_WalkUpright4_X:	equ Goggles_WalkUpright3_X
Goggles_WalkUpright4_Y:	equ Goggles_WalkUpright3_Y-1
Goggles_WalkUpright5_X:	equ Goggles_WalkUpright4_X	; Needs the next goggle frame in sequence
Goggles_WalkUpright5_Y:	equ Goggles_WalkUpright4_Y	; Needs the next goggle frame in sequence
Goggles_WalkUpright6_X:	equ Goggles_WalkUpright5_X	; Needs the next goggle frame in sequence
Goggles_WalkUpright6_Y:	equ Goggles_WalkUpright5_Y	; Needs the next goggle frame in sequence
Goggles_RunUpright_X:	equ Goggles_Stand_X
Goggles_RunUpright_Y:	equ Goggles_Stand_Y
Goggles_WalkSide_X:	equ Goggles_Stand_X+4
Goggles_WalkSide_Y:	equ Goggles_Stand_Y
Goggles_WalkInvert_X:	equ Goggles_Stand_X
Goggles_WalkInvert_Y:	equ Goggles_Stand_Y
Goggles_WalkSide2_X:	equ Goggles_Stand_X
Goggles_WalkSide2_Y:	equ Goggles_Stand_Y
Goggles_Balance1_X:	equ Goggles_Stand_X-6		; tile needs flipped x ?
Goggles_Balance1_Y:	equ Goggles_Stand_Y
Goggles_Balance2_X:	equ Goggles_Balance1_X-1	; should use same tile as balance 1
Goggles_Balance2_Y:	equ Goggles_Balance1_Y-1
Goggles_Spring_X:	equ Goggles_Stand_Y
Goggles_Spring_Y:	equ Goggles_LookUp_Y
Goggles_Hang_X:		equ Goggles_Stand_Y
Goggles_Hang_Y:		equ Goggles_LookUp_Y
Goggles_Leap_X:		equ Goggles_Stand_Y
Goggles_Leap_Y:		equ Goggles_LookUp_Y
Goggles_Push1_X:	equ Goggles_Stand_X-2		; Theres a non positional issue with the pushing goggles as if the pallet is twitching, it looks like it's jittering left and right at a sub pixel level
Goggles_Push1_Y:	equ Goggles_Stand_Y+4
Goggles_Push2_X:	equ Goggles_Push1_X
Goggles_Push2_Y:	equ Goggles_Push1_Y-1
Goggles_Surf_X:		equ Goggles_Stand_X
Goggles_Surf_Y:		equ Goggles_Stand_Y
Goggles_BubStand_X:	equ Goggles_Stand_X
Goggles_BubStand_Y:	equ Goggles_Stand_Y

; The standing looking at the camera needs -2 on x from standing

.stand:	spriteHeader
	spritePiece	Goggles_Stand_X, Goggles_Stand_Y, 2, 2, 0, 0, 0, 0, 0
.stand_End

.lookup:	spriteHeader
	spritePiece	Goggles_LookUp_X, Goggles_LookUp_Y, 2, 2, 0, 0, 0, 0, 0
.lookup_End

.walkupright1:	spriteHeader
	spritePiece	Goggles_WalkUpright1_X, Goggles_WalkUpright1_Y, 2, 2, 0, 0, 0, 0, 0
.walkupright1_End

.walkupright2:	spriteHeader
	spritePiece	Goggles_WalkUpright2_X, Goggles_WalkUpright2_Y, 2, 2, 0, 0, 0, 0, 0
.walkupright2_End

.walkupright3:	spriteHeader
	spritePiece	Goggles_WalkUpright3_X, Goggles_WalkUpright3_Y, 2, 2, 0, 0, 0, 0, 0
.walkupright3_End

.walkupright4:	spriteHeader
	spritePiece	Goggles_WalkUpright4_X, Goggles_WalkUpright4_Y, 2, 2, 0, 0, 0, 0, 0
.walkupright4_End

.walkupright5:	spriteHeader
	spritePiece	Goggles_WalkUpright5_X, Goggles_WalkUpright5_Y, 2, 2, 0, 0, 0, 0, 0
.walkupright5_End

.walkupright6:	spriteHeader
	spritePiece	Goggles_WalkUpright6_X, Goggles_WalkUpright6_Y, 2, 2, 0, 0, 0, 0, 0
.walkupright6_End

.runupright:	spriteHeader
	spritePiece	Goggles_RunUpright_X, Goggles_RunUpright_Y, 2, 2, 0, 0, 0, 0, 0
.runupright_End

.walkside:	spriteHeader
	spritePiece	Goggles_WalkSide_X, Goggles_WalkSide_Y, 2, 2, 0, 0, 0, 0, 0
.walkside_End

.walkinvert:	spriteHeader
	spritePiece	Goggles_WalkInvert_X, Goggles_WalkInvert_Y, 2, 2, 0, 0, 0, 0, 0
.walkinvert_End

.walkside2:	spriteHeader
	spritePiece	Goggles_WalkSide2_X, Goggles_WalkSide2_Y, 2, 2, 0, 0, 0, 0, 0
.walkside2_End

.balance1:	spriteHeader
	spritePiece	Goggles_Balance1_X, Goggles_Balance1_Y, 2, 2, 0, 0, 0, 0, 0
.balance1_End

.balance2:	spriteHeader
	spritePiece	Goggles_Balance2_X, Goggles_Balance2_Y, 2, 2, 0, 0, 0, 0, 0
.balance2_End

.spring:	spriteHeader
	spritePiece	Goggles_Spring_X, Goggles_Spring_Y, 2, 2, 0, 1, 0, 0, 0
.spring_End

.hang:	spriteHeader
	spritePiece	Goggles_Hang_X, Goggles_Hang_Y, 2, 2, 0, 0, 0, 0, 0
.hang_End

.leap:	spriteHeader
	spritePiece	Goggles_Leap_X, Goggles_Leap_Y, 2, 2, 0, 0, 0, 0, 0
.leap_End

.push1:	spriteHeader
	spritePiece	Goggles_Push1_X, Goggles_Push1_Y, 2, 2, 0, 0, 0, 0, 0
.push1_End

.push2:	spriteHeader
	spritePiece	Goggles_Push2_X, Goggles_Push2_Y, 2, 2, 0, 0, 0, 0, 0
.push2_End

.surf:	spriteHeader
	spritePiece	Goggles_Surf_X, Goggles_Surf_Y, 2, 2, 0, 0, 0, 0, 0
.surf_End

.bubstand:	spriteHeader
	spritePiece	Goggles_BubStand_X, Goggles_BubStand_Y, 2, 2, 0, 0, 0, 0, 0
.bubstand_End
	even

Goggles_ArtFrameMap:
	dc.b	0, 2, 0, 0, 0, 0, 0, 0
	dc.b	0, 2, 3, 4, 5, 6, 7, 8
	dc.b	8, 1, 1, 0, 0
	even

Goggles_FrameMap:
	dc.b	-1, 0, 0, 0, 0, 1		; null, stand/wait, look up
	dc.b	2, 3, 4, 5, 6, 7		; walk, upright
	dc.b	9, 9, 9, 9, 9, 9		; walk, vertical
	dc.b	10, 10, 10, 10, 10, 10		; walk, upside down
	dc.b	11, 11, 11, 11, 11, 11		; walk, vertical
	dc.b	8, 8, 8, 8			; run, upright
	dc.b	9, 9, 9, 9			; run, vertical
	dc.b	10, 10, 10, 10			; run, upside down
	dc.b	11, 11, 11, 11			; run, vertical
	dc.b	-1, -1, -1, -1, -1		; rolling frames
	dc.b	-1, -1, -1, -1			; warp frames
	dc.b	0, 0, -1, 12, 13, -1		; stop, duck, balance
	dc.b	-1, -1, -1			; floating frames
	dc.b	14, 15, 15, 16, 16, 17		; spring, hang, leap, push
	dc.b	18, 17, 18, 19, 20, -1		; push, surf, bubble stand, hurt
	dc.b	-1, -1, -1, -1, -1		; drowning/death/shrink
	dc.b	-1, -1, -1, -1, -1, -1
	dc.b	-1, -1, -1, -1, -1, -1
	dc.b	-1, -1, -1, -1, -1, -1
	dc.b	-1, -1, -1, -1			; float/get air/water slide
Goggles_FrameMap_End:
	even
	endif ; if FeatureRestoreMonitorScubaGear

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
