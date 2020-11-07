;---------------------------------------------------------------------------
;Subroutine to make Sonic perform a spindash
;---------------------------------------------------------------------------
;||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Sonic_SpinDash:
    tst.b	f_spindash(a0)			     ; already Spin Dashing?
    bne.s	loc2_1AC8E		           ; if set, branch

    cmpi.b	#id_duck,obAnim(a0)		 ; is anim duck
    bne.s	locret2_1AC8C		         ; if not, return

    move.b	(v_jpadpress2).w,d0	   ; read controller
    andi.b	#$70,d0			           ; pressing A/B/C ?
    beq.w	locret2_1AC8C		         ; if not, return

  if FeatureSpindash=1
    move.b	#$E,obHeight(a0)       ; Adjust Height for Spindash
    move.b	#7,obWidth(a0)         ; Adjust Width for Spindash
  endc

  move.b #id_Spindash,obAnim(a0) ; set Spin Dash anim (9 in s2)

    move.w	#$BE,d0			           ; spin sound ($E0 in s2)
  	jsr	(PlaySound_Special).l	     ; play spin sound

  if FeatureSpindash=1
    move.w   #$0F00,obInertia(a0)              ; Set Sonic's speed
  endc

  	addq.l	#4,sp			             ; Add 4 bytes to the stack return address to skip Sonic_Jump on next rts to Obj01_MdNormal, preventing conflicts with button presses.
  	move.b	#1,f_spindash(a0)		   ; set Spin Dash flag
  	move.w	#0,$3A(a0)		         ; set charge count to 0

  	cmpi.b	#$C,obSubtype(a0)		   ; ??? oxygen remaining?
  	bcs.s	loc2_1AC84		           ; ??? branch if carry
  	move.b	#2,($FFFFD11C).w	     ; ??? $D11C is used for the smoke/dust object

loc2_1AC84:
		bsr.w Sonic_LevelBound
		bsr.w Sonic_AnglePos

locret2_1AC8C:
		rts

;---------------------------------------------------------------------------
loc2_1AC8E:
    move.b #id_Spindash,obAnim(a0)             ; set Spin Dash anim (9 in s2)

  if FeatureSpindash=1
    move.w   #$C00,obInertia(a0)               ; Set Sonic's speed to Maximum Run Speed
  endc

    move.b	(v_jpadhold2).w,d0	               ; read controller
    btst	#1,d0			                           ; check down button
    bne.w	loc2_1AD30		                       ; if set, branch

    move.b	#$E,$16(a0)		                     ; $16(a0) is height/2
    move.b	#7,$17(a0)		                     ; $17(a0) is width/2
    move.b	#id_roll,obAnim(a0)		             ; set animation to roll

    addq.w	#5,$C(a0)		                       ; $C(a0) is Y coordinate
    move.b	#0,f_spindash(a0)		               ; clear Spin Dash flag
    moveq	#0,d0
    move.b	$3A(a0),d0		                     ; copy charge count
    add.w	d0,d0			                           ; double it
    move.w	Dash_Speeds(pc,d0.w),obInertia(a0) ; get normal speed
    move.w	obInertia(a0),d0		               ; get inertia
    subi.w	#$800,d0		                       ; subtract $800
    add.w	d0,d0			                           ; double it
    andi.w	#$1F00,d0		                       ; mask it against $1F00
    neg.w	d0			                             ; negate it
    addi.w	#$2000,d0		                       ; add $2000
    move.w	d0,($FFFFC904).w	                 ; move to $C904 - Horizontal scroll delay Fix - was move.w	d0,($FFFFEED0).w	; move to $EED0
    btst	#0,$22(a0)		                       ; is sonic facing right?
    beq.s	loc2_1ACF4		                       ; if not, branch
    neg.w	obInertia(a0)			                   ; negate inertia

