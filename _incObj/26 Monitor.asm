; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

Monitor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mon_Index(pc,d0.w),d1
		jmp	Mon_Index(pc,d1.w)
; ===========================================================================
Mon_Index:	dc.w Mon_Main-Mon_Index
		dc.w Mon_Solid-Mon_Index
		dc.w Mon_BreakOpen-Mon_Index
		dc.w Mon_Animate-Mon_Index
		dc.w Mon_Display-Mon_Index
; ===========================================================================

Mon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obHeight(a0)
		move.b	#$E,obWidth(a0)
		move.l	#Map_Monitor,obMap(a0)
		move.w	#ArtTile_Monitor,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#$F,obActWid(a0)
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)								; has monitor been broken?
		beq.s	.notbroken	; if not, branch
	if FixBugBrokenMonitorFall
		move.b	#4,ob2ndRout(a0)				; make broken monitors fall to the floor
		move.b	#9,obAnim(a0)					; set monitor type to broken
		move.b	#$B,obFrame(a0)					; use broken monitor frame
		bra.w	Mon_Solid
	else
		move.b	#8,obRoutine(a0) 					; run "Mon_Display" routine
		move.b	#$B,obFrame(a0)						; use broken monitor frame
		rts
	endif ; if FixBugBrokenMonitorFall
; ===========================================================================

.notbroken:
		move.b	#$46,obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)

Mon_Solid:														; Routine 2
		move.b	ob2ndRout(a0),d0 					; is monitor set to fall?
		beq.s	.normal		; if not, branch
		subq.b	#2,d0
		bne.s	.fall

		; 2nd Routine 2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#sonic_solid_width,d1
		bsr.w	ExitPlatform
		btst	#3,obStatus(a1) 						; is Sonic on top of the monitor?
		bne.w	.ontop		; if yes, branch
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

.ontop:
	if FixBugMonitors 							; Super Transformation Bug when Pushing
		addq.b  #pushing_bit_delta,d6
		btst    d6,status(a0)    					; is Sonic pushing this object?
		beq.s   .skip
		bclr    #is_pushing,status(a1)				; clear 'pushing' bit
		bclr    d6,status(a0)    					; clear object's 'pushing' bit
.skip:
	endif ; if FixBugMonitors
		move.w	#$10,d3
		move.w	obX(a0),d2
		bsr.w	MvSonicOnPtfm
		bra.w	Mon_Animate
; ===========================================================================

.fall:		; 2nd Routine 4
		bsr.w	ObjectFall
		jsr	(ObjFloorDist).l
		tst.w	d1
	if FixBugBrokenMonitorFall
		bmi.s	.hitfloor
		cmpi.b	#9,obAnim(a0)					; is this a broken monitor falling?
		bne.w	Mon_Animate					; if not, branch
		move.b	#$B,obFrame(a0)					; keep the broken monitor frame visible
		bra.w	DisplaySprite
.hitfloor:
	else
		bpl.w	Mon_Animate
	endif ; if FixBugBrokenMonitorFall
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		clr.b	ob2ndRout(a0)
	if FixBugBrokenMonitorFall
		cmpi.b	#9,obAnim(a0)					; is this a broken monitor landing?
		bne.s	.notbrokenfall				; if not, branch
		move.b	#8,obRoutine(a0)				; keep broken monitors display-only after landing
		move.b	#$B,obFrame(a0)					; use broken monitor frame
		bra.w	DisplaySprite
.notbrokenfall:
	endif ; if FixBugBrokenMonitorFall
		bra.w	Mon_Animate
; ===========================================================================

.normal:	; 2nd Routine 0
	if FixBugMonitors 			; Fix Errors on uphill slopes
		btst  #1,obStatus(a0)		; is Sonic standing on object?
		beq.s loc_A25C
	endif
		move.w	#$F+sonic_solid_width,d1
		move.w	#$F,d2
		bsr.w	Mon_SolidSides
		beq.w	loc_A25C
	if FixBugStackedMonitorJumpBreak
		tst.w	d1					; did Sonic hit the monitor from above?
		bpl.s	.notjumpbreak				; if not, branch
		btst	#1,obStatus(a1)				; is Sonic airborne?
		beq.s	.notjumpbreak				; if not, keep normal standing logic
	if (FixBugMonitorHurtBreak)|(FixBugs)
		btst	#2,obStatus(a1)				; is Sonic actually in ball form?
		beq.s	.notjumpbreak				; if not, keep normal standing logic
	endif ; if (FixBugMonitorHurtBreak)|(FixBugs)
		tst.w	obVelY(a1)				; is Sonic already bouncing upwards?
		bmi.s	.keepbounce				; if yes, keep the bounce for stacked monitors
		neg.w	obVelY(a1)				; bounce Sonic as React_Monitor does
