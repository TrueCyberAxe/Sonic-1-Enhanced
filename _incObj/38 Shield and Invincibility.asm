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
	if EnhancedDebug
		tst.w	(v_debuguse).w				; is debug mode active?
		beq.s	.notdebug				; if not, branch
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.s	.remove				; if not, don't show overlays in debug
.notdebug:
	endif ; if EnhancedDebug
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
	if FeatureSonic2013SuperSonic
		beq.w	Shi_Start_Delete		; if not, branch
	else
		beq.s	Shi_Start_Delete		; if not, branch
	endif ; if FeatureSonic2013SuperSonic
	if FeatureSonic2013SuperSonic
		tst.b	(v_supersonic).w			; is pseudo Super Sonic active?
		bne.s	.returnstars			; if yes, don't draw normal invincibility stars
	endif ; if FeatureSonic2013SuperSonic
	if EnhancedDebug
		tst.w	(v_debuguse).w				; is debug mode active?
		beq.s	.notdebug				; if not, branch
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.s	.return				; if not, don't show overlays in debug
.notdebug:
	endif ; if EnhancedDebug
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

	if EnhancedDebug
.return:
		rts
	endif ; if EnhancedDebug
	if FeatureSonic2013SuperSonic
.returnstars:
		rts
	endif ; if FeatureSonic2013SuperSonic

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
		bne.s	.hasgoggles			; if yes, branch
	if EnhancedDebug
		tst.w	(v_debuguse).w				; is debug mode active?
		beq.w	.delete				; if not, branch
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.w	.delete				; if not, branch
	else
		bra.w	.delete				; if not, branch
	endif ; if EnhancedDebug
.hasgoggles:
	if EnhancedDebug
		tst.w	(v_debuguse).w				; is debug mode active?
		beq.s	.notdebug				; if not, branch
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.w	.return				; if not, don't show overlays in debug
.notdebug:
	endif ; if EnhancedDebug
		cmpi.b	#6,(v_player+obRoutine).w		; is Sonic dead or dying?
		bhs.w	.delete				; if yes, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
	if EnhancedDebug
		tst.w	(v_debuguse).w				; is debug mode active?
		beq.s	.notdebugpos				; if not, branch
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.s	.notdebugpos				; if not, branch
		move.w	(v_player+obScreenY).w,obScreenY(a0) ; use the same screen-space anchor as Sonic
		move.b	(v_player+obRender).w,d0		; copy Sonic's current flip flags
		andi.b	#3,d0
		move.b	d0,obRender(a0)			; use screen-space coordinates in the viewer
		bra.s	.gotrender

.notdebugpos:
	endif ; if EnhancedDebug
		move.b	(v_player+obRender).w,d0		; copy Sonic's current flip flags
		andi.b	#3,d0
		ori.b	#4,d0					; use level-space coordinates
		move.b	d0,obRender(a0)
	if EnhancedDebug
.gotrender:
	endif ; if EnhancedDebug
		moveq	#0,d0
		move.b	(v_player+obFrame).w,d0		; get Sonic's current frame
		cmpi.b	#Goggles_FrameMap_End-Goggles_FrameMap,d0 ; is this frame in the goggles map?
		bhs.w	.debugcenter			; if not, use centered debug goggles if needed
		lea	(Goggles_FrameMap).l,a1		; load frame conversion table
		move.b	(a1,d0.w),d0			; get goggles frame
		bmi.w	.debugcenter			; if frame is incompatible, use centered debug goggles if needed
		move.b	d0,d1				; keep mapping frame for DisplaySprite
		bra.s	.checkart

.debugcenter:
	if EnhancedDebug
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.w	.return				; if not, don't show goggles
		move.b	#GogglesFrame_Center,d1		; use centered debug mapping for trial placement
		move.b	(v_debug_goggle_art).w,d0		; use debug-selected goggles art frame
		bmi.w	.return				; if no goggles is selected, don't display
		bra.s	.gotart
	else
		bra.s	.return				; if not, don't show goggles
	endif ; if EnhancedDebug

.checkart:
	if EnhancedDebug
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.s	.normalart				; if not, branch
		move.b	(v_debug_goggle_art).w,d0		; use debug-selected goggles art frame
		bmi.w	.return				; if no goggles is selected, don't display
		bra.s	.gotart
