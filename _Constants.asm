; ---------------------------------------------------------------------------
; Constants
; ---------------------------------------------------------------------------

Size_of_SegaPCM:		equ $6978
Size_of_DAC_driver_guess:	equ $1760

; Clocks
Master_Clock:    equ 53693175
M68000_Clock:    equ Master_Clock/7
Z80_Clock:       equ Master_Clock/15
FM_Sample_Rate:  equ M68000_Clock/(6*6*4)
PSG_Sample_Rate: equ Z80_Clock/16

; VDP addressses
vdp_data_port:		equ $C00000
vdp_control_port:	equ $C00004
vdp_counter:		equ $C00008

psg_input:		equ $C00011
debug_reg:		equ $C0001C

; Z80 addresses
z80_ram:		equ $A00000	; start of Z80 RAM
z80_dac3_pitch:		equ $A000EA
z80_dac_status:		equ $A01FFD
z80_dac_sample:		equ $A01FFF
z80_ram_end:		equ $A02000	; end of non-reserved Z80 RAM
z80_version:		equ $A10001
z80_port_1_data:	equ $A10002
z80_port_1_control:	equ $A10008
z80_port_2_control:	equ $A1000A
z80_expansion_control:	equ $A1000C
z80_bus_request:	equ $A11100
z80_reset:		equ $A11200
ym2612_a0:		equ $A04000
ym2612_d0:		equ $A04001
ym2612_a1:		equ $A04002
ym2612_d1:		equ $A04003
z80_bus_request:	equ $A11100
z80_reset:		equ $A11200

; I/O addresses
console_version:	equ $A10001
port_1_data_hi:		equ $A10002
port_1_data:		equ $A10003
port_2_data_hi:		equ $A10004
port_2_data:		equ $A10005
port_1_control_hi:	equ $A10008
port_1_control:		equ $A10009
port_2_control_hi:	equ $A1000A
port_2_control:		equ $A1000B
expansion_control_hi:	equ $A1000C
expansion_control:	equ $A1000D

; Misc addresses
sram_port:		equ $A130F1
security_addr:		equ $A14000