.keepbounce:
		bset	#1,obStatus(a1)				; keep Sonic airborne for stacked monitors
		bset	#2,obStatus(a1)				; keep Sonic in ball form for stacked monitors
		move.b	#sonic_roll_height,obHeight(a1)		; keep rolling hitbox after the bounce
		move.b	#sonic_roll_width,obWidth(a1)
		move.b	#id_Roll,obAnim(a1)			; keep rolling animation instead of snapping to stand
		addq.b	#2,obRoutine(a0)			; break this monitor immediately
		bclr	#3,obStatus(a0)				; don't leave standing state on stacked monitors
		bclr	#3,obStatus(a1)
		clr.b	obSolid(a0)
		bra.w	Mon_BreakOpen
.notjumpbreak:
	endif ; if FixBugStackedMonitorJumpBreak
		tst.w	obVelY(a1)
		bmi.s	loc_A20A
	if FeatureSpindash|FixBugEnemyDeathRoll
		btst	#2,obStatus(a1)			; is Sonic rolling or spin-dashing?
		bne.w	Mon_RollBreakSide		; if yes, break the monitor instead of pushing it
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll
		cmpi.b	#id_Roll,obAnim(a1) 			; is Sonic rolling?
	if FeatureSpindash|FixBugEnemyDeathRoll
		beq.w	loc_A25C										; if yes, branch
	else
		beq.s	loc_A25C										; if yes, branch
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll

	if FeatureSpindash
		cmpi.b	#id_Spindash,obAnim(a1)		; is Sonic spin-dashing?
		beq.w	loc_A25C										; if yes, branch
	endif ; if FeatureSpindash

	if FeatureSpindash|FixBugEnemyDeathRoll
		bra.s	loc_A20A				; keep original non-rolling monitor collision
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll

	if FeatureSpindash|FixBugEnemyDeathRoll
Mon_RollBreakSide:
		tst.w	d1				; did Sonic hit the monitor from above?
		bmi.s	.break				; if yes, don't side-correct him
		tst.w	d0				; did Sonic hit from the side?
		beq.s	.break				; if not, branch
		sub.w	d0,obX(a1)			; keep Sonic out of the monitor before it breaks
		move.w	#0,obInertia(a1)		; stop stale side-push momentum
		move.w	#0,obVelX(a1)			; stop stale side-push velocity

.break:
		bclr	#5,obStatus(a0)			; clear object pushing state
		bclr	#5,obStatus(a1)			; clear Sonic pushing state
		bra.w	Mon_BreakOpen			; break the monitor immediately
	endif ; if FeatureSpindash|FixBugEnemyDeathRoll

loc_A20A:
		tst.w	d1
		bpl.s	loc_A220
		sub.w	d3,obY(a1)
		bsr.w	loc_74AE
		move.b	#2,ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

loc_A220:
		tst.w	d0
		beq.w	loc_A246
		bmi.s	loc_A230
		tst.w	obVelX(a1)
		bmi.s	loc_A246
		bra.s	loc_A236
; ===========================================================================

loc_A230:
		tst.w	obVelX(a1)
		bpl.s	loc_A246

loc_A236:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_A246:
		btst	#1,obStatus(a1)
		bne.s	loc_A26A
		bset	#5,obStatus(a1)
		bset	#5,obStatus(a0)
	if FeaturePushableMonitors
		bsr.w	Mon_PushMonitor			; let intact monitors move when pushed
	endif ; if FeaturePushableMonitors
		bra.s	Mon_Animate
; ===========================================================================