.normalart:
	endif ; if EnhancedDebug
		lea	(Goggles_ArtFrameMap).l,a1	; load art-frame conversion table
		move.b	(a1,d0.w),d0			; get 2x2 goggles art frame
.gotart:
		moveq	#0,d2
	if EnhancedDebug
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.s	.getframemode			; if not, branch
		move.b	(v_debug_goggle_flip).w,d2	; get debug transform mode
		bra.s	.gotmode

.getframemode:
	endif ; if EnhancedDebug
		move.b	d1,d2				; get goggles mapping frame
		andi.w	#$FF,d2
		lea	(Goggles_FrameModeMap).l,a1	; load transform-mode conversion table
		move.b	(a1,d2.w),d2			; get default transform mode
	if EnhancedDebug
.gotmode:
	endif ; if EnhancedDebug
		move.b	d2,d3				; keep mode for flip flags
		andi.b	#3,d3				; keep x/y flip bits
		eor.b	d3,obRender(a0)			; apply goggles-specific flip mode
		move.b	d2,d3				; reload mode for rotation bits
		andi.b	#$C,d3				; keep rotation bits
		beq.s	.compareart			; if not rotating, branch
		move.b	d3,d2				; use existing rotation code
		andi.b	#$C,d2				; keep rotation bits

.normaliseart:
		cmpi.b	#GogglesArt_Count,d0		; is this already a rotated art index?
		blo.s	.applyrotation			; if not, branch
		subi.b	#GogglesArt_Count,d0		; reduce to the base goggles art frame
		bra.s	.normaliseart

.applyrotation:
		cmpi.b	#4,d2				; is it 90 degrees clockwise?
		bne.s	.check180			; if not, branch
		addi.b	#GogglesArt_Rot90,d0		; use real rotated art
		bra.s	.compareart

.check180:
		cmpi.b	#8,d2				; is it 180 degrees?
		bne.s	.rot270				; if not, use 270 degrees
		addi.b	#GogglesArt_Rot180,d0		; use real rotated art
		bra.s	.compareart

.rot270:
		addi.b	#GogglesArt_Rot270,d0		; use real rotated art

.compareart:
		cmp.b	objoff_30(a0),d0			; is the current 2x2 overlay already in VRAM?
		beq.s	.loaded				; if yes, branch
		move.b	d0,objoff_30(a0)			; remember which frame was uploaded
		bsr.w	Goggles_LoadFrame			; upload the four tiles used by this pose
.loaded:
		move.b	d1,obFrame(a0)			; use matching goggles overlay frame
	if EnhancedDebug
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		beq.s	.display			; if not, branch
		moveq	#0,d0
		move.b	(v_debug_goggle_x).w,d0		; get debug X offset adjustment
		ext.w	d0
		add.w	d0,obX(a0)
		moveq	#0,d0
		move.b	(v_debug_goggle_y).w,d0		; get debug Y offset adjustment
		ext.w	d0
		add.w	d0,obY(a0)
.display:
	endif ; if EnhancedDebug
		jmp	(DisplaySprite).l

.delete:
		jmp	(DeleteObject).l

.return:
		rts

Goggles_LoadFrame:
		movem.l	d0-d2/a1/a6,-(sp)
		andi.w	#$FF,d0
		lea	(Art_Goggles).l,a1
		cmpi.w	#GogglesArt_Rot270,d0		; is this a 270-degree rotated frame?
		blo.s	.check180			; if not, branch
		lea	(Art_Goggles_Rot270).l,a1
		subi.w	#GogglesArt_Rot270,d0
		bra.s	.load

.check180:
		cmpi.w	#GogglesArt_Rot180,d0		; is this a 180-degree rotated frame?
		blo.s	.check90			; if not, branch
		lea	(Art_Goggles_Rot180).l,a1
		subi.w	#GogglesArt_Rot180,d0
		bra.s	.load

.check90:
		cmpi.w	#GogglesArt_Rot90,d0		; is this a 90-degree rotated frame?
		blo.s	.load				; if not, branch
		lea	(Art_Goggles_Rot90).l,a1
		subi.w	#GogglesArt_Rot90,d0

