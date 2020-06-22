; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
Blk16_GHZ:		incbin	"map16\GHZ.bin"
		even
Gra_Title:		incbin	"artnem\Recompressed\8x8 - GHZ1.bin"	; GHZ primary patterns
		even
	if TweakFastLevelLoading=0
Gra_GHZ:			incbin	"artnem\Recompressed\8x8 - GHZ2.bin"	; GHZ secondary patterns
	else
Gra_GHZ:	  	incbin	"artnem\Recompressed\8x8 - GHZ.bin"	; GHZ combined patterns
	endc ; if TweakFastLoading>0
		even
	if TweakUncompressedChunkMapping=0
Blk256_GHZ:		incbin	"map256\GHZ.bin"
	else
Blk256_GHZ:		incbin	"map256_u\Uncompressed\GHZ.bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
Blk16_LZ:			incbin	"map16\LZ.bin"
		even
Gra_LZ:				incbin	"artnem\Recompressed\8x8 - LZ.bin"	; LZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_LZ:		incbin	"map256\LZ.bin"
	else
Blk256_LZ:		incbin	"map256_u\Uncompressed\LZ.bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
Blk16_MZ:			incbin	"map16\MZ.bin"
		even
Gra_MZ:				incbin	"artnem\Recompressed\8x8 - MZ.bin"	; MZ primary patterns
		even
Blk256_MZ:
	if TweakUncompressedChunkMapping=0 && Revision=0
							incbin	"map256\MZ.bin"
	elseif TweakUncompressedChunkMapping=0 && Revision>0
							incbin	"map256\MZ (JP1).bin"
	elseif TweakUncompressedChunkMapping>0 && Revision=0
							incbin	"map256_u\Uncompressed\MZ.bin"
	else
							incbin	"map256_u\Uncompressed\MZ (JP1).bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
Blk16_SLZ:		incbin	"map16\SLZ.bin"
		even
Gra_SLZ:			incbin	"artnem\Recompressed\8x8 - SLZ.bin"	; SLZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_SLZ:		incbin	"map256\SLZ.bin"
	else
Blk256_SLZ:		incbin	"map256_u\Uncompressed\SLZ.bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
Blk16_SYZ:		incbin	"map16\SYZ.bin"
		even
Gra_SYZ:			incbin	"artnem\Recompressed\8x8 - SYZ.bin"	; SYZ primary patterns
		even
	if TweakUncompressedChunkMapping=0
Blk256_SYZ:		incbin	"map256\SYZ.bin"
	else
Blk256_SYZ:		incbin	"map256_u\Uncompressed\SYZ.bin"
	endc ; if TweakUncompressedChunkMapping=0
		even
Blk16_SBZ:		incbin	"map16\SBZ.bin"
		even
Gra_SBZ:			incbin	"artnem\Recompressed\8x8 - SBZ.bin"	; SBZ primary patterns
		even
Blk256_SBZ:
	if TweakUncompressedChunkMapping=0 && Revision=0
							incbin	"map256\SBZ.bin"
	elseif TweakUncompressedChunkMapping=0 && Revision>0
							incbin	"map256\SBZ (JP1).bin"
	elseif TweakUncompressedChunkMapping>0 && Revision=0
							incbin	"map256_u\Uncompressed\SBZ.bin"
	else
							incbin	"map256_u\Uncompressed\SBZ (JP1).bin"
	endc ; if TweakUncompressedChunkMapping=0 && Revision=0
		even
