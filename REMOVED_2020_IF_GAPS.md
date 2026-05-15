# 2020 Feature Regression Scan (post-upstream merge)

Compared `55cee6d` (2020-11-09, last 2020 Cyber Axe commit) to current `HEAD` (`886c9d1`) and scanned removed `if`-condition lines.

## Findings: `if` conditions missing an equivalent toggle symbol

1. **`OptimiseSound` conditional removed with no replacement symbol in current tree**
   - Removed location in historical diff: `sound/Sonic 1 Sound Driver.asm` (two `if OptimiseSound=1` guards were deleted during upstream merge cleanup).
   - The symbol definition itself was also removed (`OptimiseSound: equ 0`).
   - Current status: no symbol named `OptimiseSound` exists at `HEAD`.

2. **`Needed` token appears only in comments from removed lines, not as an active conditional feature**
   - Appears in removed comment text (`Needed to display code in ram to create tables`) but has no current `if Needed...` feature flag equivalent.
   - This is not a real feature toggle in 2020 code, just annotation text found in removed hunks.

## Notes

- Most 2020 feature toggles (`Feature*`, `BugFix*`, `Tweak*`, `Enhanced*`) **still exist** in the merged tree, often with renamed files/relocated code.
- The only concrete removed `if`-flag with no modern equivalent found by this scan is **`OptimiseSound`**.