.load:
		lsl.w	#7,d0					; 4 tiles per goggles overlay frame
		adda.w	d0,a1
		disable_ints
		locVRAM	ArtTile_Goggles*tile_size
		lea	(vdp_data_port).l,a6
		moveq	#3,d1					; four 8x8 tiles
		jsr	(LoadTiles).l
		enable_ints
		movem.l	(sp)+,d0-d2/a1/a6
		rts

GogglesArt_LookRight:			equ 0				; 01 - looking right
GogglesArt_LookRightHeadOn:		equ 1				; 02 - looking right, more head-on
GogglesArt_LookUpRight:			equ 2				; 03 - looking up and right
GogglesArt_LookRightDuplicate:		equ GogglesArt_LookRight	; 04 - duplicate of 01, omitted from use
GogglesArt_LookRightFar:		equ 4				; 05 - looking right, further from camera
GogglesArt_LookUpRightDuplicate:	equ GogglesArt_LookUpRight	; 06 - duplicate of 03, omitted from use
GogglesArt_LookHeadOn:			equ 6				; 07 - looking head-on
GogglesArt_LookUpLeft:			equ 7				; 08 - looking up and left
GogglesArt_LookDownRight:		equ 8				; 09 - looking down and right
GogglesArt_Count:			equ 9
GogglesArt_Rot90:			equ GogglesArt_Count
GogglesArt_Rot180:			equ GogglesArt_Count*2
GogglesArt_Rot270:			equ GogglesArt_Count*3

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
	mappingsTableEntry.w	.walkside2
	mappingsTableEntry.w	.walkside3
	mappingsTableEntry.w	.walkside4
	mappingsTableEntry.w	.walkside5
	mappingsTableEntry.w	.walkside6
	mappingsTableEntry.w	.walkinvert
	mappingsTableEntry.w	.runside
	mappingsTableEntry.w	.balance1
	mappingsTableEntry.w	.balance2
	mappingsTableEntry.w	.spring
	mappingsTableEntry.w	.hang
	mappingsTableEntry.w	.leap
	mappingsTableEntry.w	.push1
	mappingsTableEntry.w	.push2
	mappingsTableEntry.w	.surf
	mappingsTableEntry.w	.bubstand
	mappingsTableEntry.w	.standheadon
	mappingsTableEntry.w	.stop
	mappingsTableEntry.w	.hang2
	mappingsTableEntry.w	.center
	mappingsTableEntry.w	.float1
	mappingsTableEntry.w	.float2
	mappingsTableEntry.w	.float4
	mappingsTableEntry.w	.burndeath
	mappingsTableEntry.w	.shrink12
	mappingsTableEntry.w	.shrink3
	mappingsTableEntry.w	.shrink4
	mappingsTableEntry.w	.shrink5
	mappingsTableEntry.w	.air
	mappingsTableEntry.w	.slide
	mappingsTableEntry.w	.roll1
	mappingsTableEntry.w	.roll2
	mappingsTableEntry.w	.roll3
	mappingsTableEntry.w	.roll4
	mappingsTableEntry.w	.glidewater
	mappingsTableEntry.w	.injury
	mappingsTableEntry.w	.debugrot90
	mappingsTableEntry.w	.debugrot180
	mappingsTableEntry.w	.debugrot270

GogglesFrame_RunSide:	equ 16
GogglesFrame_Balance1:	equ 17
GogglesFrame_Balance2:	equ 18
GogglesFrame_Spring:	equ 19
GogglesFrame_Hang1:	equ 20
GogglesFrame_Leap:	equ 21
GogglesFrame_Push1:	equ 22
GogglesFrame_Push2:	equ 23
GogglesFrame_Surf:	equ 24
GogglesFrame_BubStand:	equ 25
GogglesFrame_StandHeadOn:	equ 26
GogglesFrame_Stop:	equ 27
GogglesFrame_Hang2:	equ 28
GogglesFrame_Center:	equ 29
GogglesFrame_Float1:	equ 30
GogglesFrame_Float2:	equ 31
GogglesFrame_Float4:	equ 32
GogglesFrame_BurnDeath:	equ 33
GogglesFrame_Shrink12:	equ 34
GogglesFrame_Shrink3:	equ 35
GogglesFrame_Shrink4:	equ 36
GogglesFrame_Shrink5:	equ 37
GogglesFrame_Air:	equ 38
GogglesFrame_Slide:	equ 39
GogglesFrame_Roll1:	equ 40
GogglesFrame_Roll2:	equ 41
GogglesFrame_Roll3:	equ 42
GogglesFrame_Roll4:	equ 43
GogglesFrame_GlideWater:	equ 44
GogglesFrame_Injury:	equ 45
GogglesFrame_DebugRot90:	equ 46
GogglesFrame_DebugRot180:	equ 47
GogglesFrame_DebugRot270:	equ 48

