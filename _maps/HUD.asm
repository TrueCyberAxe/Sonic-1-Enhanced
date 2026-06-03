; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_HUD_internal:	mappingsTable
	mappingsTableEntry.w	.allyellow
	mappingsTableEntry.w	.ringred
	mappingsTableEntry.w	.timered
	mappingsTableEntry.w	.allred
	if EnhancedDebug
	mappingsTableEntry.w	.spriteview
	endif ; if EnhancedDebug

.allyellow:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; "SCOR"
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; "E" and first three score digits
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; last four score digits
	
	spritePiece	0, -$70, 4, 2, $10, 0, 0, 0, 1		; "TIME"
	spritePiece	$28, -$70, 4, 2, $28, 0, 0, 0, 1	; time counter
	
	spritePiece	0, -$60, 4, 2, 8, 0, 0, 0, 1		; "RING"
	spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1		; "S"
	spritePiece	$30, -$60, 3, 2, $30, 0, 0, 0, 1	; rings counter
	
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; lives counter (Sonic icon)
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 0, 1	; lives counter ("SONIC x N" text)
.allyellow_End
	even

.ringred:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; "SCOR"
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; "E" and first three score digits
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; last four score digits

	spritePiece	0, -$70, 4, 2, $10, 0, 0, 0, 1		; "TIME"
	spritePiece	$28, -$70, 4, 2, $28, 0, 0, 0, 1	; time counter

	spritePiece	0, -$60, 4, 2, 8, 0, 0, 1, 1		; (red) "RING"
	spritePiece	$20, -$60, 1, 2, 0, 0, 0, 1, 1		; (red) "S"
	spritePiece	$30, -$60, 3, 2, $30, 0, 0, 0, 1	; rings counter

	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; lives counter (Sonic icon)
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 0, 1	; lives counter ("SONIC x N" text)
.ringred_End
	even

.timered:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; "SCOR"
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; "E" and first three score digits
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; last four score digits

	spritePiece	0, -$70, 4, 2, $10, 0, 0, 1, 1		; (red) "TIME"
	spritePiece	$28, -$70, 4, 2, $28, 0, 0, 0, 1	; time counter

	spritePiece	0, -$60, 4, 2, 8, 0, 0, 0, 1		; "RING"
	spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1		; "S"
	spritePiece	$30, -$60, 3, 2, $30, 0, 0, 0, 1	; rings counter

	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; lives counter (Sonic icon)
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 0, 1	; lives counter ("SONIC x N" text)
.timered_End
	even

.allred:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; "SCOR"
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; "E" and first three score digits
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; last four score digits

	spritePiece	0, -$70, 4, 2, $10, 0, 0, 1, 1		; (red) "TIME"
	spritePiece	$28, -$70, 4, 2, $28, 0, 0, 0, 1	; time counter

	spritePiece	0, -$60, 4, 2, 8, 0, 0, 1, 1		; (red) "RING"
	spritePiece	$20, -$60, 1, 2, 0, 0, 0, 1, 1		; (red) "S"
	spritePiece	$30, -$60, 3, 2, $30, 0, 0, 0, 1	; rings counter

	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; lives counter (Sonic icon)
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 0, 1	; lives counter ("SONIC x N" text)
.allred_End
	even

	if EnhancedDebug
.spriteview:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; "SCOR"
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; debug frame category
	spritePiece	$40, -$80, 4, 2, $1C, 0, 0, 0, 1
	spritePiece	$20, -$70, 4, 2, $20, 0, 0, 0, 1	; debug frame subtype
	spritePiece	$40, -$70, 4, 2, $24, 0, 0, 0, 1

	spritePiece	0, -$60, 4, 2, $10, 0, 0, 0, 1	; "TIME"
	spritePiece	$28, -$60, 4, 2, $28, 0, 0, 0, 1	; debug X offset
	spritePiece	$48, -$60, 4, 2, $2C, 0, 0, 0, 1	; debug Y offset

	spritePiece	0, -$50, 4, 2, 8, 0, 0, 0, 1		; "RING"
	spritePiece	$20, -$50, 1, 2, 0, 0, 0, 0, 1		; "S"
	spritePiece	$30, -$50, 4, 2, $30, 0, 0, 0, 1	; debug goggles/flip
.spriteview_End
	even
	endif ; if EnhancedDebug
