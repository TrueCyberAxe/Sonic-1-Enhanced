; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

DebugMode:
		moveq	#0,d0
		move.b	(v_debuguse).w,d0
		move.w	Debug_Index(pc,d0.w),d1
		jmp	Debug_Index(pc,d1.w)
; ===========================================================================
Debug_Index:
		dc.w Debug_Main-Debug_Index
		dc.w Debug_Action-Debug_Index
; ===========================================================================

Debug_Main:	; Routine 0
	if FixBugDebugMomentum
		clr.w   (v_objspace+$14).w ; Clear Inertia
		clr.w   (v_objspace+$12).w ; Clear X/Y Speed
		clr.w   (v_objspace+$10).w ; Clear X/Y Speed
	endif ; if FixBugDebugMomentum
	if EnhancedDebug
		bclr	#bitDebugSonicSpriteView,(f_debugmode).w ; reset Sonic sprite viewer on debug entry
		move.b	#fr_Stand,(v_debug_sonic_frame).w ; start sprite viewer on standing Sonic
		bsr.w	Debug_ResetSonicViewGoggles	; use code-defined goggles for the frame
		clr.b	(v_debug_hide_bg).w		; regular debug keeps the level display visible
	endif ; if EnhancedDebug
		addq.b	#2,(v_debuguse).w
		move.w	(v_limittop2).w,(v_limittopdb).w ; buffer level x-boundary
		move.w	(v_limitbtm1).w,(v_limitbtmdb).w ; buffer level y-boundary
		move.w	#0,(v_limittop2).w
		move.w	#$720,(v_limitbtm1).w
		andi.w	#$7FF,(v_player+obY).w
		andi.w	#$7FF,(v_screenposy).w
		andi.w	#$3FF,(v_bgscreenposy).w
		move.b	#0,obFrame(a0)
		move.b	#id_Walk,obAnim(a0)
		cmpi.b	#id_Special,(v_gamemode).w ; is game mode $10 (special stage)?
		bne.s	.islevel	; if not, branch

		move.w	#0,(v_ssrotate).w ; stop special stage rotating
		move.w	#0,(v_ssangle).w ; make special stage "upright"
		moveq	#6,d0		; use 6th debug item list
		bra.s	.selectlist
; ===========================================================================

.islevel:
		moveq	#0,d0
		move.b	(v_zone).w,d0

.selectlist:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		cmp.b	(v_debugitem).w,d6 ; have you gone past the last item?
		bhi.s	.noreset	; if not, branch
		move.b	#0,(v_debugitem).w ; back to start of list

.noreset:
		bsr.w	Debug_ShowItem
		move.b	#12,(v_debugspeedtimer).w
		move.b	#1,(v_debugspeed).w

Debug_Action:	; Routine 2
		moveq	#6,d0
		cmpi.b	#id_Special,(v_gamemode).w
		beq.s	.isntlevel

		moveq	#0,d0
		move.b	(v_zone).w,d0

.isntlevel:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		bsr.w	Debug_Control
		jmp	(DisplaySprite).l
; ===========================================================================

Debug_Control:
	if EnhancedDebug
		tst.b	(f_debug_6button).w			; is a six-button pad detected?
		beq.s	.normaldebug				; if not, use normal debug controls
		btst	#bitY,(v_jpadpress1ext).w		; was Y pressed?
		beq.s	.checksonicview			; if not, branch
		bchg	#bitDebugSonicSpriteView,(f_debugmode).w ; toggle Sonic sprite viewer
		bne.s	.exitsonicview			; if it was active, return to object debug
		bsr.w	Debug_PrepareSonicViewPalette	; preserve live colours before fading to black
		bsr.w	Debug_PaletteFadeOut		; fade level palette before replacing the display
		bsr.w	Debug_SaveSonicViewState	; preserve the real debug/Sonic position before using screen coords
		move.b	#fr_Stand,(v_debug_sonic_frame).w ; start on standing Sonic
		bsr.w	Debug_ResetSonicViewGoggles	; use code-defined goggles for the frame
		bsr.w	Debug_EnsureGogglesObject	; make sure the overlay object exists
		bsr.w	Debug_LoadSonicViewFont		; load plane text used by the overlay debugger
		move.b	#1,(v_debug_hide_bg).w		; always hide background layers in Sonic sprite viewer
		bsr.w	Debug_UpdateBackdrop		; apply the stable calibration backdrop
		bsr.w	Debug_PaletteFadeIn		; fade into Sonic sprite viewer
		bra.w	Debug_SonicViewControl