Goggles_Stand_X:	equ -4				; Looks Correct
Goggles_Stand_Y:	equ -12				; Looks Correct
Goggles_StandHeadOn_X:	equ Goggles_Stand_X-3
Goggles_StandHeadOn_Y:	equ -11
Goggles_LookUp_X:	equ -5				; Looks Correct
Goggles_LookUp_Y:	equ -14				; Looks Correct
Goggles_WalkUpright1_X:	equ 3
Goggles_WalkUpright1_Y:	equ -12
Goggles_WalkUpright2_X:	equ 4
Goggles_WalkUpright2_Y:	equ -11
Goggles_WalkUpright3_X:	equ -1
Goggles_WalkUpright3_Y:	equ -10
Goggles_WalkUpright4_X:	equ 0
Goggles_WalkUpright4_Y:	equ -12
Goggles_WalkUpright5_X:	equ -1	; Needs the next goggle frame in sequence
Goggles_WalkUpright5_Y:	equ -11	; Needs the next goggle frame in sequence
Goggles_WalkUpright6_X:	equ 3	; Needs the next goggle frame in sequence
Goggles_WalkUpright6_Y:	equ -10	; Needs the next goggle frame in sequence
Goggles_RunUpright_X:	equ 0
Goggles_RunUpright_Y:	equ -9
Goggles_WalkSide_X:	equ -2
Goggles_WalkSide_Y:	equ -19
Goggles_WalkSide2_X:	equ -2
Goggles_WalkSide2_Y:	equ -19
Goggles_WalkSide3_X:	equ -2
Goggles_WalkSide3_Y:	equ -19
Goggles_WalkSide4_X:	equ -2
Goggles_WalkSide4_Y:	equ -19
Goggles_WalkSide5_X:	equ -2
Goggles_WalkSide5_Y:	equ -19
Goggles_WalkSide6_X:	equ -2
Goggles_WalkSide6_Y:	equ -19
Goggles_WalkInvert_X:	equ Goggles_Stand_X
Goggles_WalkInvert_Y:	equ Goggles_Stand_Y
Goggles_RunSide_X:	equ -2
Goggles_RunSide_Y:	equ -19
Goggles_Balance1_X:	equ -14		; tile needs flipped x ?
Goggles_Balance1_Y:	equ -13
Goggles_Balance2_X:	equ -12	; should use same tile as balance 1
Goggles_Balance2_Y:	equ -12
Goggles_Spring_X:	equ -5
Goggles_Spring_Y:	equ -18
Goggles_Hang_X:		equ -12
Goggles_Hang_Y:		equ -5
Goggles_Hang2_X:	equ -13
Goggles_Hang2_Y:	equ -5
Goggles_Leap_X:		equ -4
Goggles_Leap_Y:		equ -17
Goggles_Push1_X:	equ -3		; Theres a non positional issue with the pushing goggles as if the pallet is twitching, it looks like it's jittering left and right at a sub pixel level
Goggles_Push1_Y:	equ -8
Goggles_Push2_X:	equ -3
Goggles_Push2_Y:	equ -9
Goggles_Surf_X:		equ Goggles_Stand_X
Goggles_Surf_Y:		equ -12
Goggles_BubStand_X:	equ -11
Goggles_BubStand_Y:	equ -23
Goggles_Stop_X:		equ -7
Goggles_Stop_Y:		equ -9
Goggles_Center_X:	equ -8
Goggles_Center_Y:	equ -8
Goggles_Float1_X:	equ 8
Goggles_Float1_Y:	equ -5
Goggles_Float2_X:	equ -8
Goggles_Float2_Y:	equ Goggles_Float1_Y
Goggles_Float4_X:	equ 8
Goggles_Float4_Y:	equ -5
Goggles_BurnDeath_X:	equ -3
Goggles_BurnDeath_Y:	equ -17
Goggles_Shrink12_X:	equ -7
Goggles_Shrink12_Y:	equ -13
Goggles_Shrink3_X:	equ -7
Goggles_Shrink3_Y:	equ -12
Goggles_Shrink4_X:	equ -7
Goggles_Shrink4_Y:	equ -11
Goggles_Shrink5_X:	equ -8
Goggles_Shrink5_Y:	equ -9
Goggles_Air_X:		equ -3
Goggles_Air_Y:		equ -17
Goggles_Slide_X:	equ -7
Goggles_Slide_Y:	equ -8
Goggles_Roll1_X:	equ Goggles_Center_X+8
Goggles_Roll1_Y:	equ Goggles_Center_Y
Goggles_Roll2_X:	equ 8
Goggles_Roll2_Y:	equ 10
Goggles_Roll3_X:	equ -2
Goggles_Roll3_Y:	equ 0
Goggles_Roll4_X:	equ -8
Goggles_Roll4_Y:	equ -10
Goggles_GlideWater_X:	equ -24
Goggles_GlideWater_Y:	equ Goggles_Float1_Y
Goggles_Injury_X:	equ Goggles_Center_X
Goggles_Injury_Y:	equ Goggles_Center_Y

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

