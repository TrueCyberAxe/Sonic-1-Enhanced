;---------------------------------------------------------------------------
;Subroutine to make Sonic perform a spindash
;---------------------------------------------------------------------------

; loc_1AC3E:
; Sonic_CheckSpindash:
Sonic_SpinDash:
		tst.b	f_spindash(a0)			; already Spin Dashing?
		bne.s	Sonic_UpdateSpindash		; if set, branch

		cmpi.b	#id_Duck,obAnim(a0)		; is anim duck
		bne.s	.end				; if not, return

		move.b	(v_jpadpress2).w,d0		; read controller
		andi.b	#btnABC,d0			; pressing A/B/C ?
		beq.w	.end				; if not, return

		bclr	#bitPushing,obStatus(a0)	; clear stale pushing state before charging

	if FeatureSpindash>1
		move.w	#$1F00,obAnim(a0)		; changed from #$900
	else
		move.b	#sonic_roll_height,obHeight(a0) ; adjust height for CD spindash
		move.b	#sonic_roll_width,obWidth(a0) 	; adjust width for CD spindash
		move.w	#$C00,obInertia(a0)		; set Sonic's speed to maximum run speed
	endif

		move.b	#id_Spindash,obAnim(a0)		; set Spin Dash anim (9 in s2)
		sfx	#sfx_Spindash,snd_jsr		; play spin sound

		addq.l	#4,sp				; skip Sonic_Jump when returning to Obj01_MdNormal
		move.b	#$01,f_spindash(a0)		; set Spin Dash flag
		move.w	#$00,v_charging(a0)		; set charge count to 0

	if FeatureSpindash>1
		cmpi.b	#$C,obSubtype(a0)		; if he's drowning, branch to not make dust
		bcs.s	.loc2_1AC84			; if below drowning subtype, branch
		move.b	#$02,(obSmoke).w		; start the smoke/dust object
	endif

.loc2_1AC84:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos

		move.w	#$60,(v_lookshift).w

; locret2_1AC8C
; return_1AC8C:
.end:
		rts

;---------------------------------------------------------------------------

; loc2_1AC8E
Sonic_UpdateSpindash:
		move.b #id_Spindash,obAnim(a0)			; set Spin Dash anim (9 in s2)
		bclr	#bitPushing,obStatus(a0)		; prevent object pushes while charging

		move.b	(v_jpadhold2).w,d0			; read controller
		btst	#bitDn,d0				; check down button
		bne.w	Sonic_ChargingSpindash			; if set, branch

.Release_Spindash:
		; unleash the charged spindash and start rolling quickly:
		move.b	#sonic_roll_height,y_radius(a0)	; set rolling height
		move.b	#sonic_roll_width,x_radius(a0)	; set rolling width
		move.b	#id_Roll,obAnim(a0)			; set animation to roll

		; add the difference between Sonic's rolling and standing heights
		addq.w	#sonic_height-sonic_roll_height,obY(a0) ; keep Sonic grounded after radius change
		move.b	#$00,f_spindash(a0)			; clear Spin Dash flag
		bset	#2,obStatus(a0)				; enter rolling mode after releasing
		bclr	#bitPushing,obStatus(a0)		; release without stale pushing state
		moveq	#0,d0

		; Sonic 2 Style Extra Charging
	if FeatureSpindash>1
		move.b	v_charging(a0),d0			; copy charge count
		add.w	d0,d0					; double it
		move.w	SpindashSpeeds(pc,d0.w),obInertia(a0)	; get normal speed
	endif	; if FeatureSpindash>1

		move.w	obInertia(a0),d0			; get inertia
		subi.w	#$800,d0				; subtract $800
		add.w	d0,d0					; double it
		andi.w	#$1F00,d0				; mask it against $1F00
		neg.w	d0					; negate it
		addi.w	#$2000,d0				; add $2000
		move.w	d0,(v_screendelay).w			; update horizontal camera delay for the dash release
		btst	#bitHorizontal,obStatus(a0)		; is sonic facing right?
		beq.s	.skip					; if not, branch

		neg.w	obInertia(a0)				; negate inertia

