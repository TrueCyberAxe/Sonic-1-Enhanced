; Bug Fixes, Tweaks and Feature Options Implemented by Cyber Axe
; any code based on the work done by the community is given where possible.

DebugDisableDemoTime:						equ 0
OptimiseSound:							equ 0

    include "Enhancements/Features.asm"

; ============================================================================
	if (TweakUncompressedChunkMapping)|(TweakLevelCompressionMode>1)
TweakMergedArt:								equ 1
	else
TweakMergedArt:								equ 0
	endif

	if (TweakLevelCompressionMode>1)&(TweakS2LevelArtLoader)
TweakNonNemesisLevelArtLoad: 						equ Enhanced
	else
TweakNonNemesisLevelArtLoad: 						equ 0
	endif

	if (TweakS2LevelArtLoader)|(FeatureSpindash>1)
FeatureEnhancedPLCQueue: 						equ 0
	else
FeatureEnhancedPLCQueue: 						equ 0
	endif

	if (Revision=0)|(Revision>2)
FeatureEnableUnusedArt: 						equ 1
	else
FeatureEnableUnusedArt: 						equ Enhanced
	endif

	if (BugFixCameraFollow)|(FeatureSpindash)
FixCameraFollow: 							equ 1
	else
FixCameraFollow: 							equ 0
	endif

	if BugFixInvincibilityDelayDeath
OptimizeMonitorOrder:							equ 1
	else
OptimizeMonitorOrder: 							equ 0
	endif

	if (FeatureSonicCDExtendedCamera)|(BugFixCameraFollow)
FixCameraFollowBug: 							equ 1
	else
FixCameraFollowBug: 							equ 0
	endif

	if EnhancedDebugMenu
ExtendedMenu: 								equ 1
	else
ExtendedMenu: 								equ 0
	endif

	if ExtendedMenu
AsciiMenu: 								equ 1
	else
AsciiMenu: 								equ 0
	endif

	if EnhancedDebug
ExtendedGameModeArray:							equ 1	;	Based on http://sonicresearch.org/community/index.php?threads/how-to-fix-the-gamemodearray.1983/#post-31703
	else
ExtendedGameModeArray:							equ 0
	endif

	if EnhancedDebugMenu
ExtendedLevelSelect:							equ 1
	else
ExtendedLevelSelect:							equ 0
	endif

	if FeatureSpindash>1
SonicExpanded:								equ 1
	else
SonicExpanded:								equ 0
	endif ; if FeatureSpindash>1

	if FeatureSpindash>1
ExtendedSoundEffects:							equ 1
	else
ExtendedSoundEffects:							equ Enhanced
	endif ; if FeatureSpindash>1
