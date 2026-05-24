; ---------------------------------------------------------------------------
; Subroutine to pause the game
; ---------------------------------------------------------------------------

PauseGame:
	if TweakCodeOptimizations=0
		nop
	endif ; if TweakCodeOptimizations=0

		tst.b	(v_lives).w																; do you have any lives	left?

	if (EnhancedDebug)|(FeatureCDPauseRestartLevel)
		beq.w	Unpause																		; if not, branch
	else
		beq.s	Unpause																		; if not, branch
	endif

	if FixBugPauseOnSSResults
		tst.w	(f_pause).w																; is game already paused?
		bne.s	.allowpause																; if yes, allow unpausing
		cmpi.b	#id_Level,(v_gamemode).w 										; are we in a normal level?
		bne.s	.allowpause																; if not, branch
		tst.b	(f_timecount).w 													; has the stage already finished?
		beq.w	Pause_DoNothing														; if yes, don't allow pausing
.allowpause:
	endif ; if FixBugPauseOnSSResults

		tst.w	(f_pause).w																; is game already paused?
		bne.s	Pause_StopGame														; if yes, branch
		btst	#bitStart,(v_jpadpress1).w 								; is Start button pressed?

	if (EnhancedDebug)|(FeatureCDPauseRestartLevel)
		beq.w	Pause_DoNothing														; if not, branch
	else
		beq.s	Pause_DoNothing														; if not, branch
	endif

Pause_StopGame:
	if EnhancedDebug
		tst.b (v_debuguse).w 														; Is debug mode active?
		beq.s @skip																			; if not, branch

		bset	#bitDebugLevelSelect,(f_debugmode).w			; mark level select as opened from debug mode
		bra.w GotoLevelSelect
	@skip:
	endif ; if EnhancedDebug

		move.w	#1,(f_pause).w																; freeze time

	if FeatureMusicWhilePaused=0
		if FeatureUseSonic2SoundDriver
			; Tell the Sonic 2 sound driver to pause from inside its own Z80 RAM.
			stopZ80
			waitZ80
			move.b	#MusID_Pause,(Z80_RAM+zAbsVar.StopMusic).l	; pause music
			startZ80
		else
			move.b	#1,(v_snddriver_ram.f_pausemusic).w ; pause music				; pause music
		endif ; if FeatureUseSonic2SoundDriver
	endif ; if FeatureMusicWhilePaused=0

Pause_Loop:
		move.b	#id_VBlank_Paused,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		tst.b	(f_slomocheat).w 													; is slow-motion cheat on?

	if FeatureCDPauseRestartLevel
		beq.s	Pause_Check_Reset													; if not, branch
	else
		beq.s	Pause_ChkStart														; if not, branch
	endif

		btst	#bitA,(v_jpadpress1).w 										; is button A pressed?
		beq.s	Pause_ChkBC																; if not, branch
		move.b	#id_Title,(v_gamemode).w 								; set game mode to 4 (title screen)
		nop
		bra.s	Pause_EndMusic
; ===========================================================================

	if FeatureCDPauseRestartLevel
Pause_Check_Reset:
		cmpi.b	#$01,(v_lives).w		; check if only 1 life remains
		beq.s	Pause_ChkStart			; if so, avoid underflowing to 0 lives
		btst	#bitA,(v_jpadpress1).w 										; is button A pressed?
		bne.s	Pause_Reset																; if so, branch
		btst	#bitB,(v_jpadpress1).w 										; is button B pressed?
		bne.s	Pause_Reset																; if so, branch
		btst	#bitC,(v_jpadpress1).w 										; is button C pressed?
		bne.s	Pause_Reset																; if so, branch
		bra.s	Pause_ChkStart			; check Start button

Pause_Reset:
		lea	(v_objspace).w,a0
		jsr	KillSonic			; kill Sonic to restart the level
		bra.s	Pause_EndMusic			; unpause
	endif ; if FeatureCDPauseRestartLevel

Pause_ChkBC:
		btst	#bitB,(v_jpadhold1).w ; is button B held?
		bne.s	Pause_SlowMo															; if yes, branch
		btst	#bitC,(v_jpadpress1).w 										; is button C pressed?
		bne.s	Pause_SlowMo															; if yes, branch

Pause_ChkStart:
		btst	#bitStart,(v_jpadpress1).w 								; is Start button pressed?
		beq.s	Pause_Loop																; if not, branch

Pause_EndMusic:
	if FeatureMusicWhilePaused=0

	if FeatureUseSonic2SoundDriver
		; Tell the Sonic 2 sound driver to unpause from inside its own Z80 RAM.
		stopZ80
		waitZ80
		move.b	#MusID_Unpause,(Z80_RAM+zAbsVar.StopMusic).l
		startZ80
	else
		move.b	#$80,(v_snddriver_ram.f_pausemusic).w	; unpause the music
	endif ; if FeatureUseSonic2SoundDriver

	endif ; if FeatureMusicWhilePaused=0

Unpause:
		move.w	#0,(f_pause).w													; unpause the game

Pause_DoNothing:
		rts
; ===========================================================================

Pause_SlowMo:
		move.w	#1,(f_pause).w

	if FeatureMusicWhilePaused=0

	if FeatureUseSonic2SoundDriver
		; Slow motion advances one frame, so unpause the Sonic 2 sound driver here too.
		stopZ80
		waitZ80
		move.b	#MusID_Unpause,(Z80_RAM+zAbsVar.StopMusic).l
		startZ80
	else
		move.b	#$80,(v_snddriver_ram.f_pausemusic).w	; Unpause the music
	endif ; if FeatureUseSonic2SoundDriver

	endif ; if FeatureMusicWhilePaused=0

		rts
; End of function PauseGame
