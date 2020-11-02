; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PauseGame:
		nop
		tst.b	(v_lives).w																; do you have any lives	left?
	if FeatureSonicCDPauseRestartLevel=0
		beq.s	Unpause																		; if not, branch
	else
		beq.w	Unpause																		; if not, branch
	endc
		tst.w	(f_pause).w																; is game already paused?
		bne.s	Pause_StopGame														; if yes, branch
		btst	#bitStart,(v_jpadpress1).w 								; is Start button pressed?
	if FeatureSonicCDPauseRestartLevel=0
		beq.s	Pause_DoNothing														; if not, branch
	else
		beq.w	Pause_DoNothing														; if not, branch
	endc


Pause_StopGame:
		move.w	#1,(f_pause).w													; freeze time
	if FeatureMusicWhilePaused=0
		if FeatureUseSonic2SoundDriver=0
			move.b	#1,(v_snddriver_ram+f_pausemusic).w 		; pause music
		else
			stopZ80
			waitZ80
			move.b  #MusID_Pause,(Z80_RAM+zAbsVar.StopMusic).l  ; pause music
			startZ80
		endc # if FeatureUseSonic2SoundDriver=0
	endc # if FeatureMusicWhilePaused=0

Pause_Loop:
		move.b	#$10,(v_vbla_routine).w
		bsr.w	WaitForVBla
		tst.b	(f_slomocheat).w 													; is slow-motion cheat on?
	if FeatureSonicCDPauseRestartLevel=0
		beq.s	Pause_ChkStart													; if not, branch
	else
		beq.s	Pause_Check_Reset													; if not, branch
	endc
		btst	#bitA,(v_jpadpress1).w 										; is button A pressed?
		beq.s	Pause_ChkBC																; if not, branch
		move.b	#id_Title,(v_gamemode).w 								; set game mode to 4 (title screen)
		nop
		bra.s	Pause_EndMusic
; ===========================================================================

	if FeatureSonicCDPauseRestartLevel>0
Pause_Check_Reset:
		cmp.b #1,(v_lives).w    												; Check if you only have 1 life
 		beq.s Pause_ChkStart  													; If so branch (This way you don't get 0 lives and then underflow)
		btst	#bitA,(v_jpadpress1).w 										; is button A pressed?
		bne.s	Pause_Reset																; if so, branch
		btst	#bitB,(v_jpadpress1).w 										; is button B pressed?
		bne.s	Pause_Reset																; if so, branch
		btst	#bitC,(v_jpadpress1).w 										; is button C pressed?
		bne.s	Pause_Reset																; if so, branch
		bra.s	Pause_ChkStart														; Check Start Buttom

Pause_Reset:
		lea (v_objspace).w,a0
		jsr KillSonic																		; Kill Sonic
    bra.s Pause_EndMusic 														; Unpause
	endc

Pause_ChkBC:
		btst	#bitB,(v_jpadhold1).w 										; is button B pressed?
		bne.s	Pause_SlowMo															; if yes, branch
		btst	#bitC,(v_jpadpress1).w 										; is button C pressed?
		bne.s	Pause_SlowMo															; if yes, branch

Pause_ChkStart:
		btst	#bitStart,(v_jpadpress1).w 								; is Start button pressed?
		beq.s	Pause_Loop																; if not, branch

Pause_EndMusic:
	if FeatureMusicWhilePaused=0
		if FeatureUseSonic2SoundDriver=0
			move.b	#$80,(v_snddriver_ram+f_pausemusic).w		; unpause the music
		else
			stopZ80
      waitZ80
      move.b  #MusID_Unpause,(Z80_RAM+zAbsVar.StopMusic).l
      startZ80
		endc ; if FeatureUseSonic2SoundDriver=0
	endc ; if FeatureMusicWhilePaused=0

Unpause:
		move.w	#0,(f_pause).w													; unpause the game

Pause_DoNothing:
		rts
; ===========================================================================

Pause_SlowMo:
		move.w	#1,(f_pause).w
		if FeatureMusicWhilePaused=0
			if FeatureUseSonic2SoundDriver=0
				move.b	#$80,(v_snddriver_ram+f_pausemusic).w		; unpause the music
			else
				stopZ80
	      waitZ80
	      move.b  #MusID_Unpause,(Z80_RAM+zAbsVar.StopMusic).l
	      startZ80
			endc ; if FeatureUseSonic2SoundDriver=0
		endc ; if FeatureMusicWhilePaused=0
		rts
; End of function PauseGame