loc_A25C:
		btst	#5,obStatus(a0)	; is Sonic pushing?
		beq.s	Mon_Animate	; if not, branch

	if FixBugWalkJump=1
		cmpi.b	#id_Roll,obAnim(a1)				; is Sonic in his jumping/rolling animation?
		if (FixBugs=0)&(FixBugWalkJump<2)
		beq.s	loc_A26A						; if so, branch
		endif
		cmpi.b	#id_Drown,obAnim(a1)			; is Sonic in his drowning animation?
		if (FixBugs=0)&(FixBugWalkJump<2)
		beq.s	loc_A26A						; if so, branch
		endif
	endif

	if (FixBugs=0)&(FixBugWalkJump<2)
		; This causes the infamous "walk-jump bug"
		move.w	#id_Run,obAnim(a1) ; clear obAnim and set obNextAni to 1
	endif

loc_A26A:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)

Mon_Animate:	; Routine 6
		lea	(Ani_Monitor).l,a1
		bsr.w	AnimateSprite

Mon_Display:	; Routine 8
	if (FixBugRenderBeforeInit)|(FixBugs) ; Bug 1
		; Objects shouldn't call DisplaySprite and DeleteObject in
		; the same frame or else cause a null-pointer dereference.
		out_of_range.w	DeleteObject
		bra.w	DisplaySprite
	else
		bsr.w	DisplaySprite
		out_of_range.w	DeleteObject
		rts
	endif
; ===========================================================================

	if FeaturePushableMonitors
; ---------------------------------------------------------------------------
; Move an intact monitor one pixel while Sonic is pushing it. This keeps the
; original monitor break logic intact and only adds a controlled push response.
; ---------------------------------------------------------------------------

Mon_PushMonitor:
		tst.b	obColType(a0)			; is monitor collision still active?
		beq.w	.return				; if not, branch
		btst	#bitPushing,obStatus(a0)	; is Sonic pushing this monitor?
		beq.w	.return				; if not, branch
		btst	#1,obStatus(a1)			; is Sonic airborne?
		bne.w	.return				; if yes, branch
		btst	#2,obStatus(a1)			; is Sonic rolling?
		bne.w	.return				; if yes, keep original roll/break behaviour

		move.w	obX(a0),-(sp)			; save monitor X
		move.w	obY(a0),-(sp)			; save monitor Y
		moveq	#1,d6				; push right by default
		btst	#0,obStatus(a1)			; is Sonic facing left?
		beq.s	.checkright			; if not, branch
		neg.w	d6				; push left
		moveq	#0,d3
		move.b	obActWid(a0),d3			; get monitor width
		not.w	d3				; left-side wall probe
		jsr	(ObjHitWallLeft).l		; would the monitor hit a wall?
		bra.s	.chkwall

.checkright:
		moveq	#0,d3
		move.b	obActWid(a0),d3			; get monitor width
		jsr	(ObjHitWallRight).l		; would the monitor hit a wall?

.chkwall:
		tst.w	d1				; has monitor touched a wall?
		bmi.s	.blocked			; if yes, branch
		add.w	d6,obX(a0)			; move monitor one pixel
		bsr.w	Mon_CheckMonitorObjectBlock	; would monitor overlap another pushed solid?
		bne.s	.blocked			; if yes, branch
		jsr	(ObjFloorDist).l		; find floor below new position
		cmpi.w	#$C,d1				; is floor too far below?
		bgt.s	.blocked			; if yes, branch
		cmpi.w	#-$C,d1				; is step too steep?
		blt.s	.blocked			; if yes, branch
		add.w	d1,obY(a0)			; keep monitor on floor
		lea	(v_player).w,a1			; ObjFloorDist uses a1
		add.w	d6,obX(a1)			; carry Sonic with the push
		move.w	#$40,obInertia(a1)		; keep push animation active
		tst.w	d6				; pushing left?
		bpl.s	.clearspeed			; if not, branch
		neg.w	obInertia(a1)			; use leftward inertia

.clearspeed:
		clr.w	obVelX(a1)			; don't let side collision leave extra speed
		addq.l	#4,sp				; discard saved Y/X
		rts

.blocked:
		move.w	(sp)+,obY(a0)			; restore monitor Y
		move.w	(sp)+,obX(a0)			; restore monitor X
		lea	(v_player).w,a1			; restore Sonic pointer after collision helpers

.return:
		rts

