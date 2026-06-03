; ===========================================================================
; ---------------------------------------------------------------------------
; Object 01 - Sonic the Hedgehog
; ---------------------------------------------------------------------------

; Obj01:
SonicPlayer:
		tst.w	(v_debuguse).w				; is debug mode being used?
		beq.s	Sonic_Normal				; if not, branch
		jmp	(DebugMode).l				; run debug mode instead of Sonic object
; ===========================================================================

; Obj01_Normal:
Sonic_Normal:
		moveq	#0,d0					; clear d0
		move.b	obRoutine(a0),d0			; get current routine number
		move.w	Sonic_Index(pc,d0.w),d1			; find appropriate entry in jump table
		jmp	Sonic_Index(pc,d1.w)			; jump there
; ===========================================================================
; Obj01_Index:
Sonic_Index:	dc.w Sonic_Main-Sonic_Index			; 0 - object init
		dc.w Sonic_Control-Sonic_Index			; 2 - main mode
		dc.w Sonic_Hurt-Sonic_Index			; 4 - while being knocked back from damage
		dc.w Sonic_Death-Sonic_Index			; 6 - while dying and falling off screen
		dc.w Sonic_ResetLevel-Sonic_Index		; 8 - after having died and waiting for the level to restart
	if FixBugScatteredRingsTimer
		dc.w Sonic_Drowned-Sonic_Index
	endif ; if FixBugScatteredRingsTimer
; ===========================================================================

; Obj01_Main:
Sonic_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; set to Sonic_Control
		move.b	#sonic_height,obHeight(a0)		; set default height
		move.b	#sonic_width,obWidth(a0)		; set default width
		move.l	#Map_Sonic,obMap(a0)			; set mappings
		move.w	#ArtTile_Sonic,obGfx(a0)		; set VRAM location
		move.b	#2,obPriority(a0)			; set sprite priority
		move.b	#$18,obActWid(a0)			; set render width
		move.b	#4,obRender(a0)				; set to playfield-positioned mode
		move.w	#$600,(v_sonspeedmax).w			; set Sonic's top speed
		move.w	#$C,(v_sonspeedacc).w			; set Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w			; set Sonic's deceleration
; ---------------------------------------------------------------------------

; Obj01_Control:
Sonic_Control:	; Routine 2
	if AdvancedDebugger
		move.b	(v_jpadpress1).w,d0			; get pressed buttons
		andi.b	#btnA|btnStart,d0			; are A and Start pressed?
		cmpi.b	#btnA|btnStart,d0
		bne.s	Sonic_DebugSkip
		RaiseError "Intentional crash test:%<endl>Level ID = %<.w $FFFFFE10>%<endl>Frame = %<.w $FFFFFE04>",SampleLevelDebugger
Sonic_DebugSkip:
	endif ; if AdvancedDebugger

	if FixBugVictoryDebug
		tst.b	(f_victory).w				; is victory flag set?
		bne.w	Sonic_Control_Nodebug			; if yes, branch
	endif ; if FixBugVictoryDebug

	if Debug=0
		tst.w	(f_debugmode).w				; is debug cheat enabled?
		beq.s	Sonic_Control_Nodebug			; if not, branch
	endif ; if Debug=0

	if FeatureCDExtendedCamera
		bsr.s Sonic_PanCamera
	endif ; if FeatureCDExtendedCamera

	if Enhanced
		tst.b	(f_debug_6button).w			; is a six-button pad detected?
		beq.s	.chkdebug3button			; if not, branch
		btst	#bitMode,(v_jpadpress1ext).w		; is Mode pressed?
		beq.w	Sonic_Control_Nodebug			; if not, branch
		bra.s	.enterdebug

.chkdebug3button:
	endif ; if Enhanced
		btst	#bitB,(v_jpadpress1).w			; is button B pressed?
	if Enhanced
		beq.w	Sonic_Control_Nodebug			; if not, branch
	else
		beq.s	Sonic_Control_Nodebug			; if not, branch
	endif ; if Enhanced
.enterdebug:
		move.w	#1,(v_debuguse).w			; enter debug mode on the next frame (change Sonic into a ring/item)
		clr.b	(f_lockctrl).w				; unlock controls
		rts

	if FeatureCDExtendedCamera
		include "Enhancements/_incObj/Sonic_PanCamera.asm"
	endif ; if FeatureCDExtendedCamera

	; return
; ===========================================================================

; loc_12C58:
Sonic_Control_Nodebug:
		tst.b	(f_lockctrl).w				; are controls locked?
		bne.s	.ignorecontrols				; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w		; enable joypad control

; loc_12C64:
.ignorecontrols:
		btst	#0,(f_playerctrl).w			; is control override flag set?
		bne.s	.ignoremodes				; if yes, don't run Sonic_Modes

		moveq	#0,d0					; clear d0
		move.b	obStatus(a0),d0				; get Sonic's status flags
		andi.w	#%0110,d0				; limit to "is in air" and "rolling" flags
		move.w	Sonic_Modes(pc,d0.w),d1			; use the those as routine counter for the correct mode
		jsr	Sonic_Modes(pc,d1.w)			; jump to that mode

; loc_12C7E:
.ignoremodes:
	if FeatureSonic2013SuperSonic
		bsr.w	Sonic2013_CheckSuperActivation		; transform after a qualifying jump press
		bsr.w	Sonic2013_UpdateSuperSonic		; keep Super state and ring drain current
	endif ; if FeatureSonic2013SuperSonic
		bsr.s	Sonic_Display				; display Sonic sprite and handle power-up expiration
		bsr.w	Sonic_RecordPosition			; record Sonic's previous position for the invincibility stars trail
		bsr.w	Sonic_Water				; handle Sonic while in water (LZ only)
		move.b	(v_anglebuffer).w,angleright(a0)	; update front collision hot spot
		move.b	(v_anglebuffer2).w,angleleft(a0)	; update rear collision hot spot

		tst.b	(f_wtunnelmode).w			; is Sonic in a wind tunnel? (LZ only)
		beq.s	.nowindtunnel				; if not, branch
		tst.b	obAnim(a0)				; is current animation null/id_Walk?
		bne.s	.nowindtunnel				; if not, branch
		move.b	obPrevAni(a0),obAnim(a0)		; make sure Sonic is in the correct animation while in a wind tunnel

; loc_12CA6:
.nowindtunnel:
		bsr.w	Sonic_Animate				; run Sonic's animation scripts
		tst.b	(f_playerctrl).w			; is object interactions ignore flag set?
		bmi.s	.ignoreobjcoll				; if yes, branch
		jsr	(ReactToItem).l				; handle object interaction with Sonic
	if FixBugClearStalePushing
		bsr.w	Sonic_CheckPushingObject		; clear stale pushing after object collision has refreshed it
	endif ; if FixBugClearStalePushing

; loc_12CB6:
.ignoreobjcoll:
		bsr.w	Sonic_Loops				; handle Sonic running through loops
		bsr.w	Sonic_LoadGfx				; update Sonic's graphics if necessary
		rts						; return
; End of function Sonic_Control


; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic modes table, based on whether he is currently in-air and/or rolling.
; This jump table uses Sonic's actual state bits in obStatus for the index.
; ---------------------------------------------------------------------------
; Obj01_Modes:
Sonic_Modes:	dc.w Sonic_MdNormal-Sonic_Modes			; 0 - while on the ground and not rolling
		dc.w Sonic_MdJump-Sonic_Modes			; 2 - while in the air and not rolling
		dc.w Sonic_MdRoll-Sonic_Modes			; 4 - while on the ground and rolling
		dc.w Sonic_MdJump2-Sonic_Modes			; 6 - while in the air and rolling


; ===========================================================================
; ---------------------------------------------------------------------------
; Music to play after invincibility wears off
; (This is pretty much identical to the first MusicList, so it doesn't
; really make any sense as to why invincibility gets a separate one...)
; ---------------------------------------------------------------------------
MusicList2:
		dc.b bgm_GHZ					; 00 - Green Hill Zone
		dc.b bgm_LZ					; 01 - Labyrinth Zone
		dc.b bgm_MZ					; 02 - Marble Zone
		dc.b bgm_SLZ					; 03 - Star Light Zone
		dc.b bgm_SYZ					; 04 - Spring Yard Zone
		dc.b bgm_SBZ					; 05 - Scrap Brain Zone
		zonewarning MusicList2,1
		; The ending doesn't get an entry
		even


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display Sonic and set music
; ---------------------------------------------------------------------------

Sonic_Display:
		move.w	flashtime(a0),d0			; get Sonic's remaining invulnerability frames after getting hurt
		beq.s	.display				; if there are none, branch
		subq.w	#1,flashtime(a0)			; decrease invulnerability frames
		lsr.w	#3,d0					; don't render Sonic's sprite every...
		bcc.s	.chkinvincible				; ...3 or 4 frames

; Obj01_Display:
.display:
		jsr	(DisplaySprite).l			; display Sonic sprite normally

; Obj01_ChkInvin:
.chkinvincible:
		tst.b	(v_invinc).w				; does Sonic have invincibility?
		beq.s	.chkshoes				; if not, branch
	if FeatureSonic2013SuperSonic
		tst.b	(v_supersonic).w			; is pseudo Super Sonic active?
		bne.s	.chkshoes				; if yes, keep invincibility from expiring by timer
	endif ; if FeatureSonic2013SuperSonic
		tst.w	invtime(a0)				; check time remaining for invinciblity
	if FixBugInvincibleMusic
		beq.s	.restoremusic				; if no time remains, restore normal state
	else
		beq.s	.chkshoes				; if no time remains, branch
	endif ; if FixBugInvincibleMusic
		subq.w	#1,invtime(a0)				; subtract 1 from time
		bne.s	.chkshoes				; if time remains, branch

	if FixBugInvincibleMusic
.restoremusic:
	endif ; if FixBugInvincibleMusic
		tst.b	(f_lockscreen).w			; is a boss fight active?
		bne.s	.removeinvincible			; if yes, don't change music
		cmpi.w	#12,(v_air).w				; is drowning countdown active?
		blo.s	.removeinvincible			; if yes, don't change music

		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current zone ID
		cmpi.w	#id_LZ_act4,(v_zone).w			; check if level is SBZ3 (LZ4)
		bne.s	.music					; if not, branch
		moveq	#5,d0					; play SBZ music instead of LZ

; Obj01_PlayMusic:
.music:
		lea	(MusicList2).l,a1			; load music list for post-invincibility
		move.b	(a1,d0.w),d0				; get entry for current zone
		play_queued_music snd_jsr			; resume normal level music
	if FixBugInvincibleMusic
		tst.b	(v_shoes).w				; are speed shoes still active?
		beq.s	.removeinvincible			; if not, branch
		tst.w	shoetime(a0)				; is there speed shoes time remaining?
		beq.s	.removeinvincible			; if not, let the shoes expiry path restore tempo
		music	#bgm_Speedup,snd_jsr			; keep speed shoes tempo after invincibility ends
	endif ; if FixBugInvincibleMusic

; Obj01_RmvInvin:
.removeinvincible:
		move.b	#0,(v_invinc).w				; cancel invincibility
	if FixBugInvincibleMusic
		clr.w	invtime(a0)				; clear any stale invincibility timer state
	endif ; if FixBugInvincibleMusic

; Obj01_ChkShoes:
.chkshoes:
	if FeatureSonic2013SuperSonic
		tst.b	(v_supersonic).w			; is pseudo Super Sonic active?
		bne.s	.return				; if yes, don't expire the Super speed state here
	endif ; if FeatureSonic2013SuperSonic
		tst.b	(v_shoes).w				; does Sonic have speed shoes?
		beq.s	.return					; if not, branch
		tst.w	shoetime(a0)				; check time remaining
	if FixBugInvincibleMusic
		beq.s	.removeshoes				; if there is none, restore normal speed
	else
		beq.s	.return					; if there is none, branch
	endif ; if FixBugInvincibleMusic
		subq.w	#1,shoetime(a0)				; subtract 1 from time
		bne.s	.return					; if time remains, branch
.removeshoes:
		move.w	#$600,(v_sonspeedmax).w			; restore Sonic's max speed
		move.w	#$C,(v_sonspeedacc).w			; restore Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w			; restore Sonic's deceleration
		move.b	#0,(v_shoes).w				; cancel speed shoes
	if FixBugInvincibleMusic
		clr.w	shoetime(a0)				; clear any stale speed shoes timer state
	endif ; if FixBugInvincibleMusic
		music	#bgm_Slowdown,snd_jmp			; resume music at normal speed

; ===========================================================================

; Obj01_ExitChk:
.return:
		rts						; return
; End of function Sonic_Display

	if FeatureSonic2013SuperSonic
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic 2013-style pseudo Super Sonic.
; This keeps the original Sonic art and swaps palette/speed state only.
; ---------------------------------------------------------------------------

SuperSonicSpeedMax:	equ $F00
SuperSonicSpeedAcc:	equ $30
SuperSonicSpeedDec:	equ $100
SuperSonicRingTime:	equ 60-1

Sonic2013_CheckSuperActivation:
		tst.b	(v_supersonic).w			; already Super Sonic?
		bne.s	.return				; if yes, branch
		cmpi.b	#7,(v_emeralds).w			; do we have all seven emeralds?
		blo.s	.return				; if not, branch
		cmpi.w	#50,(v_rings).w			; do we have enough rings?
		blo.s	.return				; if not, branch
		btst	#1,obStatus(a0)			; is Sonic airborne after jumping?
		beq.s	.return				; if not, branch
		move.b	(v_jpadpress2).w,d0			; get jump presses
		andi.b	#btnABC,d0				; did A, B, or C trigger?
		beq.s	.return				; if not, branch
		bsr.s	Sonic2013_EnterSuperSonic		; transform

.return:
		rts

Sonic2013_UpdateSuperSonic:
		tst.b	(v_supersonic).w			; is Super Sonic active?
		beq.s	.return				; if not, branch
		tst.w	(v_rings).w				; are there any rings left?
		beq.w	Sonic2013_ExitSuperSonic		; if not, revert to normal
		subq.b	#1,(v_superringtimer).w		; drain one ring per second
		bpl.s	.keepsuper				; if timer remains, branch
		move.b	#SuperSonicRingTime,(v_superringtimer).w ; reset drain timer
		subq.w	#1,(v_rings).w			; spend one ring
		bpl.s	.ringsok				; if still positive, branch
		clr.w	(v_rings).w				; clamp underflow

.ringsok:
		move.b	#$80,(f_ringcount).w			; full refresh because Super drains rings downward
		tst.w	(v_rings).w				; did that spend the last ring?
		beq.w	Sonic2013_ExitSuperSonic		; if yes, revert

.keepsuper:
		move.b	#1,(v_invinc).w			; keep Super Sonic invulnerable
		move.b	#1,(v_shoes).w			; keep Super Sonic using the speed-shoes state
		clr.w	invtime(a0)				; do not use invincibility music/timer expiry
		clr.w	shoetime(a0)				; do not use speed-shoes music/timer expiry
		bsr.w	Sonic2013_ClearPowerUpObjects		; keep invincibility graphics disabled
		bsr.w	Sonic2013_ClearSpeedupTempo		; keep speed-shoes music speed disabled
		cmpi.w	#SuperSonicSpeedMax,(v_sonspeedmax).w ; were Super speeds overwritten?
		beq.s	.return				; if not, branch
		bsr.s	Sonic2013_SetSuperSpeeds		; restore speed values when another path overwrites them

.return:
		rts

Sonic2013_EnterSuperSonic:
		tst.b	(v_supersonic).w			; already transformed?
		bne.s	.return				; if yes, branch
		move.b	#1,(v_supersonic).w			; mark Super Sonic active
		move.b	#SuperSonicRingTime,(v_superringtimer).w ; start ring drain timer
		tst.w	invtime(a0)				; was invincibility music active before Super?
		bne.s	.restoremusic			; if yes, restore the level track
	if FeatureUseSonic2SoundDriver=0
		tst.b	(v_snddriver_ram.f_speedup).w		; was speed-shoes tempo active before Super?
		bne.s	.restoremusic			; if yes, restore the level track
	endif ; if FeatureUseSonic2SoundDriver=0
		bra.s	.musicok

.restoremusic:
		bsr.w	Sonic2013_RestoreLevelMusic		; only reset music if replacing a power-up track/tempo

.musicok:
		move.b	#1,(v_invinc).w			; Super Sonic is invulnerable
		clr.w	invtime(a0)				; do not use the normal invincibility timer
		move.b	#1,(v_shoes).w			; use the normal speed-shoes state without its timer/music
		clr.w	shoetime(a0)				; do not use the normal speed-shoes timer
		bsr.w	Sonic2013_ClearPowerUpObjects		; remove any invincibility stars from prior power-ups
		bsr.w	Sonic2013_ClearSpeedupTempo		; clear stale speed-shoes tempo state
		bsr.s	Sonic2013_SetSuperSpeeds		; apply fast movement stats
		bsr.w	Sonic2013_LoadSuperPalette		; tint Sonic yellow through palette only
		ori.b	#1,(f_ringcount).w			; refresh ring display

