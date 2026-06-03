; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------

enhancedTitleArt:	macro nem,kos,com
		if (TweakTitleCompress)&(TweakLevelCompressionMode=2)
			incbin	\kos
		elseif (TweakTitleCompress)&(TweakLevelCompressionMode>2)
			incbin	\com
		else
			incbin	\nem
		endif ; if TweakTitleCompress
		endm

enhancedLevelArt:	macro nem,kos,com
		if TweakLevelCompressionMode=2
			incbin	\kos
		elseif TweakLevelCompressionMode>2
			incbin	\com
		else
			incbin	\nem
		endif ; if TweakLevelCompressionMode=2
		endm

enhancedChunkMap:	macro compressed,uncompressed
		if TweakUncompressedChunkMapping
			incbin	\uncompressed
		else
			incbin	\compressed
		endif ; if TweakUncompressedChunkMapping
		endm

	if TweakMergedArt
Blk16_TITLE:		incbin	"Enhancements/map16/GHZ.eni"
		even
Gra_Title:		enhancedTitleArt "Enhancements/artnem/8x8 - GHZ1.nem","Enhancements/artkos/8x8 - GHZ1.kosp","Enhancements/artcom/8x8 - GHZ1.comp" ; GHZ primary patterns
		even
Blk256_TITLE:		enhancedChunkMap "Enhancements/map256/GHZ.kos","Enhancements/map256/GHZ.unc"
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
Gra_GHZ:		enhancedLevelArt "Enhancements/artnem/8x8 - GHZ.nem","Enhancements/artkos/8x8 - GHZ.kosp","Enhancements/artcom/8x8 - GHZ.comp" ; GHZ combined patterns
	else
Gra_Title:		incbin	"Enhancements/artnem/8x8 - GHZ1.nem"	; GHZ primary patterns
		even
Gra_GHZ:		enhancedLevelArt "Enhancements/artnem/8x8 - GHZ2.nem","Enhancements/artkos/8x8 - GHZ2.kosp","Enhancements/artcom/8x8 - GHZ2.comp" ; GHZ secondary patterns
	endif ; if TweakMergedArt
		even
	if TweakMergedArt=0
Blk256_TITLE:
	endif ; if TweakMergedArt=0
Blk256_GHZ:		enhancedChunkMap "Enhancements/map256/GHZ.kos","Enhancements/map256/GHZ.unc"
		even
; ---------------------------------------------------------------------------
; Labyrinth Zone
; ---------------------------------------------------------------------------
Blk16_LZ:		incbin	"Enhancements/map16/LZ.eni"
		even
Gra_LZ:			enhancedLevelArt "Enhancements/artnem/8x8 - LZ.nem","Enhancements/artkos/8x8 - LZ.kosp","Enhancements/artcom/8x8 - LZ.comp" ; LZ primary patterns
		even
Blk256_LZ:		enhancedChunkMap "Enhancements/map256/LZ.kos","Enhancements/map256/LZ.unc"
		even
; ---------------------------------------------------------------------------
; Marble Zone
; ---------------------------------------------------------------------------
Blk16_MZ:		incbin	"Enhancements/map16/MZ.eni"
		even
Gra_MZ:			enhancedLevelArt "Enhancements/artnem/8x8 - MZ.nem","Enhancements/artkos/8x8 - MZ.kosp","Enhancements/artcom/8x8 - MZ.comp" ; MZ primary patterns
		even
Blk256_MZ:
	if Revision=0
			enhancedChunkMap "Enhancements/map256/MZ.kos","Enhancements/map256/MZ.unc"
	else
			enhancedChunkMap "Enhancements/map256/MZ (JP1).kos","Enhancements/map256/MZ (JP1).unc"
	endif
		even
; ---------------------------------------------------------------------------
; Star Light Zone
; ---------------------------------------------------------------------------
Blk16_SLZ:		incbin	"Enhancements/map16/SLZ.eni"
		even
Gra_SLZ:		enhancedLevelArt "Enhancements/artnem/8x8 - SLZ.nem","Enhancements/artkos/8x8 - SLZ.kosp","Enhancements/artcom/8x8 - SLZ.comp" ; SLZ primary patterns
		even
Blk256_SLZ:		enhancedChunkMap "Enhancements/map256/SLZ.kos","Enhancements/map256/SLZ.unc"
		even
; ---------------------------------------------------------------------------
; Spring Yard Zone
; ---------------------------------------------------------------------------
Blk16_SYZ:		incbin	"Enhancements/map16/SYZ.eni"
		even
Gra_SYZ:		enhancedLevelArt "Enhancements/artnem/8x8 - SYZ.nem","Enhancements/artkos/8x8 - SYZ.kosp","Enhancements/artcom/8x8 - SYZ.comp" ; SYZ primary patterns
		even
Blk256_SYZ:		enhancedChunkMap "Enhancements/map256/SYZ.kos","Enhancements/map256/SYZ.unc"
		even
; ---------------------------------------------------------------------------
; Scrap Brain Zone
; ---------------------------------------------------------------------------
Blk16_SBZ:		incbin	"Enhancements/map16/SBZ.eni"
		even
Gra_SBZ:		enhancedLevelArt "Enhancements/artnem/8x8 - SBZ.nem","Enhancements/artkos/8x8 - SBZ.kosp","Enhancements/artcom/8x8 - SBZ.comp" ; SBZ primary patterns
		even
Blk256_SBZ:
	if Revision=0
			enhancedChunkMap "Enhancements/map256/SBZ.kos","Enhancements/map256/SBZ.unc"
	else
			enhancedChunkMap "Enhancements/map256/SBZ (JP1).kos","Enhancements/map256/SBZ (JP1).unc"
	endif
		even