.skip:

	if FeatureSpindash>1
		bset	#bitSpinSmoke,obStatus(a0)		; set unused (in s1) flag
		move.b	#$00,(obSmoke).w			; clear smoke/dust object
	endif	; if FeatureSpindash>1

		sfx	#sfx_Teleport,snd_jsr			; play release sound
		bra.s	Obj01_Spindash_ResetScr

;===========================================================================

; word_1AD0C:
SpindashSpeeds:
		dc.w  $800	; 0
		dc.w  $880	; 1
		dc.w  $900	; 2
		dc.w  $980	; 3
		dc.w  $A00	; 4
		dc.w  $A80	; 5
		dc.w  $B00	; 6
		dc.w  $B80	; 7
		dc.w  $C00	; 8

; word_1AD1E:
SpindashSpeedsSuper:
		dc.w  $B00	; 0
		dc.w  $B80	; 1
		dc.w  $C00	; 2
		dc.w  $C80	; 3
		dc.w  $D00	; 4
		dc.w  $D80	; 5
		dc.w  $E00	; 6
		dc.w  $E80	; 7
		dc.w  $F00	; 8

;===========================================================================

; If still charging the dash...
; loc2_1AD30
Sonic_ChargingSpindash:
		tst.w	v_charging(a0)				; check charge count
		beq.s	Sonic_ChargingSpindashInput			; if zero, branch
		move.w	v_charging(a0),d0			; otherwise put it in d0
		lsr.w	#5,d0					; shift right 5 (divide it by 32)
		sub.w	d0,v_charging(a0)			; subtract from charge count
		bcc.s	Sonic_ChargingSpindashInput		; if charge did not underflow, branch
		move.w	#$00,v_charging(a0)			; set charge count to 0

; loc_1AD78:
Sonic_ChargingSpindashInput:
		move.b	(v_jpadpress2).w,d0			; read controller
		andi.b	#btnABC,d0				; pressing A/B/C?
		beq.w	Obj01_Spindash_ResetScr			; if not, branch

	if FeatureSpindash>1
		queue_sfx	#sfx_Spindash			; Spindash Reving was $E0 in sonic 2
	endif ; if FeatureSpindash>1

		play_queued_sfx					; play charge sound
		addi.w	#$200,v_charging(a0)			; increase charge count
		cmpi.w	#$800,v_charging(a0)			; check if it's maxed
		bcs.s	Obj01_Spindash_ResetScr			; if not, then branch
		move.w	#$800,v_charging(a0)			; reset it to max

; loc_1AD78:
Obj01_Spindash_ResetScr:
		addq.l	#4,sp					; skip Sonic_Jump when returning to Obj01_MdNormal
		cmpi.w	#$60,(v_lookshift).w
		beq.s	Obj01_Spindash_Skip2			; to be used in Spin Dash
		bcc.s	Obj01_Spindash_Skip
		addq.w	#4,(v_lookshift).w

;loc_1AD88:
Obj01_Spindash_Skip:
		subq.w	#2,(v_lookshift).w

;loc_1AD8C:
Obj01_Spindash_Skip2:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		move.w	#$60,(v_lookshift).w			; reset looking up/down
		rts

; End of subroutine Sonic_UpdateSpindash

	if FeatureSpindash>1
; DATA XREF: ROM:0001600C?o
; Sprite_1DD20:
SpinDash_dust:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move	off_1DD2E(pc,d0.w),d1
		jmp	off_1DD2E(pc,d1.w)
;---------------------------------------------------------------------------

; DATA XREF: h+6DBA?o h+6DBC?o ...
off_1DD2E:
		dc	loc_1DD36-off_1DD2E
		dc	loc_1DD90-off_1DD2E
		dc	loc_1DE46-off_1DD2E
		dc	loc_1DE4A-off_1DD2E
;-------------obPriority----------------------------------------------------

; DATA XREF: h+6DBA?o
loc_1DD36:
		addq.b	#2,obRoutine(a0)
		move.l	#MapUnc_1DF5E,obMap(a0)
		or.b	#$04,obRender(a0)
		move.b	#$01,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move	#$7A0,obGfx(a0)
		move	#-$3000,objoff_3E(a0)
		move	#$F400,objoff_3C(a0)
		cmp	#-$2E40,a0
		beq.s	loc_1DD8C
		move.b	#$01,objoff_34(a0)