.return:
		rts

Sonic2013_ExitSuperSonic:
		clr.b	(v_supersonic).w			; clear Super Sonic flag
		clr.b	(v_superringtimer).w			; clear drain timer
		clr.b	(v_invinc).w				; remove Super invulnerability
		clr.b	(v_shoes).w				; remove Super speed-shoes state
		clr.w	invtime(a0)				; clear Super-owned invincibility timer
		clr.w	shoetime(a0)				; clear Super-owned speed-shoes timer
		bsr.s	Sonic2013_SetNormalSpeeds		; restore normal/water movement stats
		bsr.w	Sonic2013_LoadNormalSonicPalette	; restore Sonic palette
		rts

Sonic2013_SetSuperSpeeds:
		move.w	#SuperSonicSpeedMax,(v_sonspeedmax).w
		move.w	#SuperSonicSpeedAcc,(v_sonspeedacc).w
		move.w	#SuperSonicSpeedDec,(v_sonspeeddec).w
		rts

Sonic2013_SetNormalSpeeds:
		btst	#6,obStatus(a0)			; is Sonic underwater?
		beq.s	.dry				; if not, branch
		move.w	#$300,(v_sonspeedmax).w		; restore underwater max speed
		move.w	#6,(v_sonspeedacc).w		; restore underwater acceleration
		move.w	#$40,(v_sonspeeddec).w		; restore underwater deceleration
		rts

.dry:
		move.w	#$600,(v_sonspeedmax).w		; restore normal max speed
		move.w	#$C,(v_sonspeedacc).w		; restore normal acceleration
		move.w	#$80,(v_sonspeeddec).w		; restore normal deceleration
		rts

Sonic2013_ClearPowerUpObjects:
		clr.b	(v_starsobj1).w			; Super uses flags only, with no invincibility-star graphics
		clr.b	(v_starsobj2).w
		clr.b	(v_starsobj3).w
		clr.b	(v_starsobj4).w
		rts

Sonic2013_ClearSpeedupTempo:
	if FeatureUseSonic2SoundDriver=0
		clr.b	(v_snddriver_ram.f_speedup).w		; disable speed-shoes tempo without playing slowdown
	endif ; if FeatureUseSonic2SoundDriver=0
		rts

Sonic2013_RestoreLevelMusic:
		tst.b	(f_lockscreen).w			; is a boss fight active?
		bne.s	.return				; if yes, don't change music
		cmpi.w	#12,(v_air).w				; is drowning countdown active?
		blo.s	.return				; if yes, don't change music
		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current zone ID
		cmpi.w	#id_LZ_act4,(v_zone).w			; check if level is SBZ3 (LZ4)
		bne.s	.music				; if not, branch
		moveq	#5,d0					; play SBZ music instead of LZ

.music:
		lea	(MusicList2).l,a1			; load music list for the current level
		move.b	(a1,d0.w),d0				; get entry for current zone
		play_queued_music snd_jsr			; resume normal level music
.return:
		rts

Sonic2013_LoadSuperPalette:
		lea	(Pal_SuperSonic).l,a1			; use Sonic 2-like yellows with the original art
		bra.s	Sonic2013_LoadPaletteLine1

Sonic2013_LoadNormalSonicPalette:
		lea	(Pal_Sonic).l,a1

Sonic2013_LoadPaletteLine1:
		movem.l	d0/a1-a2,-(sp)
		lea	(v_palette_line_1).w,a2
		moveq	#($20/4)-1,d0			; one palette line, longword copy

.copy:
		move.l	(a1)+,(a2)+
		dbf	d0,.copy
		movem.l	(sp)+,d0/a1-a2
		rts

Sonic2013_TestSuperArt:
		moveq	#0,d0					; Super now uses a palette swap, not per-frame art recolouring
		rts

Pal_SuperSonic:
		dc.w	$0000,$0000,$0024,$006A,$008E,$00EE,$0EEE,$0AAA
		dc.w	$0888,$0444,$08AE,$046A,$000E,$0008,$0004,$00EE

SuperSonicBlueDark:	equ $E				; unused compatibility: old art remap darkest yellow
SuperSonicBlueMidDark:	equ $D				; unused compatibility: old art remap dark yellow
SuperSonicBlueMid:	equ $F				; unused compatibility: old art remap bright yellow
SuperSonicBlueLight:	equ $6				; unused compatibility: old art remap yellow-white

; ---------------------------------------------------------------------------
; Recolour Sonic's dynamic art buffer only. This keeps enemies and stage
; sprites that share Sonic's palette line from changing with Super Sonic.
; ---------------------------------------------------------------------------

Sonic2013_ApplySuperArt:
		movem.l	d0-d2/a1,-(sp)
		lea	(v_sgfx_buffer).w,a1
		move.l	a3,d1				; a3 points just after the DPLC art copied this frame
		subi.l	#v_sgfx_buffer,d1
		beq.w	.done				; no copied art to recolour
		subq.w	#1,d1				; DBF uses length minus 1

.loop:
		move.b	(a1),d0
		move.b	d0,d2
		andi.b	#$F0,d0
		cmpi.b	#$20,d0
		bne.s	.chkhighmiddark
		andi.b	#$0F,d2
		ori.b	#SuperSonicBlueDark<<4,d2
		bra.s	.chklow

.chkhighmiddark:
		cmpi.b	#$30,d0
		bne.s	.chkhighmid
		andi.b	#$0F,d2
		ori.b	#SuperSonicBlueMidDark<<4,d2
		bra.s	.chklow

.chkhighmid:
		cmpi.b	#$40,d0
		bne.s	.chkhighlight
		andi.b	#$0F,d2
		ori.b	#SuperSonicBlueMid<<4,d2
		bra.s	.chklow

.chkhighlight:
		cmpi.b	#$50,d0
		bne.s	.chklow
		andi.b	#$0F,d2
		ori.b	#SuperSonicBlueLight<<4,d2

.chklow:
		move.b	d2,d0
		andi.b	#$0F,d0
		cmpi.b	#$2,d0
		bne.s	.chklowmiddark
		andi.b	#$F0,d2
		ori.b	#SuperSonicBlueDark,d2
		bra.s	.store

.chklowmiddark:
		cmpi.b	#$3,d0
		bne.s	.chklowmid
		andi.b	#$F0,d2
		ori.b	#SuperSonicBlueMidDark,d2
		bra.s	.store

.chklowmid:
		cmpi.b	#$4,d0
		bne.s	.chklowlight
		andi.b	#$F0,d2
		ori.b	#SuperSonicBlueMid,d2
		bra.s	.store

.chklowlight:
		cmpi.b	#$5,d0
		bne.s	.store
		andi.b	#$F0,d2
		ori.b	#SuperSonicBlueLight,d2

.store:
		move.b	d2,(a1)+
		dbf	d1,.loop

.done:
		movem.l	(sp)+,d0-d2/a1
		rts
	endif ; if FeatureSonic2013SuperSonic


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to record Sonic's previous positions for invincibility stars.
; Interestingly, this buffer is way larger than it needs to be, with just
; over a full second of space for recorded data, even though the star trail
; won't ever be that long. Specifically, it's $100/4 = $40 (64 frames).
; ---------------------------------------------------------------------------

; Sonic_RecordPos:
Sonic_RecordPosition:
		move.w	(v_trackpos).w,d0			; get current index for the tracking array
		lea	(v_tracksonic).w,a1			; load tracking array
		lea	(a1,d0.w),a1				; set pointer to current index
		move.w	obX(a0),(a1)+				; store Sonic's current X-position
		move.w	obY(a0),(a1)+				; store Sonic's current Y-position
		addq.b	#4,(v_trackbyte).w			; advance to next tracking pointer (this is a byte, so it wraps from $FC back to $00)
		rts						; return
; End of function Sonic_RecordPosition


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

Sonic_Water:
		cmpi.b	#id_LZ,(v_zone).w			; is level LZ?
		beq.s	.islabyrinth				; if yes, branch

; locret_12D80:
.return:
		rts						; return
; ===========================================================================

; Obj01_InWater:
.islabyrinth:
		move.w	(v_waterpos1).w,d0			; get current water height
		cmp.w	obY(a0),d0				; is Sonic above the water?
		bge.s	.abovewater				; if yes, branch
		bset	#6,obStatus(a0)				; set underwater flag
		bne.s	.return					; was Sonic already underwater? if yes, nothing to do

		bsr.w	ResumeMusic				; replenish air (music won't resume here, we've only just entered water...)
		move.b	#id_DrownCount,(v_sonicbubbles).w	; load drown countdown object
		move.b	#$81,(v_sonicbubbles+obSubtype).w	; prepare subtype so it sets itself to Drown_Countdown
		move.w	#$300,(v_sonspeedmax).w			; change Sonic's top speed
		move.w	#6,(v_sonspeedacc).w			; change Sonic's acceleration
		move.w	#$40,(v_sonspeeddec).w			; change Sonic's deceleration
		asr.w	obVelX(a0)				; half X-speed when entering water
		asr.w	obVelY(a0)				; divide Y-speed by 4 when entering water
		asr.w	obVelY(a0)				; (can only do one bit shift at a time on RAM)
		beq.s	.return					; if Sonic's new Y-speed is 0, don't load splash object
		move.b	#id_Splash,(v_splash).w			; load splash object

	if FeatureSpindash=1
		move.w	#$100,(v_spindashdust+obAnim).w		; set the spin dash dust animation to splash
	endif

		sfx	#sfx_Splash,snd_jmp			; set splash sound and play it
; ===========================================================================

; Obj01_OutWater:
.abovewater:
		bclr	#6,obStatus(a0)				; clear underwater flag
		beq.s	.return					; was Sonic already above water? if yes, nothing to do

		bsr.w	ResumeMusic				; replenish air and resume music if necessary
		move.w	#$600,(v_sonspeedmax).w			; restore Sonic's speed
		move.w	#$C,(v_sonspeedacc).w			; restore Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w			; restore Sonic's deceleration
		asl.w	obVelY(a0)				; double Y-speed while exiting water

	if TweakFixHurtWaterPhystics
		tst.w	obVelY(a0)				; test Sonic's vertical velocity
	endif ; if TweakFixHurtWaterPhystics

		beq.w	.return					; if Sonic's new Y-speed is 0, don't load splash object
		move.b	#id_Splash,(v_splash).w			; load splash object
		cmpi.w	#-$1000,obVelY(a0)			; is Sonic's new upwards speed too fast for collision detection to handle? (red springs probably cause this)
		bgt.s	.belowmaxspeed				; if not, branch
		move.w	#-$1000,obVelY(a0)			; set maximum speed on leaving water

; loc_12E0E:
.belowmaxspeed:
		sfx	#sfx_Splash,snd_jmp			; set splash sound and play it

; End of function Sonic_Water


; ===========================================================================
; ---------------------------------------------------------------------------
; Modes for controlling Sonic
; ---------------------------------------------------------------------------

; Obj01_MdNormal:
Sonic_MdNormal:	; While Sonic is on the ground and not rolling
	if FeatureSpindash=2
		bsr.w	Sonic_SpinDash			; mode 2 keeps the CD-style spin dash available before completion
	endif ; if FeatureSpindash=2
	if ((FeatureSpindash)|(FeatureSuperPeelout))&FeatureUnlockMovesAfterCompletion
	if FeatureSonic2013SuperSonic
		tst.b	(v_supersonic).w			; Super Sonic always has the enhanced move set
		bne.s	.unlockedmoves			; if yes, skip the SRAM gate
	endif ; if FeatureSonic2013SuperSonic
		bsr.w	CheckSRAMGameComplete
		beq.s	.skipunlockedmoves
.unlockedmoves:
	endif ; if ((FeatureSpindash)|(FeatureSuperPeelout))&FeatureUnlockMovesAfterCompletion
	if FeatureSpindash
	if FeatureSpindash<>2
		bsr.w	Sonic_SpinDash
	endif ; if FeatureSpindash<>2
	endif ; if FeatureSpindash
	if FeatureSuperPeelout
		bsr.w	Sonic_Peelout
	endif ; if FeatureSuperPeelout
.skipunlockedmoves:
		bsr.w	Sonic_Jump				; check if we need to jump
		bsr.w	Sonic_SlopeResistWalk			; handle resistance from running up slopes
		bsr.w	Sonic_Move				; handle Sonic's left/right movement
		bsr.w	Sonic_Roll				; check if we need to roll
		bsr.w	Sonic_LevelBound			; make sure Sonic stays within level bounds and handle bottomless pits
		jsr	(SpeedToPos).l				; update Sonic's position based on his current velocities
		bsr.w	Sonic_AnglePos				; update Sonic's current angle as he walks along the floor
		bsr.w	Sonic_SlopeRepel			; handle Sonic detaching from walls if not fast enough
		rts
; ===========================================================================

; Obj01_MdJump:
Sonic_MdJump:
	if FeatureSpindash
		; Clear the duck flag while airborne so the spindash crouch state cannot leak into see-saws.
		clr.b	fr_Duck(a0)
	endif ; if FeatureSpindash
		; While Sonic is in the air but not rolling
		bsr.w	Sonic_JumpHeight			; handle Sonic's jump height based on whether the jump button is still held
		bsr.w	Sonic_JumpDirection			; handle midair direction adjustments while jumping
		bsr.w	Sonic_LevelBound			; make sure Sonic stays within level bounds and handle bottomless pits
		jsr	(ObjectFall).l				; apply gravity and update Sonic's position based on his current velocities
		btst	#6,obStatus(a0)				; is Sonic underwater?
		beq.s	.notunderwater				; if not, branch
		subi.w	#$28,obVelY(a0)				; reduce falling speed (ObjectFall applies $38, so this subtraction makes it $10)

; loc_12E5C:
.notunderwater:
		bsr.w	Sonic_JumpAngle				; steadily return Sonic's angle while jumping to 0
		bsr.w	Sonic_Floor				; handle collision with level while airborne
	if FeatureAirRoll
		bsr.w	Sonic_AirRoll
	endif ; if FeatureAirRoll
		rts						; return
; ===========================================================================

; Obj01_MdRoll:
Sonic_MdRoll:	; While Sonic is on the ground and rolling
		bsr.w	Sonic_Jump				; check if we need to jump
		bsr.w	Sonic_SlopeResistRoll			; handle resistance from rolling up slopes
		bsr.w	Sonic_RollSpeed				; update speed as Sonic rolls
		bsr.w	Sonic_LevelBound			; make sure Sonic stays within level bounds and handle bottomless pits
		jsr	(SpeedToPos).l				; update Sonic's position based on his current velocities
		bsr.w	Sonic_AnglePos				; update Sonic's current angle as he walks along the floor
		bsr.w	Sonic_SlopeRepel			; handle Sonic detaching from walls if not fast enough
		rts
; ===========================================================================

; Obj01_MdJump2:
Sonic_MdJump2:	; While Sonic is in the air and rolling (usually, but not limited to, jumping)
	if FeatureSpindash
		; Clear the duck flag while airborne so the spindash crouch state cannot leak into see-saws.
		clr.b	fr_Duck(a0)
	endif ; if FeatureSpindash
		bsr.w	Sonic_JumpHeight			; handle Sonic's jump height based on whether the jump button is still held
		bsr.w	Sonic_JumpDirection			; handle midair direction adjustments while jumping
		bsr.w	Sonic_LevelBound			; make sure Sonic stays within level bounds and handle bottomless pits
		jsr	(ObjectFall).l				; apply gravity and update Sonic's position based on his current velocities
		btst	#6,obStatus(a0)				; is Sonic underwater?
		beq.s	.notunderwater				; if not, branch
		subi.w	#$28,obVelY(a0)				; reduce falling speed (ObjectFall applies $38, so this subtraction makes it $10)

; loc_12EA6:
.notunderwater:
		bsr.w	Sonic_JumpAngle				; steadily return Sonic's angle while jumping to 0
		bsr.w	Sonic_Floor				; handle collision with level while airborne
	if FeatureAirRoll
		bsr.w	Sonic_AirRoll
	endif ; if FeatureAirRoll
		rts						; return
; End of Sonic_Modes


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to make Sonic walk/run
; ---------------------------------------------------------------------------

Sonic_Move:
		move.w	(v_sonspeedmax).w,d6			; get Sonic's current top speed
		move.w	(v_sonspeedacc).w,d5			; get Sonic's current acceleration
		move.w	(v_sonspeeddec).w,d4			; get Sonic's current deceleration

		tst.b	(f_slidemode).w				; is Sonic currently on a water slide? (LZ only)
		bne.w	Sonic_AngleSpeed			; if yes, branch
		tst.w	locktime(a0)				; is Sonic's D-Pad input temporarily locked?
		bne.w	Sonic_ResetScr				; if yes, ignore D-Pad input
		btst	#bitL,(v_jpadhold2).w			; is left being held?
		beq.s	.notleft				; if not, branch
		bsr.w	Sonic_MoveLeft				; apply leftside movement updates