.walkside2:	spriteHeader
	spritePiece	Goggles_WalkSide2_X, Goggles_WalkSide2_Y, 2, 2, 0, 0, 0, 0, 0
.walkside2_End

.walkside3:	spriteHeader
	spritePiece	Goggles_WalkSide3_X, Goggles_WalkSide3_Y, 2, 2, 0, 0, 0, 0, 0
.walkside3_End

.walkside4:	spriteHeader
	spritePiece	Goggles_WalkSide4_X, Goggles_WalkSide4_Y, 2, 2, 0, 0, 0, 0, 0
.walkside4_End

.walkside5:	spriteHeader
	spritePiece	Goggles_WalkSide5_X, Goggles_WalkSide5_Y, 2, 2, 0, 0, 0, 0, 0
.walkside5_End

.walkside6:	spriteHeader
	spritePiece	Goggles_WalkSide6_X, Goggles_WalkSide6_Y, 2, 2, 0, 0, 0, 0, 0
.walkside6_End

.walkinvert:	spriteHeader
	spritePiece	Goggles_WalkInvert_X, Goggles_WalkInvert_Y, 2, 2, 0, 0, 0, 0, 0
.walkinvert_End

.runside:	spriteHeader
	spritePiece	Goggles_RunSide_X, Goggles_RunSide_Y, 2, 2, 0, 0, 0, 0, 0
.runside_End

.balance1:	spriteHeader
	spritePiece	Goggles_Balance1_X, Goggles_Balance1_Y, 2, 2, 0, 0, 0, 0, 0
.balance1_End

.balance2:	spriteHeader
	spritePiece	Goggles_Balance2_X, Goggles_Balance2_Y, 2, 2, 0, 0, 0, 0, 0
.balance2_End

.spring:	spriteHeader
	spritePiece	Goggles_Spring_X, Goggles_Spring_Y, 2, 2, 0, 0, 0, 0, 0
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

.standheadon:	spriteHeader
	spritePiece	Goggles_StandHeadOn_X, Goggles_StandHeadOn_Y, 2, 2, 0, 0, 0, 0, 0
.standheadon_End

.stop:	spriteHeader
	spritePiece	Goggles_Stop_X, Goggles_Stop_Y, 2, 2, 0, 0, 0, 0, 0
.stop_End

.hang2:	spriteHeader
	spritePiece	Goggles_Hang2_X, Goggles_Hang2_Y, 2, 2, 0, 0, 0, 0, 0
.hang2_End

.center:	spriteHeader
	spritePiece	Goggles_Center_X, Goggles_Center_Y, 2, 2, 0, 0, 0, 0, 0
.center_End

.float1:	spriteHeader
	spritePiece	Goggles_Float1_X, Goggles_Float1_Y, 2, 2, 0, 0, 0, 0, 0
.float1_End