;		cmp	#2,($FFFFFF70).w
;		beq.s	loc_1DD8C
;		move	#$48C,obGfx(a0)
;		move	#-$4FC0,objoff_3E(a0)
;		move	#-$6E80,objoff_3C(a0)

; CODE XREF: h+6DF6?j h+6E04?j
loc_1DD8C:
;		bsr.w	sub_16D6E

; DATA XREF: h+6DBA?o
loc_1DD90:
		movea.w	objoff_3E(a0),a2
		moveq	#0,d0
		move.b	obAnim(a0),d0
		add	d0,d0
		move	off_1DDA4(pc,d0.w),d1
		jmp	off_1DDA4(pc,d1.w)
;---------------------------------------------------------------------------

; DATA XREF: h+6E30?o h+6E32?o ...
off_1DDA4:
		dc	loc_1DE28-off_1DDA4
		dc	loc_1DDAC-off_1DDA4
		dc	loc_1DDCC-off_1DDA4
		dc	loc_1DE20-off_1DDA4
;---------------------------------------------------------------------------

; DATA XREF: h+6E30?o
loc_1DDAC:
		move	($FFFFF646).w,obY(a0)
		tst.b	obNextAni(a0)
		bne.s	loc_1DE28
		move	obX(a2),obX(a0)
		move.b	#bitHorizontal,obStatus(a0)
		and	#$7FFF,obGfx(a0)
		bra.s	loc_1DE28
;---------------------------------------------------------------------------

; DATA XREF: h+6E30?o
loc_1DDCC:
;		cmp.b	#$C,$28(a2)
;		bcs.s	loc_1DE3E
		cmp.b	#$04,obRoutine(a2)
		bcc.s	loc_1DE3E
		tst.b	objoff_39(a2)
		beq.s	loc_1DE3E
		move	obX(a2),obX(a0)
		move	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)
		and.b	#bitVertical,obStatus(a0)
		tst.b	objoff_34(a0)
		beq.s	loc_1DE06
		sub	#4,obY(a0)

; CODE XREF: h+6E8A?j
loc_1DE06:
		tst.b	obNextAni(a0)
		bne.s	loc_1DE28
		and	#$7FFF,obGfx(a0)
		tst	obGfx(a2)
		bpl.s	loc_1DE28
		or	#-$8000,obGfx(a0)
;---------------------------------------------------------------------------

; DATA XREF: h+6E30?o
loc_1DE20:

; CODE XREF: h+6E42?j h+6E56?j ...
loc_1DE28:
		lea	(off_1DF38).l,a1
		jsr	AnimateSprite
		bsr.w	loc_1DEE4
		jmp	DisplaySprite
;---------------------------------------------------------------------------

; CODE XREF: h+6E5E?j h+6E66?j ...
loc_1DE3E:
		move.b	#$00,obAnim(a0)
		rts
;---------------------------------------------------------------------------

; DATA XREF: h+6DBA?o
loc_1DE46:
		bra.w	DeleteObject
;---------------------------------------------------------------------------

loc_1DE4A:
		movea.w	objoff_3E(a0),a2
		moveq	#$10,d1
		cmp.b	#$D,obAnim(a2)
		beq.s	loc_1DE64
		moveq	#$6,d1
		cmp.b	#$03,obColProp(a2)
		beq.s	loc_1DE64
		move.b	#$02,obRoutine(a0)
		move.b	#$00,objoff_32(a0)
		rts

;---------------------------------------------------------------------------

; CODE XREF: h+6EE0?j
loc_1DE64:
		subq.b	#1,objoff_32(a0)
		bpl.s	loc_1DEE0
		move.b	#$03,objoff_32(a0)
		jsr	FindFreeObj
		bne.s	loc_1DEE0
		move.b	obID(a0),obID(a1)
		move	obX(a2),obX(a1)
		move	obY(a2),obY(a1)
		tst.b	objoff_34(a0)
		beq.s	loc_1DE9A
		sub	#4,d1