; Obj01_NotLeft:
.notleft:
		btst	#bitR,(v_jpadhold2).w			; is right being held?
		beq.s	.notright				; if not, branch
		bsr.w	Sonic_MoveRight				; apply rightside movement updates

; Obj01_NotRight:
.notright:
		move.b	obAngle(a0),d0				; get Sonic's current angle
		addi.b	#$20,d0					; rotate it 45 degrees clockwise
		andi.b	#$C0,d0					; snap to nearest multiple of 90 degrees
		bne.w	Sonic_ResetScr				; is Sonic on a slope? if yes, branch

		tst.w	obInertia(a0)				; is Sonic standing still?
		bne.w	Sonic_ResetScr				; if not, branch
		bclr	#5,obStatus(a0)				; clear pushing flag
		move.b	#id_Wait,obAnim(a0)			; use "standing" animation
		btst	#3,obStatus(a0)				; is Sonic standing on a platform object?
		beq.s	.chkbalance				; if not, branch

		moveq	#0,d0					; clear d0
		move.b	standonobject(a0),d0			; get OST index of object Sonic is currently standing on
		lsl.w	#object_size_bits,d0			; multiply by $40 (object_size)
		lea	(v_objspace).w,a1			; load object space
		lea	(a1,d0.w),a1				; load stood-on object
		tst.b	obStatus(a1)				; was the object an enemy/boss that was destroyed? (see React_Enemy)
		bmi.s	Sonic_LookUp				; if yes, skip over balance check

		moveq	#0,d1					; clear d1
		move.b	obActWid(a1),d1				; get physical width of stood-on object
		move.w	d1,d2					; copy width
		add.w	d2,d2					; double it
		subq.w	#4,d2					; minus 4
		add.w	obX(a0),d1				; get Sonic's current X-position
		sub.w	obX(a1),d1				; subtract stood-on object's X-position
		cmpi.w	#4,d1					; is Sonic within 4px of the object's left edge?
		blt.s	.leftbalance				; if yes, branch
		cmp.w	d2,d1					; is Sonic within 4px of the object's right edge?
		bge.s	.rightbalance				; if yes, branch
		bra.s	Sonic_LookUp				; skip over (no balancing)
; ===========================================================================

; Sonic_Balance:
.chkbalance:
		jsr	(ObjFloorDist).l			; get distance of Sonic to nearest floor
		cmpi.w	#12,d1					; is he within 12px to floor?
		blt.s	Sonic_LookUp				; if yes, don't do balance animation (would look awkward)
		cmpi.b	#3,angleright(a0)			; is Sonic at the right edge of the floor?
		bne.s	.chkleftedge				; if not, check for the left edge

; loc_12F5A:
.rightbalance:
		bclr	#0,obStatus(a0)				; clear X-flip flag (make Sonic face right)
		bra.s	.balance				; do balance animation
; ===========================================================================

; loc_12F62:
.chkleftedge:
		cmpi.b	#3,angleleft(a0)			; is Sonic at the left edge of the floor?
		bne.s	Sonic_LookUp				; if not, branch (no balancing)

; loc_12F6A:
.leftbalance:
		bset	#0,obStatus(a0)				; set X-flip flag (make Sonic face left)

; loc_12F70:
.balance:
		move.b	#id_Balance,obAnim(a0)			; use "balancing" animation
		bra.s	Sonic_ResetScr				; prevent looking up/down
; ===========================================================================

Sonic_LookUp:
		btst	#bitUp,(v_jpadhold2).w			; is up being held?
		beq.s	Sonic_Duck				; if not, check for ducking instead
		move.b	#id_LookUp,obAnim(a0)			; use "looking up" animation

	if FeatureSpindash
		addq.b	#1,(v_screendelay_v).w			; increment vertical screen movement delay timer
		cmp.b	#$78,(v_screendelay_v).w		; has the delay timer reached its maximum value?

		if TweakS2LevelArtLoader
			bcs.s	Sonic_ResetScr_Alt		; branch to alternate screen reset routine
		else
			bcs.s	Sonic_ResetScr			; branch to regular screen reset routine
		endif ; if TweakS2LevelArtLoader

		move.b	#$78,(v_screendelay_v).w		; clamp delay timer to maximum value
	endif ; if FeatureSpindash

		cmpi.w	#$C8,(v_lookshift).w			; has camera already fully moved up?
		beq.s	Sonic_CheckDpadLetGo			; if yes, don't move it up further
		addq.w	#2,(v_lookshift).w			; move camera up further
		bra.s	Sonic_CheckDpadLetGo			; skip over

; Sonic_LookDown:
Sonic_Duck:
		btst	#bitDn,(v_jpadhold2).w			; is down being held?
		beq.s	Sonic_ResetScr				; if not, branch
		move.b	#id_Duck,obAnim(a0)			; use "ducking" animation
		cmpi.w	#8,(v_lookshift).w			; has camera already fully moved down?
		beq.s	Sonic_CheckDpadLetGo			; if yes, branch
		subq.w	#2,(v_lookshift).w			; move camera down further
		bra.s	Sonic_CheckDpadLetGo			; skip over
; ===========================================================================

; Obj01_ResetScr:
Sonic_ResetScr:
	if TweakS2LevelArtLoader
		move.b	#$00,(v_screendelay_v).w		; clear the vertical screen delay timer

Sonic_ResetScr_Alt:
	endif ; if TweakS2LevelArtLoader
		cmpi.w	#$60,(v_lookshift).w			; is screen in its default position?
		beq.s	Sonic_CheckDpadLetGo			; if yes, branch
		bcc.s	.resetdown				; does camera need to go back down? if yes, branch
		addq.w	#4,(v_lookshift).w			; move camera back up (becomes 2 with the next line)

; loc_12FBE:
.resetdown:
		subq.w	#2,(v_lookshift).w			; move camera back down
; ---------------------------------------------------------------------------

