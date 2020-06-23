@SETLOCAL EnableExtensions
@ECHO OFF
@CD /d %~dp0

@SET OUTPUT_PATH=%~1

@IF EXIST "errors.txt" DEL /q "errors.txt" 2>&1
@IF EXIST s1built.bin move /Y s1built.bin s1built.prev.bin >NUL 2>&1

REM Compile ROM
asm68k /k /p /o ae- sonic.asm, s1built.bin >errors.txt, , sonic.lst
@TYPE errors.txt

REM Fix ROM Header
fixheadr.exe s1built.bin

REM Copy ROM to output Folder
@FINDSTR /m "0 error(s)" errors.txt >NUL 2>&1 && IF NOT "%OUTPUT_PATH%"=="" IF EXIST "%OUTPUT_PATH%\" COPY /y s1built.bin "%OUTPUT_PATH%\Sonic 1 (Github).bin" >NUL 2>&1
