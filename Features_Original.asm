; Bug Fixes
; Revision 1 Onwards Fixes the Level Select Order and Holding buttons during the attract mode and ending demo sequences will not cause Sonic to miss jumps. (https://tcrf.net/Sonic_the_Hedgehog_(Genesis)#REV01.2FJapanese_Version)
; Revision 2 Onwards Fixes the Spike Bug

; @TODO unroll when git finish goal
; @TODO fix super peelout bug pushing when beside colidable
; @TODO set the animation for peelout and spindash to maximum
; @TODO find what is slowing down sonic when right is pressed (possibly a scrolling issue)
; @TODO fix bumpers so they put you in the right direction, hitting the bumper thatfaces the pinball bumper is an examble of it flipping you backwards

; @TODO Port Sonic CD Sprites like reverse balancing
; @TODO Port Mega CD BIOS Sprites

; ExtendedMenu Based on http://sonicresearch.org/community/index.php?threads/sonic-1-have-an-option-screen-up-using-the-level-select-and-seperating-the-two.5998/ and https://forums.sonicretro.org/index.php?threads/how-to-convert-sonic-1-level-select-to-ascii.31729/

; Feature
FeatureCentreTitleScreen:						equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-710848
FeatureLevelSelectOnC:							equ 0 ; Press C on the Title Screen to bring up Level Select, 2 for Sonic 2 style level select
FeatureSkipChecksum: 								equ 0 ; Get to the SEGA Logo Faster by removing Security Checksum
FeatureSkipSEGALogo: 								equ 0 ; Press start to Skip SEGA Logo and Sonic Team - Partially Based on https://info.sonicretro.org/SCHG_How-to:Fix_the_SEGA_Sound
FeatureUpdateHeader: 								equ 0 ; Updates the name to fix the spacing and adds a comment to the rom header

; Major Feature
FeatureAirRoll:											equ 0 ; 0 = Off, 1 = Roll when not in Spring Jump Animation, 2 = Roll when going Up from spring Curl into a ball when in a jump like in the GG and NGP Sonic Games - https://info.sonicretro.org/SCHG_How-to:Add_the_Air_Roll/Flying_Spin_Attack
FeatureBetaVictoryAnimation:				equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Restore_the_Beta_Victory_Animation
FeatureElectricShockAnimation:			equ 0 ; When you get hit with Electricity use the Electric Hit Animation
FeatureRestoreMonitorEggman:				equ 0 ; Fixes the Eggman Monitor - Based on https://info.sonicretro.org/SCHG_How-to:Have_a_functional_Eggman_monitor_in_Sonic_1
FeatureRestoreMonitorScubaGear:	  	equ 0 ; Fixes the Scuba Gear Monitor - Based on https://info.sonicretro.org/SCHG_How-to:Set_up_the_Goggle_Monitor_to_work_with_it
FeatureRestoreMonitorSuper:	  	    equ 0 ; Fixes the S Monitor - Based on http://sonicresearch.org/community/index.php?threads/how-to-restore-s-monitor-of-sonic-1.6020/
FeatureSonicCDExtendedCamera:       equ 0 ; Based on http://sonicresearch.org/community/index.php?threads/sonic-1-github-how-to-port-sonic-cds-extended-camera-to-sonic-1.5339/
FeatureUseJapaneseUpdates:					equ 0 ; Any updates exclusive to being played on a japanese console, extra lives are now gained every 50,000 points (if it's played on a Japanese console), and the final boss now awards 1,000 points in defeat.

FeatureSuperPeelout:							  equ 0 ; Based on http://sonicresearch.org/community/index.php?threads/basic-questions-and-answers-thread.1155/page-287#post-84061
FeatureSpindash:										equ 0 ; 0 = Off, 1 = Sonic CD, 2 = Sonic 2 - Based on https://info.sonicretro.org/SCHG_How-to:Add_Spin_Dash_to_Sonic_1/Part_1 and https://info.sonicretro.org/SCHG_How-to:Add_Spin_Dash_to_Sonic_1/Part_2 and https://info.sonicretro.org/SCHG_How-to:Add_Spin_Dash_to_Sonic_1/Part_3 and
TweakSlowDucking:										equ 0 ; For use with Spindash - Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-2#post-955483
																					; https://info.sonicretro.org/SCHG_How-to:Add_Spin_Dash_to_Sonic_1/Part_4 and http://sonicresearch.org/community/index.php?threads/adding-sonic-2s-splash-and-skid-dust-to-sonic-1.5970/
; Tweaks
TweakBetterFadeEffects:							equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Improve_the_fade_in%5Cfade_out_progression_routines_in_Sonic_1 - Also Based on http://sonicresearch.org/community/index.php?threads/fixed-improving-the-fade-to-white-routines.5885/
TweakFastLoadInit:									equ 0 ; Disable Some Initialization to load SEGA Logo Faster
TweakSegaLogoWhiteFade:							equ 0 ; 1 = Initial Fade to White but Black to White every time Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-3#post-960404, 2 = Better Fade From Demos by Cyber Axe and Based on https://info.sonicretro.org/SCHG_How-to:Improve_the_fade_in%5Cfade_out_progression_routines_in_Sonic_1 - Also Based on http://sonicresearch.org/community/index.php?threads/fixed-improving-the-fade-to-white-routines.5885/

BugFixDebugMomentum:                equ 0 ; Based on http://sonicresearch.org/community/index.php?threads/how-to-fix-sonic-1s-debug-mode.5664/#post-84570
BugFixDemoPlayback:									equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_demo_playback
BugFixHiddenPoints:									equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_the_Hidden_Points_bug_in_Sonic_1
BugFixTitleScreenPressStart: 				equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Display_the_Press_Start_Button_text

; ============================================================
BugFixTooFastToLive:								equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-748796
BugFixInvincibilityDelayDeath:			equ 0 ; Fixes being able to be killed after breaking an invincibility monitor before the sparkles appear
BugFixCameraFollow:									equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_the_camera_follow_bug
BugFixSpringFaceWrongDirection:			equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-729566
BugFixWalkJump:											equ 0 ; Set to 1 for fix Based on https://info.sonicretro.org/SCHG_How-to:Fix_the_Walk-Jump_Bug_in_Sonic_1 - Set to 2 for cleaner fix based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-741799

; Bug Fixes Not Inluded in Other Revisions

BugFixPatternLoadCueShifting:				equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/how-to-fix-pattern-load-cues-queue-shifting-bug.28339/
BugFixPatternLoadCueRaceCondition: 	equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_a_race_condition_with_Pattern_Load_Cues
BugFixDeleteScatteredRings:					equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_Accidental_Deletion_of_Scattered_Rings
BugFixScatteredRingsTimer:					equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_Ring_Timers
BugFixDrowningTimer:								equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Correct_Drowning_Bugs_in_Sonic_1
BugFixDeathBoundary:								equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_the_death_boundary_bug
BugFixHurtDeathBoundary:						equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-2#post-838489
BugFixSongFadeRestoration:					equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_Song_Restoration_Bugs_in_Sonic_1%27s_Sound_Driver
BugFixBlinkingHUD:									equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_the_HUD_blinking
BugFixLevelSelectCorruption:				equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_the_Level_Select_graphics_bug
BugFixRememberSprite:								equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_a_remember_sprite_related_bug
BugFixSoundDriverBugs:							equ 0 ; Uncommenting of code in ; Sound_ChkValue:
BugFixCaterkillerDeath:							equ 0 ; Fixes bug that occurs when rolling into a Caterkiller too fast - Based on https://info.sonicretro.org/SCHG_How-to:Add_Spin_Dash_to_Sonic_1/Part_4
BugFixGameOverFlicker:							equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-713108
BugFixFallOffFinalZone:							equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-752258
BugFixRollerGlitch:									equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-2#post-819718
; BugFixHorizontalSpikePole:	  			equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-2#post-826729
BugFixRenderBeforeInit:							equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-2#post-827645
BugFixFZDebugCreditTransition:			equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-2#post-838455
BugFixDrownLockTitleScreen:					equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-3#post-962010


; @todo port from sonic 2 code
BugFixMonitorBugs:									equ 0 ; Based on http://sonicresearch.org/community/index.php?threads/how-to-fix-weird-monitor-collision-errors.5834/

; @TODO Fix Bug when going too fast at ghz 1 slope checkpoint causing death
; @TODO Reset Camera location when entering DEBUG MODE
; @TODO Fix S monitor not doing sped up invinciblity music
; @TODO move debug display over score

; Re-implement 1D Unused Switch
; Bug Fix for Final Zone should be a colission map invisible barrier to prevent fall off

; http://info.sonicretro.org/SCHG_How-to:Port_S3K_Priority_Manager_into_Sonic_2 -- https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-757917
; https://forums.sonicretro.org/index.php?threads/sonic-1-mega-pcm-driver.29057/

; Bug Fixes to add
; https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-716304
; RetroKoH posted about http://sonicresearch.org/forums/index.php?showtopic=3422 what is it?

; @TODO Bugs needing fixed https://info.sonicretro.org/Sonic_the_Hedgehog_(16-bit)/Bugs#General_bugs
; @TODO Fix bug - "Zipping"
; @TODO Fix bug - Missing percussion after 1-Up music (potentially fixed)
; @TODO Fix bug - Life counter can't handle 3-digit numbers
; @TODO Fix bug - Time counter doesn't flash if has at least one ring
; @TODO Fix bug - Continuous invincibility music
; @TODO Fix bug - Marble Zone Duck through solid walls
; @TODO Fix bug - Labyrinth Corrupt bonus graphics
; @TODO Fix bug - Labyrinth Missing signpost
; @TODO Fix bug - Labyrinth 255 lives glitch

; @TODO Recompress https://forums.sonicretro.org/index.php?threads/optimized-kosdec-and-nemdec-considerably-faster-decompression.32235/#post-767170

; @TODO Own Noticed Glitch - Starlight Zone Glitch on Fade In
; @TODO Own Noticed Glitch - Fix bug when you roll into the right of an object like the rocks either side of the bridge in GHZ
; @TODO Own Noticed Glitch - Fix Being able to die after hitting invinciblity monitor before the sparkles appear
; @TODO Own Noticed Glitch - May be specific to the Air Roll however if you press jump just as you hit a sping you dont get the spring sound but still get the spring bonus height and animation

; @TODO implement Spindust properly, implement Sonic 2 Spindash Sound Effect
; @TODO fix Sonic 2 Art Loader / Compression Mode graphic Glitches either caused by QueueDMATransfer or tool that compressed / decompressed the graphics
; @TODO update the Sonic CD style spindash so it is not hovering in the air and so it speeds up
; @TODO Sonic 2 Spin Dash sound rev
; @TODO Prevent Pause Death on End Level Screen and Special Stage

; Features to Add
; @TODO implement Sonic CD Run Charge, but since this is Sonic 1 dont go faster than max run speed and just use regular run animation
; @TODO implement Sonic CD Run Charge with complete Sonic CD style animations and speed
; @TODO implement underwater mask when scuba monitor is active, also remove the scuba flag when hit by enemy make it act like shield
; @TODO implement sonic holding breath when underwater unused sprite
; @TODO implement Sonic JAMs Easy Mode
; @TODO edit Air Roll so you can only roll when falling (more in fitting with the spirit of the game)
; @TODO all possible updates from Sonic Jam

; https://info.sonicretro.org/SCHG_How-to:Port_Flamewing%27s_Sonic_3_%26_Knuckles_Sound_Driver
; https://info.sonicretro.org/SCHG_How-to:Port_Sonic_2_Final_Sound_Driver_to_Sonic_1
; https://info.sonicretro.org/SCHG_How-to:Port_Sonic_3%27s_Sound_Driver_to_Sonic_1 and https://info.sonicretro.org/SCHG_How-to:Port_Sonic_3%27s_Sound_Driver_to_Sonic_1:_Part_2

; https://info.sonicretro.org/SCHG_How-to:Port_Sonic_2_Level_Select_to_Sonic_1

; Possible Features
; Time attack https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-713108
; Turn enemy to rings power https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-758191

; Stuff to Implement for Hacks
; https://info.sonicretro.org/SCHG_How-to:Dynamic_Collision_system_in_Sonic_1
; https://info.sonicretro.org/SCHG_How-to:Dynamic_Special_Stage_Walls_system
; https://info.sonicretro.org/SCHG_How-to:Enigma_Credits_in_Sonic_1
; https://info.sonicretro.org/SCHG_How-to:Expand_the_music_index_from_$94_to_$9F
; https://info.sonicretro.org/SCHG_How-to:Expand_the_music_index_to_start_at_$00_instead_of_$80
; https://info.sonicretro.org/SCHG_How-to:Extend_the_Sonic_1_sprite_mappings_and_art_limit
; https://info.sonicretro.org/SCHG_How-to:Play_different_songs_on_different_acts
; https://info.sonicretro.org/SCHG_How-to:Separate_title_art_from_GHZ/make_GHZ_load_alternate_art
; https://info.sonicretro.org/SCHG_How-to:Sonic_2_(Simon_Wai_Prototype)_Level_Select_in_Sonic_1
; https://info.sonicretro.org/SCHG_How-to:Use_Dynamic_Palettes_in_Sonic_1
; https://info.sonicretro.org/SCHG_How-to:Use_Dynamic_Tilesets_in_Sonic_1

; Left Align the Score


TweakMathOptimizations:							equ 0 ; Replace Maths with Bit Shifts and other CPU GEMs

TweakBetterBonusControlRestore:			equ 0 ; Restore unused Bonus Stage Controls
TweakBetterBonusStageControls:			equ 0 ; Overrides TweakBetterBonusControlRestore - Based on https://info.sonicretro.org/SCHG_How-to:Fix_the_Special_Stage_jumping_physics

TweakFixUnderwaterRingPhysics:			equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Fix_Scattered_Rings_Underwater_Physics
TweakRemoveSpeedCap:								equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Remove_the_Speed_Cap
TweakFixHurtWaterPhystics:					equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Collide_with_water_after_being_hurt
TweakFasterObjectMove:							equ 0 ; Uses the faster Object Code from S3K - Based on https://info.sonicretro.org/SCHG_How-to:Improve_ObjectMove_subroutines

TweakSonic2OffScreenDeletionCode:		equ 0 ; Faster Code from Sonic 2 - Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/page-2#post-941555
TweakFasterRingScatter:							equ 0 ; Faster Scatter - Based on https://forums.sonicretro.org/index.php?threads/updated-speed-up-the-ring-loss-process-even-further-with-underwater.28725/ / https://info.sonicretro.org/SCHG_How-to:Speed_Up_Ring_Loss_Process_%28With_Underwater%29
TweakFasterUnderwaterRings:					equ 0 ; Half the Amount of ring scatter underwater -  - Based on https://forums.sonicretro.org/index.php?threads/updated-speed-up-the-ring-loss-process-even-further-with-underwater.28725/ / https://info.sonicretro.org/SCHG_How-to:Speed_Up_Ring_Loss_Process_%28With_Underwater%29
; TweakUseRecompresedAssets						equ 0 ; All Nemesis files recompressed with KENSharp, all Kos files recompressed with Kosinski+ KENSharp
; TweakExtendSonicAnimationLimit:			equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Extend_the_Sonic_1_sprite_mappings_and_art_limit

; Art and Level Tweaks
TweakSonic2LevelArtLoader:					equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Port_Sonic_2%27s_Level_Art_Loader_to_Sonic_1
; Uncompressed Chunks need fixing
TweakUncompressedChunkMapping:			equ 0 ; Loads chunks from ROM like later games and frees up more ram - Based on https://info.sonicretro.org/SCHG_How-to:Load_chunks_from_ROM_in_Sonic_1
TweakUncompressedTitleCards:				equ 0 ; Uses Faster Level Title Loading Code and Activates TweakLevelCompressionMode - Based on https://forums.sonicretro.org/index.php?threads/s1-considerably-speeding-up-level-loading.33616/

TweakImproovedDecompression:				equ 0 ; Improved Decompression Algorithms - Based on https://forums.sonicretro.org/index.php?threads/optimized-kosdec-and-nemdec-considerably-faster-decompression.32235/
TweakLevelCompressionMode:					equ 0 ; 0 = Original, 1 = Recompressed Original, 2 = Kosinski, 3 = COMPER - Based on https://info.sonicretro.org/SCHG_How-to:Port_Sonic_2%27s_Level_Art_Loader_to_Sonic_1#GitHub
TweakNoWaitingonPLCForLevelTiles:		equ 0 ; Uses Faster Level Title Loading Code and Activates TweakLevelCompressionMode - Based on https://forums.sonicretro.org/index.php?threads/s1-considerably-speeding-up-level-loading.33616/
TweakTitleCompress:									equ 0 ; 0 to Keep using Nemesis Art on the Title Screen

; Casing Graphic Glitches
TweakFastLevelReload:								equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/s1-considerably-speeding-up-level-loading.33616/#post-958087
TweakConsistantLevelSelectClear:    equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-707238

TweakRemoveUselessZ80Commands:      equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/s1-friendly-improved-sonic-2-sound-driver.34249/
TweakNavigationLevelSelect:         equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/s1-friendly-improved-sonic-2-sound-driver.34249/

; @TODO Move Press Start Accordingly too

TweakRemoveReduntantCode:						equ 0 ; Modify Certain Code to Remove Duplicate or Redundant code, should cause some performance improvments by removing junk code left over that is executed - Partially based on https://forums.sonicretro.org/index.php?threads/some-changes-fixes-for-sonic-1.29751/#post-714327

FeatureAnimateWhilePaused:					equ 0 ; Animated Background while paused - Need to fix waterfalls, need to fix HUD, need to test LZ Water
FeatureMusicWhilePaused:						equ 0
FeatureSonicCDPauseRestartLevel:		equ 0 ; Reloads Level like in Sonic CD when you press a button while paused - Based on https://forums.sonicretro.org/index.php?threads/adding-a-cd-style-level-restart-to-sonic-1.37014/

FeatureUseSonic2SoundDriver:        equ 0 ; Based on https://forums.sonicretro.org/index.php?threads/s1-friendly-improved-sonic-2-sound-driver.34249/

; Non Default Features some people may want to use
FeatureRetainRingsBetweenActs:			equ 0 ; Based on https://info.sonicretro.org/SCHG_How-to:Retain_Rings_Between_Acts_in_Sonic_1
FeatureDisableSpecialStageRotation: equ 0 ; Based on http://sonicresearch.org/community/index.php?threads/sonic-1-non-rotating-special-stages.6074/
;BugFixPauseOnSecialStageResults:		equ 0
