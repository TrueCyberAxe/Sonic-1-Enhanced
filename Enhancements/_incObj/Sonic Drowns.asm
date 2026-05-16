; ---------------------------------------------------------------------------
; Sonic when he's drowning
; ---------------------------------------------------------------------------

Sonic_Drowned:
		bsr.w	SpeedToPos			; make Sonic able to move
		addi.w	#$10,y_vel(a0)			; apply gravity
		bsr.w	Sonic_RecordPosition		; record position
		bsr.s	Sonic_Animate			; animate Sonic
		bsr.w	Sonic_LoadGfx			; load Sonic's DPLCs
		bra.w	DisplaySprite			; display Sonic