.float2:	spriteHeader
	spritePiece	Goggles_Float2_X, Goggles_Float2_Y, 2, 2, 0, 0, 0, 0, 0
.float2_End

.float4:	spriteHeader
	spritePiece	Goggles_Float4_X, Goggles_Float4_Y, 2, 2, 0, 0, 0, 0, 0
.float4_End

.burndeath:	spriteHeader
	spritePiece	Goggles_BurnDeath_X, Goggles_BurnDeath_Y, 2, 2, 0, 0, 0, 0, 0
.burndeath_End

.shrink12:	spriteHeader
	spritePiece	Goggles_Shrink12_X, Goggles_Shrink12_Y, 2, 2, 0, 0, 0, 0, 0
.shrink12_End

.shrink3:	spriteHeader
	spritePiece	Goggles_Shrink3_X, Goggles_Shrink3_Y, 2, 2, 0, 0, 0, 0, 0
.shrink3_End

.shrink4:	spriteHeader
	spritePiece	Goggles_Shrink4_X, Goggles_Shrink4_Y, 2, 2, 0, 0, 0, 0, 0
.shrink4_End

.shrink5:	spriteHeader
	spritePiece	Goggles_Shrink5_X, Goggles_Shrink5_Y, 2, 2, 0, 0, 0, 0, 0
.shrink5_End

.air:	spriteHeader
	spritePiece	Goggles_Air_X, Goggles_Air_Y, 2, 2, 0, 0, 0, 0, 0
.air_End

.slide:	spriteHeader
	spritePiece	Goggles_Slide_X, Goggles_Slide_Y, 2, 2, 0, 0, 0, 0, 0
.slide_End

.roll1:	spriteHeader
	spritePiece	Goggles_Roll1_X, Goggles_Roll1_Y, 2, 2, 0, 0, 0, 0, 0
.roll1_End

.roll2:	spriteHeader
	spritePiece	Goggles_Roll2_X, Goggles_Roll2_Y, 2, 2, 0, 0, 0, 0, 0
.roll2_End

.roll3:	spriteHeader
	spritePiece	Goggles_Roll3_X, Goggles_Roll3_Y, 2, 2, 0, 0, 0, 0, 0
.roll3_End

.roll4:	spriteHeader
	spritePiece	Goggles_Roll4_X, Goggles_Roll4_Y, 2, 2, 0, 0, 0, 0, 0
.roll4_End

.glidewater:	spriteHeader
	spritePiece	Goggles_GlideWater_X, Goggles_GlideWater_Y, 2, 2, 0, 1, 0, 0, 0
.glidewater_End

.injury:	spriteHeader
	spritePiece	Goggles_Injury_X, Goggles_Injury_Y, 2, 2, 0, 0, 0, 0, 0
.injury_End

.debugrot90:	spriteHeader
	spritePiece	0, 0, 1, 1, 2, 0, 0, 0, 0
	spritePiece	8, 0, 1, 1, 0, 0, 0, 0, 0
	spritePiece	0, 8, 1, 1, 3, 0, 0, 0, 0
	spritePiece	8, 8, 1, 1, 1, 0, 0, 0, 0
.debugrot90_End

.debugrot180:	spriteHeader
	spritePiece	0, 0, 1, 1, 3, 0, 0, 0, 0
	spritePiece	8, 0, 1, 1, 2, 0, 0, 0, 0
	spritePiece	0, 8, 1, 1, 1, 0, 0, 0, 0
	spritePiece	8, 8, 1, 1, 0, 0, 0, 0, 0
.debugrot180_End

.debugrot270:	spriteHeader
	spritePiece	0, 0, 1, 1, 1, 0, 0, 0, 0
	spritePiece	8, 0, 1, 1, 3, 0, 0, 0, 0
	spritePiece	0, 8, 1, 1, 0, 0, 0, 0, 0
	spritePiece	8, 8, 1, 1, 2, 0, 0, 0, 0
.debugrot270_End
	even

