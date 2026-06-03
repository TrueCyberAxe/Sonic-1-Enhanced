; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

DisplaySprite:
	if FeatureEnhancedLevelFadeIn
		tst.b	(f_titlecard_only).w
		beq.s	.checkdebug
		cmpa.w	#v_titlecard,a0
		blo.s	.hide
		cmpa.w	#v_titlecard+(object_size*4),a0
		blo.s	.checkdebug

.hide:
		rts

.checkdebug:
	endif ; if FeatureEnhancedLevelFadeIn
	if EnhancedDebug
		tst.w	(v_debuguse).w
		beq.s	.show
		btst	#bitDebugSonicSpriteView,(f_debugmode).w
		beq.s	.show
		cmpa.w	#v_player,a0
		beq.s	.show
		cmpa.w	#v_gogglesobj,a0
		beq.s	.show
		rts

.show:
	endif ; if EnhancedDebug

		lea	(v_spritequeue).w,a1
		move.w	obPriority(a0),d0 ; get sprite priority
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a1		; jump to position in queue
		cmpi.w	#$7E,(a1)	; is this part of the queue full?
		bhs.s	DSpr_Full	; if yes, branch
		addq.w	#2,(a1)		; increment sprite count
		adda.w	(a1),a1		; jump to empty position
		move.w	a0,(a1)		; insert RAM address for object

DSpr_Full:
		rts
; End of function DisplaySprite

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a 2nd sprite/object, when a1 is the object RAM
; ---------------------------------------------------------------------------

; DisplaySprite1: <-- old misnomer
DisplaySprite2:
	if FeatureEnhancedLevelFadeIn
		tst.b	(f_titlecard_only).w
		beq.s	.checkdebug
		cmpa.w	#v_titlecard,a1
		blo.s	.hide
		cmpa.w	#v_titlecard+(object_size*4),a1
		blo.s	.checkdebug

.hide:
		rts

.checkdebug:
	endif ; if FeatureEnhancedLevelFadeIn
	if EnhancedDebug
		tst.w	(v_debuguse).w
		beq.s	.show
		btst	#bitDebugSonicSpriteView,(f_debugmode).w
		beq.s	.show
		cmpa.w	#v_player,a1
		beq.s	.show
		cmpa.w	#v_gogglesobj,a1
		beq.s	.show
		rts

.show:
	endif ; if EnhancedDebug

		lea	(v_spritequeue).w,a2
		move.w	obPriority(a1),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a2
		cmpi.w	#$7E,(a2)
		bhs.s	DSpr2_Full
		addq.w	#2,(a2)
		adda.w	(a2),a2
		move.w	a1,(a2)

DSpr2_Full:
		rts
; End of function DisplaySprite2
