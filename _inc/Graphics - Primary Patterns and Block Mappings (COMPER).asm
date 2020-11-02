; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
	if TweakMergedArt=0
Blk16_TITLE:
	else
Blk16_TITLE:		incbin	"map16\GHZ.eni"
		even
		if TweakTitleCompress=0
Gra_Title:			incbin	"artnem\8x8 - GHZ1.nem"	; GHZ primary patterns
		else
Gra_Title:			incbin	"artcom\8x8 - GHZ1.comp"	; GHZ primary patterns
		endc
		even
		if TweakUncompressedChunkMapping=0
Blk256_TITLE:		incbin	"map256\GHZ.kosp"
		else
Blk256_TITLE:		incbin	"map256\GHZ.unc"
		endc ; if TweakUncompressedChunkMapping=0
		even
	endc ; if TweakMergedArt=0
; ---------------------------------------------------------------------------
; Green Hill Zone
; ---------------------------------------------------------------------------
Blk16_GHZ:		incbin	"map16\GHZ.eni"
		even
	if TweakMergedArt=0
Gra_Title:		incbin	"artnem\8x8 - GHZ1.nem"	; GHZ primary patterns
		even
Gra_GHZ:			incbin	"artcom\8x8 - GHZ2.comp"	; GHZ secondary patterns
	else
Gra_GHZ:	  	incbin	"artcom\8x8 - GHZ.comp"	; GHZ combined patterns
	endc ; if TweakMergedArt=0
		even
	if TweakMergedArt=0
Blk256_TITLE:
	endc ; if TweakMergedArt=0
	if TweakUncompressedChunkMapping=0
Blk256_GHZ:		incbin	"map256\GHZ.kosp"
	else
Blk256_GHZ:		incbin	"map256\GHZ.unc"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Labyrinth Zone
; ---------------------------------------------------------------------------
Blk16_LZ:			incbin	"map16\LZ.eni"
		even
Gra_LZ:				incbin	"artcom\8x8 - LZ.comp"	; LZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_LZ:		incbin	"map256\LZ.kosp"
	else
Blk256_LZ:		incbin	"map256\LZ.unc"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Marble Zone
; ---------------------------------------------------------------------------
Blk16_MZ:			incbin	"map16\MZ.eni"
		even
Gra_MZ:				incbin	"artcom\8x8 - MZ.comp"	; MZ primary patterns
		even
Blk256_MZ:
	if Revision=0
		if TweakUncompressedChunkMapping=0
							incbin	"map256\MZ.kosp"
		else
							incbin	"map256\MZ.unc"
		endc
	else
		if TweakUncompressedChunkMapping=0
							incbin	"map256\MZ (JP1).kosp"
		else
							incbin	"map256\MZ (JP1).unc"
		endc
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Star Light Zone
; ---------------------------------------------------------------------------
Blk16_SLZ:		incbin	"map16\SLZ.eni"
		even
Gra_SLZ:			incbin	"artcom\8x8 - SLZ.comp"	; SLZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_SLZ:		incbin	"map256\SLZ.kosp"
	else
Blk256_SLZ:		incbin	"map256\SLZ.unc"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Spring Yard Zone
; ---------------------------------------------------------------------------
Blk16_SYZ:		incbin	"map16\SYZ.eni"
		even
Gra_SYZ:			incbin	"artcom\8x8 - SYZ.comp"	; SYZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_SYZ:		incbin	"map256\SYZ.kosp"
	else
Blk256_SYZ:		incbin	"map256\SYZ.unc"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Scrap Brain Zone
; ---------------------------------------------------------------------------
Blk16_SBZ:		incbin	"map16\SBZ.eni"
		even
Gra_SBZ:			incbin	"artcom\8x8 - SBZ.comp"	; SBZ primary patterns
		even
Blk256_SBZ:
	if Revision=0
		if TweakUncompressedChunkMapping=0
							incbin	"map256\SBZ.kosp"
		else
							incbin	"map256\SBZ.unc"
		endc
	else
		if TweakUncompressedChunkMapping=0
							incbin	"map256\SBZ (JP1).kosp"
		else
							incbin	"map256\SBZ (JP1).unc"
		endc
	endc ; if TweakUncompressedChunkMapping=0
		even
