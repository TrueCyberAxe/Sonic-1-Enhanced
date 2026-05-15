; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 1, often used for BGM

; input:
;	d0 = track to play
; ---------------------------------------------------------------------------

; PlaySound:
QueueSound1:
	if FeatureUseSonic2SoundDriver=0
		move.b	d0,(v_snddriver_ram+v_soundqueue0).w
	else
		stopZ80                     ; Stop the Z80 so the 68k can write to Z80 RAM
		waitZ80
		tst.b   (Z80_RAM+zAbsVar.QueueToPlay).l     ; If this (zQueueToPlay) isn't $00, the driver is processing a previous sound request.
		bne.s   .skip                   ; So we'll put this sound in a backup queue
		move.b  d0,(Z80_RAM+zAbsVar.QueueToPlay).l  ; Queue sound
		startZ80                    ; Start the Z80 back up again so the sound driver can continue functioning
		rts
.skip:
		move.b  d0,(Z80_RAM+zAbsVar.SFXUnknown).l   ; Queue sound
		startZ80                    ; Start the Z80 back up again so the sound driver can continue functioning
	endif
		rts
; End of function QueueSound1

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 2, often used for SFX
; ---------------------------------------------------------------------------

; PlaySound_Special:
QueueSound2:
	if FeatureUseSonic2SoundDriver=0
		move.b	d0,(v_snddriver_ram+v_soundqueue1).w
	else
		stopZ80                     ; Stop the Z80 so the 68k can write to Z80 RAM
		waitZ80
		tst.b   (Z80_RAM+zAbsVar.SFXToPlay).l       ; Is this queue occupied?
		bne.s   .skip                   ; If so, we'll put this sound in a different queue
		move.b  d0,(Z80_RAM+zAbsVar.SFXToPlay).l    ; Queue sound
		startZ80                    ; Start the Z80 back up again so the sound driver can continue functioning
		rts
.skip:
		move.b  d0,(Z80_RAM+zAbsVar.SFXStereoToPlay).l  ; Queue sound
		startZ80                    ; Start the Z80 back up again so the sound driver can continue functioning
	endif
		rts
; End of function QueueSound2

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	queue a sound into buffer 3, unused and broken.
; Enabling "FixBugs" will make this usable.
; ---------------------------------------------------------------------------

; PlaySound_Unused:
QueueSound3:
		move.b	d0,(v_snddriver_ram.v_soundqueue2).w
		rts
; End of function QueueSound3