loc2_1ACF4:
    bset	#2,$22(a0)		                       ; set unused (in s1) flag
    move.b	#0,($FFFFD11C).w	                 ; clear $D11C (smoke)
    move.w	#$BC,d0			                       ; spin release sound
    jsr	(PlaySound_Special).l	                 ; play it!
		bra.s loc2_1AD78

;===========================================================================
Dash_Speeds:
  	dc.w $800 ; 0
  	dc.w $880 ; 1
  	dc.w $900 ; 2
  	dc.w $980 ; 3
  	dc.w $A00 ; 4
  	dc.w $A80 ; 5
  	dc.w $B00 ; 6
  	dc.w $B80 ; 7
  	dc.w $C00 ; 8

;===========================================================================
loc2_1AD30: ; If still charging the dash...
    tst.w	$3A(a0)		               ; check charge count
    beq.s	loc2_1AD48	             ; if zero, branch
    move.w	$3A(a0),d0	           ; otherwise put it in d0
    lsr.w	#5,d0		                 ; shift right 5 (divide it by 32)
    sub.w	d0,$3A(a0)	             ; subtract from charge count
    bcc.s	loc2_1AD48	             ; ??? branch if carry clear
    move.w	#0,$3A(a0)	           ; set charge count to 0

loc2_1AD48:
    move.b	(v_jpadpress2).w,d0	   ; read controller
    andi.b	#$70,d0			           ; pressing A/B/C?
    beq.w	loc2_1AD78		           ; if not, branch
  if FeatureSpindash>1
    move.w	#$BE,d0			           ; Spindash Reving was $E0 in sonic 2
  endc                             ; @TODO check this is the correct place for this endc
    jsr	(PlaySound_Special).l	     ; play charge sound
    addi.w	#$200,$3A(a0)		       ; increase charge count
    cmpi.w	#$800,$3A(a0)		       ; check if it's maxed
    bcs.s	loc2_1AD78		           ; if not, then branch
    move.w	#$800,$3A(a0)		       ; reset it to max

loc2_1AD78:
    addq.l	#4,sp			             ; Add 4 bytes to the stack return address to skip Sonic_Jump on next rts to Obj01_MdNormal, preventing conflicts with button presses.
    cmpi.w	#$60,(v_lookshift).w
    beq.s	loc2_1AD8C		           ; to be used in Spin Dash
		bcc.s loc2_1AD88
		addq.w #4,(v_lookshift).w

loc2_1AD88:
		subq.w #2,(v_lookshift).w

loc2_1AD8C:
		bsr.w Sonic_LevelBound
		bsr.w Sonic_AnglePos
		move.w #$60,(v_lookshift).w    ; reset looking up/down
rts

; End of subroutine Sonic_SpinDash

  if FeatureSpindash>1
SpinDash_dust:
Sprite_1DD20:				; DATA XREF: ROM:0001600C?o
		moveq	#0,d0
		move.b	$24(a0),d0
		move	off_1DD2E(pc,d0.w),d1
		jmp	off_1DD2E(pc,d1.w)
;---------------------------------------------------------------------------
off_1DD2E:	dc loc_1DD36-off_1DD2E; 0 ; DATA XREF: h+6DBA?o h+6DBC?o ...
		dc loc_1DD90-off_1DD2E; 1
		dc loc_1DE46-off_1DD2E; 2
		dc loc_1DE4A-off_1DD2E; 3
;---------------------------------------------------------------------------

loc_1DD36:				; DATA XREF: h+6DBA?o
		addq.b	#2,$24(a0)
		move.l	#MapUnc_1DF5E,4(a0)
		or.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$10,$19(a0)
		move	#$7A0,2(a0)
		move	#-$3000,$3E(a0)
		move	#$F400,$3C(a0)
		cmp	#-$2E40,a0
		beq.s	loc_1DD8C
		move.b	#1,$34(a0)
;		cmp	#2,($FFFFFF70).w
;		beq.s	loc_1DD8C
;		move	#$48C,2(a0)
;		move	#-$4FC0,$3E(a0)
;		move	#-$6E80,$3C(a0)

