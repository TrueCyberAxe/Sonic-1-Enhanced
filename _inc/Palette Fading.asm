; ---------------------------------------------------------------------------
; Subroutine to fade in from black
; ---------------------------------------------------------------------------

PaletteFadeIn:
		move.w	#$003F,(v_pfade_start).w ; set start position = 0; size = $40

PalFadeIn_Alt:				; start position and size are already set
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0

.fill:
		move.w	d1,(a0)+
		dbf	d0,.fill 	; fill palette with black
	if TweakBetterFadeEffects=0
		move.w	#$16-1,d4
	else
		moveq	#$0E,d4												; MJ: prepare maximum colour check
		moveq	#$00,d6												; MJ: clear d6
	endc

.mainloop:
	if TweakBetterFadeEffects=0
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.s	FadeIn_FromBlack
		bsr.w	RunPLC
		dbf	d4,.mainloop
		rts
	else
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitforVBla
		bchg	#$00,d6												; MJ: change delay counter
		beq	.mainloop												; MJ: if null, delay a frame
		bsr.s	FadeIn_FromBlack
		subq.b	#$02,d4											; MJ: decrease colour check
		bne	.mainloop												; MJ: if it has not reached null, branch
		move.b	#$12,(v_vbla_routine).w			; MJ: wait for V-blank again (so colours transfer)
		bra	WaitforVBla											; MJ: ''
	endc
; End of function PaletteFadeIn
; ===========================================================================

