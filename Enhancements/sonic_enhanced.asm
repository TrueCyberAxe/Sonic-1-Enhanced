; Bug Fixes, Tweaks and Feature Options Implemented by Cyber Axe
; any code based on the work done by the community is given where possible.

	if Original=1
AdvancedDebugger				equ 0
Debug:          				equ 0 ; Debug Mode Always Enabled
EnhancedDebug:  				equ 0 ; Some Additions Based on Based on http://sonicresearch.org/community/index.php?threads/how-to-fix-sonic-1s-debug-mode.5664/#post-84570
EnhancedDebugMenu: 			equ 0
	else
AdvancedDebugger				equ 1 ; Vladik's Advanced Error Handler and Debugger 2.0
Debug:          				equ 1 ; Debug Mode Always Enabled
EnhancedDebug:  				equ 1 ; Some Additions Based on Based on http://sonicresearch.org/community/index.php?threads/how-to-fix-sonic-1s-debug-mode.5664/#post-84570
EnhancedDebugMenu: 			equ 0
	endc

if Original=1
    include "Features_Original.asm"
else
    include "Features.asm"
endc

; ============================================================================
	if TweakUncompressedChunkMapping>0
TweakMergedArt:											equ 1
	elseif TweakLevelCompressionMode>1
TweakMergedArt:											equ 1
	else
TweakMergedArt:											equ 0
	endc

	if TweakLevelCompressionMode<2
TweakNonNemesisLevelArtLoad: 				equ 0
	elseif TweakSonic2LevelArtLoader=0
TweakNonNemesisLevelArtLoad: 				equ 0
	else
TweakNonNemesisLevelArtLoad: 				equ 1
	endc

	if TweakSonic2LevelArtLoader>0
FeatureEnhancedPLCQueue: 						equ 1
	elseif FeatureSpindash>1
FeatureEnhancedPLCQueue: 						equ 1
	else
FeatureEnhancedPLCQueue: 						equ 1
	endc

	if Revision=0
FeatureEnableUnusedArt: 						equ 1
	elseif Revision>2
FeatureEnableUnusedArt: 						equ 1
	else
FeatureEnableUnusedArt: 						equ 0
	endc

	if (BugFixCameraFollow+FeatureSpindash)>0
FixCameraFollow: 										equ 1
	else
FixCameraFollow: 										equ 0
	endc

	if (BugFixInvincibilityDelayDeath)>0
OptimizeMonitorOrder:								equ 1
	else
OptimizeMonitorOrder: 							equ 0
	endc

	if (FeatureSonicCDExtendedCamera+BugFixCameraFollow)>0
FixCameraFollowBug: 								equ 1
	else
FixCameraFollowBug: 								equ 0
	endc

	if EnhancedDebugMenu>0
ExtendedMenu: 											equ 1
	else
ExtendedMenu: 											equ 0
	endc

	if ExtendedMenu>0
AsciiMenu: 													equ 1
	else
AsciiMenu: 													equ 0
	endc

	if EnhancedDebug>0
ExtendedGameModeArray:							equ 1	;	Based on http://sonicresearch.org/community/index.php?threads/how-to-fix-the-gamemodearray.1983/#post-31703
	else
ExtendedGameModeArray:							equ 0
	endc

	if EnhancedDebug>0
ExtendedLevelSelect:								equ 1
	else
ExtendedLevelSelect:								equ 0
	endc

	if FeatureSpindash>1
SonicExpanded:											equ 1
	else
SonicExpanded:											equ 1
	endc ; if FeatureSpindash>1

	if FeatureSpindash>1
ExtendedSoundEffects:								equ 1
	else
ExtendedSoundEffects:								equ 1
	endc ; if FeatureSpindash>1