; loc_12FC2:
Sonic_CheckDpadLetGo:
		move.b	(v_jpadhold2).w,d0			; get held buttons
		andi.b	#btnL+btnR,d0				; is left or right held?
		bne.s	Sonic_AngleSpeed			; if yes, branch (don't decrease speed)
		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		beq.s	Sonic_AngleSpeed			; is he standing still? if yes, branch
		bmi.s	.movingleftward				; is he moving to the left? if yes, branch
		sub.w	d5,d0					; reduce current rightward speed by acceleration
		bcc.s	.stillright				; if result is still to the right, branch
		move.w	#0,d0					; reset speed to zero on sign change

; loc_12FDC:
.stillright:
		move.w	d0,obInertia(a0)			; set Sonic's new ground speed
		bra.s	Sonic_AngleSpeed			; skip over
; ===========================================================================

; loc_12FE2:
.movingleftward:
		add.w	d5,d0					; reduce current leftward speed by acceleration
		bcc.s	.stillleft				; if result is still to the left, branch
		move.w	#0,d0					; reset speed to zero on sign change

; loc_12FEA:
.stillleft:
		move.w	d0,obInertia(a0)			; set Sonic's new ground speed
; ---------------------------------------------------------------------------

; loc_12FEE:
Sonic_AngleSpeed:
		move.b	obAngle(a0),d0				; get Sonic's current angle in relation to the floor
		jsr	(CalcSine).l				; get sine and cosine values based on angle
		muls.w	obInertia(a0),d1			; multiply cosine value by current ground speed
		asr.l	#8,d1					; shift result up a byte
		move.w	d1,obVelX(a0)				; set new X-velocity
		muls.w	obInertia(a0),d0			; multiply sine value by current ground speed
		asr.l	#8,d0					; shift result up a byte
		move.w	d0,obVelY(a0)				; set new Y-velocity
; ---------------------------------------------------------------------------

; loc_1300C:
Sonic_WallSpeedAdjust:
	if FixBugs
		; This was added to S&K to prevent an issue where Sonic could run through walls
		; if he is upside-down, or moving on a wall if his angle is exactly $80. This issue
		; can be seen in S3 alone's Carnival Night Zone if you jump onto a curved ceiling.
		move.b	obAngle(a0),d0				; get Sonic's current angle in relation to the floor
		andi.b	#$3F,d0					; is he standing on a flat surface in any of the four quadrants?
		beq.s	.noearlyexit				; if yes, skip the upside-down exit below
	endif
		move.b	obAngle(a0),d0				; get Sonic's current angle in relation to the floor
		addi.b	#$40,d0					; rotate it by 90 degrees
	if FeatureSpindash|FixBugEnemyDeathRoll
		bmi.w	.return					; if Sonic is upside down, branch (to prevent potential collision issues with loops)
	else
		bmi.s	.return					; if Sonic is upside down, branch (to prevent potential collision issues with loops)
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll

.noearlyexit:
		move.b	#$40,d1					; get angle rotation for wall collision detection
		tst.w	obInertia(a0)				; is Sonic standing still?
	if FeatureSpindash|FixBugEnemyDeathRoll
		beq.w	.return					; if yes, branch
	else
		beq.s	.return					; if yes, branch
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll
		bmi.s	.negspeed				; is he moving to the left? if yes, branch
		neg.w	d1					; invert angle rotation when moving right

; loc_13024:
.negspeed:
		move.b	obAngle(a0),d0				; get Sonic's current angle
		add.b	d1,d0					; rotate it by 90 degrees depending on directional speed
		move.w	d0,-(sp)				; backup d0
		bsr.w	Sonic_CalcRoomAhead			; calculate distance to the wall in front of Sonic (if any)
		move.w	(sp)+,d0				; restore d0
		tst.w	d1					; has Sonic touched a wall?
	if FeatureSpindash|FixBugEnemyDeathRoll
		bpl.w	.return					; if not, branch
	else
		bpl.s	.return					; if not, branch
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll
		asl.w	#8,d1					; convert diff to wall into 8.8 fixed point for adjusting velocity
		addi.b	#$20,d0					; rotate angle by 45 degrees clockwise
		andi.b	#$C0,d0					; snap angle to nearest multiple of 90 degrees
	if FeatureSpindash|FixBugEnemyDeathRoll
		beq.w	.hitdown				; if Sonic is facing down, branch
		cmpi.b	#$40,d0					; is Sonic facing left?
		beq.w	.hitleft				; if yes, branch
		cmpi.b	#$80,d0					; is Sonic facing up?
		beq.w	.hitup					; if yes, branch
	else
		beq.s	.hitdown				; if Sonic is facing down, branch
		cmpi.b	#$40,d0					; is Sonic facing left?
		beq.s	.hitleft				; if yes, branch
		cmpi.b	#$80,d0					; is Sonic facing up?
		beq.s	.hitup					; if yes, branch
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll

.hitright:	; d0 is $C0, Sonic is facing right
		add.w	d1,obVelX(a0)				; adjust X-velocity to prevent Sonic from walking into the wall
	if FeatureSpindash|FixBugEnemyDeathRoll
		btst	#2,obStatus(a0)				; is Sonic rolling?
		bne.s	.stoprolling_right			; if yes, stop rolling without entering pushing state
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll
		bset	#5,obStatus(a0)				; set pushing flag
	if FeatureSpindash|FixBugEnemyDeathRoll
		bra.s	.clearrollspeed_right

.stoprolling_right:
		bclr	#2,obStatus(a0)				; clear rolling flag
		bclr	#bitPushing,obStatus(a0)		; clear pushing flag
		move.b	#sonic_height,obHeight(a0)		; reset Sonic's hitbox height to default
		move.b	#sonic_width,obWidth(a0)		; reset Sonic's hitbox width to default
		move.b	#id_Wait,obAnim(a0)			; use "standing" animation
		subq.w	#sonic_height-sonic_roll_height,obY(a0) ; adjust Y-position for standing
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll
.clearrollspeed_right:
		move.w	#0,obInertia(a0)			; clear ground speed
		rts						; return
; ===========================================================================

; loc_13060:
.hitup:		; d0 is $80, Sonic is facing up
		sub.w	d1,obVelY(a0)				; adjust Y-velocity to prevent Sonic from walking into the ceiling
		rts
; ===========================================================================

; loc_13066:
.hitleft:	; d0 is $40, Sonic is facing left
		sub.w	d1,obVelX(a0)				; adjust X-velocity to prevent Sonic from walking into the wall
	if FeatureSpindash|FixBugEnemyDeathRoll
		btst	#2,obStatus(a0)				; is Sonic rolling?
		bne.s	.stoprolling_left			; if yes, stop rolling without entering pushing state
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll
		bset	#5,obStatus(a0)				; set pushing flag
	if FeatureSpindash|FixBugEnemyDeathRoll
		bra.s	.clearrollspeed_left

.stoprolling_left:
		bclr	#2,obStatus(a0)				; clear rolling flag
		bclr	#bitPushing,obStatus(a0)		; clear pushing flag
		move.b	#sonic_height,obHeight(a0)		; reset Sonic's hitbox height to default
		move.b	#sonic_width,obWidth(a0)		; reset Sonic's hitbox width to default
		move.b	#id_Wait,obAnim(a0)			; use "standing" animation
		subq.w	#sonic_height-sonic_roll_height,obY(a0) ; adjust Y-position for standing
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll
.clearrollspeed_left:
		move.w	#0,obInertia(a0)			; clear ground speed
		rts						; return
; ===========================================================================

; loc_13078:
.hitdown:	; d0 is $00, Sonic is facing down
		add.w	d1,obVelY(a0)				; adjust Y-velocity to prevent Sonic from walking into the floor

; locret_1307C:
.return:
		rts						; return
; End of function Sonic_Move

	if FixBugClearStalePushing
; ---------------------------------------------------------------------------
; Clear Sonic's pushing flag when no pushable object remains in front of the
; middle of his body. Object collisions still set pushing later in the object
; pass; this only clears stale states after walking away or stepping above it.
; ---------------------------------------------------------------------------

Sonic_CheckPushingObject:
		btst	#bitPushing,obStatus(a0)		; is Sonic currently marked as pushing?
		beq.w	.return					; if not, branch
		lea	(v_lvlobjspace).w,a1			; only level objects can be push targets
		move.w	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d6 ; check every dynamic object slot

.loop:
		move.b	obID(a1),d7				; get object ID
		beq.s	.next					; if not active, branch
		cmpi.b	#id_PushBlock,d7			; is this a real pushable block?
		beq.s	.pushable				; if yes, branch
	if FeaturePushableMonitors
		cmpi.b	#id_Monitor,d7				; is this an intact pushable monitor?
		bne.s	.next					; if not, branch
		tst.b	obColType(a1)
		beq.s	.next					; if broken, branch
	else
		bra.s	.next
	endif ; if FeaturePushableMonitors

.pushable:
		btst	#bitPushing,obStatus(a1)		; did this object mark Sonic as pushing it?
		beq.s	.next					; if not, branch

.checkposition:
		moveq	#0,d0
		move.b	obHeight(a0),d0			; get Sonic's collision height
		moveq	#0,d1
		move.b	obHeight(a1),d1			; get object collision height
		add.w	d1,d0					; combined vertical overlap
		addq.w	#4,d0					; allow minor animation bobbing
		move.w	obY(a1),d1				; get object Y
		sub.w	obY(a0),d1				; compare against Sonic Y
		bpl.s	.ypositive				; if positive, branch
		neg.w	d1					; get absolute Y difference

.ypositive:
		cmp.w	d0,d1					; is it in Sonic's middle rows?
		bhi.s	.next					; if not, branch
		moveq	#0,d0
		move.b	obWidth(a0),d0			; get Sonic's collision width
		moveq	#0,d1
		move.b	obActWid(a1),d1			; get object's active width
		bne.s	.gotwidth				; if it has one, branch
		move.b	obWidth(a1),d1			; otherwise use collision width

.gotwidth:
		add.w	d1,d0					; combined horizontal overlap
		addq.w	#8,d0					; allow one tile of side correction
		move.w	obX(a1),d1				; get object X
		sub.w	obX(a0),d1				; compare against Sonic X
		btst	#0,obStatus(a0)				; is Sonic facing left?
		bne.s	.faceleft				; if yes, branch

.faceright:
		tst.w	d1					; is object in front of Sonic?
		bmi.s	.next					; if not, branch
		cmp.w	d0,d1					; is it close enough to still be pushed?
		bls.s	.return					; if yes, keep pushing
		bra.s	.next
; ===========================================================================

.faceleft:
		tst.w	d1					; is object in front of Sonic?
		bpl.s	.next					; if not, branch
		neg.w	d1					; get distance to object on the left
		cmp.w	d0,d1					; is it close enough to still be pushed?
		bls.s	.return					; if yes, keep pushing

.next:
		lea	object_size(a1),a1			; next object slot
		dbf	d6,.loop				; repeat for all dynamic objects
		bclr	#bitPushing,obStatus(a0)		; otherwise clear stale pushing
		cmpi.b	#id_Push,obAnim(a0)			; was the push animation active?
		bne.s	.return					; if not, branch
		move.b	#id_Walk,obAnim(a0)			; resume regular walking animation

.return:
		rts
	endif ; if FixBugClearStalePushing


; ---------------------------------------------------------------------------
; Subroutine handling Sonic's movement while moving to the left
; ---------------------------------------------------------------------------

Sonic_MoveLeft:
		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		beq.s	.still					; is Sonic standing still? if yes, branch
		bpl.s	.changeddirection			; has Sonic changed direction? if yes, branch

; loc_13086:
.still:
		bset	#0,obStatus(a0)				; set X-flip flag (Sonic is facing left)
		bne.s	.alreadyleft				; if he already was facing left, branch
		bclr	#5,obStatus(a0)				; clear pushing flag
		move.b	#id_Run,obPrevAni(a0)			; restart Sonic's animation

; loc_1309A:
.alreadyleft:
		sub.w	d5,d0					; subtract acceleration to current ground speed
		move.w	d6,d1					; get current top speed
		neg.w	d1					; negate it for left-side check
		cmp.w	d1,d0					; is new speed above max speed?
		bgt.s	.nocap					; if not, branch

	if TweakRemoveSpeedCap
		add.w	d5,d0					; +++ remove this frame's acceleration change
		cmp.w	d1,d0					; +++ compare speed with top speed
		ble.s	.nocap					; +++ if speed was already greater than the maximum, branch
	endif ; if TweakRemoveSpeedCap

		move.w	d1,d0					; cap Sonic's ground speed

; loc_130A6:
.nocap:
		move.w	d0,obInertia(a0)			; set new ground speed
		move.b	#id_Walk,obAnim(a0)			; use walking animation
		rts						; return
; ===========================================================================

; loc_130B2:
.changeddirection:
		sub.w	d4,d0					; apply deceleration to current speed
		bcc.s	.stilldecel       			; if still decelerating, branch
		move.w	#-$80,d0        			; set minumum speed on sign change

; loc_130BA:
.stilldecel:
		move.w	d0,obInertia(a0)			; set new ground speed

		move.b	obAngle(a0),d0				; get Sonic's current angle
		addi.b	#$20,d0					; rotate by 45 degrees clockwise
		andi.b	#$C0,d0					; snap to nearest multiple of 90 degrees
		bne.s	.nostopping				; if Sonic is on a wall or ceiling, prevent stopping animation
		cmpi.w	#$400,d0				; has Sonic changed direction while being really fast?
		blt.s	.nostopping				; if not, don't play skidding animation/sound
		move.b	#id_Stop,obAnim(a0)			; use "stopping" animation
		bclr	#0,obStatus(a0)				; clear X-flip flag (Sonic is now facing right)
		sfx	#sfx_Skid,snd_jsr,snd_load_w,QueueSound2	; set skidding sound and play it

	if FeatureSpindash>1
		move.b	#$06,(v_spindashdust+obRoutine).w	; set the spin dash dust routine to skid dust
		move.b	#$15,(v_spindashdust+obFrame).w		; set skid dust animation/frame duration
	endif

; locret_130E8:
.nostopping:
		rts						; return
; End of function Sonic_MoveLeft


; ---------------------------------------------------------------------------
; Subroutine handling Sonic's movement while moving to the right
; ---------------------------------------------------------------------------

Sonic_MoveRight:
		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		bmi.s	.changedirection			; has Sonic changed direction? if yes, branch
		bclr	#0,obStatus(a0)				; clear X-flip flag (Sonic is facing right)
		beq.s	.alreadyright				; if he already was facing right, branch
		bclr	#5,obStatus(a0)				; clear pushing flag
		move.b	#id_Run,obPrevAni(a0)			; restart Sonic's animation

; loc_13104:
.alreadyright:
		add.w	d5,d0					; add acceleration to current ground speed
		cmp.w	d6,d0					; is new speed above max speed?
		blt.s	.nocap					; if not, branch

	if TweakRemoveSpeedCap
		add.w	d5,d0					; +++ remove this frame's acceleration change
		cmp.w	d1,d0					; +++ compare speed with top speed
		ble.s	.nocap					; +++ if speed was already greater than the maximum, branch
	endif

		move.w	d6,d0					; cap Sonic's ground speed

; loc_1310C:
.nocap:
		move.w	d0,obInertia(a0)			; set new ground speed
		move.b	#id_Walk,obAnim(a0)			; use walking animation
		rts						; return
; ===========================================================================

; loc_13118:
.changedirection:
		add.w	d4,d0					; apply deceleration to current speed
		bcc.s	.stilldecel				; if still decelerating, branch
		move.w	#$80,d0					; set minumum speed on sign change

; loc_13120:
.stilldecel:
		move.w	d0,obInertia(a0)			; set new ground speed

		move.b	obAngle(a0),d0				; get Sonic's current angle
		addi.b	#$20,d0					; rotate by 45 degrees clockwise
		andi.b	#$C0,d0					; snap to nearest multiple of 90 degrees
		bne.s	.nostopping				; if Sonic is on a wall or ceiling, prevent stopping animation
		cmpi.w	#-$400,d0				; has Sonic changed direction while being really fast?
		bgt.s	.nostopping				; if not, don't play skidding animation/sound

		move.b	#id_Stop,obAnim(a0)			; use "stopping" animation
		bset	#0,obStatus(a0)				; set X-flip flag (Sonic is now facing left)
		sfx	#sfx_Skid,snd_jsr,snd_load_w,QueueSound2	; set skidding sound and play it

	if FeatureSpindash>1
		move.b	#$06,(v_spindashdust+obRoutine).w	; change spin dash dust animation routine to skid dust
		move.b	#$15,(v_spindashdust+obFrame).w		; set skid dust animation/frame duration
	endif

; locret_1314E:
.nostopping:
		rts						; return
; End of function Sonic_MoveRight


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

Sonic_RollSpeed:
		move.w	(v_sonspeedmax).w,d6			; get Sonic's current max speed...
		asl.w	#1,d6					; ...doubled while rolling
		move.w	(v_sonspeedacc).w,d5			; get Sonic's current acceleration...
		asr.w	#1,d5					; ...halved while rolling
		move.w	(v_sonspeeddec).w,d4			; get Sonic's current deceleration...
		asr.w	#2,d4					; ...divided by 4 while rolling

		tst.b	(f_slidemode).w				; is Sonic on a water slide? (LZ only)
		bne.w	Sonic_AngledRollSpeed			; if yes, branch (no rolling)
		tst.w	locktime(a0)				; is Sonic's D-Pad input temporarily locked?
		bne.s	.notright				; if yes, ignore D-Pad input
		btst	#bitL,(v_jpadhold2).w			; is left being held?
		beq.s	.notleft				; if not, branch
		bsr.w	Sonic_RollLeft				; apply leftside movement updates for rolling

; loc_1317C:
.notleft:
		btst	#bitR,(v_jpadhold2).w			; is right being held?
		beq.s	.notright				; if not, branch
		bsr.w	Sonic_RollRight				; apply rightward movement updates for rolling
; ---------------------------------------------------------------------------

; loc_13188:
.notright:
		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		beq.s	Sonic_RollSlowdownDone			; is he standing still? if yes, branch
		bmi.s	.rollingleft				; is he moving to the left? if yes, branch
		sub.w	d5,d0					; slightly decrease Sonic's current roll speed
		bcc.s	.stillrollingright			; if still rolling, branch
		move.w	#0,d0					; reset speed to zero on sign change

; loc_13198:
.stillrollingright:
		move.w	d0,obInertia(a0)			; set new ground speed
		bra.s	Sonic_RollSlowdownDone			; skip over leftward rolling updates
; ===========================================================================

; loc_1319E:
.rollingleft:
		add.w	d5,d0					; slightly decrease Sonic's current roll speed
		bcc.s	.stillrollingleft			; if still rolling, branch
		move.w	#0,d0					; reset speed to zero on sign change

; loc_131A6:
.stillrollingleft:
		move.w	d0,obInertia(a0)			; set new ground speed
; ---------------------------------------------------------------------------

; loc_131AA:
Sonic_RollSlowdownDone:
		tst.w	obInertia(a0)				; is Sonic standing still?
		bne.s	Sonic_AngledRollSpeed			; if not, branch

		bclr	#2,obStatus(a0)				; clear rolling flag
		move.b	#sonic_height,obHeight(a0)		; reset Sonic's hitbox height to default
		move.b	#sonic_width,obWidth(a0)		; reset Sonic's hitbox width to default
		move.b	#id_Wait,obAnim(a0)			; use "standing" animation
		subq.w	#sonic_height-sonic_roll_height,obY(a0)	; adjust Y-position for standing
; ---------------------------------------------------------------------------

; loc_131CC:
Sonic_AngledRollSpeed:
	if FeatureSpindash
		cmp.w	#$60,(v_lookshift).w			; has the camera look-shift reached the target position?
		beq.s	.cont2					; if so, skip adjustment
		bcc.s	.cont1					; if above target, begin reducing shift value
		addq.w	#4,(v_lookshift).w			; increase look-shift toward target position
.cont1:
		subq.w	#2,(v_lookshift).w			; gradually reduce look-shift each frame
.cont2:
	endif ; if FeatureSpindash

		move.b	obAngle(a0),d0				; get Sonic's current angle in relation to the floor
		jsr	(CalcSine).l				; get sine and cosine values for the angle
		muls.w	obInertia(a0),d0			; multiply angle sine by ground speed
		asr.l	#8,d0					; shift result one byte down

	if FixBugs
		; Fix max roll speed not being capped for vertical momentum,
		; original code only caps for horizontal movement
		cmpi.w	#$1000,d0				; is new Y-velocity bigger than maximum screen shift speed? (downward)
		ble.s	.noPosIntCapY				; if not, branch
		move.w	#$1000,d0				; cap roll speed to screen shift speed (downward)
.noPosIntCapY:	cmpi.w	#-$1000,d0				; is new Y-velocity bigger than maximum screen shfit speed? (upward)
		bge.s	.noNegIntCapY				; if not, branch
		move.w	#-$1000,d0				; cap roll speed to screen shift speed (upward)
.noNegIntCapY:
	endif
		move.w	d0,obVelY(a0)				; set new Y-velocity

		muls.w	obInertia(a0),d1			; multiply angle cosine by ground speed
		asr.l	#8,d1					; shift result one byte down
		cmpi.w	#$1000,d1				; is new X-velocity bigger than maximum screen shift speed? (rightward)
		ble.s	.noPosIntCapX				; if not, branch
		move.w	#$1000,d1				; cap roll speed to screen shift speed (rightward)
; loc_131F0:
.noPosIntCapX:
		cmpi.w	#-$1000,d1				; is new X-velocity bigger than maximum screen shfit speed? (leftward)
		bge.s	.noNegIntCapX				; if not, branch
		move.w	#-$1000,d1				; cap roll speed to screen shift speed (leftward)
; loc_131FA:
.noNegIntCapX:
		move.w	d1,obVelX(a0)				; set new X-velocity

		bra.w	Sonic_WallSpeedAdjust			; adjust speed variations depending on current angle, or stop at wall
; End of function Sonic_RollSpeed


; ---------------------------------------------------------------------------
; Subroutine handling Sonic's movement while rolling to the left
; ---------------------------------------------------------------------------

Sonic_RollLeft:
		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		beq.s	.still					; is Sonic standing still? if yes, branch
		bpl.s	.changeddirection			; has Sonic changed direction? if yes, branch

; loc_1320A:
.still:
		bset	#0,obStatus(a0)				; set X-flip flag (Sonic is facing left)
		move.b	#id_Roll,obAnim(a0)			; use "rolling" animation
		rts						; return
; ===========================================================================

; loc_13218:
.changeddirection:
		sub.w	d4,d0					; apply deceleration to current speed
		bcc.s	.stilldecel				; if still decelerating, branch
		move.w	#-$80,d0				; set minumum speed on sign change

; loc_13220:
.stilldecel:
		move.w	d0,obInertia(a0)			; set new ground speed
		rts						; return
; End of function Sonic_RollLeft


; ---------------------------------------------------------------------------
; Subroutine handling Sonic's movement while rolling to the right
; ---------------------------------------------------------------------------

Sonic_RollRight:
		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		bmi.s	.changedirection			; has Sonic changed direction? if yes, branch
		bclr	#0,obStatus(a0)				; clear X-flip flag (Sonic is facing right)
		move.b	#id_Roll,obAnim(a0)			; use "rolling" animation
		rts						; return
; ===========================================================================

; loc_1323A:
.changedirection:
		add.w	d4,d0					; apply deceleration to current speed
		bcc.s	.stilldecel				; if still decelerating, branch
		move.w	#$80,d0					; set minumum speed on sign change

; loc_13242:
.stilldecel:
		move.w	d0,obInertia(a0)			; set new ground speed
		rts						; return
; End of function Sonic_RollRight


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change Sonic's direction while jumping
; ---------------------------------------------------------------------------

; Sonic_ChgJumpDir:
Sonic_JumpDirection:
		move.w	(v_sonspeedmax).w,d6			; get Sonic's current top speed
		move.w	(v_sonspeedacc).w,d5			; get Sonic's current acceleration...
		asl.w	#1,d5					; ...doubled

		btst	#4,obStatus(a0)				; is Roll-Jump flag set?
		bne.s	Sonic_RollJumpLock			; if yes, prevent midair direction change

		move.w	obVelX(a0),d0				; get Sonic's current X-velocity
		btst	#bitL,(v_jpadhold2).w			; is left being held?
		beq.s	.notleft				; if not, branch
		bset	#0,obStatus(a0)				; set X-flip flag (Sonic is facing left)
		sub.w	d5,d0					; increase leftward movement speed
		move.w	d6,d1					; copy top speed
		neg.w	d1					; negate it for leftward movement check
		cmp.w	d1,d0					; is new speed exceeding maximum?
		bgt.s	.notleft				; if not, branch

	if TweakRemoveSpeedCap
		add.w	d5,d0					; +++ remove this frame's acceleration change
		cmp.w	d1,d0					; +++ compare speed with top speed
		ble.s	.notleft				; +++ if speed was already greater than the maximum, branch
	endif

		move.w	d1,d0					; cap leftward X-speed to maximum

; loc_13278:
.notleft:
		btst	#bitR,(v_jpadhold2).w			; is right being held?
		beq.s	Sonic_JumpMove				; if not, branch
		bclr	#0,obStatus(a0)				; clear X-flip flag (Sonic is facing right)
		add.w	d5,d0					; increase rightward movement speed
		cmp.w	d6,d0					; is new speed exceeding maximum?
		blt.s	Sonic_JumpMove				; if not, branch

	if TweakRemoveSpeedCap
		sub.w	d5,d0					; +++ remove this frame's acceleration change
		cmp.w	d6,d0					; +++ compare speed with top speed
		bge.s	Obj01_JumpMove				; +++ if speed was already greater than the maximum, branch
	endif

		move.w	d6,d0					; cap rightward X-speed to maximum

; Obj01_JumpMove:
Obj01_JumpMove:
Sonic_JumpMove:
		move.w	d0,obVelX(a0)				; update Sonic's horizontal speed
; ---------------------------------------------------------------------------

; Obj01_ResetScr2:
Sonic_RollJumpLock:
		cmpi.w	#$60,(v_lookshift).w			; is screen in its default position?
		beq.s	Sonic_AirDrag				; if yes, branch
		bcc.s	.resetdown				; does camera need to go back down? if yes, branch
		addq.w	#4,(v_lookshift).w			; move camera back up (becomes 2 with the next line)

; loc_132A0:
.resetdown:
		subq.w	#2,(v_lookshift).w			; move camera back down
; ---------------------------------------------------------------------------

; loc_132A4:
Sonic_AirDrag:
		cmpi.w	#-$400,obVelY(a0)			; is Sonic moving faster than -$400 upwards?
		blo.s	.return					; if yes, branch (skip air drag)

		move.w	obVelX(a0),d0				; get current X-velocity
		move.w	d0,d1					; copy it
		asr.w	#5,d1					; divide that copy by $20
		beq.s	.return					; if result is zero, branch
		bmi.s	.jumpingleftward			; if speed is negative, branch
		sub.w	d1,d0					; slightly reduce speed (air drag)
		bcc.s	.stillright				; if result is still rightward, branch
		move.w	#0,d0					; reset speed on sign change

; loc_132C0:
.stillright:
		move.w	d0,obVelX(a0)				; set new X-speed
		rts						; return
; ===========================================================================

; loc_132C6:
.jumpingleftward:
		sub.w	d1,d0					; slightly reduce speed (air drag)
		bcs.s	.stillleft				; if result is still leftward, branch
		move.w	#0,d0					; reset speed on sign change

; loc_132CE:
.stillleft:
		move.w	d0,obVelX(a0)				; set new X-speed

; locret_132D2:
.return:
		rts						; return
; End of function Sonic_JumpDirection

	if FeatureSpindash
		include "Enhancements/_incObj/Sonic Spindash.asm"
	endif

	if FeatureSuperPeelout
		include "Enhancements/_incObj/Sonic SuperPeelout.asm"
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused subroutine to squash Sonic into the ceiling. When Sonic gets stuck
; in a ceiling, this would zero all his momentum and set his animation to
; be the vertical "warping" sprite, which is also unused. The purpose of
; this routine isn't known, though it possibly was for troubleshooting
; collision errors in which Sonic would somehow clip through ceilings.
; ---------------------------------------------------------------------------
	if TweakRemoveReduntantCode=0
Sonic_SquashUnused:
		move.b	obAngle(a0),d0				; get Sonic's current angle
		addi.b	#$20,d0					; rotate it by 45 degrees
		andi.b	#$C0,d0					; snap angle to nearest multiple of 90 degrees
		bne.s	.return					; if Sonic is standing on a wall/ceiling, branch (must be standing on a floor)
		bsr.w	Sonic_FindCeiling			; find Sonic's distance to the ceiling
		tst.w	d1					; is he below it?
		bpl.s	.return					; if yes, branch (this should always happen unless he clipped through)

		move.w	#0,obInertia(a0)			; clear Sonic's ground speed
		move.w	#0,obVelX(a0)				; clear Sonic's horizontal speed
		move.w	#0,obVelY(a0)				; clear Sonic#s vertical speed
		move.b	#id_Warp3,obAnim(a0)			; use "warping" animation
	endif

; locret_13302:
.return:
		rts						; return
; End of function Sonic_SquashUnused


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to prevent Sonic leaving the left/right boundaries of a level,
; dying to bottomless pits, and handling the transition from SBZ2 to SBZ3.
; This routine does not do anything about the top boundary.
; ---------------------------------------------------------------------------

Sonic_LevelBound:
		move.l	obX(a0),d1				; get Sonic's current X-position
		move.w	obVelX(a0),d0				; get Sonic's current X-velocity
		ext.l	d0					; sign-extend X-velocity
		asl.l	#8,d0					; shift upper byte of velocity to upper word
		add.l	d0,d1					; add to previous X-position
		swap	d1					; move new absolute pixel position to lower word

		move.w	(v_limitleft2).w,d0			; load level's left boundary
		addi.w	#16,d0					; add 16px of leeway
		cmp.w	d1,d0					; has Sonic touched the left level boundary?
		bhi.s	.sides					; if yes, branch

		move.w	(v_limitright2).w,d0			; load level's right boundary
		addi.w	#320-24,d0				; add screen width - 24px of leeway
		tst.b	(f_lockscreen).w			; is a boss fight active?
		bne.s	.screenlocked				; if yes, branch
		addi.w	#64,d0					; increase leeway by 64px outside of boss fights

; loc_13332:
.screenlocked:
		cmp.w	d1,d0					; has Sonic touched the right level boundary?
		bls.s	.sides					; if yes, branch

; loc_13336:
.chkbottom:
		move.w	(v_limitbtm2).w,d0			; load current target bottom level boundary
	if (FixBugTooFastToLive)|(FixBugs)
		; The original code does not consider that the camera boundary
		; may be in the middle of lowering itself, which is why going
		; down the S-tunnel in GHZ act 1 fast enough can kill Sonic.
		move.w	(v_limitbtm1).w,d1			; load current actual bottom level boundary
		cmp.w	d0,d1					; is target bottom level boundary higher than current real one?
		blo.s	.skipboundaryoverride			; if not, branch
		move.w	d1,d0					; use target level boundary while it's moving down to prevent unfair deaths
.skipboundaryoverride:
	endif

		addi.w	#224,d0					; add screen beight
	if FeatureSonicJamModes|FeatureSonicJam
		cmpi.b	#id_GHZ,(v_zone).w			; is level GHZ?
		bne.s	.no_ghz_bottom_spike_grace		; if not, branch
		addi.w	#$10,d0					; let bottom-row GHZ spikes hurt before the pit death check
.no_ghz_bottom_spike_grace:
	endif ; if FeatureSonicJamModes|FeatureSonicJam
		cmp.w	obY(a0),d0				; has Sonic touched the bottom boundary?
		blt.s	.bottom					; if yes, branch
		rts						; return
; ===========================================================================

; Boundary_Bottom:
.bottom:
	if FeatureSpindash
		; Match the spindash path to the moving lower boundary while the screen scrolls down.
		move.w	(v_limitbtm1).w,d0
		move.w	(v_limitbtm2).w,d1
		cmp.w	d0,d1				; screen still scrolling down?
		blt.s	.dontkill			; if so, don't kill Sonic
	endif ; if FeatureSpindash

	if FixBugFallOffFinalZone
		cmpi.w	#id_FZ,(v_zone).w		; is level FZ?
		beq.s	Sonic_LevelBound_Next
	endif ; if FixBugFallOffFinalZone

		cmpi.w	#id_SBZ_act2,(v_zone).w			; is level SBZ2?

	if FixBugs
		bne.s	JumpTo_KillSonic
	else
		bne.w	KillSonic				; if not, kill Sonic
	endif

		cmpi.w	#$2000,(v_player+obX).w			; is Sonic far enough into the level?

	if FixBugs
		blo.s	JumpTo_KillSonic			; if not, kill Sonic
	else
		blo.w	KillSonic				; if not, kill Sonic
	endif

		; Transition from SBZ2 to SBZ3
		clr.b	(v_lastlamp).w				; clear lamppost counter
		move.w	#1,(f_restart).w			; restart the level
		move.w	#id_LZ_act4,(v_zone).w			; set level to SBZ3 (LZ4)
.dontkill:
		rts						; return
; ===========================================================================

; Boundary_Sides:
.sides:
		move.w	d0,obX(a0)				; prevent Sonic from leaving the side boundary
		move.w	#0,obSubpixelX(a0)			; clear subpixel portion
		move.w	#0,obVelX(a0)				; clear X-velocity
		move.w	#0,obInertia(a0)			; clear ground speed
		bra.s	.chkbottom				; check for bottom boundary collision as well

; ===========================================================================

	if FixBugs
; Jump-redirect to the KillSonic subroutine, as it otherwise results in an out-of-range error
; just from enabling FixBugs. This is also a very common beginner's trap
JumpTo_KillSonic:
		jmp	(KillSonic).l				; kill Sonic
	endif
; End of function Sonic_LevelBound

	if FixBugFallOffFinalZone
Sonic_LevelBound_Next:
		move.b	#id_Ending,(v_gamemode).w	; go to the ending instead of killing Sonic in FZ
		rts
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

Sonic_Roll:
		tst.b	(f_slidemode).w				; is Sonic currently on a water slide?
		bne.s	.noroll					; if yes, don't allow rolling

		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		bpl.s	.ispositive				; is it positive? if yes, branch
		neg.w	d0					; otherwise, make it positive
; loc_13392:
.ispositive:
	if TweakSlowDucking
		btst	#bitDn,(v_jpadhold2).w			; is down being held?
		beq.s	.noroll					; if not, branch
		move.b	(v_jpadhold2).w,d0			; get held buttons
		andi.b	#btnL+btnR,d0				; is left/right being held?
		bne.s	.noroll					; if yes, branch
		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		bpl.s	.cont					; if ground speed is positive, continue
		neg.w	d0					; otherwise, make it positive

.cont:
		cmpi.w	#$100,d0				; is Sonic moving at $100 speed or faster?
		bhi.s	Sonic_ChkRoll				; if yes, branch
		move.b	#id_Duck,obAnim(a0)			; use "ducking" animation
	else
		cmpi.w	#$80,d0					; is Sonic moving at $80 speed or faster?
		blo.s	.noroll					; if not, branch
		move.b	(v_jpadhold2).w,d0			; get held buttons
		andi.b	#btnL+btnR,d0				; is left/right being held?
		bne.s	.noroll					; if yes, prevent rolling (some kind of fat-fingering convenience feature?)
		btst	#bitDn,(v_jpadhold2).w			; is down being held?
		bne.s	Sonic_ChkRoll				; if yes, branch
	endif ; if TweakSlowDucking

; Obj01_NoRoll:
.noroll:
		rts						; return
; ===========================================================================

; Obj01_ChkRoll:
Sonic_ChkRoll:
		btst	#2,obStatus(a0)				; is Sonic already rolling?
		beq.s	.roll					; if not, branch to initiate a roll
		rts						; otherwise, do nothing
; ===========================================================================

; Obj01_DoRoll:
.roll:
		bset	#2,obStatus(a0)				; set rolling flag
		move.b	#sonic_roll_height,obHeight(a0)		; set Sonic's hitbox height to rolling size
		move.b	#sonic_roll_width,obWidth(a0)		; set Sonic's hitbox width to rolling size
		move.b	#id_Roll,obAnim(a0)			; use "rolling" animation
		addq.w	#sonic_height-sonic_roll_height,obY(a0)	; adjust Y-position to align Sonic to the floor
		sfx	#sfx_Roll,snd_jsr,snd_load_w,QueueSound2	; set rolling sound and play it

		tst.w	obInertia(a0)				; is current speed zero?
		bne.s	.ismoving				; if not, branch
		move.w	#$200,obInertia(a0)			; force forward movement (this is used for the S-tunels in GHZ to not get stuck)

; locret_133E8:
.ismoving:
		rts						; return
; End of function Sonic_Roll


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

Sonic_Jump:
		move.b	(v_jpadpress2).w,d0			; get pressed buttons
		andi.b	#btnABC,d0				; is A, B or C pressed?
		beq.w	Sonic_Jump_Return				; if not, branch

		moveq	#0,d0					; clear d0
		move.b	obAngle(a0),d0				; get Sonic's current angle
		addi.b	#$80,d0					; rotate 180 degrees for ceiling collision check
		bsr.w	Sonic_CalcHeadroom			; calculate pixels above Sonic's head
		cmpi.w	#6,d1					; are there less than 6px between Sonic and the ceiling?
		blt.w	Sonic_Jump_Return				; if yes, prevent jumping

		move.w	#$680,d2				; set initial jump force
		btst	#6,obStatus(a0)				; is Sonic underwater?
		beq.s	.notunderwater				; if not, continue
		move.w	#$380,d2				; set underwater jump force
; loc_1341C:
.notunderwater:
		moveq	#0,d0					; clear d0
		move.b	obAngle(a0),d0				; get Sonic's current angle
		subi.b	#$40,d0					; rotate it perpendicularly for jump trajectory
		jsr	(CalcSine).l				; find the direction Sonic should jump
		muls.w	d2,d1					; apply jump force to the cosine angle
		asr.l	#8,d1					; shift it to upper word
		add.w	d1,obVelX(a0)				; apply to X speed
		muls.w	d2,d0					; apply jump force to the sine angle
		asr.l	#8,d0					; shift it to upper word
		add.w	d0,obVelY(a0)				; apply to Y speed
		bset	#1,obStatus(a0)				; set in-air flag
		bclr	#5,obStatus(a0)				; clear pushing flag
		addq.l	#4,sp					; run in-air subroutines when we return
		move.b	#1,jumping(a0)				; set jump flag
		clr.b	sticktoconvex(a0)			; detach Sonic from the gears in SBZ
		sfx	#sfx_Jump,snd_jsr,snd_load_w,QueueSound2	; set jump sound and play it

	if (FeatureBetaVictoryAnimation)|(FixBugs=0)
		; This sets Sonic's hitbox to standing size when roll-jumping.
		; A leftover from the victory animation in prototypes.
		move.b	#sonic_height,obHeight(a0)		; set height to standing size
		move.b	#sonic_width,obWidth(a0)		; set width to standing size
	endif

	if FeatureBetaVictoryAnimation
		tst.b	(f_victory).w				; has the victory animation flag been set?
		bne.s	Sonic_Jump_VictoryJump		; if yes, branch
	endif ; if FeatureBetaVictoryAnimation


		btst	#2,obStatus(a0)				; is Sonic already in a ball state?
		bne.s	Sonic_Jump_RollJump			; if so, branch

Jump_Regular:
		move.b	#sonic_roll_height,obHeight(a0)		; set height to rolling size
		move.b	#sonic_roll_width,obWidth(a0)		; set width to rolling size
		move.b	#id_Roll,obAnim(a0)			; use "jumping" animation
		bset	#2,obStatus(a0)				; set rolling flag
		addq.w	#sonic_height-sonic_roll_height,obY(a0)	; adjust Y-position to align Sonic to the floor

; locret_1348E:
Sonic_Jump_Return:
		rts						; return

; ===========================================================================

.victoryjump:
Sonic_Jump_VictoryJump:
	if FeatureBetaVictoryAnimation
		move.b	#id_Leap2,obAnim(a0)			; play the victory animation
		rts
	endif ; if FeatureBetaVictoryAnimation

; ===========================================================================

; loc_13490:
.rolljump:
Sonic_Jump_RollJump:
		bset	#4,obStatus(a0)				; set Roll-Jump flag
		rts						; return
; End of function Sonic_Jump

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine controlling Sonic's jump height/duration
; ---------------------------------------------------------------------------

Sonic_JumpHeight:
	if FeatureBetaVictoryAnimation
		tst.b	(f_victory).w				; has the victory animation flag been set?
		bne.s	AirVictory				; if yes, branch
	endif

		tst.b	jumping(a0)				; is Sonic airborne specifically from a jump?
		beq.s	.capyvel				; if not, just cap Y speed normally
		move.w	#-$400,d1				; set max jump height
		btst	#6,obStatus(a0)				; is Sonic underwater?
		beq.s	.notunderwater				; if not, continue
		move.w	#-$200,d1				; set underwater jump height

; loc_134AE:
.notunderwater:
		cmp.w	obVelY(a0),d1				; get current y speed
		ble.s	.return					; is Sonic moving up slower than the cap speed? if yes, branch
		move.b	(v_jpadhold2).w,d0			; get currently held buttons
		andi.b	#btnABC,d0				; is A, B or C still held after jumping?
		bne.s	.return					; if yes, branch
		move.w	d1,obVelY(a0)				; otherwise, cap Sonic's maximum jump height

; locret_134C2:
.return:
	if FixBugs=0
		; This prevents the max Y-vel cap from running while jumping
		rts						; return
	endif
; ===========================================================================

; loc_134C4:
.capyvel:
		cmpi.w	#-$FC0,obVelY(a0)			; is Sonic moving up just below the maximum screen scroll speed? (-$1000)
		bge.s	.return2				; if not, branch
		move.w	#-$FC0,obVelY(a0)			; force Sonic to stay below maximum screen scroll speed

; locret_134D2:
.return2:
	if FixBugs
		; The above vertical speed cap doesn't account for falling
		cmpi.w	#$FC0,obVelY(a0)			; is Sonic moving down just below the maximum screen scroll speed? ($1000)
		ble.s	.return3				; if not, branch
		move.w	#$FC0,obVelY(a0)			; force Sonic to stay below maximum screen scroll speed
.return3:
	endif

	if FeatureAirRoll
Sonic_AirRoll:
		move.b	(v_jpadpress2).w,d0			; get buttons pressed this frame
		andi.b	#btnABC,d0				; has A/B/C been pressed?
		bne.w	AirRoll_Checks				; if so, branch
		rts

AirRoll_Checks:
	if FeatureAirRoll=1
		cmpi.b	#id_Spring,obAnim(a0)			; is spring jump active?
		beq.s	Sonic_AirRoll_Return			; if so, branch ; locret_134D2
	endif

		cmpi.b	#id_Roll,obAnim(a0)			; is the rolling animation active?
		bne.s	AirRoll_Set				; if not, branch

		btst	#1,obStatus(a0)				; is Sonic in the air?
		bne.s	AirRoll_Set				; if so, branch
		rts

AirRoll_Set:
		move.b	#id_Roll,obAnim(a0)			; set Sonic's animation to the rolling animation
	endif ; if FeatureAirRoll

; locret_134D2
Sonic_AirRoll_Return:
		rts						; return
; End of function Sonic_JumpHeight

AirVictory:
	if FeatureBetaVictoryAnimation
		move.b	#id_Leap2,obAnim(a0)
		rts
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to adjust Sonic's speed while walking up/down slopes
; ---------------------------------------------------------------------------

; Sonic_SlopeResist:
Sonic_SlopeResistWalk:
		move.b	obAngle(a0),d0				; get Sonic's current angle
		addi.b	#$60,d0					; rotate it by 135 degrees
		cmpi.b	#$C0,d0					; is Sonic on a steep enough slope?
		bhs.s	.return					; if no, don't do slope resist

		move.b	obAngle(a0),d0				; get Sonic's current angle
		jsr	(CalcSine).l				; get sine and cosine values for angle
		muls.w	#$20,d0					; multiply by resist force while walking
		asr.l	#8,d0					; shift down a byte

		tst.w	obInertia(a0)				; check Sonic's ground speed
		beq.s	.return					; if he's standing still, branch
		bmi.s	.left					; if he's walking leftward, branch
		tst.w	d0					; is resist force zero?
		beq.s	.noresist				; if yes, branch
		add.w	d0,obInertia(a0)			; add resist force to Sonic's speed while walking up a right slope

; locret_13502:
.noresist:
		rts						; return
; ===========================================================================

; loc_13504:
.left:
		add.w	d0,obInertia(a0)			; add resist force to Sonic's speed while walking up a left slope

; locret_13508:
.return:
		rts						; return
; End of function Sonic_SlopeResist


; ---------------------------------------------------------------------------
; ; Subroutine to adjust Sonic's speed while rolling up/down slopes
; ---------------------------------------------------------------------------

; Sonic_RollRepel:
Sonic_SlopeResistRoll:
		move.b	obAngle(a0),d0				; get Sonic's current angle
		addi.b	#$60,d0					; rotate it by 135 degrees
		cmpi.b	#$C0,d0					; is Sonic on a steep enough slope?
		bhs.s	.return					; if no, don't do slope resist

		move.b	obAngle(a0),d0				; get Sonic's current angled
		jsr	(CalcSine).l				; get sine and cosine values for angle
		muls.w	#$50,d0					; multiply by resist force while rolling (2.5x larger than walking)
		asr.l	#8,d0					; shift down a byte

		tst.w	obInertia(a0)				; check Sonic's current ground speed
		bmi.s	.left					; he's rolling to the left, branch
		tst.w	d0					; is resist force zero or positive?
		bpl.s	.resistright				; if yes, branch (descending from slope rolls faster)
		asr.l	#2,d0					; reduce resist force while ascending a slope

; loc_13534:
.resistright:
		add.w	d0,obInertia(a0)			; add resist force to Sonic's speed while rolling up a right slope
		rts						; return
; ===========================================================================

; loc_1353A:
.left:
		tst.w	d0					; is resist force negative?
		bmi.s	.resistleft				; if yes, branch (descending from slope rolls faster)
		asr.l	#2,d0					; reduce resist force while ascending a slope

; loc_13540:
.resistleft:
		add.w	d0,obInertia(a0)			; add resist force to Sonic's speed while walking up a left slope

; locret_13544:
.return:
		rts						; return
; End of function Sonic_RollRepel


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to detach Sonic from steep slopes if he's too slow
; ---------------------------------------------------------------------------

Sonic_SlopeRepel:
		nop						; (probably replaced with an rts during development to stick to walls)
		tst.b	sticktoconvex(a0)			; is Sonic on an SBZ gear?
		bne.s	.return					; if yes, branch
		tst.w	locktime(a0)				; are left/right controls temporarily locked?
		bne.s	.decrementlocktime			; if yes, branch

		move.b	obAngle(a0),d0				; get Sonic's current angle
		addi.b	#$20,d0					; rotate it by 45 degrees
		andi.b	#$C0,d0					; snap to nearest multiple of 90 degrees
		beq.s	.return					; if Sonic is not on a wall or ceiling, branch

		move.w	obInertia(a0),d0			; get Sonic's current ground speed
		bpl.s	.posinertia				; is it positive? if yes, branch
		neg.w	d0					; otherwise, make it positive

; loc_1356A:
.posinertia:
		cmpi.w	#$280,d0				; is Sonic's ground speed high enough?
		bhs.s	.return					; if yes, branch
		clr.w	obInertia(a0)				; clear ground speed
		bset	#1,obStatus(a0)				; set in-air flag to detach Sonic from wall
		move.w	#30,locktime(a0)			; disable left/right input for half a second

; locret_13580:
.return:
		rts						; return
; ===========================================================================

; loc_13582:
.decrementlocktime:
		subq.w	#1,locktime(a0)				; decrement left/right disable timer
		rts						; return
; End of function Sonic_SlopeRepel


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

Sonic_JumpAngle:
		move.b	obAngle(a0),d0				; get Sonic's angle
		beq.s	.return					; if already 0, branch
		bpl.s	.decrease				; if higher than 0, branch
		addq.b	#2,d0					; increase angle
		bcc.s	.dontclear				; if the angle's still below 0, don't clear the angle
		moveq	#0,d0					; set angle to d0

; loc_13596:
.dontclear:
		bra.s	.applyangle				; skip over to update angle
; ===========================================================================

; loc_13598:
.decrease:
		subq.b	#2,d0					; decrease angle
		bcc.s	.applyangle				; if the angle's still above 0, don't clear the angle
		moveq	#0,d0					; set angle to 0

; loc_1359E:
.applyangle:
		move.b	d0,obAngle(a0)				; set new angle value

; locret_135A2:
.return:
		rts						; return
; End of function Sonic_JumpAngle


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with the floor after jumping/falling.
; To save on resouces, the game will only check one out of four quadrants,
; depending on which direction Sonic moving toward the most.
; This routine contains various writes to unused variables, likely used
; during development to debug the collision system while in air.
; ---------------------------------------------------------------------------

Sonic_Floor:
		move.w	obVelX(a0),d1				; get current horizontal speed
		move.w	obVelY(a0),d2				; get current vertical speed
		jsr	(CalcAngle).l				; calculate arctan based on Sonic's current fall direction
		move.b	d0,(v_unused3).w			; (unused) store basic angle
		subi.b	#$20,d0					; rotate 45 degrees counterclockwise
		move.b	d0,(v_unused4).w			; (unused) store -45 degrees angle
		andi.b	#$C0,d0					; snap to nearest multiple of 90 degrees
		move.b	d0,(v_unused5).w			; (unused) store snapped angle

		cmpi.b	#$40,d0					; is main movement direction to the left?
		beq.w	Sonic_FloorLeft				; if yes, branch
		cmpi.b	#$80,d0					; is main movement direction upward?
		beq.w	Sonic_FloorUp				; if yes, branch
		cmpi.b	#$C0,d0					; is main movement direction to the right?
		beq.w	Sonic_FloorRight			; if yes, branch
		; otherwise, d0 is $00 (fall-through...)

; ---------------------------------------------------------------------------
; When Sonic is in-air with his main momentum being downward
; ---------------------------------------------------------------------------

Sonic_FloorDown:
		bsr.w	Sonic_FindWallLeft_Quick_UsePos		; check Sonic's distance to nearest left wall
		tst.w	d1					; is Sonic grazing a wall to the left while falling?
		bpl.s	.noleftgraze				; if not, branch
		sub.w	d1,obX(a0)				; align Sonic with the wall
	if FixBugs
		clr.w	obSubpixelX(a0)				; reset subpixel portion
	endif
		move.w	#0,obVelX(a0)				; clear horizontal speed

; loc_135F0:
.noleftgraze:
		bsr.w	Sonic_FindWallRight_Quick_UsePos	; check Sonic's distance to nearest right wall
		tst.w	d1					; is Sonic grazing a wall to the right while falling?
		bpl.s	.norightgraze				; if not, branch
		add.w	d1,obX(a0)				; align Sonic with the wall
	if FixBugs
		clr.w	obSubpixelX(a0)				; reset subpixel portion
	endif
		move.w	#0,obVelX(a0)				; clear horizontal speed

; loc_13602:
.norightgraze:
		bsr.w	Sonic_FindFloor				; find distance between Sonic and floor
		move.b	d1,(v_unused6).w			; (unused) store distance to floor
		tst.w	d1					; has Sonic touched the floor again?
	if FixBugs=0
		bpl.s	.return					; if not, branch
	else
		bpl.w	.return					; if not, branch

		; The floor depth check should only be done if the floor is top solid,
		; not fully solid. Otherwise, if Sonic manages to clip into a fully
		; solid floor (i.e. the Lava Reef Zone stairs clip in Sonic & Knuckles),
		; Sonic could potentially fall right through.

		; Note that modifications to FindWall, FindFloor, Sonic_FindFloor,
		; Sonic_FindWallRight, Sonic_FindCeiling, Sonic_FindWallLeft, and
		; Sonic_FindSmaller are needed for this fix to work.
		btst	#$E,d4					; is the floor fully solid?
		bne.s	.landed					; if so, branch
	endif
		move.b	obVelY(a0),d2				; get Sonic's fall speed at the time of impact (upper byte only, pixel delta)
		addq.b	#8,d2					; increase it by one tile
		neg.b	d2					; mirror it
		cmp.b	d2,d1					; is result bigger than distance to floor?
		bge.s	.landed					; if yes, branch
		cmp.b	d2,d0					; is result bigger than distance to floor? (sloped variant)
		blt.s	.return					; if not, branch

; loc_1361E:
.landed:
		add.w	d1,obY(a0)				; fix Sonic to floor
	if FixBugs
		clr.w	obSubpixelY(a0)				; reset subpixel portion
	endif
		move.b	d3,obAngle(a0)				; update Sonic's angle for the landed-on floor
		bsr.w	Sonic_ResetOnFloor			; reset various flags and states back to standing state
		move.b	#id_Walk,obAnim(a0)			; set to "walking" animation

	if FixBugs
		; Fix angle inconsistencies on sloped surfaces
		move.b	d3,d0					; get floor angle
		bpl.s	.checkupper				; if it's in the left half, branch
		neg.b	d0					; if if's in the right half, mirror it
	.checkupper:
		btst	#6,d0					; is it in the lower half?
		beq.s	.checkslope				; if so, branch
		subi.b	#$80,d0					; if it's in the upper half...
		neg.b	d0					; ...mirror it
	.checkslope:
		cmpi.b	#$20,d0					; are we landing on a steep slope?
		bhs.s	.steepslope				; if so, branch
		cmpi.b	#$11,d0					; are we landing on a shallow slope?
		blo.s	.flatsurface				; if not, branch
	else
		move.b	d3,d0					; get landing angle
		addi.b	#$20,d0					; rotate it by 45 degrees clockwise
		andi.b	#$40,d0					; are we landing on a steep slope?
		bne.s	.steepslope				; if yes, branch
		move.b	d3,d0					; get landing angle
		addi.b	#$10,d0					; rotate it by 22.5 degrees clockwise
		andi.b	#$20,d0					; are we landing on a shallow slope?
		beq.s	.flatsurface				; if not, branch
	endif
		asr.w	obVelY(a0)				; halve Sonic's vertical speed when landing on a shallow slope
		bra.s	.noslopecap				; skip over
; ===========================================================================

; loc_1364E:
.flatsurface:
		move.w	#0,obVelY(a0)				; completely clear Sonic's vertical speed when landing on a flat surface
		move.w	obVelX(a0),obInertia(a0)		; convert in-air horizontal speed to ground speed when landing
		rts						; return
; ===========================================================================

; loc_1365C:
.steepslope:
		move.w	#0,obVelX(a0)				; completely clear Sonic's horizontal speed when londing on a steep slope
		cmpi.w	#$FC0,obVelY(a0)			; is Sonic's fall speed almost at the maximum screen shift speed?
		ble.s	.noslopecap				; if not, branch
		move.w	#$FC0,obVelY(a0)			; otherwise, cap it to not exceed maximum screen shift speed

; loc_13670:
.noslopecap:
		move.w	obVelY(a0),obInertia(a0)		; convert in-air vertical speed to ground speed when landing
		tst.b	d3					; is slope (when viewed left-to-right in game) ascending?
		bpl.s	.return					; if not, branch
		neg.w	obInertia(a0)				; negate converted ground speed for ascending slopes

; locret_1367E:
.return:
		rts						; return
; End of function Sonic_FloorDown


; ---------------------------------------------------------------------------
; When Sonic is in-air with his main momentum being to the left
; ---------------------------------------------------------------------------

; loc_13680:
Sonic_FloorLeft:
		bsr.w	Sonic_FindWallLeft_Quick_UsePos		; check Sonic's distance to nearest left wall
		tst.w	d1					; is Sonic grazing a wall to the left while falling?
		bpl.s	.noleftgraze				; if not, branch
		sub.w	d1,obX(a0)				; align Sonic to the wall
	if FixBugs
		clr.w	obSubpixelX(a0)				; reset subpixel portion
	endif
		move.w	#0,obVelX(a0)				; clear horizontal speed
		move.w	obVelY(a0),obInertia(a0)		; convert in-air vertical speed to ground speed when landing
		rts						; return
; ===========================================================================

; loc_1369A:
.noleftgraze:
		bsr.w	Sonic_FindCeiling			; check if Sonic's distance to the ceiling
		tst.w	d1					; is Sonic touching the ceiling?
		bpl.s	.noceiling				; if not, branch
		sub.w	d1,obY(a0)				; align Sonic with the ceiling
	if FixBugs
		clr.w	obSubpixelY(a0)				; reset subpixel portion
	endif
		tst.w	obVelY(a0)				; is vertical speed postive?
		bpl.s	.noyspeedreset				; if yes, branch
		move.w	#0,obVelY(a0)				; if going up, reset it to zero

.noyspeedreset:
		rts						; return
; ===========================================================================

; loc_136B4:
.noceiling:
		tst.w	obVelY(a0)				; is Sonic going up?
		bmi.s	.return					; if yes, branch
		bsr.w	Sonic_FindFloor				; find Sonic's distance to floor
		tst.w	d1					; has Sonic touched the floor?
		bpl.s	.return					; if not, branch
	if FixBugs
		; See explanation in .norightgraze under Sonic_FloorDown
		btst	#$E,d4					; is the floor fully solid?
		bne.s	.landed					; if so, branch

		; When Sonic is moving down and a floor collision is detected, there exists
		; a check that makes it so that he doesn't clip on top of a surface that
		; he's too far below from. However, said check doesn't exist for when Sonic
		; is moving left or right. The effects of this can easily be seen if you
		; place a solid object on a top solid surface and hit the object from the bottom,
		; where Sonic's Y movement will be cancelled out, causing him to start checking
		; for floor collision, which makes him clip onto the surface.
		move.b	obVelY(a0),d2				; get Sonic's fall speed at the time of impact (upper byte only, pixel delta)
		addq.b	#8,d2					; increase it by one tile
		neg.b	d2					; mirror it
		cmp.b	d2,d1					; is result bigger than distance to floor?
		bge.s	.landed					; if yes, branch
		cmp.b	d2,d0					; is result bigger than distance to floor? (sloped variant)
		blt.s	.return					; if not, branch

.landed:
	endif
		add.w	d1,obY(a0)				; align Sonic with floor
	if FixBugs
		clr.w	obSubpixelY(a0)				; reset subpixel portion
	endif
		move.b	d3,obAngle(a0)				; update Sonic's angle for the landed-on floor
		bsr.w	Sonic_ResetOnFloor			; reset various flags and states back to standing state
		move.b	#id_Walk,obAnim(a0)			; set to "walking" animation
		move.w	#0,obVelY(a0)				; completely clear Sonic's vertical speed when landing on a flat surface
		move.w	obVelX(a0),obInertia(a0)		; convert in-air horizontal speed to ground speed when landing

; locret_136E0:
.return:
		rts						; return
; End of function Sonic_FloorLeft


; ---------------------------------------------------------------------------
; When Sonic is in-air with his main momentum being upward
; ---------------------------------------------------------------------------

; loc_136E2:
Sonic_FloorUp:
		bsr.w	Sonic_FindWallLeft_Quick_UsePos		; check Sonic's distance to nearest left wall
		tst.w	d1					; is Sonic grazing a wall to the left while going up?
		bpl.s	.noleftgraze				; if not, branch
		sub.w	d1,obX(a0)				; align Sonic to wall
	if FixBugs
		clr.w	obSubpixelX(a0)				; reset subpixel portion
	endif
		move.w	#0,obVelX(a0)				; clear horizontal speed

; loc_136F4:
.noleftgraze:
		bsr.w	Sonic_FindWallRight_Quick_UsePos	; check Sonic's distance to nearest right wall
		tst.w	d1					; is Sonic grazing a wall to the right while going up?
		bpl.s	.norightgraze				; if not, branch
		add.w	d1,obX(a0)				; align Sonic to wall
	if FixBugs
		clr.w	obSubpixelX(a0)				; reset subpixel portion
	endif
		move.w	#0,obVelX(a0)				; cleaer horizontal speed

; loc_13706:
.norightgraze:
		bsr.w	Sonic_FindCeiling			; find Sonic's distance to the ceiling
		tst.w	d1					; is Sonic touching the ceiling?
		bpl.s	.return					; if not, branch
		sub.w	d1,obY(a0)				; align Sonic with the ceiling
	if FixBugs
		clr.w	obSubpixelY(a0)				; reset subpixel portion
	endif
		move.b	d3,d0					; get Sonic's landing angle
		addi.b	#$20,d0					; rotate it by 45 degrees
		andi.b	#$40,d0					; are we bumping against an angled ceiling?
		bne.s	.angledceiling				; if yes, branch
		move.w	#0,obVelY(a0)				; clear vertical speed when bumping against a flat ceiling
		rts						; return
; ===========================================================================

; loc_13726:
.angledceiling:
		move.b	d3,obAngle(a0)				; update Sonic's angle for the landed-on floor
		bsr.w	Sonic_ResetOnFloor			; reset various flags and states back to standing state
		move.w	obVelY(a0),obInertia(a0)		; convert in-air vertical speed to ground speed when landing
		tst.b	d3					; is slope (when viewed left-to-right in game) ascending?
		bpl.s	.return					; if not, branch
		neg.w	obInertia(a0)				; negate converted ground speed for ascending slopes

; locret_1373C:
.return:
		rts						; return
; End of function Sonic_FloorUp


; ---------------------------------------------------------------------------
; When Sonic is in-air with his main momentum being towards the right
; ---------------------------------------------------------------------------

; loc_1373E:
Sonic_FloorRight:
		bsr.w	Sonic_FindWallRight_Quick_UsePos	; check Sonic's distance to nearest right wall
		tst.w	d1					; is Sonic grazing a wall to the right while falling?
		bpl.s	.norightgraze				; if not, branch
		add.w	d1,obX(a0)				; align Sonic to the wall
	if FixBugs
		clr.w	obSubpixelX(a0)				; reset subpixel portion
	endif
		move.w	#0,obVelX(a0)				; clear horizontal speed
		move.w	obVelY(a0),obInertia(a0)		; convert in-air vertical speed to ground speed when landing
		rts						; return
; ===========================================================================

; loc_13758:
.norightgraze:
		bsr.w	Sonic_FindCeiling			; check if Sonic's distance to the ceiling
		tst.w	d1					; is Sonic touching the ceiling?
		bpl.s	.noceiling				; if not, branch
		sub.w	d1,obY(a0)				; align Sonic with the ceiling
	if FixBugs
		clr.w	obSubpixelY(a0)				; reset subpixel portion
	endif
		tst.w	obVelY(a0)				; is vertical speed postive?
		bpl.s	.noyspeedreset				; if yes, branch
		move.w	#0,obVelY(a0)				; if going up, reset it to zero

; locret_13770:
.noyspeedreset:
		rts						; return
; ===========================================================================

; loc_13772:
.noceiling:
		tst.w	obVelY(a0)				; is Sonic going up?
		bmi.s	.return					; if yes, branch
		bsr.w	Sonic_FindFloor				; find Sonic's distance to floor
		tst.w	d1					; has Sonic touched the floor?
		bpl.s	.return					; if not, branch
	if FixBugs
		; See explanation in .norightgraze under Sonic_FloorDown
		btst	#$E,d4					; is the floor fully solid?
		bne.s	.landed					; if so, branch

		; See explanation in .noceiling under Sonic_FloorLeft
		move.b	obVelY(a0),d2				; get Sonic's fall speed at the time of impact (upper byte only, pixel delta)
		addq.b	#8,d2					; increase it by one tile
		neg.b	d2					; mirror it
		cmp.b	d2,d1					; is result bigger than distance to floor?
		bge.s	.landed					; if yes, branch
		cmp.b	d2,d0					; is result bigger than distance to floor? (sloped variant)
		blt.s	.return					; if not, branch

.landed:
	endif
		add.w	d1,obY(a0)				; align Sonic with floor
	if FixBugs
		clr.w	obSubpixelY(a0)				; reset subpixel portion
	endif
		move.b	d3,obAngle(a0)				; update Sonic's angle for the landed-on floor
		bsr.w	Sonic_ResetOnFloor			; reset various flags and states back to standing state
		move.b	#id_Walk,obAnim(a0)			; set to "walking" animation
		move.w	#0,obVelY(a0)				; completely clear Sonic's vertical speed when landing on a flat surface
		move.w	obVelX(a0),obInertia(a0)		; convert in-air horizontal speed to ground speed when landing

; locret_1379E:
.return:
		rts						; return
; End of function Sonic_FloorRight
; End of function Sonic_Floor (as a whole)


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

Sonic_ResetOnFloor:
		btst	#4,obStatus(a0)				; is Sonic roll-jumping?
		beq.s	.notrolljump				; if not, skip
		nop						; unknown removed code
		nop						; (some extra feature of the roll-jump lock?)
		nop						; (we will never know...)

; loc_137AE:
.notrolljump:
		bclr	#5,obStatus(a0)				; clear push flag
		bclr	#1,obStatus(a0)				; clear in-air flag
		bclr	#4,obStatus(a0)				; clear roll-jump flag
	if FixBugs
		; This line was placed too late into the routine,
		; occasionally causing Sonic "sliding" on the floor
		move.b	#id_Walk,obAnim(a0)			; use running/walking animation
	endif
		btst	#2,obStatus(a0)				; check if Sonic is in a ball state
		beq.s	.notball				; if not, skip
		bclr	#2,obStatus(a0)				; clear ball flag
		move.b	#sonic_height,obHeight(a0)		; set Sonic's hitbox height to standing
		move.b	#sonic_width,obWidth(a0)		; set Sonic's hitbox width to standing
	if FixBugs=0
		move.b	#id_Walk,obAnim(a0)			; use running/walking animation
	endif
		subq.w	#sonic_height-sonic_roll_height,obY(a0)	; raise Sonic up 5 pixels so he's not inside the ground

; loc_137E4:
.notball:
		move.b	#0,jumping(a0)				; clear jump flag
		move.w	#0,(v_itembonus).w			; clear enemy score chain
		rts						; return
; End of function Sonic_ResetOnFloor


; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he gets hurt
; ---------------------------------------------------------------------------

; Obj01_Hurt:
Sonic_Hurt:	; Routine 4
		jsr	(SpeedToPos).l				; update Sonic's current position based on his velocities
		addi.w	#$30,obVelY(a0)				; apply gravity (this is 8 less than the normal gravity of $38)
		btst	#6,obStatus(a0)				; is Sonic underwater?
		beq.s	.notunderwater				; if not, branch
		subi.w	#$20,obVelY(a0)				; reduce gravity to be only $10 while underwater

; loc_1380C:
.notunderwater:
		bsr.w	Sonic_HurtStop				; check if Sonic has landed again after taking damage and revert to normal state
	if (TweakFixHurtWaterPhystics)|(FixBugs)
		; Fix water not being acknowledged during a hurt state
		bsr.w	Sonic_Water				; handle Sonic while in water (LZ only)
	endif
		bsr.w	Sonic_LevelBound			; make sure Sonic stays within level bounds and handle bottomless pits
		bsr.w	Sonic_RecordPosition			; record Sonic's previous position for the invincibility stars trail
		bsr.w	Sonic_Animate				; run Sonic's animation scripts
		bsr.w	Sonic_LoadGfx				; update Sonic's graphics if necessary
		jmp	(DisplaySprite).l			; display Sonic's sprites
; End of function Sonic_Hurt


; ---------------------------------------------------------------------------
; Subroutine to stop Sonic falling after he's been hurt
; ---------------------------------------------------------------------------

Sonic_HurtStop:
		move.w	(v_limitbtm2).w,d0			; get current target bottom level boundary
	if FixBugs
		; The original code does not consider that the camera boundary
		; may be in the middle of lowering itself, which is why going
		; down the S-tunnel in Green Hill Zone Act 1 fast enough can
		; kill Sonic.
		move.w	(v_limitbtm1).w,d1			; get current real bottom level boundary
		cmp.w	d0,d1					; is target bottom boundary lower than real one?
		blo.s	.skip					; if not, branch
		move.w	d1,d0					; use target bottom boundary for check to prevent unfair deaths
.skip:
	endif
		addi.w	#224,d0					; add screen height
		cmp.w	obY(a0),d0				; has Sonic touched the bottom level boundary?
	if (FixBugHurtDeathBoundary)|(FixBugs)
		blt.w	JumpTo_KillSonic			; if yes, kill Sonic (signed check to not die while leaving the top screen)
	else
		; This would cause Sonic to die from the upper/top boundary of the level, while in hurt state.
		; Also, the above branch goes out of range just from enabling FixBugs.
		blo.w	KillSonic				; if yes, kill Sonic (unsigned, this will kill Sonic if leaving the top screen)
	endif

		bsr.w	Sonic_Floor				; handle Sonic landing on the floor again
		btst	#1,obStatus(a0)				; is Sonic still in the air?
		bne.s	.continuehurt				; if yes, branch

		moveq	#0,d0					; clear d0
		move.w	d0,obVelY(a0)				; set Y-speed to 0
		move.w	d0,obVelX(a0)				; set X-speed to 0
		move.w	d0,obInertia(a0)			; set ground speed to 0
		move.b	#id_Walk,obAnim(a0)			; set to walking animation
		subq.b	#2,obRoutine(a0)			; set routine back to Sonic_Control
		move.w	#120,flashtime(a0)			; set flash time to 2 seconds of invulnerability frames

; locret_13860:
.continuehurt:
		rts						; return
; End of function Sonic_HurtStop


; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he dies (triggered from "KillSonic" in ReactToItem and when drowning)
; ---------------------------------------------------------------------------

; Obj01_Death:
Sonic_Death:	; Routine 6
		bsr.w	Sonic_HandleDeath			; handle Sonic falling, deducting a life, and maybe triggering game over
		jsr	(ObjectFall).l				; apply gravity
		bsr.w	Sonic_RecordPosition			; record Sonic's previous position for the invincibility stars trail (kinda pointless here...)
		bsr.w	Sonic_Animate				; run Sonic's animation scripts
		bsr.w	Sonic_LoadGfx				; update Sonic's graphics if necessary
		jmp	(DisplaySprite).l			; display Sonic's sprite
; End of function Sonic_Death


; ---------------------------------------------------------------------------
; Subroutine to check if Sonic has gone below the screen after dying, and
; update lives, restart the level, and potentially run game over
; ---------------------------------------------------------------------------

; GameOver: <-- old misnomer (this routine ALSO handles game overs, but not just)
Sonic_HandleDeath:
	if (FixBugDeathBoundary)|(FixBugs)
		; Fix the death boundary bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_death_boundary_bug
		move.w	(v_screenposy).w,d0			; get current Y screen position
	else
		move.w	(v_limitbtm2).w,d0			; get current bottom boundary position
	endif

		addi.w	#$100,d0				; go $100 pixels lower
		cmp.w	obY(a0),d0				; has Sonic's death animation gone below the screen?

	if (FixBugDeathBoundary)|(FixBugs)
		bge.w	.return					; if not, branch
	else
		bhs.w	.return					; if not, branch
	endif

		; Bottom reached, remove a life and check if game over was triggered
		move.w	#-$38,obVelY(a0)			; set to -$38 to cancel ObjectFall gravity (freeze Sonic in place)
		addq.b	#2,obRoutine(a0)			; go to Sonic_ResetLevel
		clr.b	(f_timecount).w				; stop time counter
		addq.b	#1,(f_lifecount).w			; update lives counter
		subq.b	#1,(v_lives).w				; subtract 1 from number of lives
		bne.s	.extraLivesRemaining			; did you run out of extra lives? if not, branch

		; GAME OVER
		move.w	#0,restartime(a0)			; set to not restart the level
		move.b	#id_GameOverCard,(v_gameovertext1).w	; load GAME object
		move.b	#id_GameOverCard,(v_gameovertext2).w	; load OVER object
		move.b	#1,(v_gameovertext2+obFrame).w		; set OVER object to correct frame
		clr.b	(f_timeover).w				; clear time over flag

; loc_138C2:
.gameOverBgmAndPatterns:
		music	#bgm_GameOver,snd_jsr			; set GAME OVER music and play it
		moveq	#plcid_GameOver,d0			; set game over patterns
		jmp	(AddPLC).l				; load them
; ===========================================================================

; loc_138D4:
.extraLivesRemaining:
		move.w	#60,restartime(a0)			; set reset level delay to 1 second
		tst.b	(f_timeover).w				; is TIME OVER tag set?
		beq.s	.return					; if not, branch
		move.w	#0,restartime(a0)			; set to not restart the level
		move.b	#id_GameOverCard,(v_gameovertext1).w	; load GAME object
		move.b	#id_GameOverCard,(v_gameovertext2).w	; load OVER object
		move.b	#2,(v_gameovertext1+obFrame).w		; set GAME frame to TIME
		move.b	#3,(v_gameovertext2+obFrame).w		; set OVER frame to OVER (different frame ID, but looks identical)
		bra.s	.gameOverBgmAndPatterns			; play music and load patterns
; ===========================================================================

; locret_13900:
.return:
		rts						; return
; End of function Sonic_HandleDeath


; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic after having died and fallen off the bottom of the screen
; ---------------------------------------------------------------------------

; Obj01_ResetLevel:
Sonic_ResetLevel: ; Routine 8
		tst.w	restartime(a0)				; was no restart time set? (game over / time over)
		beq.s	.return					; if yes, don't restart level
		subq.w	#1,restartime(a0)			; subtract 1 from time delay
		bne.s	.return					; if time remains, branch
		move.w	#1,(f_restart).w			; restart the level

; locret_13914:
.return:
		rts						; return
; End of function Sonic_ResetLevel


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to make Sonic run around loops (GHZ/SLZ).
; The visual effect of rendering Sonic behind the loop is handled through
; bit 6 in obRender, of which Sonic is the only object in the entire game
; to use it. The effect itself is handled in "FindNearestTile".
; ---------------------------------------------------------------------------

Sonic_Loops:
		cmpi.b	#id_SLZ,(v_zone).w			; is level SLZ?
		beq.s	.isstarlight				; if yes, branch
		tst.b	(v_zone).w				; is level GHZ?
		bne.w	.return					; if not, branch

; loc_13926:
.isstarlight:
		move.w	obY(a0),d0				; get Sonic's current Y-position
		lsr.w	#1,d0					; halve it (level layouts have FG and BG interlaced)
		andi.w	#$380,d0				; mask out irrelevant bits for Y-position
		move.b	obX(a0),d1				; get Sonic's current X-position
		andi.w	#$7F,d1					; mask out irrelevant bits for X-position
		add.w	d1,d0					; combine the two (this is now the index to get the current 256x256 chunk in the level)
		lea	(v_lvllayout_fg).w,a1			; load foreground level layout
		move.b	(a1,d0.w),d1				; load ID of 256x256 chunk Sonic is currently standing on

		cmp.b	(v_256roll1).w,d1			; is Sonic on a "roll tunnel" tile? (type A, entrance from the left)
		beq.w	Sonic_ChkRoll				; if yes, force Sonic into a rolling state
		cmp.b	(v_256roll2).w,d1			; is Sonic on a "roll tunnel" tile? (type B, exit to the right)
		beq.w	Sonic_ChkRoll				; if yes, force Sonic into a rolling state

		cmp.b	(v_256loop1).w,d1			; is Sonic on a loop tile? (type A, entering from/exiting to the left)
		beq.s	.chkifleft				; if yes, branch
		cmp.b	(v_256loop2).w,d1			; is Sonic on a loop tile? (type B, entering from/exiting to the right)
		beq.s	.chkifinair				; if yes, branch

		bclr	#6,obRender(a0)				; clear loop flag (return Sonic to high plane)
		rts
; ===========================================================================

; loc_13966:
.chkifinair:
		btst	#1,obStatus(a0)				; is Sonic in the air?
		beq.s	.chkifleft				; if not, branch

		bclr	#6,obRender(a0)				; clear loop flag (return Sonic to high plane)
		rts
; ===========================================================================

; loc_13976:
.chkifleft:
		move.w	obX(a0),d2				; get Sonic's current X position
		cmpi.b	#44,d2					; is Sonic past the first couple pixels of the loop? (byte check)
		bhs.s	.chkifright				; if yes, branch

		bclr	#6,obRender(a0)				; clear loop flag (return Sonic to high plane)
		rts						; return
; ===========================================================================

; loc_13988:
.chkifright:
		cmpi.b	#224,d2					; is Sonic past the last couple pixels of the loop? (byte check)
		blo.s	.chkangle1				; if not, branch

		bset	#6,obRender(a0)				; set loop flag (send Sonic to low plane)
		rts						; return
; ===========================================================================

; loc_13996:
.chkangle1:
		btst	#6,obRender(a0) 			; is loop flag already set?
		bne.s	.chkangle2				; if yes, branch

		move.b	obAngle(a0),d1				; get Sonic's current angle
		beq.s	.return					; if Sonic is on the flat surface of the loop, branch
		cmpi.b	#$80,d1					; has Sonic crossed the apex of the loop (i.e. is he upside-down)?
		bhi.s	.return					; if yes, branch
		bset	#6,obRender(a0)				; set loop flag (send Sonic to low plane)
		rts						; return
; ===========================================================================

; loc_139B2:
.chkangle2:
		move.b	obAngle(a0),d1				; get Sonic's current angle
		cmpi.b	#$80,d1					; has Sonic crossed the apex of the loop (i.e. is he upside-down)?
		bls.s	.return					; if not, branch
		bclr	#6,obRender(a0)				; clear loop flag (return Sonic to high plane)

; locret_139C2:
.return:
		rts						; return
; End of function Sonic_Loops

	if FixBugScatteredRingsTimer
		include "Enhancements/_incObj/Sonic Drowns.asm"
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to animate Sonic's sprites
; ---------------------------------------------------------------------------

Sonic_Animate:
		lea	(Ani_Sonic).l,a1			; load Sonic's animation scripts
		moveq	#0,d0					; clear d0
		move.b	obAnim(a0),d0				; get Sonic's currently set animation ID
		cmp.b	obPrevAni(a0),d0			; does it differ from the previous animation? (i.e. has animation changed?)
		beq.s	.do					; if not, branch
		move.b	d0,obPrevAni(a0)			; remember new animation
		move.b	#0,obAniFrame(a0)			; restart animation from beginning
		move.b	#0,obTimeFrame(a0)			; reset animation frame duration
	if (FixBugWalkJump=2)|(FixBugs)
		; This fixes the occasional "pushing air" bug
		bclr	#5,obStatus(a0)				; clear pushing flag
	endif

; SAnim_Do:
.do:
		add.w	d0,d0					; double animation ID for word-based indexing
		adda.w	(a1,d0.w),a1				; jump to appropriate animation script
		move.b	(a1),d0					; load frame interval for this animation
		bmi.s	.walkrunroll				; if frame interval is negative, this is a special walk/run/roll/jump animation, branch

		move.b	obStatus(a0),d1				; get Sonic's status bitfield
		andi.b	#1,d1					; mask out everything but the X-flip flag
		andi.b	#$FC,obRender(a0)			; clear X-flip and Y-flip flags in Sonic's render flags
		or.b	d1,obRender(a0)				; set new X-flip flag state

		subq.b	#1,obTimeFrame(a0)			; subtract 1 from frame duration
		bpl.s	.delay					; if time remains, branch
		move.b	d0,obTimeFrame(a0)			; reset frame duration

; SAnim_Do2:
.loadframe:
		moveq	#0,d1					; clear d1
		move.b	obAniFrame(a0),d1			; load current frame number
		move.b	1(a1,d1.w),d0				; read sprite number from script
		bmi.s	.end_FF					; if animation is complete, branch

; SAnim_Next:
.next:
		move.b	d0,obFrame(a0)				; load sprite number
		addq.b	#1,obAniFrame(a0)			; next frame number

; SAnim_Delay:
.delay:
		rts						; return
; ===========================================================================

; SAnim_End_FF:
.end_FF:
		addq.b	#1,d0					; is this the afEnd flag ($FF)?
		bne.s	.end_FE					; if not, branch
		move.b	#0,obAniFrame(a0)			; restart the animation
		move.b	1(a1),d0				; read sprite number
		bra.s	.next					; set new frame
; ===========================================================================

; SAnim_End_FE
.end_FE:
		addq.b	#1,d0					; is this the afBack flag ($FE)?
		bne.s	.end_FD					; if not, branch
		move.b	2(a1,d1.w),d0				; read the next byte in the script
		sub.b	d0,obAniFrame(a0)			; jump back d0 bytes in the script
		sub.b	d0,d1					; adjust sprite index
		move.b	1(a1,d1.w),d0				; read new sprite number
		bra.s	.next					; set new frame
; ===========================================================================

; SAnim_End_FD:
.end_FD:
		addq.b	#1,d0					; is this the afChange flag ($FD)?
		bne.s	.end					; if not, branch
		move.b	2(a1,d1.w),obAnim(a0)			; read next byte, run that animation

; SAnim_End:
.end:
		rts						; return
; ===========================================================================

; SAnim_WalkRun:
.walkrunroll:
		subq.b	#1,obTimeFrame(a0)			; subtract 1 from frame duration
		bpl.s	.delay					; if time remains, branch
		addq.b	#1,d0					; is animation walking/running?
		bne.w	.rolljump				; if not, branch
		moveq	#0,d1					; clear d1 (do not alter flip flags)
		move.b	obAngle(a0),d0				; get Sonic's angle
	if FixBugs
		; Fix off-by-one-radian error (this was implemented in S2/S3K)
		ble.s	.notoffbyone				; on a flat surface or ascending slope? if yes, branch
		subq.b	#1,d0					; adjust off-by-one angle on descending slopes
.notoffbyone:
	endif
		move.b	obStatus(a0),d2				; get Sonic's current status bitfield
		andi.b	#1,d2					; mask out anything but the X-flip flag
		bne.s	.flip					; is Sonic mirrored horizontally? if yes, branch
		not.b	d0					; reverse angle
; loc_13A70:
.flip:
		addi.b	#$10,d0					; add $10 to angle
		bpl.s	.noinvert				; if angle is $0-$7F, branch
		moveq	#3,d1					; invert both flip flags
; loc_13A78:
.noinvert:
		andi.b	#$FC,obRender(a0)			; clear current flip flags
		eor.b	d1,d2					; invert flip flags depending on current angle
		or.b	d2,obRender(a0)				; set new flip flags

		btst	#5,obStatus(a0)				; is Sonic pushing something?
		bne.w	.push					; if yes, branch

		lsr.b	#4,d0					; divide angle by $10
		andi.b	#6,d0					; angle must be 0, 2, 4 or 6 (this is now the octant modifier)
		move.w	obInertia(a0),d2			; get Sonic's ground speed
		bpl.s	.nomodspeed				; if it's positive, branch
		neg.w	d2					; otherwise, make it positive

; loc_13A9C:
.nomodspeed:
		lea	(SonAni_Run).l,a1			; use running animation
		cmpi.w	#$600,d2				; is Sonic at running speed?
		bhs.s	.running				; if yes, branch

		lea	(SonAni_Walk).l,a1			; use walking animation instead
		move.b	d0,d1					; make octant modifier a multiple of 3
		lsr.b	#1,d1					; (0, 3, 6, 9)
		add.b	d1,d0					; this accounts for 6 total walking frames (Sonic 2 would change this to support 8)

; loc_13AB4:
.running:
		add.b	d0,d0					; multiply octant modifier by 2
		move.b	d0,d3					; (becomes multiple of 4 for running (0, 4, 8, 12), multiple of 6 for walking (0, 6, 12, 18))
		neg.w	d2					; make speed negative
		addi.w	#$800,d2				; add a significant amount of speed (-$600+$800 >> 8 would result in a frame interval of 2)
		bpl.s	.belowmax				; if result is positive, use that as frame interval
		moveq	#0,d2					; otherwise, set max animation speed

; loc_13AC2:
.belowmax:
		lsr.w	#8,d2					; shift down by one byte
		move.b	d2,obTimeFrame(a0)			; modify frame duration
		bsr.w	.loadframe				; update current frame
		add.b	d3,obFrame(a0)				; modify frame number
		rts						; return
; ===========================================================================

; SAnim_RollJump:
.rolljump:
		addq.b	#1,d0					; is animation rolling/jumping?
		bne.s	.push					; if not, branch
		move.w	obInertia(a0),d2			; get Sonic's speed
		bpl.s	.nomodspeed2				; is it positive? if yes, branch
		neg.w	d2					; otherwise, make it positive

; loc_13ADE:
.nomodspeed2:
		lea	(SonAni_Roll2).l,a1			; use fast rolling animation
		cmpi.w	#$600,d2				; is Sonic moving fast?
		bhs.s	.rollfast				; if yes, branch
		lea	(SonAni_Roll).l,a1			; use slower rolling animation instead

; loc_13AF0:
.rollfast:
		neg.w	d2					; make speed negative
		addi.w	#$400,d2				; add a significant amount of speed (-$200+$400 >> 8 would result in a frame interval of 2)
		bpl.s	.belowmax2				; if result is positive, use that as frame interval
		moveq	#0,d2					; otherwise, set maximum animation speed

; loc_13AFA:
.belowmax2:
		lsr.w	#8,d2					; shift down a byte
		move.b	d2,obTimeFrame(a0)			; modify frame duration

		move.b	obStatus(a0),d1				; get Sonic's current status flags
		andi.b	#1,d1					; mask out everything but the X-flip flag
		andi.b	#$FC,obRender(a0)			; clear Sonic's current flip flags
		or.b	d1,obRender(a0)				; set new X-flip flag
		bra.w	.loadframe				; update current frame
; ===========================================================================

; SAnim_Push:
.push:
		move.w	obInertia(a0),d2			; get Sonic's speed
		bmi.s	.negspeed				; if it's negative, branch
		neg.w	d2					; otherwise, make it negative

; loc_13B1E:
.negspeed:
		addi.w	#$800,d2				; add a significant amount of speed (-$100+$700 >> 6 would result in a frame interval of 7)
		bpl.s	.belowmax3				; if result is positive, use that as frame interval
		moveq	#0,d2					; otherwise, set maximum animation speed (with pushing, this shouldn't ever happen...)

; loc_13B26:
.belowmax3:
		lsr.w	#6,d2					; shift down a byte and further multiply frame interval by 4
		move.b	d2,obTimeFrame(a0)			; modify frame duration

		lea	(SonAni_Push).l,a1			; load Sonic's animation script for pushing

		move.b	obStatus(a0),d1				; get Sonic's current status flags
		andi.b	#1,d1					; mask out everything but the X-flip flag
		andi.b	#$FC,obRender(a0)			; clear Sonic's current flip flags
		or.b	d1,obRender(a0)				; set new X-flip flag
		bra.w	.loadframe				; update current frame
; End of function Sonic_Animate

; ---------------------------------------------------------------------------
; Animation scripts - Sonic (also includes constants for frame IDs)
; SonicAniData:
		include	"_anim/Sonic.asm"
; ---------------------------------------------------------------------------


; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic graphics loading subroutine (DPLC - Dynamic Pattern Load Cues)
; ---------------------------------------------------------------------------

; LoadSonicDynPLC:
Sonic_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0				; load frame number
		cmp.b	(v_sonframenum).w,d0			; has frame changed?
		beq.s	.nochange				; if not, branch (nothing to do)

		move.b	d0,(v_sonframenum).w			; remember new frame ID
		lea	(SonicDynPLC).l,a2			; load PLC script
		add.w	d0,d0					; double current frame for word-based indexing
		adda.w	(a2,d0.w),a2				; find relevant DPLC definition for new frame

	if FeatureEnhancedPLCQueue
		moveq	#0,d1
		move.b	(a2)+,d1				; read "number of entries" value
		subq.b	#1,d1
		move.w	d1,d5					; keep a copy for the DMA queue path
	else
		moveq	#0,d1					; clear d1
		move.b	(a2)+,d1				; read "number of entries" value
		subq.b	#1,d1					; subtract by 1 for first iteration
	endif ; if FeatureEnhancedPLCQueue

		bmi.s	.nochange				; if this was an empty entry, nothing to do, branch

	if FeatureEnhancedPLCQueue
	if FeatureSonic2013SuperSonic
		bsr.w	Sonic2013_TestSuperArt		; does this frame need recoloured art?
		beq.s	.queuedsetup				; if not, branch
		lea	(v_sgfx_buffer).w,a3			; load Sonic's graphics transfer buffer
		bra.s	.readentry

.queuedsetup:
	endif ; if FeatureSonic2013SuperSonic
		move.w	#$F000,d4				; set starting VRAM destination for Sonic graphics
		move.l	#Art_Sonic,d6				; load base address of Sonic's uncompressed art
	else
		lea	(v_sgfx_buffer).w,a3			; load Sonic's graphics transfer buffer
		move.b	#1,(f_sonframechg).w			; set flag for VBlank to update Sonic graphics via DMA
	endif ; if FeatureEnhancedPLCQueue

; SPLC_ReadEntry:
.readentry:
	if FeatureEnhancedPLCQueue
	if FeatureSonic2013SuperSonic
		bsr.w	Sonic2013_TestSuperArt		; copy through RAM so only Sonic gets recoloured
		bne.s	.bufferentry				; if yes, branch
	endif ; if FeatureSonic2013SuperSonic
		moveq	#0,d1					; clear d1
		move.b	(a2)+,d1				; read first byte of DPLC entry
		lsl.w	#8,d1					; shift into upper byte
		move.b	(a2)+,d1				; read second byte of DPLC entry
		move.w	d1,d3					; copy DPLC entry to d3
		lsr.w	#8,d3					; move tile count nybble into lower byte
		andi.w	#$F0,d3					; isolate upper nybble (tile count)
		addi.w	#$10,d3					; add 1 tile ($10 == 1 tile in bytes)
		andi.w	#$FFF,d1				; isolate source tile index/offset
		lsl.l	#5,d1					; multiply by $20 (tile_size)
		add.l	d6,d1					; add base art address
		move.w	d4,d2					; copy current VRAM destination to d2
		add.w	d3,d4					; advance VRAM destination by transfer size
		add.w	d3,d4					; double because VRAM addresses are word-based
		jsr	(QueueDMATransfer).l			; queue DMA transfer for this DPLC entry
		dbf	d5,.readentry				; repeat for number of entries
	if FeatureSonic2013SuperSonic
		bra.s	.nochange

.bufferentry:
		moveq	#0,d2					; clear d2
		move.b	(a2)+,d2				; read next byte of DPLC entry
		move.w	d2,d0					; copy to d0
		lsr.b	#4,d0					; shift out lower nybble, upper nybble is number of tiles
		lsl.w	#8,d2					; shift value into upper byte of word
		move.b	(a2)+,d2				; read next byte of DPLC entry
		lsl.w	#5,d2					; multiply by $20 (tile_size)
		lea	(Art_Sonic).l,a1			; load Sonic's uncompressed graphics
		adda.l	d2,a1					; add offset for current DPLC entry

.loadsupertile:
		movem.l	(a1)+,d2-d6/a4-a6			; copy a full tile's worth of data to 8 different registers
		movem.l	d2-d6/a4-a6,(a3)			; write them to Sonic's graphics transfer buffer
		lea	tile_size(a3),a3			; go to next tile
		dbf	d0,.loadsupertile			; repeat for number of tiles
		dbf	d1,.readentry				; repeat for number of entries
		bsr.w	Sonic2013_ApplySuperArt		; recolour only Sonic's buffered art
		move.l	#v_sgfx_buffer,d1			; source buffer
		move.w	#ArtTile_Sonic*tile_size,d2		; VRAM destination
		move.w	#(v_sgfx_buffer_end-v_sgfx_buffer)/2,d3 ; transfer length in words
		jsr	(QueueDMATransfer).l			; queue recoloured Sonic art
	endif ; if FeatureSonic2013SuperSonic
	else
		moveq	#0,d2					; clear d2
		move.b	(a2)+,d2				; read next byte of DPLC entry
		move.w	d2,d0					; copy to d0
		lsr.b	#4,d0					; shift out lower nybble, upper nybble is number of tiles
		lsl.w	#8,d2					; shift value into upper byte of word
		move.b	(a2)+,d2				; read next byte of DPLC entry
		lsl.w	#5,d2					; multiply by $20 (tile_size)
		lea	(Art_Sonic).l,a1			; load Sonic's uncompressed graphics
		adda.l	d2,a1					; add offset for current DPLC entry

; SPLC_LoadTile:
.loadtile:
		movem.l	(a1)+,d2-d6/a4-a6			; copy a full tile's worth of data to 8 different registers
		movem.l	d2-d6/a4-a6,(a3)			; write them to Sonic's graphics transfer buffer
		lea	tile_size(a3),a3			; go to next tile
		dbf	d0,.loadtile				; repeat for number of tiles
		dbf	d1,.readentry				; repeat for number of entries
	endif ; if FeatureEnhancedPLCQueue

	if FeatureSonic2013SuperSonic&(FeatureEnhancedPLCQueue=0)
		bsr.w	Sonic2013_TestSuperArt		; is Super Sonic art active?
		beq.s	.nochange				; if not, branch
		bsr.w	Sonic2013_ApplySuperArt		; recolour only Sonic's buffered art
	endif ; if FeatureSonic2013SuperSonic&(FeatureEnhancedPLCQueue=0)

; locret_13C96:
.nochange:
		rts						; return
; End of function Sonic_LoadGfx
; ===========================================================================

	if FeatureUnlockMovesAfterCompletion
; ---------------------------------------------------------------------------
; Check if the SRAM completion flag has been written.
; ---------------------------------------------------------------------------

CheckSRAMGameComplete:
	if EnableSRAM=1
		gotoSRAM
		cmpi.b	#"S",(sram_save_sig1).l		; has SRAM been initialized?
		bne.s	.locked				; if not, branch
		cmpi.b	#"1",(sram_save_sig2).l		; is this this game's save data?
		bne.s	.locked				; if not, branch
		move.b	(sram_unlock_flags).l,d0	; get unlocked feature flags
		andi.b	#maskSRAMGameComplete,d0	; has the game been completed?
		bra.s	.return				; restore ROM mapping and return

.locked:
		moveq	#0,d0				; no unlocks

.return:
		gotoROM
		tst.b	d0				; set condition codes for callers
	else
		moveq	#0,d0				; no SRAM means no saved completion flag
	endif ; if EnableSRAM=1
		rts
; End of function CheckSRAMGameComplete
; ===========================================================================
	endif ; if FeatureUnlockMovesAfterCompletion