.exitsonicview:
		bsr.w	Debug_PaletteFadeOut		; hide viewer before restoring level graphics
		bsr.w	Debug_RestoreSonicViewState	; restore the real object position before redrawing the level
		clr.b	(v_debug_hide_bg).w		; mark background as visible
		move.b	#1,(f_debug_restore_fade).w	; keep restored palette in fade buffer
		bsr.w	Debug_UpdateBackdrop		; restore level planes
		bsr.w	Debug_PaletteFadeIn		; fade back to the active level
		bsr.w	Debug_RemoveDebugGoggles	; clear debug-only goggles before returning to object debug
		bsr.w	Debug_ShowItem			; restore the currently selected debug item
		bra.w	Debug_StayInDebug

.checksonicview:
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; is Sonic sprite viewer active?
		bne.w	Debug_SonicViewControl		; if yes, branch

.normaldebug:
	endif ; if EnhancedDebug
		moveq	#0,d4
		move.w	#1,d1
		move.b	(v_jpadpress1).w,d4
		andi.w	#btnDir,d4	; is up/down/left/right pressed?
		bne.s	.dirpressed	; if yes, branch

		move.b	(v_jpadhold1).w,d0
		andi.w	#btnDir,d0	; is up/down/left/right held?
		bne.s	.dirheld	; if yes, branch

		move.b	#12,(v_debugspeedtimer).w
		move.b	#15,(v_debugspeed).w
		bra.w	Debug_ChgItem
; ===========================================================================

.dirheld:
		subq.b	#1,(v_debugspeedtimer).w
		bne.s	loc_1D01C
		move.b	#1,(v_debugspeedtimer).w
		addq.b	#1,(v_debugspeed).w
		bne.s	.dirpressed
		move.b	#-1,(v_debugspeed).w

.dirpressed:
		move.b	(v_jpadhold1).w,d4	; get held button presses

loc_1D01C:
		moveq	#0,d1
		move.b	(v_debugspeed).w,d1
		addq.w	#1,d1
		swap	d1
		asr.l	#4,d1
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		btst	#bitUp,d4	; is up being held?
		beq.s	loc_1D03C	; if not, branch
		sub.l	d1,d2
		bcc.s	loc_1D03C
		moveq	#0,d2

loc_1D03C:
		btst	#bitDn,d4	; is down being held?
		beq.s	loc_1D052	; if not, branch
		add.l	d1,d2
		cmpi.l	#$7FF0000,d2
		blo.s	loc_1D052
		move.l	#$7FF0000,d2

loc_1D052:
		btst	#bitL,d4	; is left being held?
		beq.s	loc_1D05E	; if not, branch
		sub.l	d1,d3
		bcc.s	loc_1D05E
		moveq	#0,d3

loc_1D05E:
		btst	#bitR,d4	; is right being held?
		beq.s	loc_1D066	; if not, branch
		add.l	d1,d3

loc_1D066:
		move.l	d2,obY(a0)
		move.l	d3,obX(a0)

Debug_ChgItem:
	if Enhanced
		tst.b	(f_debug_6button).w			; is a six-button pad detected?
		beq.s	.threebutton				; if not, use original debug controls
		btst	#bitX,(v_jpadpress1ext).w		; was X pressed?
		beq.s	.checknext6				; if not, branch
		subq.b	#1,(v_debugitem).w			; go back 1 item
		bcc.s	.display
		add.b	d6,(v_debugitem).w
		bra.s	.display
; ===========================================================================

.checknext6:
		btst	#bitZ,(v_jpadpress1ext).w		; was Z pressed?
		beq.s	.createitem6				; if not, branch
		addq.b	#1,(v_debugitem).w			; go forwards 1 item
		cmp.b	(v_debugitem).w,d6
		bhi.s	.display
		move.b	#0,(v_debugitem).w			; loop back to first item
		bra.s	.display
; ===========================================================================

