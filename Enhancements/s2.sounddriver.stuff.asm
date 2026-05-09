Size_of_Snd_driver_guess =	$DFA ; approximate post-compressed size of the Z80 sound driver

id function ptr,((ptr-offset)/ptrsize+idstart)

; function to make a little-endian 16-bit pointer for the Z80 sound driver
z80_ptr function x,(x)<<8&$FF00|(x)>>8&$7F|$80

; macro to declare a little-endian 16-bit pointer for the Z80 sound driver
rom_ptr_z80 macro addr
	dc.w z80_ptr(addr)
    endm

; aligns the start of a bank, and detects when the bank's contents is too large
; can also print the amount of free space in a bank with DebugSoundbanks set
startBank macro {INTLABEL}
	align	$8000
__LABEL__ label *
soundBankStart := __LABEL__
soundBankName := "__LABEL__"
    endm

DebugSoundbanks := 1

finishBank macro
	if * > soundBankStart + $8000
		fatal "soundBank \{soundBankName} must fit in $8000 bytes but was $\{*-soundBankStart}. Try moving something to the other bank."
	elseif (DebugSoundbanks<>0)&&(MOMPASS=1)
		message "soundBank \{soundBankName} has $\{$8000+soundBankStart-*} bytes free at end."
	endif
    endm

; ---BOUNDARIES---
MusID__First	= bgm__First
;	| ID of your first song
;
MusID__End	= bgm__Last+1
;	| ID of your last song+1
;
SndID__First	= sfx__First
;	| ID of your first SFX
;
SndID__End	= sfx__Last+1
;	| ID of your last SFX+1
;
SpecID__First	= spec__First
;	| ID of your first Special SFX
;
SpecID__End	= spec__Last+1
;	| ID of your last Special SFX+1
;
CmdID__First	= flg__First
;	| ID of your first command
;
CmdID__End	= flg__Last+1
;	| ID of your last command+1
;

; ---MUSIC---
MusID_ExtraLife	= bgm_ExtraLife
;	| ID of your Extra Life jingle
;

; ---SFX---
SndID_Ring	= sfx_Ring
;	| ID of your ring SFX
;
SndID_RingLeft	= sfx_RingLeft
;	| ID of your alternate ring SFX
;
MusID_Pause = $7F
MusID_Unpause = $80

SndID_Push = sfx_push

; ---------------------------------------------------------------------------
; Subroutine to load the sound driver
; ---------------------------------------------------------------------------
; sub_EC000:
SoundDriverLoad:
	stopZ80
	resetZ80
	lea	Snd_Driver(pc),a0
	lea	(Z80_RAM).l,a1
	jsr	(KosDec).l
	btst	#0,(VDP_control_port+1).l	; check video mode
	sne	(Z80_RAM+zPalModeByte).l	; set if PAL
	resetZ80a
	nop
	nop
	nop
	nop
	resetZ80
	startZ80
	rts

; ===========================================================================
; ---------------------------------------------------------------------------
; S2 sound driver
; ---------------------------------------------------------------------------
; loc_EC0E8:
Snd_Driver:
	save
	include "s2.sounddriver.asm" ; CPU Z80
	restore
	padding off
	!org (Snd_Driver+Size_of_Snd_driver_guess) ; don't worry; I know what I'm doing


; loc_ED04C:
Snd_Driver_End:



; ---------------------------------------------------------------------------
; DAC samples
; ---------------------------------------------------------------------------
SndDAC_Sample1:
	BINCLUDE	"sound/DAC/Sample 1.bin"
SndDAC_Sample1_End

SndDAC_Sample2:
	BINCLUDE	"sound/DAC/Sample 2.bin"
SndDAC_Sample2_End

SndDAC_Sample5:
	BINCLUDE	"sound/DAC/Sample 5.bin"
SndDAC_Sample5_End

    if S2DACSamples
SndDAC_Sample6:
	BINCLUDE	"sound/DAC/Sample 6.bin"
SndDAC_Sample6_End

SndDAC_Sample3:
	BINCLUDE	"sound/DAC/Sample 3.bin"
SndDAC_Sample3_End

SndDAC_Sample4:
	BINCLUDE	"sound/DAC/Sample 4.bin"
SndDAC_Sample4_End

SndDAC_Sample7:
	BINCLUDE	"sound/DAC/Sample 7.bin"
SndDAC_Sample7_End
    endif

; ------------------------------------------------------------------------------
; Music pointers
; ------------------------------------------------------------------------------

MusicPoint:	startBank