Goggles_FrameXOffsets:
	dc.b	Goggles_Stand_X, Goggles_LookUp_X
	dc.b	Goggles_WalkUpright1_X, Goggles_WalkUpright2_X, Goggles_WalkUpright3_X
	dc.b	Goggles_WalkUpright4_X, Goggles_WalkUpright5_X, Goggles_WalkUpright6_X
	dc.b	Goggles_RunUpright_X, Goggles_WalkSide_X, Goggles_WalkSide2_X, Goggles_WalkSide3_X
	dc.b	Goggles_WalkSide4_X, Goggles_WalkSide5_X, Goggles_WalkSide6_X, Goggles_WalkInvert_X
	dc.b	Goggles_RunSide_X, Goggles_Balance1_X, Goggles_Balance2_X, Goggles_Spring_X
	dc.b	Goggles_Hang_X, Goggles_Leap_X, Goggles_Push1_X, Goggles_Push2_X
	dc.b	Goggles_Surf_X, Goggles_BubStand_X, Goggles_StandHeadOn_X, Goggles_Stop_X
	dc.b	Goggles_Hang2_X, Goggles_Center_X, Goggles_Float1_X, Goggles_Float2_X
	dc.b	Goggles_Float4_X, Goggles_BurnDeath_X, Goggles_Shrink12_X, Goggles_Shrink3_X
	dc.b	Goggles_Shrink4_X, Goggles_Shrink5_X, Goggles_Air_X, Goggles_Slide_X
	dc.b	Goggles_Roll1_X, Goggles_Roll2_X, Goggles_Roll3_X, Goggles_Roll4_X
	dc.b	Goggles_GlideWater_X, Goggles_Injury_X, 0, 0, 0
	even

Goggles_FrameYOffsets:
	dc.b	Goggles_Stand_Y, Goggles_LookUp_Y
	dc.b	Goggles_WalkUpright1_Y, Goggles_WalkUpright2_Y, Goggles_WalkUpright3_Y
	dc.b	Goggles_WalkUpright4_Y, Goggles_WalkUpright5_Y, Goggles_WalkUpright6_Y
	dc.b	Goggles_RunUpright_Y, Goggles_WalkSide_Y, Goggles_WalkSide2_Y, Goggles_WalkSide3_Y
	dc.b	Goggles_WalkSide4_Y, Goggles_WalkSide5_Y, Goggles_WalkSide6_Y, Goggles_WalkInvert_Y
	dc.b	Goggles_RunSide_Y, Goggles_Balance1_Y, Goggles_Balance2_Y, Goggles_Spring_Y
	dc.b	Goggles_Hang_Y, Goggles_Leap_Y, Goggles_Push1_Y, Goggles_Push2_Y
	dc.b	Goggles_Surf_Y, Goggles_BubStand_Y, Goggles_StandHeadOn_Y, Goggles_Stop_Y
	dc.b	Goggles_Hang2_Y, Goggles_Center_Y, Goggles_Float1_Y, Goggles_Float2_Y
	dc.b	Goggles_Float4_Y, Goggles_BurnDeath_Y, Goggles_Shrink12_Y, Goggles_Shrink3_Y
	dc.b	Goggles_Shrink4_Y, Goggles_Shrink5_Y, Goggles_Air_Y, Goggles_Slide_Y
	dc.b	Goggles_Roll1_Y, Goggles_Roll2_Y, Goggles_Roll3_Y, Goggles_Roll4_Y
	dc.b	Goggles_GlideWater_Y, Goggles_Injury_Y, 0, 0, 0
	even