.createitem6:
		move.b	(v_jpadpress1).w,d0			; get pressed face buttons
		andi.b	#btnABC,d0				; were A, B, or C pressed?
		bne.s	.createitemnow				; if yes, place the current debug object
		btst	#bitMode,(v_jpadpress1ext).w		; was Mode pressed?
		bne.w	Debug_Exit				; if yes, leave debug mode
		bra.w	Debug_StayInDebug			; otherwise, remain in debug mode
; ===========================================================================

.threebutton:
	endif ; if Enhanced
		btst	#bitA,(v_jpadhold1).w ; is button A held?
		beq.s	.createitem	; if not, branch
		btst	#bitC,(v_jpadpress1).w ; is button C pressed?
		beq.s	.nextitem	; if not, branch
		subq.b	#1,(v_debugitem).w ; go back 1 item
		bcc.s	.display
		add.b	d6,(v_debugitem).w
		bra.s	.display
; ===========================================================================

.nextitem:
		btst	#bitA,(v_jpadpress1).w ; is button A pressed?
		beq.s	.createitem	; if not, branch
		addq.b	#1,(v_debugitem).w ; go forwards 1 item
		cmp.b	(v_debugitem).w,d6
		bhi.s	.display
		move.b	#0,(v_debugitem).w ; loop back to first item

.display:
		bra.w	Debug_ShowItem
; ===========================================================================

.createitem:
		btst	#bitC,(v_jpadpress1).w ; is button C pressed?
		beq.s	.backtonormal	; if not, branch

.createitemnow:
		jsr	(FindFreeObj).l
		bne.s	.backtonormal

	if (EnhancedDebug)|(FixBugs)
		; fix not being able to place more rings and such after collecting one
		clr.b	(v_objstate+2).w
	endif ; if (EnhancedDebug)|(FixBugs)

		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		_move.b	obMap(a0),obID(a1)	; create object
		move.b	obRender(a0),obRender(a1)
		move.b	obRender(a0),obStatus(a1)
		andi.b	#$7F,obStatus(a1)
		moveq	#0,d0
		move.b	(v_debugitem).w,d0
		lsl.w	#3,d0
		move.b	4(a2,d0.w),obSubtype(a1)
		rts
; ===========================================================================

.backtonormal:
		btst	#bitB,(v_jpadpress1).w 	; is button B pressed?
	if EnhancedDebug
		beq.w	Debug_StayInDebug	; if not, branch
	else
		beq.s	Debug_StayInDebug	; if not, branch
	endif ; if EnhancedDebug

Debug_Exit:
		moveq	#0,d0
		move.w	d0,(v_debuguse).w 		; deactivate debug mode
	if EnhancedDebug
		btst	#bitDebugSonicSpriteView,(f_debugmode).w ; are we leaving from Sonic sprite viewer?
		beq.s	.sonicrestored			; if not, branch
		bsr.w	Debug_RestoreSonicViewState	; restore world position before re-entering the level

.sonicrestored:
		tst.b	(v_debug_hide_bg).w		; are background layers hidden?
		beq.s	.bgshownexit			; if not, branch
		bsr.w	Debug_PaletteFadeOut		; hide viewer before restoring level graphics
		clr.b	(v_debug_hide_bg).w		; mark background as visible
		move.b	#1,(f_debug_restore_fade).w	; keep restored palette in fade buffer
		bsr.w	Debug_UpdateBackdrop		; restore level planes
		bsr.w	Debug_PaletteFadeIn		; fade back to the active level

.bgshownexit:
		bsr.w	Debug_RemoveDebugGoggles	; clear debug-only goggles before leaving debug
		bclr	#bitDebugSonicSpriteView,(f_debugmode).w ; exit Sonic sprite viewer
	endif ; if EnhancedDebug

	if EnhancedDebug
		bsr.w   Hud_Base
		move.b	#1,(f_scorecount).w 	; update score counter
		move.b	#1,(f_ringcount).w  	; update rings counter
	endif ; if EnhancedDebug

		move.l	#Map_Sonic,(v_player+obMap).w
		move.w	#ArtTile_Sonic,(v_player+obGfx).w
		move.b	d0,(v_player+obAnim).w
		move.w	d0,obX+2(a0)
		move.w	d0,obY+2(a0)
		move.w	(v_limittopdb).w,(v_limittop2).w 	; restore level boundaries
		move.w	(v_limitbtmdb).w,(v_limitbtm1).w
		cmpi.b	#id_Special,(v_gamemode).w 				; are you in the special stage?
		bne.s	Debug_StayInDebug	; if not, branch

		clr.w	(v_ssangle).w
		move.w	#$40,(v_ssrotate).w ; set new level rotation speed
		move.l	#Map_Sonic,(v_player+obMap).w
		move.w	#ArtTile_Sonic,(v_player+obGfx).w
		move.b	#id_Roll,(v_player+obAnim).w
		bset	#2,(v_player+obStatus).w
		bset	#1,(v_player+obStatus).w

