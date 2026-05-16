; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
	if TweakMergedArt
Blk16_TITLE:		incbin	"Enhancements/map16/GHZ.bin"
		even
Gra_Title:			incbin	"artnem/8x8 - GHZ1.bin"	; GHZ primary patterns
		even
		if TweakUncompressedChunkMapping
Blk256_TITLE:		incbin	"Enhancements/map256/GHZ.unc"
		else
Blk256_TITLE:		incbin	"map256/GHZ.bin"
		endif ; if TweakUncompressedChunkMapping
		even
	else
Blk16_TITLE:
	endif ; if TweakMergedArt
; ---------------------------------------------------------------------------
; Green Hill Zone
; ---------------------------------------------------------------------------
Blk16_GHZ:		incbin	"map16/GHZ.bin"
		even
	if TweakMergedArt
Gra_GHZ:	  	incbin	"Enhancements/artnem/8x8 - GHZ.nem"	; GHZ combined patterns
	else
Gra_Title:		incbin	"artnem/8x8 - GHZ1.bin"	; GHZ primary patterns
		even
Gra_GHZ:			incbin	"artnem/8x8 - GHZ2.bin"	; GHZ secondary patterns
	endif ; if TweakMergedArt
		even
	if TweakMergedArt=0
Blk256_TITLE:
	endif ; if TweakMergedArt=0
	if TweakUncompressedChunkMapping
Blk256_GHZ:		incbin	"Enhancements/map256/GHZ.unc"
	else
Blk256_GHZ:		incbin	"map256/GHZ.bin"
	endif ; if TweakUncompressedChunkMapping
		even
; ---------------------------------------------------------------------------
; Labyrinth Zone
; ---------------------------------------------------------------------------
Blk16_LZ:			incbin	"map16/LZ.bin"
		even
Gra_LZ:				incbin	"artnem/8x8 - LZ.bin"	; LZ primary patterns
		even
	if TweakUncompressedChunkMapping
Blk256_LZ:		incbin	"map256/LZ.unc"
	else
Blk256_LZ:		incbin	"map256/LZ.bin"
	endif ; if TweakUncompressedChunkMapping
		even
; ---------------------------------------------------------------------------
; Marble Zone
; ---------------------------------------------------------------------------
Blk16_MZ:			incbin	"map16/MZ.bin"
		even
Gra_MZ:				incbin	"artnem/8x8 - MZ.bin"	; MZ primary patterns
		even
Blk256_MZ:
	if Revision=0
		if TweakUncompressedChunkMapping
							incbin	"map256/MZ.unc"
		else
							incbin	"map256/MZ.bin"
		endif
	else
		if TweakUncompressedChunkMapping
							incbin	"map256/MZ (JP1).unc"
		else
							incbin	"map256/MZ (JP1).bin"
		endif
	endif ; if TweakUncompressedChunkMapping
		even
; ---------------------------------------------------------------------------
; Star Light Zone
; ---------------------------------------------------------------------------
Blk16_SLZ:		incbin	"map16/SLZ.bin"
		even
Gra_SLZ:			incbin	"artnem/8x8 - SLZ.bin"	; SLZ primary patterns
		even
	if TweakUncompressedChunkMapping
Blk256_SLZ:		incbin	"map256/SLZ.unc"
	else
Blk256_SLZ:		incbin	"map256/SLZ.bin"
	endif ; if TweakUncompressedChunkMapping
		even
; ---------------------------------------------------------------------------
; Spring Yard Zone
; ---------------------------------------------------------------------------
Blk16_SYZ:		incbin	"map16/SYZ.bin"
		even
Gra_SYZ:			incbin	"artnem/8x8 - SYZ.bin"	; SYZ primary patterns
		even
	if TweakUncompressedChunkMapping
Blk256_SYZ:		incbin	"map256/SYZ.unc"
	else
Blk256_SYZ:		incbin	"map256/SYZ.bin"
	endif ; if TweakUncompressedChunkMapping
		even
; ---------------------------------------------------------------------------
; Scrap Brain Zone
; ---------------------------------------------------------------------------
Blk16_SBZ:		incbin	"map16/SBZ.bin"
		even
Gra_SBZ:			incbin	"artnem/8x8 - SBZ.bin"	; SBZ primary patterns
		even
Blk256_SBZ:
	if Revision=0
		if TweakUncompressedChunkMapping
							incbin	"map256/SBZ.unc"
		else
							incbin	"map256/SBZ.bin"
		endif
	else
		if TweakUncompressedChunkMapping
							incbin	"map256/SBZ (JP1).unc"
		else
							incbin	"map256/SBZ (JP1).bin"
		endif
	endif ; if TweakUncompressedChunkMapping
		even
