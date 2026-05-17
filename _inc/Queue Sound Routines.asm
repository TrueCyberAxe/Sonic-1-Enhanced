; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 1, often used for BGM

; input:
;	d0 = track to play
; ---------------------------------------------------------------------------

; PlaySound:
QueueSound1:
	if FeatureUseSonic2SoundDriver
		; Queue music through the Sonic 2 Z80 driver's primary slot, with backup if busy.
		stopZ80						; Stop the Z80 so the 68k can write to Z80 RAM
		waitZ80
		; QueueToPlay uses S2QueueEmpty when the primary music slot is idle.
		cmpi.b	#S2QueueEmpty,(Z80_RAM+zAbsVar.QueueToPlay).l
		bne.s	.skip					; If not, put this sound in a backup queue
		move.b	d0,(Z80_RAM+zAbsVar.QueueToPlay).l	; Queue sound
		startZ80					; Start the Z80 back up again so the sound driver can continue functioning
		rts
.skip:
		move.b	d0,(Z80_RAM+zAbsVar.SFXUnknown).l	; Queue sound
		startZ80					; Start the Z80 back up again so the sound driver can continue functioning
	else
		move.b	d0,(v_snddriver_ram.v_soundqueue0).w
	endif
		rts
; End of function QueueSound1

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 2, often used for SFX
; ---------------------------------------------------------------------------

; PlaySound_Special:
QueueSound2:
	if FeatureUseSonic2SoundDriver
		cmpi.b	#flg__First,d0				; Is this one of the Sonic 2 driver's command IDs?
		blo.s	.sfx					; If not, use the SFX queue
		cmpi.b	#flg__Last+1,d0
		blo.s	.command				; If yes, queue it through the main command slot

.sfx:
		; Queue SFX through the Sonic 2 Z80 driver's primary slot, with backup if busy.
		stopZ80						; Stop the Z80 so the 68k can write to Z80 RAM
		waitZ80
		tst.b	(Z80_RAM+zAbsVar.SFXToPlay).l		; Is this queue occupied?
		bne.s	.skip					; If so, we'll put this sound in a different queue
		move.b	d0,(Z80_RAM+zAbsVar.SFXToPlay).l		; Queue sound
		startZ80					; Start the Z80 back up again so the sound driver can continue functioning
		rts
.skip:
		move.b	d0,(Z80_RAM+zAbsVar.SFXStereoToPlay).l	; Queue sound
		startZ80					; Start the Z80 back up again so the sound driver can continue functioning
		bra.s	.done

.command:
		stopZ80						; Stop the Z80 so the 68k can write to Z80 RAM
		waitZ80
		; QueueToPlay uses S2QueueEmpty when the command slot is idle.
		cmpi.b	#S2QueueEmpty,(Z80_RAM+zAbsVar.QueueToPlay).l
		bne.s	.skipcommand				; If not, use the backup command queue
		move.b	d0,(Z80_RAM+zAbsVar.QueueToPlay).l	; Queue command
		startZ80					; Start the Z80 back up again so the sound driver can continue functioning
		rts
.skipcommand:
		move.b	d0,(Z80_RAM+zAbsVar.SFXUnknown).l	; Queue command
		startZ80					; Start the Z80 back up again so the sound driver can continue functioning
.done:
	else
		move.b	d0,(v_snddriver_ram.v_soundqueue1).w
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