Debug_StayInDebug:
		rts
; End of function Debug_Control
; ===========================================================================

	if EnhancedDebug
; ---------------------------------------------------------------------------
; Six-button debug helper to inspect Sonic frames and goggles overlays.
; Y toggles this mode. X/Z scroll Sonic frames, A/C scroll goggles art frames,
; and the D-pad adjusts the goggles overlay offset for note-taking.
; ---------------------------------------------------------------------------

Debug_SonicViewControl:
		clearRAM v_spritequeue,v_spritequeue+$400 ; only Sonic and the overlay should be queued in this debug view
		clearRAM v_spritetablebuffer,v_spritetablebuffer_end ; remove stale HUD/stage sprites from the previous frame
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded ; keep the debug HUD screen-relative
		clr.l	(v_scrposy_vdp).w		; keep the debug HUD at an absolute screen position
		move.l	#Map_Sonic,obMap(a0)		; show Sonic mappings instead of a debug object
		move.w	#ArtTile_Sonic,obGfx(a0)	; use Sonic's art tile
		move.w	#$120,obX(a0)			; center Sonic in screen-space coordinates
		move.w	#$F8,obScreenY(a0)		; keep Sonic vertically centered for overlay checks
		move.b	#0,obRender(a0)			; use screen-space coordinates
		move.b	#2,obPriority(a0)		; use Sonic's normal priority

		btst	#bitX,(v_jpadpress1ext).w	; was X pressed?
		beq.s	.checknextframe		; if not, branch
		subq.b	#1,(v_debug_sonic_frame).w	; go back one Sonic frame
		cmpi.b	#fr_Stand,(v_debug_sonic_frame).w ; did we go before the first visible frame?
		bhs.s	.applyframe			; if not, branch
		move.b	#fr_WaterSlide,(v_debug_sonic_frame).w ; wrap to last base Sonic frame
		bra.s	.applyframe

.checknextframe:
		btst	#bitZ,(v_jpadpress1ext).w	; was Z pressed?
		beq.s	.checkprevart			; if not, branch
		addq.b	#1,(v_debug_sonic_frame).w	; go forwards one Sonic frame
		cmpi.b	#fr_WaterSlide+1,(v_debug_sonic_frame).w ; past last base Sonic frame?
		blo.s	.applyframe			; if not, branch
		move.b	#fr_Stand,(v_debug_sonic_frame).w ; wrap to first visible frame

.applyframe:
		move.b	(v_debug_sonic_frame).w,obFrame(a0) ; show selected Sonic frame
		bsr.w	Debug_ResetSonicViewGoggles	; reset to default goggles for this frame

.checkprevart:
		btst	#bitA,(v_jpadpress1).w		; was A pressed?
		beq.s	.checknextart			; if not, branch
		cmpi.b	#-1,(v_debug_goggle_art).w	; is no goggles selected?
		bne.s	.prevart			; if not, branch
		move.b	#GogglesArt_Count-1,(v_debug_goggle_art).w ; wrap to last goggles art frame
		bra.s	.checkoffset

.prevart:
		subq.b	#1,(v_debug_goggle_art).w	; go back one goggles art frame
		bcc.s	.checkoffset
		move.b	#-1,(v_debug_goggle_art).w	; wrap to no goggles
		bra.s	.checkoffset

.checknextart:
		btst	#bitC,(v_jpadpress1).w		; was C pressed?
		beq.s	.checkoffset			; if not, branch
		addq.b	#1,(v_debug_goggle_art).w	; go forwards one goggles art frame
		cmpi.b	#GogglesArt_Count,(v_debug_goggle_art).w ; past last goggles art frame?
		blo.s	.checkoffset			; if not, branch
		move.b	#-1,(v_debug_goggle_art).w	; wrap to no goggles

