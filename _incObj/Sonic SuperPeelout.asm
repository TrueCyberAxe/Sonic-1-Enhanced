;---------------------------------------------------------------------------
;Subroutine to make Sonic perform a spindash
;---------------------------------------------------------------------------
;||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Sonic_Peelout:
    btst   #1,f_superpeelout(a0)
    bne.s   Sonic_DashLaunch

    cmpi.b   #7,$1C(a0)                     ; check to see if your looking up
    bne.s   @return

    bclr    #5,obStatus(a0) 								; clear pushing flag

    move.b   (v_jpadpress2).w,d0
    andi.b   #%01110000,d0
    beq.w   @return

    move.b   #id_Run,obAnim(a0)

    move.w   #0,v_peelout(a0)
    ; move.w   #$82,d0
    move.w	#$BE,d0			                     ; spin sound ($E0 in s2)
    jsr    (PlaySound_Special).l            ; Play peelout charge sound
    addq.l #4,sp

    bset   #1,f_superpeelout(a0)
    bsr.w   Sonic_LevelBound
    bsr.w   Sonic_AnglePos

  @return:
    rts

Sonic_DashLaunch:
    move.b   #id_PeeloutCharge,obAnim(a0)
  if FeatureSuperPeelout=1
    move.w   #$760,obInertia(a0)                ; Set Sonic's speed to Maximum Run Speed
  else
    move.w   #$0F00,obInertia(a0)               ; Set sonic's speed to Sonic CD Peelout Speed
  endc

    move.b   (v_jpadhold2).w,d0
    btst   #0,d0
    bne.w   Sonic_DashCharge

    bclr     #1,f_superpeelout(a0)              ; stop Dashing
    cmpi.b   #obTimeFrame,v_peelout(a0)         ; have we been charging long enough?
    move.b   #id_Dash,obAnim(a0)                ; launches here (peelout sprites)

    move.w   #1,$10(a0)                         ; force X speed to nonzero for camera lag's benefit

    move.w   obInertia(a0),d0
    subi.w   #$800,d0
    add.w   d0,d0
    andi.w   #$1F00,d0
    neg.w   d0
    addi.w   #$2000,d0
    ;move.w   d0,(v_cameralag).w
    btst   #0,obStatus(a0)
    beq.s   @dontflip
    neg.w   obInertia(a0)

  @dontflip:
    ;bset   #2,obStatus(a0)                  ; apparently with this commented out, it won't cause extreme camera lag. weird that it's even here.
    bclr   #7,obStatus(a0)
    move.w   #$D3,d0
    ;jsr       (PlaySound_Special).l
    move.w   #$D4,d0
    ;jsr       (PlaySound_Special).l
    bra.w   Sonic_DashResetScr
; ---------------------------------------------------------------------------
Sonic_DashCharge:                      ; If still charging the dash...
    cmpi.b   #obTimeFrame,v_peelout(a0)
    beq.s   Sonic_DashResetScr
    addi.b   #1,v_peelout(a0)
    jmp    Sonic_DashResetScr

Sonic_Dash_Stop_Sound:
    move.w   #$D3,d0
    ;jsr       (PlaySound_Special).l

Sonic_DashResetScr:
    addq.l   #4,sp                    ; increase stack ptr ; was 4
    cmpi.w   #$60,(v_lookshift).w
    beq.s   @finish
    bcc.s   @skip
    addq.w   #4,(v_lookshift).w

  @skip:
    subq.w   #2,(v_lookshift).w

  @finish:
    bsr.w   Sonic_LevelBound
    bsr.w   Sonic_AnglePos
    rts