; CODE XREF: h+6F1E?j
loc_1DE9A:
		add	d1,obY(a1)
		move.b	#bitHorizontal,obStatus(a1)
		move.b	#$03,obAnim(a1)
		addq.b	#2,obRoutine(a1)
		move.l	obMap(a0),obMap(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	#$01,obPriority(a1)
		move.b	#$04,obActWid(a1)
		move	obGfx(a0),obGfx(a1)
		move	objoff_3E(a0),objoff_3E(a1)
		and	#$7FFF,obGfx(a1)
		tst	obGfx(a2)
		bpl.s	loc_1DEE0
		or	#-$8000,obGfx(a1)

; CODE XREF: h+6EF4?j h+6F00?j ...
loc_1DEE0:
		bsr.s	loc_1DEE4
		rts
;---------------------------------------------------------------------------

; CODE XREF: h+6EC0?p h+6F6C?p
loc_1DEE4:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		cmp.b	objoff_30(a0),d0
		beq.w	locret_1DF36
		move.b	d0,objoff_30(a0)
		lea	(off_1E074).l,a2
		add	d0,d0
		add	(a2,d0.w),a2
		move	(a2)+,d5
		subq	#1,d5
		bmi.w	locret_1DF36
		move	objoff_3C(a0),d4

; CODE XREF: h+6FBE?j
loc_1DF0A:
		moveq	#0,d1
		move	(a2)+,d1
		move	d1,d3
		lsr.w	#8,d3
		and	#$F0,d3	; '?'
		add	#$10,d3
		and	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_Dust,d1
		move	d4,d2
		add	d3,d4
		add	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,loc_1DF0A
		rts

; CODE XREF: h+6F7A?j h+6F90?j
locret_1DF36:
		rts
;---------------------------------------------------------------------------

; DATA XREF: h+6EB4?o h+6FC4?o ...
off_1DF38:
		dc	byte_1DF40-off_1DF38
		dc	byte_1DF43-off_1DF38
		dc	byte_1DF4F-off_1DF38
		dc	byte_1DF5obRoutineff_1DF38

; DATA XREF: h+6FC4?o
byte_1DF40:
		dc.b	$1F,0,$FF

; DATA XREF: h+6FC4?o
byte_1DF43:
		dc.b	3,1,2,3,4,5,6,7,8,9,$FD,0
		
; DATA XREF: h+6FC4?o	
byte_1DF4F:
		dc.b	1,$A,$B,$C,$D,$E,$F,$10,$FF
		
; DATA XREF: h+6FC4?o
byte_1DF58:
		dc.b	3,$11,$12,$13,$14,$FC
; -------------------------------------------------------------------------------
; Unknown Sprite Mappings
; -------------------------------------------------------------------------------
MapUnc_1DF5E:
		dc	word_1DF8A-MapUnc_1DF5E
		dc	word_1DF8C-MapUnc_1DF5E
		dc	word_1DF96-MapUnc_1DF5E
		dc	word_1DFA0-MapUnc_1DF5E
		dc	word_1DFAA-MapUnc_1DF5E
		dc	word_1DFB4-MapUnc_1DF5E
		dc	word_1DFBE-MapUnc_1DF5E
		dc	word_1DFC8-MapUnc_1DF5E
		dc	word_1DFD2-MapUnc_1DF5E
		dc	word_1DFDC-MapUnc_1DF5E
		dc	word_1DFE6-MapUnc_1DF5E
		dc	word_1DFF0-MapUnc_1DF5E
		dc	word_1DFFA-MapUnc_1DF5E
		dc	word_1E004-MapUnc_1DF5E
		dc	word_1E016-MapUnc_1DF5E
		dc	word_1E028-MapUnc_1DF5E
		dc	word_1E03A-MapUnc_1DF5E
		dc	word_1E04C-MapUnc_1DF5E
		dc	word_1E056-MapUnc_1DF5E
		dc	word_1E060-MapUnc_1DF5E
		dc	word_1E06A-MapUnc_1DF5E
		dc	word_1DF8A-MapUnc_1DF5E
		
word_1DF8A:
		dc.b	0
	
word_1DF8C:
		dc.b	1
		dc.b	$F2,$0D,$0,0,$F0
	
word_1DF96:
		dc.b	1
		dc.b	$E2,$0F,$0,0,$F0
	
word_1DFA0:
		dc.b	1
		dc.b	$E2,$0F,$0,0,$F0
	
word_1DFAA:
		dc.b	1
		dc.b	$E2,$0F,$0,0,$F0
	
word_1DFB4:
		dc.b	1
		dc.b	$E2,$0F,$0,0,$F0
	
word_1DFBE:
		dc.b	1
		dc.b	$E2,$0F,$0,0,$F0
	
word_1DFC8:
		dc.b	1
		dc.b	$F2,$0D,$0,0,$F0
	
word_1DFD2:
		dc.b	1
		dc.b	$F2,$0D,$0,0,$F0
	
word_1DFDC:
		dc.b	1
		dc.b	$F2,$0D,$0,0,$F0
	
word_1DFE6:
		dc.b	1
		dc.b	$4,$0D,$0,0,$E0
	
word_1DFF0:
		dc.b	1
		dc.b	$4,$0D,$0,0,$E0
	
word_1DFFA:
		dc.b	1
		dc.b	$4,$0D,$0,0,$E0
	
word_1E004:
		dc.b	2
		dc.b	$F4,$01,$0,0,$E8
		dc.b	$4,$0D,$0,2,$E0
	
word_1E016:
		dc.b	2
		dc.b	$F4,$05,$0,0,$E8
		dc.b	$4,$0D,$0,4,$E0
	
word_1E028:
		dc.b	2
		dc.b	$F4,$09,$0,0,$E0
		dc.b	$4,$0D,$0,6,$E0
	
word_1E03A:
		dc.b	2
		dc.b	$F4,$09,$0,0,$E0
		dc.b	$4,$0D,$0,6,$E0
	
word_1E04C:
		dc.b	1
		dc.b	$F8,$05,$0,0,$F8
	
word_1E056:
		dc.b	1
		dc.b	$F8,$05,$0,4,$F8
	
word_1E060:
		dc.b	1
		dc.b	$F8,$05,$0,8,$F8
	
word_1E06A:
		dc.b	1
		dc.b	$F8,$05,$0,$C,$F8
		dc.b	0
	
off_1E074:
		dc	word_1E0A0-off_1E074
		dc	word_1E0A2-off_1E074
		dc	word_1E0A6-off_1E074
		dc	word_1E0AA-off_1E074
		dc	word_1E0AE-off_1E074
		dc	word_1E0B2-off_1E074
		dc	word_1E0B6-off_1E074
		dc	word_1E0BA-off_1E074
		dc	word_1E0BE-off_1E074
		dc	word_1E0C2-off_1E074
		dc	word_1E0C6-off_1E074
		dc	word_1E0CA-off_1E074
		dc	word_1E0CE-off_1E074
		dc	word_1E0D2-off_1E074
		dc	word_1E0D8-off_1E074
		dc	word_1E0DE-off_1E074
		dc	word_1E0E4-off_1E074
		dc	word_1E0EA-off_1E074
		dc	word_1E0EA-off_1E074
		dc	word_1E0EA-off_1E074
		dc	word_1E0EA-off_1E074
		dc	word_1E0EC-off_1E074
		
word_1E0A0:
		dc	0
	
word_1E0A2:
		dc	1
		dc	$7000
		
word_1E0A6:
		dc	1
		dc	$F008
		
word_1E0AA:
		dc	1
		dc	$F018
		
word_1E0AE:
		dc	1
		dc	$F028
		
word_1E0B2:
		dc	1
		dc	$F038
		
word_1E0B6:
		dc	1
		dc	$F048
		
word_1E0BA:
		dc	1
		dc	$7058
		
word_1E0BE:
		dc	1
		dc	$7060
		
word_1E0C2:
		dc	1
		dc	$7068
		
word_1E0C6:
		dc	1
		dc	$7070
		
word_1E0CA:
		dc	1
		dc	$7078
		
word_1E0CE:
		dc	1
		dc	$7080
		
word_1E0D2:
		dc	2
		dc	$1088
		dc	$708A
		
word_1E0D8:
		dc	2
		dc	$3092
		dc	$7096
		
word_1E0DE:
		dc	2
		dc	$509E
		dc	$70A4
		
word_1E0E4:
		dc	2
		dc	$50AC
		dc	$70B2
		
word_1E0EA:
		dc	0
	
word_1E0EC:
		dc	1
		dc	$F0BA
		even
	endif
; end of SpinDash_dust Routine