.checkoffset:
		btst	#bitMode,(v_jpadpress1ext).w	; was Mode pressed?
		beq.s	.checkdirections		; if not, branch
		addq.b	#1,(v_debug_goggle_flip).w	; cycle goggles flip adjustment
		andi.b	#$F,(v_debug_goggle_flip).w	; include all rotation and flip modes

.checkdirections:
		move.b	(v_jpadpress1).w,d0		; get pressed D-pad buttons
		btst	#bitL,d0			; was left pressed?
		beq.s	.checkright			; if not, branch
		subq.b	#1,(v_debug_goggle_x).w		; move goggles left

.checkright:
		btst	#bitR,d0			; was right pressed?
		beq.s	.checkup			; if not, branch
		addq.b	#1,(v_debug_goggle_x).w		; move goggles right

.checkup:
		btst	#bitUp,d0			; was up pressed?
		beq.s	.checkdown			; if not, branch
		subq.b	#1,(v_debug_goggle_y).w		; move goggles up

.checkdown:
		btst	#bitDn,d0			; was down pressed?
		beq.s	.return				; if not, branch
		addq.b	#1,(v_debug_goggle_y).w		; move goggles down

.return:
		move.b	(v_debug_sonic_frame).w,obFrame(a0) ; show selected Sonic frame
		move.b	#$FF,(v_gogglesobj+objoff_30).w ; force goggles art to match this frame immediately
		jsr	(Sonic_LoadGfx).l		; load the selected Sonic frame art
		rts

Debug_ResetSonicViewGoggles:
		clr.b	(v_debug_goggle_x).w		; clear debug goggles X adjustment
		clr.b	(v_debug_goggle_y).w		; clear debug goggles Y adjustment
		clr.b	(v_debug_goggle_flip).w		; clear debug goggles flip adjustment
		moveq	#0,d0
		move.b	(v_debug_sonic_frame).w,d0	; get selected Sonic frame
		cmpi.b	#Goggles_FrameMap_End-Goggles_FrameMap,d0 ; is this frame in the goggles map?
		bhs.s	.nogoggles			; if not, branch
		lea	(Goggles_FrameMap).l,a1		; load frame conversion table
		move.b	(a1,d0.w),d0			; get goggles frame
		bmi.s	.nogoggles			; if incompatible, branch
		move.b	d0,d1				; keep goggles frame for default transform mode
		lea	(Goggles_ArtFrameMap).l,a1	; load art-frame conversion table
		move.b	(a1,d0.w),(v_debug_goggle_art).w ; use code-defined art frame
		move.b	d0,(v_gogglesobj+obFrame).w	; keep the overlay mapping in step with Sonic
		move.b	#$FF,(v_gogglesobj+objoff_30).w ; force the new art frame to upload this frame
		andi.w	#$FF,d1
		lea	(Goggles_FrameModeMap).l,a1	; load transform-mode conversion table
		move.b	(a1,d1.w),(v_debug_goggle_flip).w ; use code-defined transform mode
		rts

.nogoggles:
		move.b	#-1,(v_debug_goggle_art).w	; default to no goggles on unmapped frames
		rts

Debug_EnsureGogglesObject:
		cmpi.b	#id_ShieldItem,(v_gogglesobj).w	; is the goggles object already active?
		bne.s	.init				; if not, initialise it
		cmpi.b	#$80,(v_gogglesobj+obAnim).w	; is it the goggles overlay?
		beq.s	.return				; if yes, branch

.init:
		move.b	#id_ShieldItem,(v_gogglesobj).w	; load goggles object
		clr.b	(v_gogglesobj+obRoutine).w	; start from object init
		move.b	#$80,(v_gogglesobj+obAnim).w	; mark object as goggles, not stars
		move.b	#$FF,(v_gogglesobj+objoff_30).w	; force the first goggles frame upload

.return:
		rts

Debug_RemoveDebugGoggles:
		tst.b	(v_goggles).w			; does Sonic really have goggles?
		bne.s	.return				; if yes, keep the overlay object
		clearRAM v_gogglesobj,v_gogglesobj+object_size ; remove debug-only goggles object