Mus_GHZ:	include		"sound/music/Mus81 - GHZ.asm"
Mus_LZ:		include		"sound/music/Mus82 - LZ.asm"
Mus_MZ:		include		"sound/music/Mus83 - MZ.asm"
Mus_SLZ:	include		"sound/music/Mus84 - SLZ.asm"
Mus_SYZ:	include		"sound/music/Mus85 - SYZ.asm"
Mus_SBZ:	include		"sound/music/Mus86 - SBZ.asm"
Mus_Invincible:	include		"sound/music/Mus87 - Invincibility.asm"
Mus_ExtraLife:	include		"sound/music/Mus88 - Extra Life.asm"
Mus_SS:		include		"sound/music/Mus89 - Special Stage.asm"
Mus_Title:	include		"sound/music/Mus8A - Title Screen.asm"
Mus_Ending:	include		"sound/music/Mus8B - Ending.asm"
Mus_Boss:	include		"sound/music/Mus8C - Boss.asm"
Mus_FZ:		include		"sound/music/Mus8D - FZ.asm"
Mus_GotThrough:	include		"sound/music/Mus8E - Sonic Got Through.asm"
Mus_GameOver:	include		"sound/music/Mus8F - Game Over.asm"
Mus_Continue:	include		"sound/music/Mus90 - Continue Screen.asm"
Mus_Credits:	include		"sound/music/Mus91 - Credits.asm"
Mus_Drowning:	include		"sound/music/Mus92 - Drowning.asm"
Mus_Emerald:	include		"sound/music/Mus93 - Get Emerald.asm"


	finishBank

; -------------------------------------------------------------------------------
; Sega Intro Sound
; 8-bit unsigned raw audio at 16Khz
; -------------------------------------------------------------------------------

SegaSFXBank:	startBank

Snd_Sega:	BINCLUDE	"sound/PCM/SEGA.bin"
Snd_Sega_End:

; ------------------------------------------------------------------------------------------
; Sound effect pointers
; ------------------------------------------------------------------------------------------

SoundIndex:

ptr_sndA0:		rom_ptr_z80	SoundA0
ptr_sndA1:		rom_ptr_z80	SoundA1
ptr_sndA2:		rom_ptr_z80	SoundA2
ptr_sndA3:		rom_ptr_z80	SoundA3
ptr_sndA4:		rom_ptr_z80	SoundA4
ptr_sndA5:		rom_ptr_z80	SoundA5
ptr_sndA6:		rom_ptr_z80	SoundA6
ptr_sndA7:		rom_ptr_z80	SoundA7
ptr_sndA8:		rom_ptr_z80	SoundA8
ptr_sndA9:		rom_ptr_z80	SoundA9
ptr_sndAA:		rom_ptr_z80	SoundAA
ptr_sndAB:		rom_ptr_z80	SoundAB
ptr_sndAC:		rom_ptr_z80	SoundAC
ptr_sndAD:		rom_ptr_z80	SoundAD
ptr_sndAE:		rom_ptr_z80	SoundAE
ptr_sndAF:		rom_ptr_z80	SoundAF
ptr_sndB0:		rom_ptr_z80	SoundB0
ptr_sndB1:		rom_ptr_z80	SoundB1
ptr_sndB2:		rom_ptr_z80	SoundB2
ptr_sndB3:		rom_ptr_z80	SoundB3
ptr_sndB4:		rom_ptr_z80	SoundB4
ptr_sndB5:		rom_ptr_z80	SoundB5
ptr_sndB6:		rom_ptr_z80	SoundB6
ptr_sndB7:		rom_ptr_z80	SoundB7
ptr_sndB8:		rom_ptr_z80	SoundB8
ptr_sndB9:		rom_ptr_z80	SoundB9
ptr_sndBA:		rom_ptr_z80	SoundBA
ptr_sndBB:		rom_ptr_z80	SoundBB
ptr_sndBC:		rom_ptr_z80	SoundBC
ptr_sndBD:		rom_ptr_z80	SoundBD
ptr_sndBE:		rom_ptr_z80	SoundBE
ptr_sndBF:		rom_ptr_z80	SoundBF
ptr_sndC0:		rom_ptr_z80	SoundC0
ptr_sndC1:		rom_ptr_z80	SoundC1
ptr_sndC2:		rom_ptr_z80	SoundC2
ptr_sndC3:		rom_ptr_z80	SoundC3
ptr_sndC4:		rom_ptr_z80	SoundC4
ptr_sndC5:		rom_ptr_z80	SoundC5
ptr_sndC6:		rom_ptr_z80	SoundC6
ptr_sndC7:		rom_ptr_z80	SoundC7
ptr_sndC8:		rom_ptr_z80	SoundC8
ptr_sndC9:		rom_ptr_z80	SoundC9
ptr_sndCA:		rom_ptr_z80	SoundCA
ptr_sndCB:		rom_ptr_z80	SoundCB
ptr_sndCC:		rom_ptr_z80	SoundCC
ptr_sndCD:		rom_ptr_z80	SoundCD
ptr_sndCE:		rom_ptr_z80	SoundCE
ptr_sndCF:		rom_ptr_z80	SoundCF
SndPtr__End:

