; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
	if TweakMergedArt=0
Blk16_TITLE:
	else
Blk16_TITLE:		incbin	"map16\GHZ.bin"
		even
Gra_Title:		incbin	"artkos\Recompressed\8x8 - GHZ1.bin"	; GHZ primary patterns
		even
		if TweakUncompressedChunkMapping=0
Blk256_TITLE:		incbin	"map256\GHZ.bin"
		else
Blk256_TITLE:		incbin	"map256\Uncompressed\GHZ.bin"
		endc ; if TweakUncompressedChunkMapping=0
	endc ; if TweakMergedArt>0
; ---------------------------------------------------------------------------
; Green Hill Zone
; ---------------------------------------------------------------------------
Blk16_GHZ:		incbin	"map16\GHZ.bin"
		even
	if TweakMergedArt=0
Gra_Title:		incbin	"artkos\Recompressed\8x8 - GHZ1.bin"	; GHZ primary patterns
		even
Gra_GHZ:			incbin	"artkos\Recompressed\8x8 - GHZ2.bin"	; GHZ secondary patterns
	else
Gra_GHZ:	  	incbin	"artkos\Recompressed\8x8 - GHZ.bin"	; GHZ combined patterns
	endc ; if TweakFastLoading>0
		even
	if TweakMergedArt=0
Blk256_TITLE:
	endc
	if TweakUncompressedChunkMapping=0
Blk256_GHZ:		incbin	"map256\GHZ.bin"
	else
Blk256_GHZ:		incbin	"map256\Uncompressed\GHZ.bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Labyrinth Zone
; ---------------------------------------------------------------------------
Blk16_LZ:			incbin	"map16\LZ.bin"
		even
Gra_LZ:				incbin	"artkos\Recompressed\8x8 - LZ.bin"	; LZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_LZ:		incbin	"map256\LZ.bin"
	else
Blk256_LZ:		incbin	"map256\Uncompressed\LZ.bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Marble Zone
; ---------------------------------------------------------------------------
Blk16_MZ:			incbin	"map16\MZ.bin"
		even
Gra_MZ:				incbin	"artkos\Recompressed\8x8 - MZ.bin"	; MZ primary patterns
		even
Blk256_MZ:
	if Revision=0
		if TweakUncompressedChunkMapping=0
							incbin	"map256\MZ.bin"
		else
							incbin	"map256\Uncompressed\MZ.bin"
		endc
	else
		if TweakUncompressedChunkMapping=0
							incbin	"map256\MZ (JP1).bin"
		else
							incbin	"map256\Uncompressed\MZ (JP1).bin"
		endc
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Star Light Zone
; ---------------------------------------------------------------------------
Blk16_SLZ:		incbin	"map16\SLZ.bin"
		even
Gra_SLZ:			incbin	"artkos\Recompressed\8x8 - SLZ.bin"	; SLZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_SLZ:		incbin	"map256\SLZ.bin"
	else
Blk256_SLZ:		incbin	"map256\Uncompressed\SLZ.bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Spring Yard Zone
; ---------------------------------------------------------------------------
Blk16_SYZ:		incbin	"map16\SYZ.bin"
		even
Gra_SYZ:			incbin	"artkos\Recompressed\8x8 - SYZ.bin"	; SYZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_SYZ:		incbin	"map256\SYZ.bin"
	else
Blk256_SYZ:		incbin	"map256\Uncompressed\SYZ.bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
; ---------------------------------------------------------------------------
; Scrap Brain Zone
; ---------------------------------------------------------------------------
Blk16_SBZ:		incbin	"map16\SBZ.bin"
		even
Gra_SBZ:			incbin	"artkos\Recompressed\8x8 - SBZ.bin"	; SBZ primary patterns
		even
Blk256_SBZ:
	if Revision=0
		if TweakUncompressedChunkMapping=0
							incbin	"map256\SBZ.bin"
		else
							incbin	"map256\Uncompressed\SBZ.bin"
		endc
	else
		if TweakUncompressedChunkMapping=0
							incbin	"map256\SBZ (JP1).bin"
		else
							incbin	"map256\Uncompressed\SBZ (JP1).bin"
		endc
	endc ; if TweakUncompressedChunkMapping=0
		even