; ---------------------------------------------------------------------------
; Prevent a pushed monitor from being moved into another intact monitor or
; pushable block. Other level walls are handled by the tile collision checks.
; ---------------------------------------------------------------------------

Mon_CheckMonitorObjectBlock:
		movem.l	d0-d3/a1,-(sp)
		lea	(v_lvlobjspace).w,a1
		move.w	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d3

.loop:
		cmpa.l	a0,a1				; is this the current monitor?
		beq.s	.next				; if yes, branch
		move.b	obID(a1),d0			; get object ID
		beq.s	.next				; if not active, branch
		cmpi.b	#id_Monitor,d0			; is this another monitor?
		beq.s	.chkmonitor			; if yes, branch
		cmpi.b	#id_PushBlock,d0		; is this a pushable block?
		bne.s	.next				; if not, branch
		bra.s	.chkoverlap

.chkmonitor:
		tst.b	obColType(a1)			; is other monitor intact?
		beq.s	.next				; if not, branch

.chkoverlap:
		move.w	obY(a1),d0			; get object Y
		sub.w	obY(a0),d0			; compare against monitor Y
		bpl.s	.ypositive			; if positive, branch
		neg.w	d0				; get absolute Y distance

.ypositive:
		cmpi.w	#$1C,d0				; close enough vertically?
		bhi.s	.next				; if not, branch
		move.w	obX(a1),d0			; get object X
		sub.w	obX(a0),d0			; compare against monitor X
		bpl.s	.xpositive			; if positive, branch
		neg.w	d0				; get absolute X distance

.xpositive:
		cmpi.w	#$1C,d0				; close enough horizontally?
		bls.s	.blocked			; if yes, branch

.next:
		lea	object_size(a1),a1		; next object slot
		dbf	d3,.loop			; repeat for all objects
		moveq	#0,d0				; set Z flag for allowed movement
		bra.s	.done

.blocked:
		moveq	#1,d0				; clear Z flag for blocked movement

.done:
		movem.l	(sp)+,d0-d3/a1
		rts
	endif ; if FeaturePushableMonitors

	if FixBugMonitors 							; Spindash Roll to Walk when Spindashing Next to Monitor
Mon_CheckRelease:
		btst d6,obStatus(a0)    					; if we're standing on the object
		beq.s @skip1
		bset #1,obStatus(a1)    					; set 'in air' bit
		bclr #3,obStatus(a1)    					; clear 'should not fall' bit
	@skip1:

		addq.b #pushing_bit_delta,d6
		btst d6,obStatus(a0)    					; if we're pushing against the object
		beq.s @skip2
		bclr #is_pushing,obStatus(a1)     ; clear 'pushing' bit
	@skip2:
		rts
	endif ; if FixBugMonitors

Mon_BreakOpen:	; Routine 4
	if FixBugMonitors 							; Spindash Roll to Walk when Spindashing Next to Monitor
		moveq #p1_standing_bit,d6
		lea (MainCharacter).w,a1
		bsr.s Mon_CheckRelease    				; Release player 1 -  d6 = p1 standing bit, a1 = player 1 address
		moveq #p2_standing_bit,d6
		lea (Sidekick).w,a1
		bsr.s Mon_CheckRelease    				; Release player 2 - d6 = p2 standing bit, a1 = player 2 address
	endif ; if FixBugMonitors
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.s	Mon_Explode
		_move.b	#id_PowerUp,obID(a1) ; load monitor contents object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obAnim(a0),obAnim(a1)

Mon_Explode:
		bsr.w	FindFreeObj
		bne.s	.fail
		_move.b	#id_ExplosionItem,obID(a1) ; load explosion object
		addq.b	#2,obRoutine(a1) 					; don't create an animal
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

.fail:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bset	#0,2(a2,d0.w)
		move.b	#9,obAnim(a0)							; set monitor type to broken
	if FixBugBrokenMonitorFall
		move.b	#2,obRoutine(a0)				; return to Mon_Solid for the fall routine
		move.b	#4,ob2ndRout(a0)				; make the broken monitor fall to the floor
		move.b	#$B,obFrame(a0)					; show the broken monitor frame while it falls
		bra.w	DisplaySprite
	endif ; if FixBugBrokenMonitorFall
		bra.w	DisplaySprite