SoundA0:	include		"sound/sfx/SndA0 - Jump.asm"
SoundA1:	include		"sound/sfx/SndA1 - Lamppost.asm"
SoundA2:	include		"sound/sfx/SndA2.asm"
SoundA3:	include		"sound/sfx/SndA3 - Death.asm"
SoundA4:	include		"sound/sfx/SndA4 - Skid.asm"
SoundA5:	include		"sound/sfx/SndA5.asm"
SoundA6:	include		"sound/sfx/SndA6 - Hit Spikes.asm"
SoundA7:	include		"sound/sfx/SndA7 - Push Block.asm"
SoundA8:	include		"sound/sfx/SndA8 - SS Goal.asm"
SoundA9:	include		"sound/sfx/SndA9 - SS Item.asm"
SoundAA:	include		"sound/sfx/SndAA - Splash.asm"
SoundAB:	include		"sound/sfx/SndAB.asm"
SoundAC:	include		"sound/sfx/SndAC - Hit Boss.asm"
SoundAD:	include		"sound/sfx/SndAD - Get Bubble.asm"
SoundAE:	include		"sound/sfx/SndAE - Fireball.asm"
SoundAF:	include		"sound/sfx/SndAF - Shield.asm"
SoundB0:	include		"sound/sfx/SndB0 - Saw.asm"
SoundB1:	include		"sound/sfx/SndB1 - Electric.asm"
SoundB2:	include		"sound/sfx/SndB2 - Drown Death.asm"
SoundB3:	include		"sound/sfx/SndB3 - Flamethrower.asm"
SoundB4:	include		"sound/sfx/SndB4 - Bumper.asm"
SoundB5:	include		"sound/sfx/SndB5 - Ring.asm"
SoundB6:	include		"sound/sfx/SndB6 - Spikes Move.asm"
SoundB7:	include		"sound/sfx/SndB7 - Rumbling.asm"
SoundB8:	include		"sound/sfx/SndB8.asm"
SoundB9:	include		"sound/sfx/SndB9 - Collapse.asm"
SoundBA:	include		"sound/sfx/SndBA - SS Glass.asm"
SoundBB:	include		"sound/sfx/SndBB - Door.asm"
SoundBC:	include		"sound/sfx/SndBC - Teleport.asm"
SoundBD:	include		"sound/sfx/SndBD - ChainStomp.asm"
SoundBE:	include		"sound/sfx/SndBE - Roll.asm"
SoundBF:	include		"sound/sfx/SndBF - Get Continue.asm"
SoundC0:	include		"sound/sfx/SndC0 - Basaran Flap.asm"
SoundC1:	include		"sound/sfx/SndC1 - Break Item.asm"
SoundC2:	include		"sound/sfx/SndC2 - Drown Warning.asm"
SoundC3:	include		"sound/sfx/SndC3 - Giant Ring.asm"
SoundC4:	include		"sound/sfx/SndC4 - Bomb.asm"
SoundC5:	include		"sound/sfx/SndC5 - Cash Register.asm"
SoundC6:	include		"sound/sfx/SndC6 - Ring Loss.asm"
SoundC7:	include		"sound/sfx/SndC7 - Chain Rising.asm"
SoundC8:	include		"sound/sfx/SndC8 - Burning.asm"
SoundC9:	include		"sound/sfx/SndC9 - Hidden Bonus.asm"
SoundCA:	include		"sound/sfx/SndCA - Enter SS.asm"
SoundCB:	include		"sound/sfx/SndCB - Wall Smash.asm"
SoundCC:	include		"sound/sfx/SndCC - Spring.asm"
SoundCD:	include		"sound/sfx/SndCD - Switch.asm"
SoundCE:	include		"sound/sfx/SndCE - Ring Left Speaker.asm"
SoundCF:	include		"sound/sfx/SndCF - Signpost.asm"

; ------------------------------------------------------------------------------------------
; Special sound effect pointers
; ------------------------------------------------------------------------------------------

SpecSoundIndex:
ptr_sndD0:		rom_ptr_z80	SoundD0
SpecPtr__End:

SoundD0:	include		"sound/sfx/SndD0 - Waterfall.asm"


	finishBank
