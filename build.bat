@ECHO OFF

REM // Rename previously successful build if one existed.
IF EXIST s1built.bin move /Y s1built.bin s1built.prev.bin > NUL

REM // Run the ASM68K assembly with the following parameters:
REM //   k  >>  allow use of ifeq, etc.
REM //   m  >>  expand macros in listing file (disabled; this asm68k build crashes with current macros)
REM //   p  >>  produce pure binary output file
REM //   o ___  >>  set assembler options/optimisations:
REM //     ae-  >>  disable automatic even on dc/dcb/ds/rs .w/l
REM //     oz+  >>  enable zero offset optimisation
REM //     c+   >>  enable case sensitivity
REM //     l+   >>  use '.' as leading character for local labels
REM //     ws+  >>  allow white space in operands
REM // 
REM // Files:
REM //   sonic.asm    >>  input assembly file
REM //   s1built.bin  >>  assembled ROM
REM //   [blank]      >>  symbol file (disabled)
REM //   sonic.lst    >>  listing file (disabled; this asm68k build crashes while writing listings)
REM //   sonic.log    >>  console output redirected to log file
"build_tools\asm68k.exe" /k /p /o ae-,oz+,c+,l+,ws+ sonic.asm, s1built.bin > sonic.log

REM // If the assembler crashed, do not leave a zero-byte ROM that emulators
REM // can load as a black screen.
if exist s1built.bin (
    for %%A in (s1built.bin) do if %%~zA EQU 0 (
        del s1built.bin
    )
)

REM // Still print redirected log output to console (Batch doesn't suppport tee).
type sonic.log

REM // Fix checksum (only if output was generated).
if exist s1built.bin (
    "build_tools\fixheadr.exe" s1built.bin
)

REM // If assembly produced warnings or errors, pause here so that the user can read them.
findstr /i /c:"Warning :" /c:"Error :" sonic.log > NUL
if not errorlevel 1 (
    echo.
    pause
)