loc_1DD8C:				; CODE XREF: h+6DF6?j h+6E04?j
;		bsr.w	sub_16D6E

loc_1DD90:				; DATA XREF: h+6DBA?o
		movea.w	$3E(a0),a2
		moveq	#0,d0
		move.b	$1C(a0),d0
		add	d0,d0
		move	off_1DDA4(pc,d0.w),d1
		jmp	off_1DDA4(pc,d1.w)
;---------------------------------------------------------------------------
off_1DDA4:	dc loc_1DE28-off_1DDA4; 0 ; DATA XREF: h+6E30?o h+6E32?o ...
		dc loc_1DDAC-off_1DDA4; 1
		dc loc_1DDCC-off_1DDA4; 2
		dc loc_1DE20-off_1DDA4; 3
;---------------------------------------------------------------------------

loc_1DDAC:				; DATA XREF: h+6E30?o
		move	($FFFFF646).w,$C(a0)
		tst.b	$1D(a0)
		bne.s	loc_1DE28
		move	8(a2),8(a0)
		move.b	#0,$22(a0)
		and	#$7FFF,2(a0)
		bra.s	loc_1DE28
;---------------------------------------------------------------------------

loc_1DDCC:				; DATA XREF: h+6E30?o
;		cmp.b	#$C,$28(a2)
;		bcs.s	loc_1DE3E
		cmp.b	#4,$24(a2)
		bcc.s	loc_1DE3E
		tst.b	$39(a2)
		beq.s	loc_1DE3E
		move	8(a2),8(a0)
		move	$C(a2),$C(a0)
		move.b	$22(a2),$22(a0)
		and.b	#1,$22(a0)
		tst.b	$34(a0)
		beq.s	loc_1DE06
		sub	#4,$C(a0)

loc_1DE06:				; CODE XREF: h+6E8A?j
		tst.b	$1D(a0)
		bne.s	loc_1DE28
		and	#$7FFF,2(a0)
		tst	2(a2)
		bpl.s	loc_1DE28
		or	#-$8000,2(a0)
;---------------------------------------------------------------------------

loc_1DE20:				; DATA XREF: h+6E30?o
loc_1DE28:				; CODE XREF: h+6E42?j h+6E56?j ...
		lea	(off_1DF38).l,a1
		jsr	AnimateSprite
		bsr.w	loc_1DEE4
		jmp	DisplaySprite
;---------------------------------------------------------------------------

loc_1DE3E:				; CODE XREF: h+6E5E?j h+6E66?j ...
		move.b	#0,$1C(a0)
		rts
;---------------------------------------------------------------------------

loc_1DE46:				; DATA XREF: h+6DBA?o
		bra.w	DeleteObject
;---------------------------------------------------------------------------

loc_1DE4A:
	movea.w	$3E(a0),a2
	moveq	#$10,d1
	cmp.b	#$D,$1C(a2)
	beq.s	loc_1DE64
	moveq	#$6,d1
	cmp.b	#$3,$21(a2)
	beq.s	loc_1DE64
	move.b	#2,$24(a0)
	move.b	#0,$32(a0)
	rts
;---------------------------------------------------------------------------

loc_1DE64:				; CODE XREF: h+6EE0?j
		subq.b	#1,$32(a0)
		bpl.s	loc_1DEE0
		move.b	#3,$32(a0)
		jsr	SingleObjLoad
		bne.s	loc_1DEE0
		move.b	0(a0),0(a1)
		move	8(a2),8(a1)
		move	$C(a2),$C(a1)
		tst.b	$34(a0)
		beq.s	loc_1DE9A
		sub	#4,d1

loc_1DE9A:				; CODE XREF: h+6F1E?j
		add	d1,$C(a1)
		move.b	#0,$22(a1)
		move.b	#3,$1C(a1)
		addq.b	#2,$24(a1)
		move.l	4(a0),4(a1)
		move.b	1(a0),1(a1)
		move.b	#1,$18(a1)
		move.b	#4,$19(a1)
		move	2(a0),2(a1)
		move	$3E(a0),$3E(a1)
		and	#$7FFF,2(a1)
		tst	2(a2)
		bpl.s	loc_1DEE0
		or	#-$8000,2(a1)