Goggles_ArtFrameMap:
	dc.b	GogglesArt_LookRight, GogglesArt_LookUpRight
	dc.b	GogglesArt_LookRightFar, GogglesArt_LookRightFar, GogglesArt_LookRight
	dc.b	GogglesArt_LookRightDuplicate, GogglesArt_LookRightDuplicate, GogglesArt_LookRightFar
	dc.b	GogglesArt_LookRight, GogglesArt_LookRightFar, GogglesArt_LookRightFar
	dc.b	GogglesArt_LookRightFar, GogglesArt_LookRightFar, GogglesArt_LookRightFar, GogglesArt_LookRightFar
	dc.b	GogglesArt_LookRightFar, GogglesArt_LookRightFar, GogglesArt_LookRightHeadOn, GogglesArt_LookRightHeadOn
	dc.b	GogglesArt_LookUpRight, GogglesArt_LookUpLeft, GogglesArt_LookRightHeadOn
	dc.b	GogglesArt_LookDownRight, GogglesArt_LookDownRight
	dc.b	GogglesArt_LookRight, GogglesArt_LookUpRight, GogglesArt_LookRightHeadOn
	dc.b	GogglesArt_LookRightHeadOn, GogglesArt_LookUpLeft, GogglesArt_LookRight
	dc.b	GogglesArt_LookRight, GogglesArt_LookHeadOn, GogglesArt_LookRight
	dc.b	GogglesArt_LookHeadOn, GogglesArt_LookHeadOn, GogglesArt_LookHeadOn
	dc.b	GogglesArt_LookHeadOn, GogglesArt_LookHeadOn, GogglesArt_LookRight, GogglesArt_LookRight
	dc.b	GogglesArt_LookRightFar, GogglesArt_LookRightFar, GogglesArt_LookRightFar
	dc.b	GogglesArt_LookRightFar, GogglesArt_LookRight, GogglesArt_LookRightHeadOn
	dc.b	GogglesArt_LookRight, GogglesArt_LookRight, GogglesArt_LookRight
	even

Goggles_FrameModeMap:
	dc.b	0, 0				; stand, look up
	dc.b	0, 0, 0, 0, 0, 0		; walk upright
	dc.b	0, 7, 7, 7, 7, 7, 7, 0		; run upright, walk up, walk invert
	dc.b	7, 0, 0, 0, 0, 0, 0, 0		; run side, balance, spring, hang, leap, push
	dc.b	0, 0, 0, 0, 0, 0, 0, 0		; surf through float
	dc.b	0, 0, 0, 0, 0, 0, 0, 0		; burn through slide
	dc.b	0, 5, 11, 2, 0, 0, 0, 0, 0	; roll, glide, injury, debug rotations
	even

Goggles_FrameMap:
	dc.b	-1, 0, GogglesFrame_StandHeadOn, GogglesFrame_StandHeadOn, GogglesFrame_StandHeadOn, 1 ; null, stand/wait, look up
	dc.b	2, 3, 4, 5, 6, 7		; walk, upright
	dc.b	9, 10, 11, 12, 13, 14		; walk, up-right
	dc.b	9, 10, 11, 12, 13, 14		; walk, up
	dc.b	2, 3, 4, 5, 6, 7		; walk, up-left
	dc.b	8, 8, 8, 8			; run, upright
	dc.b	GogglesFrame_RunSide, GogglesFrame_RunSide, GogglesFrame_RunSide, GogglesFrame_RunSide ; run, up-right
	dc.b	GogglesFrame_RunSide, GogglesFrame_RunSide, GogglesFrame_RunSide, GogglesFrame_RunSide ; run, up
	dc.b	8, 8, 8, 8			; run, up-left
	dc.b	GogglesFrame_Roll1, GogglesFrame_Roll2, GogglesFrame_Roll3, GogglesFrame_Roll4, -1 ; rolling frames
	dc.b	-1, -1, -1, -1			; warp frames
	dc.b	GogglesFrame_Stop, GogglesFrame_Stop, -1, GogglesFrame_Balance1, GogglesFrame_Balance2, GogglesFrame_Float1 ; stop, duck, balance, float 1
	dc.b	GogglesFrame_Float2, -1, GogglesFrame_Float4 ; floating frames
	dc.b	GogglesFrame_Spring, GogglesFrame_Hang1, GogglesFrame_Hang2, GogglesFrame_Leap, GogglesFrame_Leap, GogglesFrame_Push1 ; spring, hang, leap, push
	dc.b	GogglesFrame_Push2, GogglesFrame_Push1, GogglesFrame_Push2, GogglesFrame_Surf, GogglesFrame_BubStand, GogglesFrame_BurnDeath ; push, surf, bubble stand, burnt
	dc.b	-1, GogglesFrame_BurnDeath, GogglesFrame_Shrink12, GogglesFrame_Shrink12, GogglesFrame_Shrink3 ; drowning/death/shrink
	dc.b	GogglesFrame_Shrink4, GogglesFrame_Shrink5, GogglesFrame_GlideWater, -1, GogglesFrame_Injury, GogglesFrame_Air
	dc.b	GogglesFrame_Slide, -1, -1, -1, -1, -1
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
