; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
	if TweakMergedArt
Blk16_TITLE:		incbin	"Enhancements/map16/GHZ.eni"
		even
Gra_Title:			incbin	"Enhancements/artnem/8x8 - GHZ1.nem"	; GHZ primary patterns
		even
		if TweakUncompressedChunkMapping
Blk256_TITLE:		incbin	"Enhancements/map256/GHZ.unc"
		else
Blk256_TITLE:		incbin	"Enhancements/map256/GHZ.kosp"
		endif ; if TweakUncompressedChunkMapping
		even
	else
Blk16_TITLE:
	endif ; if TweakMergedArt
; ---------------------------------------------------------------------------
; Green Hill Zone
; ---------------------------------------------------------------------------
Blk16_GHZ:		incbin	"Enhancements/map16/GHZ.eni"
		even
	if TweakMergedArt
Gra_GHZ:	  	incbin	"Enhancements/artnem/8x8 - GHZ.nem"	; GHZ combined patterns
	else
Gra_Title:		incbin	"Enhancements/artnem/8x8 - GHZ1.nem"	; GHZ primary patterns
		even
Gra_GHZ:			incbin	"Enhancements/artnem/8x8 - GHZ2.nem"	; GHZ secondary patterns
	endif ; if TweakMergedArt
		even
	if TweakMergedArt=0
Blk256_TITLE:
	endif ; if TweakMergedArt=0
	if TweakUncompressedChunkMapping
Blk256_GHZ:		incbin	"Enhancements/map256/GHZ.unc"
	else
Blk256_GHZ:		incbin	"Enhancements/map256/GHZ.kosp"
	endif ; if TweakUncompressedChunkMapping
		even
; ---------------------------------------------------------------------------
; Labyrinth Zone
; ---------------------------------------------------------------------------
Blk16_LZ:			incbin	"Enhancements/map16/LZ.eni"
		even
Gra_LZ:				incbin	"Enhancements/artnem/8x8 - LZ.nem"	; LZ primary patterns
		even
	if TweakUncompressedChunkMapping
Blk256_LZ:		incbin	"Enhancements/map256/LZ.unc"
	else
Blk256_LZ:		incbin	"Enhancements/map256/LZ.kosp"
	endif ; if TweakUncompressedChunkMapping
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
		if TweakUncompressedChunkMapping
							incbin	"Enhancements/map256/MZ.unc"
		else
							incbin	"Enhancements/map256/MZ.kosp"
		endif
	else
		if TweakUncompressedChunkMapping
							incbin	"Enhancements/map256/MZ (JP1).unc"
		else
							incbin	"Enhancements/map256/MZ (JP1).kosp"
		endif
	endif ; if TweakUncompressedChunkMapping
		even
; ---------------------------------------------------------------------------
; Star Light Zone
; ---------------------------------------------------------------------------
Blk16_SLZ:		incbin	"Enhancements/map16/SLZ.eni"
		even
Gra_SLZ:			incbin	"Enhancements/artnem/8x8 - SLZ.nem"	; SLZ primary patterns
		even
	if TweakUncompressedChunkMapping
Blk256_SLZ:		incbin	"Enhancements/map256/SLZ.unc"
	else
Blk256_SLZ:		incbin	"Enhancements/map256/SLZ.kosp"
	endif ; if TweakUncompressedChunkMapping
		even
; ---------------------------------------------------------------------------
; Spring Yard Zone
; ---------------------------------------------------------------------------
Blk16_SYZ:		incbin	"Enhancements/map16/SYZ.eni"
		even
Gra_SYZ:			incbin	"Enhancements/artnem/8x8 - SYZ.nem"	; SYZ primary patterns
		even
	if TweakUncompressedChunkMapping
Blk256_SYZ:		incbin	"Enhancements/map256/SYZ.unc"
	else
Blk256_SYZ:		incbin	"Enhancements/map256/SYZ.kosp"
	endif ; if TweakUncompressedChunkMapping
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
		if TweakUncompressedChunkMapping
							incbin	"Enhancements/map256/SBZ.unc"
		else
							incbin	"Enhancements/map256/SBZ.kosp"
		endif
	else
		if TweakUncompressedChunkMapping
							incbin	"Enhancements/map256/SBZ (JP1).unc"
		else
							incbin	"Enhancements/map256/SBZ (JP1).kosp"
		endif
	endif ; if TweakUncompressedChunkMapping
		even