loc_1DEE0:				; CODE XREF: h+6EF4?j h+6F00?j ...
		bsr.s	loc_1DEE4
		rts
;---------------------------------------------------------------------------

loc_1DEE4:				; CODE XREF: h+6EC0?p h+6F6C?p
		moveq	#0,d0
		move.b	$1A(a0),d0
		cmp.b	$30(a0),d0
		beq.w	locret_1DF36
		move.b	d0,$30(a0)
		lea	(off_1E074).l,a2
		add	d0,d0
		add	(a2,d0.w),a2
		move	(a2)+,d5
		subq	#1,d5
		bmi.w	locret_1DF36
		move $3C(a0),d4

loc_1DF0A:				; CODE XREF: h+6FBE?j
		moveq	#0,d1
		move	(a2)+,d1
		move	d1,d3
		lsr.w	#8,d3
		and	#$F0,d3	; 'ð'
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

locret_1DF36:				; CODE XREF: h+6F7A?j h+6F90?j
		rts
;---------------------------------------------------------------------------
off_1DF38:	dc byte_1DF40-off_1DF38; 0 ; DATA XREF: h+6EB4?o h+6FC4?o ...
		dc byte_1DF43-off_1DF38; 1
		dc byte_1DF4F-off_1DF38; 2
		dc byte_1DF58-off_1DF38; 3
byte_1DF40:	dc.b $1F,  0,$FF	; 0 ; DATA XREF: h+6FC4?o
byte_1DF43:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,  9,$FD,  0; 0	; DATA XREF: h+6FC4?o
byte_1DF4F:	dc.b   1, $A, $B, $C, $D, $E, $F,$10,$FF; 0 ; DATA XREF: h+6FC4?o
byte_1DF58:	dc.b   3,$11,$12,$13,$14,$FC; 0	; DATA XREF: h+6FC4?o
; -------------------------------------------------------------------------------
; Unknown Sprite Mappings
; -------------------------------------------------------------------------------
MapUnc_1DF5E:
	dc word_1DF8A-MapUnc_1DF5E; 0
	dc word_1DF8C-MapUnc_1DF5E; 1
	dc word_1DF96-MapUnc_1DF5E; 2
	dc word_1DFA0-MapUnc_1DF5E; 3
	dc word_1DFAA-MapUnc_1DF5E; 4
	dc word_1DFB4-MapUnc_1DF5E; 5
	dc word_1DFBE-MapUnc_1DF5E; 6
	dc word_1DFC8-MapUnc_1DF5E; 7
	dc word_1DFD2-MapUnc_1DF5E; 8
	dc word_1DFDC-MapUnc_1DF5E; 9
	dc word_1DFE6-MapUnc_1DF5E; 10
	dc word_1DFF0-MapUnc_1DF5E; 11
	dc word_1DFFA-MapUnc_1DF5E; 12
	dc word_1E004-MapUnc_1DF5E; 13
	dc word_1E016-MapUnc_1DF5E; 14
	dc word_1E028-MapUnc_1DF5E; 15
	dc word_1E03A-MapUnc_1DF5E; 16
	dc word_1E04C-MapUnc_1DF5E; 17
	dc word_1E056-MapUnc_1DF5E; 18
	dc word_1E060-MapUnc_1DF5E; 19
	dc word_1E06A-MapUnc_1DF5E; 20
	dc word_1DF8A-MapUnc_1DF5E; 21
word_1DF8A:	dc.b 0
word_1DF8C:	dc.b 1
	dc.b $F2, $0D, $0, 0,$F0; 0
word_1DF96:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
word_1DFA0:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
word_1DFAA:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
word_1DFB4:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
word_1DFBE:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
word_1DFC8:	dc.b 1
	dc.b $F2, $0D, $0, 0,$F0; 0
