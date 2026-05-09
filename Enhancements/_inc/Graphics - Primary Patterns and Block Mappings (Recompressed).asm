; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
	if TweakMergedArt=0
Blk16_TITLE:
	else
Blk16_TITLE:		incbin	"Enhancements/map16/GHZ.eni"
		even
Gra_Title:			incbin	"Enhancements/artnem/8x8 - GHZ1.nem"	; GHZ primary patterns
		even
		if TweakUncompressedChunkMapping=0
Blk256_TITLE:		incbin	"Enhancements/map256/GHZ.kosp"
		else
Blk256_TITLE:		incbin	"Enhancements/map256/GHZ.unc"
		endc ; if TweakUncompressedChunkMapping=0
		even
	endc ; if TweakMergedArt=0
; ---------------------------------------------------------------------------
; Green Hill Zone
; ---------------------------------------------------------------------------
Blk16_GHZ:		incbin	"Enhancements/map16/GHZ.eni"
		even
	if TweakMergedArt=0
Gra_Title:		incbin	"Enhancements/artnem/8x8 - GHZ1.nem"	; GHZ primary patterns
		even
Gra_GHZ:			incbin	"Enhancements/artnem/8x8 - GHZ2.nem"	; GHZ secondary patterns
	else
Gra_GHZ:	  	incbin	"Enhancements/artnem/8x8 - GHZ.nem"	; GHZ combined patterns
	endc ; if TweakMergedArt=0
		even
	if TweakMergedArt=0
Blk256_TITLE:
	endc ; if TweakMergedArt=0
	if TweakUncompressedChunkMapping=0
Blk256_GHZ:		incbin	"Enhancements/map256/GHZ.kosp"
	else
Blk256_GHZ:		incbin	"Enhancements/map256/GHZ.unc"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Labyrinth Zone
; ---------------------------------------------------------------------------
Blk16_LZ:			incbin	"Enhancements/map16/LZ.eni"
		even
Gra_LZ:				incbin	"Enhancements/artnem/8x8 - LZ.nem"	; LZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_LZ:		incbin	"Enhancements/map256/LZ.kosp"
	else
Blk256_LZ:		incbin	"Enhancements/map256/LZ.unc"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Marble Zone
; ---------------------------------------------------------------------------
Blk16_MZ:			incbin	"Enhancements/map16/MZ.eni"
		even
Gra_MZ:				incbin	"Enhancements/artnem/8x8 - MZ.nem"	; MZ primary patterns
		even
Blk256_MZ:
	if Revision=0
		if TweakUncompressedChunkMapping=0
							incbin	"Enhancements/map256/MZ.kosp"
		else
							incbin	"Enhancements/map256/MZ.unc"
		endc
	else
		if TweakUncompressedChunkMapping=0
							incbin	"Enhancements/map256/MZ (JP1).kosp"
		else
							incbin	"Enhancements/map256/MZ (JP1).unc"
		endc
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Star Light Zone
; ---------------------------------------------------------------------------
Blk16_SLZ:		incbin	"Enhancements/map16/SLZ.eni"
		even
Gra_SLZ:			incbin	"Enhancements/artnem/8x8 - SLZ.nem"	; SLZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_SLZ:		incbin	"Enhancements/map256/SLZ.kosp"
	else
Blk256_SLZ:		incbin	"Enhancements/map256/SLZ.unc"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Spring Yard Zone
; ---------------------------------------------------------------------------
Blk16_SYZ:		incbin	"Enhancements/map16/SYZ.eni"
		even
Gra_SYZ:			incbin	"Enhancements/artnem/8x8 - SYZ.nem"	; SYZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_SYZ:		incbin	"Enhancements/map256/SYZ.kosp"
	else
Blk256_SYZ:		incbin	"Enhancements/map256/SYZ.unc"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Scrap Brain Zone
; ---------------------------------------------------------------------------
Blk16_SBZ:		incbin	"Enhancements/map16/SBZ.eni"
		even
Gra_SBZ:			incbin	"Enhancements/artnem/8x8 - SBZ.nem"	; SBZ primary patterns
		even
Blk256_SBZ:
	if Revision=0
		if TweakUncompressedChunkMapping=0
							incbin	"Enhancements/map256/SBZ.kosp"
		else
							incbin	"Enhancements/map256/SBZ.unc"
		endc
	else
		if TweakUncompressedChunkMapping=0
							incbin	"Enhancements/map256/SBZ (JP1).kosp"
		else
							incbin	"Enhancements/map256/SBZ (JP1).unc"
		endc
	endc ; if TweakUncompressedChunkMapping=0
		even
