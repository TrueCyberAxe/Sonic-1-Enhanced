@SETLOCAL EnableExtensions EnableDelayedExpansion
@ECHO OFF
@CD /d %~DP0

@SET "OUTPUT_PATH=%~1"

@IF EXIST "errors.txt" DEL /q "errors.txt" 2>&1
@IF EXIST s1built.bin move /Y s1built.bin s1built.prev.bin >NUL 2>&1

REM Compile ROM
@REM Echo a Seperator for easier console browsing
@ECHO ==================================================================================
@ECHO  Reference - Checksum: Rev0 = 264A, Rev1 = AFC7, Rev2 = 2F9C - Size 6FEFF / 7FFFF
@ECHO ==================================================================================
asm68k /k /p /o ae- sonic.asm, s1built.bin >errors.txt, , sonic.lst

@REM Echo out Error Log with some Formatting
@ECHO.
SET "ERROR=FALSE"
FOR /F "TOKENS=*" %%A IN (errors.txt) DO IF NOT "%%A"=="" IF NOT "%%A"=="SN 68k version 2.53" IF "%%A"=="Assembly completed." ( @ECHO. ) ELSE ( @ECHO %%~A| FIND /I " error(s)">NUL && ( @ECHO= %%~A ) || ( SET "ERROR=%%~A" & @ECHO= !ERROR:%~DP0=! ) )

IF NOT "%ERROR%"=="FALSE" GOTO :END
@ECHO.
@ECHO ==================================================================================
REM Fix ROM Header
fixheadr.exe s1built.bin

REM Copy ROM to output Folder
IF NOT "%OUTPUT_PATH%"=="" IF EXIST "%OUTPUT_PATH%\" COPY /y s1built.bin "%OUTPUT_PATH%\Sonic 1 (Github).bin" >NUL 2>&1

:END
@ENDLOCAL
