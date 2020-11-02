; ---------------------------------------------------------------------------
; Subroutine to	play a music track

; input:
;	d0 = track to play
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PlaySound:
	if FeatureUseSonic2SoundDriver=0
		move.b	d0,(v_snddriver_ram+v_soundqueue0).w
	else
		stopZ80                     ; Stop the Z80 so the 68k can write to Z80 RAM
		waitZ80
		tst.b   (Z80_RAM+zAbsVar.QueueToPlay).l     ; If this (zQueueToPlay) isn't $00, the driver is processing a previous sound request.
		bne.s   @skip                   ; So we'll put this sound in a backup queue
		move.b  d0,(Z80_RAM+zAbsVar.QueueToPlay).l  ; Queue sound
		startZ80                    ; Start the Z80 back up again so the sound driver can continue functioning
		rts
	@skip:
		move.b  d0,(Z80_RAM+zAbsVar.SFXUnknown).l   ; Queue sound
		startZ80                    ; Start the Z80 back up again so the sound driver can continue functioning
	endc
		rts
; End of function PlaySound

; ---------------------------------------------------------------------------
; Subroutine to	play a sound effect
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PlaySound_Special:
	if FeatureUseSonic2SoundDriver=0
		move.b	d0,(v_snddriver_ram+v_soundqueue1).w
	else
		stopZ80                     ; Stop the Z80 so the 68k can write to Z80 RAM
		waitZ80
		tst.b   (Z80_RAM+zAbsVar.SFXToPlay).l       ; Is this queue occupied?
		bne.s   @skip                   ; If so, we'll put this sound in a different queue
		move.b  d0,(Z80_RAM+zAbsVar.SFXToPlay).l    ; Queue sound
		startZ80                    ; Start the Z80 back up again so the sound driver can continue functioning
		rts
	@skip:
		move.b  d0,(Z80_RAM+zAbsVar.SFXStereoToPlay).l  ; Queue sound
		startZ80                    ; Start the Z80 back up again so the sound driver can continue functioning
		rts
	endc
		rts
; End of function PlaySound_Special

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused sound/music subroutine
; ---------------------------------------------------------------------------

PlaySound_Unused:
		move.b	d0,(v_snddriver_ram+v_soundqueue2).w
		rts