FadeIn_FromBlack:
		moveq	#0,d0
		lea	(v_palette).w,a0
		lea	(v_palette_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.addcolour:
		bsr.s	FadeIn_AddColour ; increase colour
		dbf	d0,.addcolour	; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w	; is level Labyrinth?
		bne.s	.exit		; if not, branch

		moveq	#0,d0
		lea	(v_palette_water).w,a0
		lea	(v_palette_water_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.addcolour2:
		bsr.s	FadeIn_AddColour ; increase colour again
		dbf	d0,.addcolour2 ; repeat

.exit:
		rts
; End of function FadeIn_FromBlack
; ===========================================================================

FadeIn_AddColour:
	if TweakBetterFadeEffects=0
.addblue:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3		; is colour already at threshold level?
		beq.s	.next		; if yes, branch
		move.w	d3,d1
		addi.w	#$200,d1	; increase blue value
		cmp.w	d2,d1		; has blue reached threshold level?
		bhi.s	.addgreen	; if yes, branch
		move.w	d1,(a0)+	; update palette
		rts
; ===========================================================================

.addgreen:
		move.w	d3,d1
		addi.w	#$20,d1		; increase green value
		cmp.w	d2,d1
		bhi.s	.addred
		move.w	d1,(a0)+	; update palette
		rts
; ===========================================================================

.addred:
		addq.w	#2,(a0)+	; increase red value
		rts
; ===========================================================================

.next:
		addq.w	#2,a0		; next colour
		rts
; End of function FadeIn_AddColour

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to fade out to black
; ---------------------------------------------------------------------------

PaletteFadeOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
	if TweakBetterFadeEffects=0
		move.w	#$16-1,d4
	else
		moveq	#$07,d4		; MJ: set repeat times
		moveq	#$00,d6		; MJ: clear d6
	endc


.mainloop:
	if TweakBetterFadeEffects
		bsr.w	RunPLC
	endc Cyber Axe: This set of Code seems to be the problem code
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w
		bsr.w	WaitForVBlank
	if TweakBetterFadeEffects>0
		bchg	#$00,d6												; MJ: change delay counter
		beq	.mainloop												; MJ: if null, delay a frame
	endc
		bsr.s	FadeOut_ToBlack
	if TweakBetterFadeEffects=0
		bsr.w	RunPLC
	endc
		dbf	d4,.mainloop
		rts
; End of function PaletteFadeOut
; ===========================================================================

FadeOut_ToBlack:
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.decolour:
		bsr.s	FadeOut_DecColour ; decrease colour
		dbf	d0,.decolour	; repeat for size of palette

		moveq	#0,d0
		lea	(v_palette_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.decolour2:
		bsr.s	FadeOut_DecColour
		dbf	d0,.decolour2
		rts
; End of function FadeOut_ToBlack
; ===========================================================================

FadeOut_DecColour:
	if TweakBetterFadeEffects=0
.dered:
		move.w	(a0),d2
		beq.s	.next
		move.w	d2,d1
		andi.w	#$E,d1
		beq.s	.degreen
		subq.w	#2,(a0)+	; decrease red value
		rts
; ===========================================================================

.degreen:
		move.w	d2,d1
		andi.w	#$E0,d1
		beq.s	.deblue
		subi.w	#$20,(a0)+	; decrease green value
		rts
; ===========================================================================

.deblue:
		move.w	d2,d1
		andi.w	#$E00,d1
		beq.s	.next
		subi.w	#$200,(a0)+	; decrease blue value
		rts
; ===========================================================================

.next:
		addq.w	#2,a0
else
		move.w	(a0),d5		; MJ: load colour
		move.w	d5,d1		; MJ: copy to d1
		move.b	d1,d2		; MJ: load green and red
		move.b	d1,d3		; MJ: load red
		andi.w	#$0E00,d1	; MJ: get only blue
		beq	.noblue		; MJ: if blue is finished, branch
		subi.w	#$0200,d5	; MJ: decrease blue

.noblue:
		andi.w	#$00E0,d2	; MJ: get only green (needs to be word)
		beq	.nogreen	; MJ: if green is finished, branch
		subi.b	#$20,d5		; MJ: decrease green

.nogreen:
		andi.b	#$0E,d3		; MJ: get only red
		beq	.nored		; MJ: if red is finished, branch
		subq.b	#$02,d5		; MJ: decrease red

.nored:
		move.w	d5,(a0)+	; MJ: save new colour
	endc
		rts
; End of function FadeOut_DecColour

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to fade in from white (Special Stage)
; ---------------------------------------------------------------------------

PaletteWhiteIn:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#cWhite,d1
		move.b	(v_pfade_size).w,d0

.fill:
		move.w	d1,(a0)+
		dbf	d0,.fill 	; fill palette with white

	if TweakBetterFadeEffects=0
		move.w	#$16-1,d4
	else
		moveq	#$0E,d4		; MJ: prepare maximum colour check
		moveq	#$00,d6		; MJ: clear d6
	endc

.mainloop:
	if TweakBetterFadeEffects=0
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.s	WhiteIn_FromWhite
		bsr.w	RunPLC
		dbf	d4,.mainloop
		rts
	else
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitforVBla
		bchg	#$00,d6				; MJ: change delay counter
		beq	.mainloop			; MJ: if null, delay a frame
		bsr.s	WhiteIn_FromWhite
		subq.b	#$02,d4				; MJ: decrease colour check
		bne	.mainloop			; MJ: if it has not reached null, branch
		move.b	#$12,(v_vbla_routine).w		; MJ: wait for V-blank again (so colours transfer)
		bra	WaitforVBla			; MJ: wait for V-blank again (so colours transfer)
	endc
; End of function PaletteWhiteIn
; ===========================================================================

WhiteIn_FromWhite:
		moveq	#0,d0
		lea	(v_palette).w,a0
		lea	(v_palette_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.decolour:
		bsr.s	WhiteIn_DecColour ; decrease colour
		dbf	d0,.decolour	; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w	; is level Labyrinth?
		bne.s	.exit		; if not, branch
		moveq	#0,d0
		lea	(v_palette_water).w,a0
		lea	(v_palette_water_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.decolour2:
		bsr.s	WhiteIn_DecColour
		dbf	d0,.decolour2

.exit:
		rts
; End of function WhiteIn_FromWhite
; ===========================================================================

WhiteIn_DecColour:
	if TweakBetterFadeEffects=0
.deblue:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	.next
		move.w	d3,d1
		subi.w	#$200,d1	; decrease blue value
		blo.s	.degreen
		cmp.w	d2,d1
		blo.s	.degreen
		move.w	d1,(a0)+
		rts
; ===========================================================================

.degreen:
		move.w	d3,d1
		subi.w	#$20,d1		; decrease green value
		blo.s	.dered
		cmp.w	d2,d1
		blo.s	.dered
		move.w	d1,(a0)+
		rts
; ===========================================================================

.dered:
		subq.w	#2,(a0)+	; decrease red value
		rts
; ===========================================================================

.next:
		addq.w	#2,a0
	else
		move.b (a1),d5 												; MJ: load blue
		move.w (a1)+,d1 											; MJ: load green and red
		move.b d1,d2 													; MJ: load red
		lsr.b #$04,d1 												; MJ: get only green
		andi.b #$0E,d2 												; MJ: get only red
		move.w (a0),d3 												; MJ: load current colour in buffer
		cmp.b d5,d4 													; MJ: is it time for blue to fade?
		bls .deblue 													; MJ: if not, branch
		subi.w #$0200,d3 											; MJ: dencrease blue

.deblue:
		cmp.b d1,d4 													; MJ: is it time for green to fade?
		bls .degreen 													; MJ: if not, branch
		subi.b #$20,d3 												; MJ: dencrease green

.degreen:
		cmp.b d2,d4 													; MJ: is it time for red to fade?
		bls .dered 														; MJ: if not, branch
		subq.b #$02,d3 												; MJ: dencrease red

.dered:
   		move.w d3,(a0)+ 											; MJ: save colour

	endc
		rts
; End of function WhiteIn_DecColour
	else
		move.b	(a1),d5										; MJ: load blue
		move.w	(a1)+,d1									; MJ: load green and red
		move.b	d1,d2											; MJ: load red
		lsr.b	#$04,d1											; MJ: get only green
		andi.b	#$0E,d2										; MJ: get only red
		move.w	(a0),d3										; MJ: load current colour in buffer
		cmp.b	d5,d4												; MJ: is it time for blue to fade?
		bhi	.noblue												; MJ: if not, branch
		addi.w	#$0200,d3									; MJ: increase blue

.noblue:
		cmp.b	d1,d4												; MJ: is it time for green to fade?
		bhi	.nogreen											; MJ: if not, branch
		addi.b	#$20,d3										; MJ: increase green

.nogreen:
		cmp.b	d2,d4												; MJ: is it time for red to fade?
		bhi	.nored												; MJ: if not, branch
		addq.b	#$02,d3										; MJ: increase red

.nored:
		move.w	d3,(a0)+									; MJ: save colour
		rts																; MJ: return
	endc

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage)
; ---------------------------------------------------------------------------

PaletteWhiteOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
	if TweakBetterFadeEffects=0
		move.w	#$16-1,d4
	else
		moveq #$07,d4			; MJ: set repeat times
		moveq #$00,d6			; MJ: clear d6
	endc

.mainloop:
	if TweakBetterFadeEffects
		bsr.w	RunPLC
	endc
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w
		bsr.w	WaitForVBlank

	if TweakBetterFadeEffects
		bchg #$00,d6 			; MJ: change delay counter
		beq .mainloop 			; MJ: if null, delay a frame
	endc

		bsr.s	WhiteOut_ToWhite
	if TweakBetterFadeEffects=0
		bsr.w	RunPLC
	endc
		dbf	d4,.mainloop
		rts
; End of function PaletteWhiteOut
; ===========================================================================

WhiteOut_ToWhite:
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.addcolour:
		bsr.s	WhiteOut_AddColour
		dbf	d0,.addcolour

		moveq	#0,d0
		lea	(v_palette_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.addcolour2:
		bsr.s	WhiteOut_AddColour
		dbf	d0,.addcolour2
		rts
; End of function WhiteOut_ToWhite
; ===========================================================================

WhiteOut_AddColour:
	if TweakBetterFadeEffects=0
.addred:
		move.w	(a0),d2
		cmpi.w	#cWhite,d2
		beq.s	.next
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#cRed,d1
		beq.s	.addgreen
		addq.w	#2,(a0)+	; increase red value
		rts
; ===========================================================================

.addgreen:
		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#cGreen,d1
		beq.s	.addblue
		addi.w	#$20,(a0)+	; increase green value
		rts
; ===========================================================================

.addblue:
		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#cBlue,d1
		beq.s	.next
		addi.w	#$200,(a0)+	; increase blue value
		rts
; ===========================================================================

.next:
		addq.w	#2,a0
	else
		move.w (a0),d5 			; MJ: load colour
		cmpi.w #$EEE,d5
		beq.s .allred
		move.w d5,d1 			; MJ: copy to d1
		move.b d1,d2 			; MJ: load green and red
		move.b d1,d3 			; MJ: load red
		andi.w #$0E00,d1 		; MJ: get only blue
		cmpi.w #$0E00,d1
		beq .allblue 			; MJ: if blue is finished, branch
		addi.w #$0200,d5 		; MJ: increase blue

.allblue:
		andi.w #$00E0,d2 		; MJ: get only green (needs to be word)
		cmpi.w #$00E0,d2
		beq  .allgreen 			; MJ: if green is finished, branch
		addi.b #$20,d5 			; MJ: increase green

.allgreen:
		andi.b #$0E,d3 			; MJ: get only red
		cmpi.b #$0E,d3
		beq  .allred 			; MJ: if red is finished, branch
		addq.b #$02,d5 			; MJ: increase red

.allred:
		move.w d5,(a0)+ 		; MJ: save new colour

	endc
		rts
; End of function WhiteOut_AddColour
