; ---------------------------------------------------------------------------
; Subroutine to	horizontally pan the camera view ahead of the player
; (Ported from the US version of Sonic CD's "R11A__.MMD" by Nat The Porcupine)
; ---------------------------------------------------------------------------

Sonic_PanCamera:
		tst.w	(f_demo).w 			; Do Not Alter Camera in Demo Mode, causes death bug on demo #2
		beq.s	.skip_demo
		rts

.skip_demo:
		move.w	(v_camera_pan).w,d1		; get the current camera pan value
		move.w	obInertia(a0),d0		; get sonic's inertia
		bpl.s	.abs_inertia			; if sonic's inertia is positive, branch ahead
		neg.w	d0				; otherwise, we negate it to get the absolute value

.abs_inertia:

; These lines were intended to prevent the Camera from panning while
; going up the very first giant ramp in Palmtree Panic Zone Act 1.
; However, given that no such object exists in Sonic 1, I just went
; ahead and commented these out.
;		btst	#1,$2C(a0)			; is sonic going up a giant ramp in PPZ?
;		beq.s	.skip				; if not, branch
;		cmpi.w	#$1B00,obX(a0)			; is sonic's x position lower than $1B00?
;		bcs.s	.reset_pan			; if so, branch

	if FeatureSpindash|FeatureSuperPeelout
	if FeatureSpindash&FeatureSuperPeelout
		tst.b	f_spindash(a0)			; is Sonic charging a spin dash?
		bne.s	.charge_pan			; if yes, branch
		btst	#1,f_superpeelout(a0)		; is Sonic charging a peel-out?
		beq.s	.skip				; if not, branch
	elseif FeatureSpindash
		tst.b	f_spindash(a0)			; is Sonic charging a spin dash?
		beq.s	.skip				; if not, branch
	elseif FeatureSuperPeelout
		btst	#1,f_superpeelout(a0)		; is Sonic charging a peel-out?
		beq.s	.skip				; if not, branch
	endif ; if FeatureSpindash&FeatureSuperPeelout
.charge_pan:
		btst	#0,obStatus(a0)			; check the direction that Sonic is facing
		bne.s	.pan_right			; if facing left, pan the camera left
		bra.s	.pan_left			; otherwise, pan the camera right
	endif ; if FeatureSpindash|FeatureSuperPeelout

.skip:
		cmpi.w	#$600,d0			; is sonic's inertia greater than $600
		bcs.s	.reset_pan			; if not, recenter the screen (if needed)
		tst.w	obInertia(a0)			; otherwise, check the direction of inertia (by subtracting it from 0)
		bmi.s	.pan_right			; if inertia is negative, pan the screen left
		bra.s	.pan_left			; otherwise, pan the screen right

.pan_right:
		addq.w	#2,d1				; add 2 to the pan value
		cmpi.w	#$E0,d1			; is the pan value greater than 224 pixels?
		bcs.s	.update_pan			; if not, branch
		move.w	#$E0,d1			; otherwise, cap the value at the maximum of 224 pixels
		bra.s	.update_pan			; branch
; ---------------------------------------------------------------------------

.pan_left:
		subq.w	#2,d1				; subtract 2 from the pan value
		cmpi.w	#$60,d1			; is the pan value less than 96 pixels?
		bcc.s	.update_pan			; if not, branch
		move.w	#$60,d1			; otherwise, cap the value at the minimum of 96 pixels
		bra.s	.update_pan			; branch
; ---------------------------------------------------------------------------

.reset_pan:
		cmpi.w	#$A0,d1			; is the pan value 160 pixels?
		beq.s	.update_pan			; if so, branch
		bcc.s	.reset_left			; otherwise, branch if it greater than 160

.reset_right:
		addq.w	#2,d1				; add 2 to the pan value
		bra.s	.update_pan			; branch
; ---------------------------------------------------------------------------

.reset_left:
		subq.w	#2,d1				; subtract 2 from the pan value

.update_pan:
		move.w	d1,(v_camera_pan).w		; update the camera pan value
		rts								; return

; End of function Sonic_PanCamera