word_1DFD2:	dc.b 1
	dc.b $F2, $0D, $0, 0,$F0; 0
word_1DFDC:	dc.b 1
	dc.b $F2, $0D, $0, 0,$F0; 0
word_1DFE6:	dc.b 1
	dc.b $4, $0D, $0, 0,$E0; 0
word_1DFF0:	dc.b 1
	dc.b $4, $0D, $0, 0,$E0; 0
word_1DFFA:	dc.b 1
	dc.b $4, $0D, $0, 0,$E0; 0
word_1E004:	dc.b 2
	dc.b $F4, $01, $0, 0,$E8; 0
	dc.b $4, $0D, $0, 2,$E0; 4
word_1E016:	dc.b 2
	dc.b $F4, $05, $0, 0,$E8; 0
	dc.b $4, $0D, $0, 4,$E0; 4
word_1E028:	dc.b 2
	dc.b $F4, $09, $0, 0,$E0; 0
	dc.b $4, $0D, $0, 6,$E0; 4
word_1E03A:	dc.b 2
	dc.b $F4, $09, $0, 0,$E0; 0
	dc.b $4, $0D, $0, 6,$E0; 4
word_1E04C:	dc.b 1
	dc.b $F8, $05, $0, 0,$F8; 0
word_1E056:	dc.b 1
	dc.b $F8, $05, $0, 4,$F8; 0
word_1E060:	dc.b 1
	dc.b $F8, $05, $0, 8,$F8; 0
word_1E06A:	dc.b 1
	dc.b $F8, $05, $0, $C,$F8; 0
	dc.b 0
off_1E074:
	  dc word_1E0A0-off_1E074; 0
  	dc word_1E0A2-off_1E074; 1
  	dc word_1E0A6-off_1E074; 2
  	dc word_1E0AA-off_1E074; 3
  	dc word_1E0AE-off_1E074; 4
  	dc word_1E0B2-off_1E074; 5
  	dc word_1E0B6-off_1E074; 6
  	dc word_1E0BA-off_1E074; 7
  	dc word_1E0BE-off_1E074; 8
  	dc word_1E0C2-off_1E074; 9
  	dc word_1E0C6-off_1E074; 10
  	dc word_1E0CA-off_1E074; 11
  	dc word_1E0CE-off_1E074; 12
  	dc word_1E0D2-off_1E074; 13
  	dc word_1E0D8-off_1E074; 14
  	dc word_1E0DE-off_1E074; 15
  	dc word_1E0E4-off_1E074; 16
  	dc word_1E0EA-off_1E074; 17
  	dc word_1E0EA-off_1E074; 18
  	dc word_1E0EA-off_1E074; 19
  	dc word_1E0EA-off_1E074; 20
  	dc word_1E0EC-off_1E074; 21
word_1E0A0:	dc 0
word_1E0A2:	dc 1
  	dc $7000
word_1E0A6:	dc 1
  	dc $F008
word_1E0AA:	dc 1
  	dc $F018
word_1E0AE:	dc 1
  	dc $F028
word_1E0B2:	dc 1
  	dc $F038
word_1E0B6:	dc 1
  	dc $F048
word_1E0BA:	dc 1
  	dc $7058
word_1E0BE:	dc 1
  	dc $7060
word_1E0C2:	dc 1
  	dc $7068
word_1E0C6:	dc 1
  	dc $7070
word_1E0CA:	dc 1
  	dc $7078
word_1E0CE:	dc 1
  	dc $7080
word_1E0D2:	dc 2
  	dc $1088
  	dc $708A
word_1E0D8:	dc 2
  	dc $3092
  	dc $7096
word_1E0DE:	dc 2
  	dc $509E
  	dc $70A4
word_1E0E4:	dc 2
  	dc $50AC
  	dc $70B2
word_1E0EA:	dc 0
word_1E0EC:	dc 1
  	dc $F0BA
  	even
  endc
; end of SpinDash_dust Routine