.return:
		rts

Debug_SaveSonicViewState:
		move.w	obX(a0),objoff_2A(a0)		; save debug/Sonic X before screen-space viewer writes
		move.w	obY(a0),objoff_2C(a0)		; save debug/Sonic Y before screen-space viewer writes
		move.b	obRender(a0),objoff_29(a0)	; save coordinate mode
		move.b	obPriority(a0),objoff_2E(a0)	; save sprite priority
		rts

Debug_RestoreSonicViewState:
		lea	(v_player).w,a0			; restore the real player/debug object slot
		move.w	objoff_2A(a0),obX(a0)		; restore X position
		move.w	objoff_2C(a0),obY(a0)		; restore Y position
		clr.w	obX+2(a0)			; clear viewer screen-Y alias/subpixel value
		clr.w	obY+2(a0)			; clear stale subpixel value
		move.b	objoff_29(a0),obRender(a0)	; restore coordinate mode
		move.b	objoff_2E(a0),obPriority(a0)	; restore priority
		move.l	#Map_Sonic,obMap(a0)		; restore Sonic mappings after the viewer
		move.w	#ArtTile_Sonic,obGfx(a0)	; restore Sonic art tile
		rts

Debug_BackdropTile:	equ ArtTile_Sonic-1 ; blank tile outside HUD/debug art
Debug_BackdropLong:	equ (Debug_BackdropTile<<16)|Debug_BackdropTile

Debug_LoadSonicViewFont:
		disable_ints
		lea	(vdp_data_port).l,a6
		locVRAM	ArtTile_Level_Select_Font*tile_size,4(a6) ; load debug text font
		lea	(Art_Text).l,a5
		move.w	#(Art_Text_end-Art_Text)/2-1,d1

.loadfont:
		move.w	(a5)+,(a6)
		dbf	d1,.loadfont

		locVRAM	Debug_BackdropTile*tile_size,4(a6) ; blank tile for cleared debug rows
		moveq	#8-1,d1

.cleartile:
		move.l	#0,(a6)
		dbf	d1,.cleartile

		lea	(v_palette_line_4).w,a1		; give the debug font a stable white palette
		move.w	#cBlack,(a1)+
		moveq	#15-1,d1

.setwhite:
		move.w	#cWhite,(a1)+
		dbf	d1,.setwhite
		enable_ints
		rts

Debug_PrepareSonicViewPalette:
		lea	(v_palette).w,a1		; preserve Sonic and goggles colours for the viewer
		lea	(v_palette_fading).w,a2
		moveq	#((v_palette_end-v_palette)/4)-1,d0

.copypal:
		move.l	(a1)+,(a2)+
		dbf	d0,.copypal

		lea	(v_palette_water).w,a1		; preserve underwater colours too
		lea	(v_palette_water_fading).w,a2
		moveq	#((v_palette_water_end-v_palette_water)/4)-1,d0

.copywaterpal:
		move.l	(a1)+,(a2)+
		dbf	d0,.copywaterpal

		move.w	#cMagenta,(v_palette_fading).w	; magenta backdrop colour
		move.w	#cMagenta,(v_palette_water_fading).w ; magenta underwater backdrop colour
		lea	(v_palette_fading_line_4).w,a1	; debug text uses palette line 4
		move.w	#cBlack,(a1)+
		moveq	#15-1,d1

.setwhite:
		move.w	#cWhite,(a1)+
		dbf	d1,.setwhite
		rts

Debug_PaletteFadeOut:
		movem.l	d0-d7/a0-a6,-(sp)
		jsr	(PaletteFadeOut).l
		movem.l	(sp)+,d0-d7/a0-a6
		rts

Debug_PaletteFadeIn:
		movem.l	d0-d7/a0-a6,-(sp)
		jsr	(PaletteFadeIn).l
		movem.l	(sp)+,d0-d7/a0-a6
		rts

