; ---------------------------------------------------------------------------
; Sprite mappings - water splash (LZ)
; ---------------------------------------------------------------------------
Map_Splash_internal:	mappingsTable
	mappingsTableEntry.w	.splash1
	mappingsTableEntry.w	.splash2
	mappingsTableEntry.w	.splash3

.splash1:	spriteHeader
	spritePiece	-8, -$E, 2, 1, $6D, 0, 0, 0, 0
	spritePiece	-$10, -6, 4, 1, $6F, 0, 0, 0, 0
.splash1_End

.splash2:	spriteHeader
	spritePiece	-8, -$1E, 1, 1, $73, 0, 0, 0, 0
	spritePiece	-$10, -$16, 4, 3, $74, 0, 0, 0, 0
.splash2_End

.splash3:	spriteHeader
	spritePiece	-$10, -$1E, 4, 4, $80, 0, 0, 0, 0
.splash3_End

	if FeatureLavaSplash
; Lava splashes use extracted splash-only art, so the mapping tile IDs are
; relative to ArtTile_MZ_Lava_Splash instead of the original LZ splash base.
Map_LavaSplash:	mappingsTable
	mappingsTableEntry.w	.lava_splash1
	mappingsTableEntry.w	.lava_splash2
	mappingsTableEntry.w	.lava_splash3

.lava_splash1:	spriteHeader
	spritePiece	-8, -$E, 2, 1, 0, 0, 0, 0, 0
	spritePiece	-$10, -6, 4, 1, 2, 0, 0, 0, 0
.lava_splash1_End

.lava_splash2:	spriteHeader
	spritePiece	-8, -$1E, 1, 1, 6, 0, 0, 0, 0
	spritePiece	-$10, -$16, 4, 3, 7, 0, 0, 0, 0
.lava_splash2_End

.lava_splash3:	spriteHeader
	spritePiece	-$10, -$1E, 4, 4, $13, 0, 0, 0, 0
.lava_splash3_End
	endif ; if FeatureLavaSplash

	even