; Sound driver constants
TrackPlaybackControl:	equ 0		; All tracks
TrackVoiceControl:	equ 1		; All tracks
TrackTempoDivider:	equ 2		; All tracks
TrackDataPointer:	equ 4		; All tracks (4 bytes)
TrackTranspose:		equ 8		; FM/PSG only (sometimes written to as a word, to include TrackVolume)
TrackVolume:		equ 9		; FM/PSG only
TrackAMSFMSPan:		equ $A		; FM/DAC only
TrackVoiceIndex:	equ $B		; FM/PSG only
TrackVolEnvIndex:	equ $C		; PSG only
TrackStackPointer:	equ $D		; All tracks
TrackDurationTimeout:	equ $E		; All tracks
TrackSavedDuration:	equ $F		; All tracks
TrackSavedDAC:		equ $10		; DAC only
TrackFreq:		equ $10		; FM/PSG only (2 bytes)
TrackNoteTimeout:	equ $12		; FM/PSG only
TrackNoteTimeoutMaster:equ $13		; FM/PSG only
TrackModulationPtr:	equ $14		; FM/PSG only (4 bytes)
TrackModulationWait:	equ $18		; FM/PSG only
TrackModulationSpeed:	equ $19		; FM/PSG only
TrackModulationDelta:	equ $1A		; FM/PSG only
TrackModulationSteps:	equ $1B		; FM/PSG only
TrackModulationVal:	equ $1C		; FM/PSG only (2 bytes)
TrackDetune:		equ $1E		; FM/PSG only
TrackPSGNoise:		equ $1F		; PSG only
TrackFeedbackAlgo:	equ $1F		; FM only
TrackVoicePtr:		equ $20		; FM SFX only (4 bytes)
TrackLoopCounters:	equ $24		; All tracks (multiple bytes)
TrackGoSubStack:	equ TrackSz	; All tracks (multiple bytes. This constant won't get to be used because of an optimisation that just uses zTrackSz)

TrackSz:	equ $30

; VRAM data
vram_fg:	equ $C000	; foreground namespace
vram_bg:	equ $E000	; background namespace
vram_sonic:	equ $F000	; Sonic graphics
vram_sprites:	equ $F800	; sprite table
vram_hscroll:	equ $FC00	; horizontal scroll table

; Various sizes
tile_size:	equ 8*8/2	; size of a single 8x8 tile
chunk_size:	equ $200	; size of a single 256x256 chunk
plane_size_64x32: equ 64*32*2	; size of plane in 512x256 mode

layout_row_interlaced:	equ $40			; size of a single level layout row (FG/BG alternating)
layout_row:	equ layout_row_interlaced*2	; size of a single level layout row (skipping over other plane)

; Game modes
id_Sega:	equ ptr_GM_Sega-GameModeArray	                 ; $00
id_Title:	equ ptr_GM_Title-GameModeArray	               ; $04
id_Demo:	equ ptr_GM_Demo-GameModeArray	                 ; $08
id_Level:	equ ptr_GM_Level-GameModeArray	               ; $0C
id_Special:	equ ptr_GM_Special-GameModeArray             ; $10
id_Continue:	equ ptr_GM_Cont-GameModeArray	             ; $14
id_Ending:	equ ptr_GM_Ending-GameModeArray	             ; $18
id_Credits:	equ ptr_GM_Credits-GameModeArray             ; $1C
id_LevelSelect:	equ ptr_GM_Level_Select-GameModeArray

; Levels (zones)
id_GHZ:		equ 0
id_LZ:		equ 1
id_MZ:		equ 2
id_SLZ:		equ 3
id_SYZ:		equ 4
id_SBZ:		equ 5
id_EndZ:	equ 6
id_SS:		equ 7	; only used for level select

; Levels (zone/act word combos)
act1:		equ 0
act2:		equ 1
act3:		equ 2
act4:		equ 3	; only used for SBZ3/LZ4

id_GHZ_act1:	equ (id_GHZ<<8)+act1	; $0000
id_GHZ_act2:	equ (id_GHZ<<8)+act2	; $0001
id_GHZ_act3:	equ (id_GHZ<<8)+act3	; $0002

id_LZ_act1:	equ (id_LZ<<8)+act1	; $0100
id_LZ_act2:	equ (id_LZ<<8)+act2	; $0101
id_LZ_act3:	equ (id_LZ<<8)+act3	; $0102

id_MZ_act1:	equ (id_MZ<<8)+act1	; $0200
id_MZ_act2:	equ (id_MZ<<8)+act2	; $0201
id_MZ_act3:	equ (id_MZ<<8)+act3	; $0202

id_SLZ_act1:	equ (id_SLZ<<8)+act1	; $0300
id_SLZ_act2:	equ (id_SLZ<<8)+act2	; $0301
id_SLZ_act3:	equ (id_SLZ<<8)+act3	; $0302

id_SYZ_act1:	equ (id_SYZ<<8)+act1	; $0400
id_SYZ_act2:	equ (id_SYZ<<8)+act2	; $0401
id_SYZ_act3:	equ (id_SYZ<<8)+act3	; $0402

id_SBZ_act1:	equ (id_SBZ<<8)+act1	; $0500
id_SBZ_act2:	equ (id_SBZ<<8)+act2	; $0501
;id_SBZ_act3 is ambiguous, could mean LZ4 or FZ
id_LZ_act4:	equ (id_LZ<<8)+act4	; $0103 (SBZ3)
id_FZ:		equ (id_SBZ<<8)+act3	; $0502 (real SBZ3)

id_EndZ_good:	equ (id_EndZ<<8)+act1	; $0600 (good ending, all emeralds)
id_EndZ_bad:	equ (id_EndZ<<8)+act2	; $0601 (bad ending, not all emeralds)

; Colours
cBlack:		equ $000		; colour black
cWhite:		equ $EEE		; colour white
cBlue:		equ $E00		; colour blue
cGreen:		equ $0E0		; colour green
cRed:		equ $00E		; colour red
cYellow:	equ cGreen+cRed		; colour yellow
cAqua:		equ cGreen+cBlue	; colour aqua
cMagenta:	equ cBlue+cRed		; colour magenta

; Joypad input
bitUp:		equ 0
bitDn:		equ 1
bitL:		equ 2
bitR:		equ 3
bitB:		equ 4
bitC:		equ 5
bitA:		equ 6
bitStart:	equ 7
btnUp:		equ 1<<bitUp			; ($01)
btnDn:		equ 1<<bitDn			; ($02)
btnL:		equ 1<<bitL			; ($04)
btnR:		equ 1<<bitR			; ($08)
btnB:		equ 1<<bitB			; ($10)
btnC:		equ 1<<bitC			; ($20)
btnA:		equ 1<<bitA			; ($40)
btnStart:	equ 1<<bitStart			; ($80)
btnDir:		equ btnUp|btnDn|btnL|btnR	; ($0F)
btnABC:		equ btnA|btnB|btnC		; ($70)

; Object variables
obID:		equ 0	; object ID number
obRender:	equ 1	; bitfield for x/y flip, display mode
obGfx:		equ 2	; palette line & VRAM setting (2 bytes)
obMap:		equ 4	; mappings address (4 bytes)
obX:		equ 8	; x-axis position (2-4 bytes)
obSubpixelX:	equ $A	; x-axis subpixel position for playfield items (2 bytes)
obScreenY:	equ obSubpixelX	; y-axis position for screen-fixed items (2 bytes)
obY:		equ $C	; y-axis position (2-4 bytes)
obSubpixelY:	equ $E	; y-axis subpixel position for playfield items (2 bytes)
obVelX:		equ $10	; x-axis velocity (2 bytes)
obVelY:		equ $12	; y-axis velocity (2 bytes)
obInertia:	equ $14	; potential speed (2 bytes)
obHeight:	equ $16	; height/2
obWidth:	equ $17	; width/2
obPriority:	equ $18	; sprite stack priority -- 0 is front
obActWid:	equ $19	; action width
obFrame:	equ $1A	; current frame displayed
obAniFrame:	equ $1B	; current frame in animation script
obAnim:		equ $1C	; current animation
obPrevAni:	equ $1D	; previous animation
obNextAni:	equ $1D	; next animation
obTimeFrame:	equ $1E	; time to next frame
obDelayAni:	equ $1F	; time to delay animation
obColType:	equ $20	; collision response type
obColProp:	equ $21	; collision extra property
obStatus:	equ $22	; orientation or mode
obRespawnNo:	equ $23	; respawn list index number
obRoutine:	equ $24	; routine number
ob2ndRout:	equ $25	; secondary routine number
obSolid:	equ ob2ndRout ; solid status flag
obAngle:	equ $26	; angle
obSubtype:	equ $28	; object subtype
obSolid:	equ ob2ndRout ; solid status flag

; Object variables used by Sonic
flashtime:	equ $30	; time between flashes after getting hit (2 bytes)
invtime:	equ $32	; time left for invincibility (2 bytes)
shoetime:	equ $34	; time left for speed shoes (2 bytes)
angleright:	equ $36	; angle of floor on Sonic's right side
angleleft:	equ $37	; angle of floor on Sonic's left side
sticktoconvex:	equ $38	; flag set while running on an SBZ gear
;unused:	equ $39	; unused by Sonic
restartime:	equ $3A	; time left before level restarts after dying (2 bytes)
jumping:	equ $3C	; flag set while Sonic is jumping
standonobject:	equ $3D	; object index Sonic stands on
locktime:	equ $3E	; temporary D-Pad control lock timer (2 bytes)

; Sonic's collision sizes
sonic_width:		equ 9		; Sonic's width
sonic_height:		equ $13		; Sonic's height
sonic_roll_width:	equ 7		; Sonic's width (rolling)
sonic_roll_height:	equ $E		; Sonic's height (rolling)
sonic_solid_width:	equ $B		; Sonic's width (solid object collision)
sonic_react_width:	equ 8		; Sonic's width (object collision)
sonic_duck_height:	equ $A		; Sonic's height (object collision, ducking)
sonic_quick_size:	equ $A		; Sonic's size (quick terrain find)

; Miscellaneous object scratch-RAM
objoff_29:	equ $29
objoff_2A:	equ $2A
objoff_2B:	equ $2B
objoff_2C:	equ $2C
objoff_2E:	equ $2E
objoff_2F:	equ $2F
objoff_30:	equ $30
objoff_31:	equ $31
objoff_32:	equ $32
objoff_33:	equ $33
objoff_34:	equ $34
objoff_35:	equ $35
objoff_36:	equ $36
objoff_37:	equ $37
objoff_38:	equ $38
objoff_39:	equ $39
objoff_3A:	equ $3A
objoff_3B:	equ $3B
objoff_3C:	equ $3C
objoff_3D:	equ $3D
objoff_3E:	equ $3E
objoff_3F:	equ $3F

; Object variables (Sonic 2 disassembly nomenclature)
render_flags:	equ 1	; bitfield for x/y flip, display mode
art_tile:	equ 2	; palette line & VRAM setting (2 bytes)
mappings:	equ 4	; mappings address (4 bytes)
x_pos:		equ 8	; x-axis position (2-4 bytes)
y_pos:		equ $C	; y-axis position (2-4 bytes)
x_vel:		equ $10	; x-axis velocity (2 bytes)
y_vel:		equ $12	; y-axis velocity (2 bytes)
y_radius:	equ $16	; height/2
x_radius:	equ $17	; width/2
priority:	equ $18	; sprite stack priority -- 0 is front
width_pixels:	equ $19	; action width
mapping_frame:	equ $1A	; current frame displayed
anim_frame:	equ $1B	; current frame in animation script
anim:		equ $1C	; current animation
next_anim:	equ $1D	; next animation
anim_frame_duration: equ $1E ; time to next frame
collision_flags: equ $20 ; collision response type
collision_property: equ $21 ; collision extra property
status:		equ $22	; orientation or mode
respawn_index:	equ $23	; respawn list index number
routine:	equ $24	; routine number
routine_secondary: equ $25 ; secondary routine number
angle:		equ $26	; angle
subtype:	equ $28	; object subtype

; Object variables used by bosses
obBossHits:	equ obColProp ; number of remaining hit points for boss, defaults to 8
obBossX:	equ objoff_30 ; base X boss position (2 bytes)
obBossY:	equ objoff_38 ; base Y boss position without swaying effect (2 bytes)
obBossFlash:	equ objoff_3E ; number of remaining flash frames after taking a hit

; Size definition for one object in RAM ($40 bytes)
object_size_bits:	equ 6
object_size:	equ 1<<object_size_bits

; Animation flags
afEnd:		equ $FF	; return to beginning of animation
afBack:		equ $FE	; go back (specified number) bytes
afChange:	equ $FD	; run specified animation
afRoutine:	equ $FC	; increment routine counter
afReset:	equ $FB	; reset animation and 2nd object routine counter
af2ndRoutine:	equ $FA	; increment 2nd routine counter

aniXFlip:	equ $20 ; horizontally mirrors the current frame
aniYFlip:	equ $40 ; vertically mirrors the current frame

; Background music
  if FeatureUseSonic2SoundDriver=0
bgm__First:	equ $81
bgm__Last:	equ ((ptr_musend-MusicIndex-4)/4)+bgm__First

; Sound effects
sfx__First:	equ $A0
sfx__Last:	equ ((ptr_sndend-SoundIndex-4)/4)+sfx__First

; Special sound effects
spec__First:	equ $D0
spec__Last:	equ ((ptr_specend-SpecSoundIndex-4)/4)+spec__First

flg__First:	equ $E0
flg__Last:	equ ((ptr_flgend-Sound_ExIndex-4)/4)+flg__First
  else
bgm__First:	equ $01
bgm__Last:	equ ((zMusIDPtr__End-zMasterPlaylist-4)/4)+bgm__First

; Sound effects
sfx__First:	equ bgm__Last+1
sfx__Last:	equ ((SndPtr__End-SoundIndex-2)/2)+sfx__First

; Special sound effects
spec__First:	equ sfx__Last+1
spec__Last:	equ ((SpecPtr__End-SpecSoundIndex-4)/4)+spec__First

flg__First  equ $FA
flg__Last:  equ ((CmdPtr__End-zCommandIndex-2)/2)+flg__First

sfx_Stop:   equ ((CmdPtr_StopSFX-zCommandIndex)/2)+flg__First

  endif ; if FeatureUseSonic2SoundDriver=0

bgm_GHZ:	equ ((ptr_mus81-MusicIndex)/4)+bgm__First
bgm_LZ:		equ ((ptr_mus82-MusicIndex)/4)+bgm__First
bgm_MZ:		equ ((ptr_mus83-MusicIndex)/4)+bgm__First
bgm_SLZ:	equ ((ptr_mus84-MusicIndex)/4)+bgm__First
bgm_SYZ:	equ ((ptr_mus85-MusicIndex)/4)+bgm__First
bgm_SBZ:	equ ((ptr_mus86-MusicIndex)/4)+bgm__First
bgm_Invincible:	equ ((ptr_mus87-MusicIndex)/4)+bgm__First
bgm_ExtraLife:	equ ((ptr_mus88-MusicIndex)/4)+bgm__First
bgm_SS:		equ ((ptr_mus89-MusicIndex)/4)+bgm__First
bgm_Title:	equ ((ptr_mus8A-MusicIndex)/4)+bgm__First
bgm_Ending:	equ ((ptr_mus8B-MusicIndex)/4)+bgm__First
bgm_Boss:	equ ((ptr_mus8C-MusicIndex)/4)+bgm__First
bgm_FZ:		equ ((ptr_mus8D-MusicIndex)/4)+bgm__First
bgm_GotThrough:	equ ((ptr_mus8E-MusicIndex)/4)+bgm__First
bgm_GameOver:	equ ((ptr_mus8F-MusicIndex)/4)+bgm__First
bgm_Continue:	equ ((ptr_mus90-MusicIndex)/4)+bgm__First
bgm_Credits:	equ ((ptr_mus91-MusicIndex)/4)+bgm__First
bgm_Drowning:	equ ((ptr_mus92-MusicIndex)/4)+bgm__First
bgm_Emerald:	equ ((ptr_mus93-MusicIndex)/4)+bgm__First
bgm__Last:	equ ((ptr_musend-MusicIndex-4)/4)+bgm__First

; Sound effects
sfx__First:	equ $A0
sfx_Jump:	equ ((ptr_sndA0-SoundIndex)/4)+sfx__First
sfx_Lamppost:	equ ((ptr_sndA1-SoundIndex)/4)+sfx__First
sfx_A2:		equ ((ptr_sndA2-SoundIndex)/4)+sfx__First
sfx_Death:	equ ((ptr_sndA3-SoundIndex)/4)+sfx__First
sfx_Skid:	equ ((ptr_sndA4-SoundIndex)/4)+sfx__First
sfx_A5:		equ ((ptr_sndA5-SoundIndex)/4)+sfx__First
sfx_HitSpikes:	equ ((ptr_sndA6-SoundIndex)/4)+sfx__First
sfx_Push:	equ ((ptr_sndA7-SoundIndex)/4)+sfx__First
sfx_SSGoal:	equ ((ptr_sndA8-SoundIndex)/4)+sfx__First
sfx_SSItem:	equ ((ptr_sndA9-SoundIndex)/4)+sfx__First
sfx_Splash:	equ ((ptr_sndAA-SoundIndex)/4)+sfx__First
sfx_AB:		equ ((ptr_sndAB-SoundIndex)/4)+sfx__First
sfx_HitBoss:	equ ((ptr_sndAC-SoundIndex)/4)+sfx__First
sfx_Bubble:	equ ((ptr_sndAD-SoundIndex)/4)+sfx__First
sfx_Fireball:	equ ((ptr_sndAE-SoundIndex)/4)+sfx__First
sfx_Shield:	equ ((ptr_sndAF-SoundIndex)/4)+sfx__First
sfx_Saw:	equ ((ptr_sndB0-SoundIndex)/4)+sfx__First
sfx_Electric:	equ ((ptr_sndB1-SoundIndex)/4)+sfx__First
sfx_Drown:	equ ((ptr_sndB2-SoundIndex)/4)+sfx__First
sfx_Flamethrower:equ ((ptr_sndB3-SoundIndex)/4)+sfx__First
sfx_Bumper:	equ ((ptr_sndB4-SoundIndex)/4)+sfx__First
sfx_Ring:	equ ((ptr_sndB5-SoundIndex)/4)+sfx__First
sfx_SpikesMove:	equ ((ptr_sndB6-SoundIndex)/4)+sfx__First
sfx_Rumbling:	equ ((ptr_sndB7-SoundIndex)/4)+sfx__First
sfx_B8:		equ ((ptr_sndB8-SoundIndex)/4)+sfx__First
sfx_Collapse:	equ ((ptr_sndB9-SoundIndex)/4)+sfx__First
sfx_SSGlass:	equ ((ptr_sndBA-SoundIndex)/4)+sfx__First
sfx_Door:	equ ((ptr_sndBB-SoundIndex)/4)+sfx__First
sfx_Teleport:	equ ((ptr_sndBC-SoundIndex)/4)+sfx__First
sfx_ChainStomp:	equ ((ptr_sndBD-SoundIndex)/4)+sfx__First
sfx_Roll:	equ ((ptr_sndBE-SoundIndex)/4)+sfx__First
sfx_Continue:	equ ((ptr_sndBF-SoundIndex)/4)+sfx__First
sfx_Basaran:	equ ((ptr_sndC0-SoundIndex)/4)+sfx__First
sfx_BreakItem:	equ ((ptr_sndC1-SoundIndex)/4)+sfx__First
sfx_Warning:	equ ((ptr_sndC2-SoundIndex)/4)+sfx__First
sfx_GiantRing:	equ ((ptr_sndC3-SoundIndex)/4)+sfx__First
sfx_Bomb:	equ ((ptr_sndC4-SoundIndex)/4)+sfx__First
sfx_Cash:	equ ((ptr_sndC5-SoundIndex)/4)+sfx__First
sfx_RingLoss:	equ ((ptr_sndC6-SoundIndex)/4)+sfx__First
sfx_ChainRise:	equ ((ptr_sndC7-SoundIndex)/4)+sfx__First
sfx_Burning:	equ ((ptr_sndC8-SoundIndex)/4)+sfx__First
sfx_Bonus:	equ ((ptr_sndC9-SoundIndex)/4)+sfx__First
sfx_EnterSS:	equ ((ptr_sndCA-SoundIndex)/4)+sfx__First
sfx_WallSmash:	equ ((ptr_sndCB-SoundIndex)/4)+sfx__First
sfx_Spring:	equ ((ptr_sndCC-SoundIndex)/4)+sfx__First
sfx_Switch:	equ ((ptr_sndCD-SoundIndex)/4)+sfx__First
sfx_RingLeft:	equ ((ptr_sndCE-SoundIndex)/4)+sfx__First
sfx_Signpost:	equ ((ptr_sndCF-SoundIndex)/4)+sfx__First
sfx__Last:	equ ((ptr_sndend-SoundIndex-4)/4)+sfx__First

; Special sound effects
spec__First:	equ $D0
sfx_Waterfall:	equ ((ptr_sndD0-SpecSoundIndex)/4)+spec__First
spec__Last:	equ ((ptr_specend-SpecSoundIndex-4)/4)+spec__First

flg__First:	equ $E0
bgm_Fade:	equ ((ptr_flgE0-Sound_ExIndex)/4)+flg__First
sfx_Sega:	equ ((ptr_flgE1-Sound_ExIndex)/4)+flg__First
bgm_Speedup:	equ ((ptr_flgE2-Sound_ExIndex)/4)+flg__First
bgm_Slowdown:	equ ((ptr_flgE3-Sound_ExIndex)/4)+flg__First
bgm_Stop:	equ ((ptr_flgE4-Sound_ExIndex)/4)+flg__First
flg__Last:	equ ((ptr_flgend-Sound_ExIndex-4)/4)+flg__First

; Boss locations
; The main values are based on where the camera boundaries mainly lie
; The end values are where the camera scrolls towards after defeat
boss_ghz_x:	equ $2960		; Green Hill Zone
boss_ghz_y:	equ $300
boss_ghz_end:	equ boss_ghz_x+$160

boss_lz_x:	equ $1DE0		; Labyrinth Zone
boss_lz_y:	equ $C0
boss_lz_end:	equ boss_lz_x+$250

boss_mz_x:	equ $1800		; Marble Zone
boss_mz_y:	equ $210
boss_mz_end:	equ boss_mz_x+$160

boss_slz_x:	equ $2000		; Star Light Zone
boss_slz_y:	equ $210
boss_slz_end:	equ boss_slz_x+$160

boss_syz_x:	equ $2C00		; Spring Yard Zone
boss_syz_y:	equ $4CC
boss_syz_end:	equ boss_syz_x+$140

boss_sbz2_x:	equ $2050		; Scrap Brain Zone Act 2 Cutscene
boss_sbz2_y:	equ $510

boss_fz_x:	equ $2450		; Final Zone
boss_fz_y:	equ $510
boss_fz_end:	equ boss_fz_x+$2B0

; Tile flags (replaces the old "make_art_tile" function)
Tile_Prio:	equ	1<<15
Tile_Pal1:	equ	0<<13
Tile_Pal2:	equ	1<<13
Tile_Pal3:	equ	2<<13
Tile_Pal4:	equ	3<<13

; VRAM ArtTile definitions
; Multiply by $20 (tile_size) to get the actual location in VRAM

; Shared
ArtTile_GHZ_MZ_Swing:		equ $380
ArtTile_MZ_SYZ_Caterkiller:	equ $4FF
ArtTile_GHZ_SLZ_Smashable_Wall:	equ $50F

; Green Hill Zone
ArtTile_GHZ_Flower_4:		equ ArtTile_Level+$340
ArtTile_GHZ_Edge_Wall:		equ $34C
ArtTile_GHZ_Flower_Stalk:	equ ArtTile_Level+$358
ArtTile_GHZ_Big_Flower_1:	equ ArtTile_Level+$35C
ArtTile_GHZ_Small_Flower:	equ ArtTile_Level+$36C
ArtTile_GHZ_Waterfall:		equ ArtTile_Level+$378
ArtTile_GHZ_Flower_3:		equ ArtTile_Level+$380
ArtTile_GHZ_Bridge:		equ $38E
ArtTile_GHZ_Big_Flower_2:	equ ArtTile_Level+$390
ArtTile_GHZ_Spike_Pole:		equ $398
ArtTile_GHZ_Giant_Ball:		equ $3AA
ArtTile_GHZ_Purple_Rock:	equ $3D0

; Marble Zone
ArtTile_MZ_Block:		equ $2B8
ArtTile_MZ_Animated_Magma:	equ ArtTile_Level+$2D2
ArtTile_MZ_Animated_Lava:	equ ArtTile_Level+$2E2
ArtTile_MZ_Torch:		equ ArtTile_Level+$2F2
ArtTile_MZ_Spike_Stomper:	equ $300
ArtTile_MZ_Fireball:		equ $345
ArtTile_MZ_Glass_Pillar:	equ $38E
ArtTile_MZ_Lava:		equ $3A8

; Spring Yard Zone
ArtTile_SYZ_Bumper:		equ $380
ArtTile_SYZ_Big_Spikeball:	equ $396
ArtTile_SYZ_Spikeball_Chain:	equ $3BA

; Labyrinth Zone
ArtTile_LZ_Block_1:		equ $1E0
ArtTile_LZ_Block_2:		equ $1F0
ArtTile_LZ_Splash:		equ $259
ArtTile_LZ_Gargoyle:		equ $2E9
ArtTile_LZ_Water_Surface:	equ $300
ArtTile_LZ_Spikeball_Chain:	equ $310
ArtTile_LZ_Flapping_Door:	equ $328
ArtTile_LZ_Bubbles:		equ $348
ArtTile_LZ_Moving_Block:	equ $3BC
ArtTile_LZ_Door:		equ $3C4
ArtTile_LZ_Harpoon:		equ $3CC
ArtTile_LZ_Pole:		equ $3DE
ArtTile_LZ_Push_Block:		equ $3DE
ArtTile_LZ_Blocks:		equ $3E6
ArtTile_LZ_Conveyor_Belt:	equ $3F6
ArtTile_LZ_Sonic_Drowning:	equ $440
ArtTile_LZ_Rising_Platform:	equ ArtTile_LZ_Blocks+$69
ArtTile_LZ_Orbinaut:		equ $467
ArtTile_LZ_Cork:		equ ArtTile_LZ_Blocks+$11A

; Star Light Zone
ArtTile_SLZ_Seesaw:		equ $374
ArtTile_SLZ_Fan:		equ $3A0
ArtTile_SLZ_Pylon:		equ $3CC
ArtTile_SLZ_Swing:		equ $3DC
ArtTile_SLZ_Orbinaut:		equ $429
ArtTile_SLZ_Fireball:		equ $480
ArtTile_SLZ_Fireball_Launcher:	equ $4D8
ArtTile_SLZ_Collapsing_Floor:	equ $4E0
ArtTile_SLZ_Spikeball:		equ $4F0

; Scrap Brain Zone
ArtTile_SBZ_Caterkiller:	equ $2B0
ArtTile_SBZ_Moving_Block_Short:	equ $2C0
ArtTile_SBZ_Door:		equ $2E8
ArtTile_SBZ_Girder:		equ $2F0
ArtTile_SBZ_Disc:		equ $344
ArtTile_SBZ_Junction:		equ $348
ArtTile_SBZ_Swing:		equ $391
ArtTile_SBZ_Saw:		equ $3B5
ArtTile_SBZ_Flamethrower:	equ $3D9
ArtTile_SBZ_Collapsing_Floor:	equ $3F5
ArtTile_SBZ_Orbinaut:		equ $429
ArtTile_SBZ_Smoke_Puff_1:	equ ArtTile_Level+$448
ArtTile_SBZ_Smoke_Puff_2:	equ ArtTile_Level+$454
ArtTile_SBZ_Moving_Block_Long:	equ $460
ArtTile_SBZ_Horizontal_Door:	equ $46F
ArtTile_SBZ_Electric_Orb:	equ $47E
ArtTile_SBZ_Trap_Door:		equ $492
ArtTile_SBZ_Vanishing_Block:	equ $4C3
ArtTile_SBZ_Spinning_Platform:	equ $4DF

; Final Zone
ArtTile_FZ_Boss:		equ $300
ArtTile_FZ_Eggman_Fleeing:	equ $3A0
ArtTile_FZ_Eggman_No_Vehicle:	equ $470

; General Level Art
ArtTile_Level:			equ $000
ArtTile_Ball_Hog:		equ $302
ArtTile_Bomb:			equ $400
ArtTile_Crabmeat:		equ $400
ArtTile_UnusedExplosion:	equ $41C ; Unused
ArtTile_Buzz_Bomber:		equ $444
ArtTile_Chopper:		equ $47B
ArtTile_Yadrin:			equ $47B
ArtTile_Jaws:			equ $486
ArtTile_Newtron:		equ $49B
ArtTile_Burrobot:		equ $4A6
ArtTile_Basaran:		equ $4B8
ArtTile_Roller:			equ $4B8
ArtTile_Moto_Bug:		equ $4F0
ArtTile_Button:			equ $50F
ArtTile_Spikes:			equ $51B
ArtTile_Spring_Horizontal:	equ $523
ArtTile_Spring_Vertical:	equ $533
ArtTile_Shield:			equ $541
ArtTile_Invincibility:		equ $55C
ArtTile_Game_Over:		equ $55E
ArtTile_Title_Card:		equ $580
ArtTile_Animal_1:		equ $580
ArtTile_Animal_2:		equ $592
ArtTile_Explosion:		equ $5A0
ArtTile_Monitor:		equ $680
ArtTile_HUD:			equ $6CA
ArtTile_Sonic:			equ $780
ArtTile_Points:			equ $797
ArtTile_Lamppost:		equ $7A0
ArtTile_Ring:			equ $7B2
ArtTile_Lives_Counter:		equ $7D4
ArtTile_SpindashDust:     equ ($D800/$20) ; $6C0

; Eggman
ArtTile_Eggman:			equ $400
ArtTile_Eggman_Weapons:		equ $46C
ArtTile_Eggman_Button:		equ $4A4
ArtTile_Eggman_Spikeball:	equ $518
ArtTile_Eggman_Trap_Floor:	equ $518
ArtTile_Eggman_Exhaust:		equ ArtTile_Eggman+$12A

; End of Level
ArtTile_Giant_Ring:		equ $400
ArtTile_Giant_Ring_Flash:	equ $462
ArtTile_Prison_Capsule:		equ $49D
ArtTile_Hidden_Points:		equ $4B6
ArtTile_Warp:			equ $541
ArtTile_Mini_Sonic:		equ $551
ArtTile_Bonuses:		equ $570
ArtTile_Signpost:		equ $680

; Sega Screen
ArtTile_Sega_Tiles:		equ $000

; Title Screen
ArtTile_Title_Japanese_Text:	equ $000
ArtTile_Title_Foreground:	equ $200
ArtTile_Title_Sonic:		equ $300
ArtTile_Title_Trademark:	equ $510
ArtTile_Level_Select_Font:	equ $680

; Continue Screen
ArtTile_Continue_Sonic:		equ $500
ArtTile_Continue_Number:	equ $6FC

; Ending
ArtTile_Ending_Flowers:		equ $3A0
ArtTile_Ending_Emeralds:	equ $3C5
ArtTile_Ending_Sonic:		equ $3E1
ArtTile_Ending_Eggman:		equ $524
ArtTile_Ending_Rabbit:		equ $553
ArtTile_Ending_Chicken:		equ $565
ArtTile_Ending_Penguin:		equ $573
ArtTile_Ending_Seal:		equ $585
ArtTile_Ending_Pig:		equ $593
ArtTile_Ending_Flicky:		equ $5A5
ArtTile_Ending_Squirrel:	equ $5B3
ArtTile_Ending_STH:		equ $5C5

; Try Again Screen
ArtTile_Try_Again_Emeralds:	equ $3C5
ArtTile_Try_Again_Eggman:	equ $3E1

; Special Stage
ArtTile_SS_Background_Clouds:	equ $000
ArtTile_SS_Background_Fish:	equ $051
ArtTile_SS_Wall:		equ $142
ArtTile_SS_Plane_1:		equ $200
ArtTile_SS_Bumper:		equ $23B
ArtTile_SS_Goal:		equ $251
ArtTile_SS_Up_Down:		equ $263
ArtTile_SS_R_Block:		equ $2F0
ArtTile_SS_Plane_2:		equ $300
ArtTile_SS_Extra_Life:		equ $370
ArtTile_SS_Emerald_Sparkle:	equ $3F0
ArtTile_SS_Plane_3:		equ $400
ArtTile_SS_Red_White_Block:	equ $470
ArtTile_SS_Ghost_Block:		equ $4F0
ArtTile_SS_Plane_4:		equ $500
ArtTile_SS_W_Block:		equ $570
ArtTile_SS_Glass:		equ $5F0
ArtTile_SS_Plane_5:		equ $600
ArtTile_SS_Plane_6:		equ $700
ArtTile_SS_Emerald:		equ $770
ArtTile_SS_Zone_1:		equ $797
ArtTile_SS_Zone_2:		equ $7A0
ArtTile_SS_Zone_3:		equ $7A9
ArtTile_SS_Zone_4:		equ $797
ArtTile_SS_Zone_5:		equ $7A0
ArtTile_SS_Zone_6:		equ $7A9

; Special Stage Results
ArtTile_SS_Results_Emeralds:	equ $541

; Font
ArtTile_Sonic_Team_Font:	equ $0A6
ArtTile_Credits_Font:		equ $5A0

; Error Handler
ArtTile_Error_Handler_Font:	equ $7C0
		plcm	Nem_GHZ_1st, 0		; GHZ main patterns
		plcm	Nem_GHZ_2nd, $39A0	; GHZ secondary	patterns
Gra_LZ Nem_LZ
; Sonic frame IDs
fr_Null:	equ 0
fr_Stand:	equ 1
fr_Wait1:	equ 2
fr_Wait2:	equ 3
fr_Wait3:	equ 4
fr_LookUp:	equ 5
fr_Walk11:	equ 6
fr_Walk12:	equ 7
fr_Walk13:	equ 8
fr_Walk14:	equ 9
fr_Walk15:	equ $A
fr_Walk16:	equ $B
fr_Walk21:	equ $C
fr_Walk22:	equ $D
fr_Walk23:	equ $E
fr_Walk24:	equ $F
fr_Walk25:	equ $10
fr_Walk26:	equ $11
fr_Walk31:	equ $12
fr_Walk32:	equ $13
fr_Walk33:	equ $14
fr_Walk34:	equ $15
fr_Walk35:	equ $16
fr_Walk36:	equ $17
fr_Walk41:	equ $18
fr_Walk42:	equ $19
fr_Walk43:	equ $1A
fr_Walk44:	equ $1B
fr_Walk45:	equ $1C
fr_Walk46:	equ $1D
fr_Run11:	equ $1E
fr_Run12:	equ $1F
fr_Run13:	equ $20
fr_Run14:	equ $21
fr_Run21:	equ $22
fr_Run22:	equ $23
fr_Run23:	equ $24
fr_Run24:	equ $25
fr_Run31:	equ $26
fr_Run32:	equ $27
fr_Run33:	equ $28
fr_Run34:	equ $29
fr_Run41:	equ $2A
fr_Run42:	equ $2B
fr_Run43:	equ $2C
fr_Run44:	equ $2D
fr_Roll1:	equ $2E
fr_Roll2:	equ $2F
fr_Roll3:	equ $30
fr_Roll4:	equ $31
fr_Roll5:	equ $32
fr_Warp1:	equ $33
fr_Warp2:	equ $34
fr_Warp3:	equ $35
fr_Warp4:	equ $36
fr_Stop1:	equ $37
fr_Stop2:	equ $38
fr_Duck:	equ $39
fr_Balance1:	equ $3A
fr_Balance2:	equ $3B
fr_Float1:	equ $3C
fr_Float2:	equ $3D
fr_Float3:	equ $3E
fr_Float4:	equ $3F
fr_Spring:	equ $40
fr_Hang1:	equ $41
fr_Hang2:	equ $42
fr_Leap1:	equ $43
fr_Leap2:	equ $44
fr_Push1:	equ $45
fr_Push2:	equ $46
fr_Push3:	equ $47
fr_Push4:	equ $48
fr_Surf:	equ $49
fr_BubStand:	equ $4A
fr_Burnt:	equ $4B
fr_Drown:	equ $4C
fr_Death:	equ $4D
fr_Shrink1:	equ $4E
fr_Shrink2:	equ $4F
fr_Shrink3:	equ $50
fr_Shrink4:	equ $51
fr_Shrink5:	equ $52
fr_Float5:	equ $53
fr_Float6:	equ $54
fr_Injury:	equ $55
fr_GetAir:	equ $56
fr_WaterSlide:	equ $57

bitHorizontal:	 equ 0
bitVertical:	   equ 1
bitSpinSmoke:	   equ 2
bitStandingOn:	 equ 3
bitPushing:	     equ 5
bitObjectFlag:	 equ 7

; ------- Additional -------
fr_Spindash1:	equ (ptr_MS_Spindash1-Map_Sonic)/2	; $58
fr_Spindash2:	equ (ptr_MS_Spindash2-Map_Sonic)/2	; $59
fr_Spindash3:	equ (ptr_MS_Spindash3-Map_Sonic)/2	; $5A
fr_Spindash4:	equ (ptr_MS_Spindash4-Map_Sonic)/2	; $5B
fr_Spindash5:	equ (ptr_MS_Spindash5-Map_Sonic)/2	; $5C
fr_Spindash6:	equ (ptr_MS_Spindash6-Map_Sonic)/2	; $5D

  if FeatureSpindash=1
sfx_Spindash:	equ sfx_Roll ; $BE
  else
sfx_Spindash:	equ ((ptr_sndD1-SpecSoundIndex)/4)+spec__First
  endif

obSmoke:      equ $FFFFD11C

max_ring_scatter: equ $20 ; 32
max_demo:         equ 4

bit_in_air:       equ 1
bit_pushing:      equ 5