Debug_UpdateBackdrop:
		tst.b	(v_debug_hide_bg).w		; should the background be hidden?
		beq.w	.restore			; if not, restore normal planes
		move.w	#cMagenta,(v_palette).w		; keep VBlank palette transfer on the calibration colour
		move.w	#cMagenta,(v_palette_water).w	; keep underwater palette on the calibration colour
		clearRAM v_fg_scroll_flags,v_bg3_scroll_flags+2 ; stop tile redraw flags from restoring hidden planes
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded ; keep the debug planes fixed
		clr.l	(v_scrposy_vdp).w		; keep the debug planes fixed vertically
		disable_ints
		lea	(vdp_data_port).l,a6
		move.w	#$8700,(vdp_control_port).l	; use palette line 0 colour 0 for the backdrop
		move.l	#$40000010,(vdp_control_port).l	; set VDP to VSRAM write mode
		move.l	#0,(vdp_data_port).l		; clear vertical scroll immediately
		locVRAM	Debug_BackdropTile*tile_size,4(a6) ; clear the calibration backdrop tile
		moveq	#8-1,d0

.cleartile:
		move.l	#0,(a6)
		dbf	d0,.cleartile

		locVRAM	vram_fg,4(a6)			; clear foreground plane
		move.w	#plane_size_64x32/4-1,d0

.clearfg:
		move.l	#Debug_BackdropLong,(a6)
		dbf	d0,.clearfg

		locVRAM	vram_bg,4(a6)			; clear background plane
		move.w	#plane_size_64x32/4-1,d0

.clearbg:
		move.l	#Debug_BackdropLong,(a6)
		dbf	d0,.clearbg

		move.l	#$C0000000,4(a6)		; write CRAM colour 0
		move.w	#cMagenta,(a6)			; use magenta backdrop for sprite calibration
		enable_ints
		rts

.restore:
		movem.l	d0-d7/a0-a6,-(sp)
		jsr	(LevSel_RestoreLevelDisplay).l	; restore planes, palettes, and common art
		jsr	(Hud_Base).l			; reload HUD art overwritten by debug text
		move.b	#1,(f_scorecount).w		; refresh score after returning to object debug
		move.b	#1,(f_ringcount).w		; refresh rings after returning to object debug
		move.b	#1,(f_timecount).w		; refresh time after returning to object debug
		move.w	#4-1,d1				; let restored common art start loading

.delay:
		move.b	#id_VBlank_Levels,(v_vblank_routine).w
		jsr	(WaitForVBlank).l
		jsr	(RunPLC).l
		dbf	d1,.delay

.waitplc:
		tst.l	(v_plc_queue_base).w		; has restored common art finished loading?
		bne.s	.runplc				; if not, keep waiting
		tst.w	(v_plc_patternsleft).w		; is the final restored chunk still decompressing?
		beq.s	.plcdone			; if not, branch

.runplc:
		move.b	#id_VBlank_Levels,(v_vblank_routine).w
		jsr	(WaitForVBlank).l
		jsr	(RunPLC).l
		bra.s	.waitplc

.plcdone:
		tst.b	(f_debug_restore_fade).w	; should caller fade from black to restored palette?
		beq.s	.copyactivepal			; if not, copy restored palette immediately
		clr.b	(f_debug_restore_fade).w	; consume fade request
		bra.s	.donepal			; leave target palette for PaletteFadeIn

.copyactivepal:
		lea	(v_palette_fading_line_2).w,a1	; restore the prepared stage palette without fading to black
		lea	(v_palette_line_2).w,a2
		moveq	#((v_palette_end-v_palette_line_2)/4)-1,d0

.restorepalloop:
		move.l	(a1)+,(a2)+
		dbf	d0,.restorepalloop

		lea	(v_palette_water_fading+$20).w,a1
		lea	(v_palette_water_line_2).w,a2
		moveq	#((v_palette_water_end-v_palette_water_line_2)/4)-1,d0

.restorewaterpal:
		move.l	(a1)+,(a2)+
		dbf	d0,.restorewaterpal

.donepal:
		movem.l	(sp)+,d0-d7/a0-a6
		rts
	endif ; if EnhancedDebug
; ===========================================================================

Debug_ShowItem:
		moveq	#0,d0
		move.b	(v_debugitem).w,d0
		lsl.w	#3,d0
		move.l	(a2,d0.w),obMap(a0) ; load mappings for item
		move.w	6(a2,d0.w),obGfx(a0) ; load VRAM setting for item
		move.b	5(a2,d0.w),obFrame(a0) ; load frame number for item
		rts
; End of function Debug_ShowItem
