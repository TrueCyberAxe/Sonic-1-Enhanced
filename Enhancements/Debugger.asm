
; ===============================================================
; ---------------------------------------------------------------
; Error handling and debugging modules
; 2016-2017, Vladikcomper
; ---------------------------------------------------------------
; Debugging macros definitions file
; ---------------------------------------------------------------


; ===============================================================
; ---------------------------------------------------------------
; Constants
; ---------------------------------------------------------------

; ----------------------------
; Arguments formatting flags
; ----------------------------

; General arguments format flags
hex		equ		$80				; flag to display as hexadecimal number
dec		equ		$90				; flag to display as decimal number
bin		equ		$A0				; flag to display as binary number
sym		equ		$B0				; flag to display as symbol (treat as offset, decode into symbol +displacement, if present)
symdisp	equ		$C0				; flag to display as symbol's displacement alone (DO NOT USE, unless complex formatting is required, see notes below)
str		equ		$D0				; flag to display as string (treat as offset, insert string from that offset)

; NOTES:
;	* By default, the "sym" flag displays both symbol and displacement (e.g.: "Map_Sonic+$2E")
;		In case, you need a different formatting for the displacement part (different text color and such),
;		use "sym|split", so the displacement won't be displayed until symdisp is met
;	* The "symdisp" can only be used after the "sym|split" instance, which decodes offset, otherwise, it'll
;		display a garbage offset.
;	* No other argument format flags (hex, dec, bin, str) are allowed between "sym|split" and "symdisp",
;		otherwise, the "symdisp" results are undefined.
;	* When using "str" flag, the argument should point to string offset that will be inserted.
;		Arguments format flags CAN NOT be used in the string (as no arguments are meant to be here),
;		only console control flags (see below).


; Additional flags ...
; ... for number formatters (hex, dec, bin)
signed	equ		8				; treat number as signed (display + or - before the number depending on sign)

; ... for symbol formatter (sym)
split	equ		8				; DO NOT write displacement (if present), skip and wait for "symdisp" flag to write it later (optional)
forced	equ		4				; display "<unknown>" if symbol was not found, otherwise, plain offset is displayed by the displacement formatter

; ... for symbol displacement formatter (symdisp)
weak	equ		8				; DO NOT write plain offset if symbol is displayed as "<unknown>"

; Argument type flags:
; - DO NOT USE in formatted strings processed by macros, as these are included automatically
; - ONLY USE when writting down strings manually with DC.B
byte	equ		0
word	equ		1
long	equ		3

; -----------------------
; Console control flags
; -----------------------

; Plain control flags: no arguments following
endl	equ		$E0				; "End of line": flag for line break
cr		equ		$E6				; "Carriage return": jump to the beginning of the line
pal0	equ		$E8				; use palette line #0
pal1	equ		$EA				; use palette line #1
pal2	equ		$EC				; use palette line #2
pal3	equ		$EE				; use palette line #3

; Parametrized control flags: followed by 1-byte argument
setw	equ		$F0				; set line width: number of characters before automatic line break
setoff	equ		$F4				; set tile offset: lower byte of base pattern, which points to tile index of ASCII character 00
setpat	equ		$F8				; set tile pattern: high byte of base pattern, which determines palette flags and $100-tile section id
setx	equ		$FA				; set x-position



; ---------------------------------------------------------------
; Macros
; ---------------------------------------------------------------

RaiseError:	macro	string, consoleprogram, opts=0

	pea		*(pc)
	move.w	sr, -(sp)
	__FSTRING_GenerateArgumentsCode string
	jsr		ErrorHandler
	__FSTRING_GenerateDecodedString string
	if strlen("consoleprogram")			; if console program offset is specified ...
		even
		dc.b	opts+_eh_enter_console|_eh_align_offset				; tell Error handler to skip the padding byte, so it'll jump to ...
		dc.b	0
		even
		jmp		consoleprogram										; ... an aligned "jmp" instruction that calls console program itself
	else
		dc.b	opts+0						; otherwise, just specify opts for error handler, +0 will generate dc.b 0 ...
		even								; ... in case \opts argument is empty or skipped
	endif
	even

	endm

; ---------------------------------------------------------------
Console_Write:	macro	string,{INTLABEL}
	move.w	sr,-(sp)
	__FSTRING_GenerateArgumentsCode string
	movem.l	a0-a2/d7,-(sp)
	if (__sp>0)
		lea		4*4(sp),a2
	endif
	lea		__LABEL___str(pc),a1
	jsr		ErrorHandler+$BB4
	movem.l	(sp)+,a0-a2/d7
	if (__sp>8)
		lea		__sp(sp),sp
	elseif (__sp>0)
		addq.w	#__sp,sp
	endif
	move.w	(sp)+,sr
	bra.w	__LABEL___instr_end
__LABEL___str:
	__FSTRING_GenerateDecodedString string
	even
__LABEL___instr_end:
	endm

; ---------------------------------------------------------------
Console_WriteLine:	macro	string,{INTLABEL}
	move.w	sr,-(sp)
	__FSTRING_GenerateArgumentsCode string
	movem.l	a0-a2/d7,-(sp)
	if (__sp>0)
		lea		4*4(sp),a2
	endif
	lea		__LABEL___str(pc),a1
	jsr		ErrorHandler+$BB0
	movem.l	(sp)+,a0-a2/d7
	if (__sp>8)
		lea		__sp(sp),sp
	elseif (__sp>0)
		addq.w	#__sp,sp
	endif
	move.w	(sp)+,sr
	bra.w	__LABEL___instr_end
__LABEL___str:
	__FSTRING_GenerateDecodedString string
	even
__LABEL___instr_end:
	endm

; ---------------------------------------------------------------
Console_Run:	macro	consoleprogram
	jsr		ErrorHandler.__extern__console_only
	jsr		consoleprogram
	bra.s	*
	endm

; ---------------------------------------------------------------
Console_SetXY:	macro	xpos,ypos
	move.w	sr,-(sp)
	movem.l	d0-d1,-(sp)
	move.w	ypos,-(sp)
	move.w	xpos,-(sp)
	jsr		ErrorHandler+$A58
	addq.w	#4,sp
	movem.l	(sp)+,d0-d1
	move.w	(sp)+,sr
	endm

; ---------------------------------------------------------------
Console_BreakLine:	macro
	move.w	sr,-(sp)
	jsr		ErrorHandler+$AAC
	move.w	(sp)+,sr
	endm

; ---------------------------------------------------------------
__ErrorMessage:	macro	string, opts
		__FSTRING_GenerateArgumentsCode string
		jsr		ErrorHandler
		__FSTRING_GenerateDecodedString string
		dc.b	opts+0
		even

	endm

; ---------------------------------------------------------------
__FSTRING_GenerateArgumentsCode:	macro	string

__sp := 0

	endm

; ---------------------------------------------------------------
__FSTRING_GenerateArgumentsCode_Recursive:	macro	string

__pos := strstr(string,"%<")			; token position

	if __pos>=0

		; Retrive expression in brackets following % char
__endrel := strstr(substr(string,__pos+2,strlen(string)-(__pos+2)),">")
		if __endrel<0
			fatal "Unterminated format item"
		endif
__endpos := __pos+2+__endrel
__token := substr(string,__pos+2,__endpos-(__pos+2))
__rest := substr(string,__endpos+1,strlen(string)-(__endpos+1))
		__FSTRING_GenerateArgumentsCode_Recursive __rest
		__FSTRING_GenerateArgument __token
	endif

	endm

; ---------------------------------------------------------------
__FSTRING_GenerateArgument:	macro	token

__type := substr(token,0,2)

	; Expression is an effective address (e.g. %<.w d0 hex> )
	if __type=".b"
__space := strstr(token," ")
__ea := substr(token,__space+1,strlen(token)-(__space+1))
		move.b	__ea,1(sp)
		subq.w	#2,sp
__sp := __sp+2
	elseif __type=".w"
__space := strstr(token," ")
__ea := substr(token,__space+1,strlen(token)-(__space+1))
		move.w	__ea,-(sp)
__sp := __sp+2
	elseif __type=".l"
__space := strstr(token," ")
__ea := substr(token,__space+1,strlen(token)-(__space+1))
		move.l	__ea,-(sp)
__sp := __sp+4
	endif

	endm

; ---------------------------------------------------------------
__FSTRING_GenerateDecodedString:	macro	string

	dc.b	string
	dc.b	0

	endm

; ---------------------------------------------------------------
__FSTRING_GenerateDecodedString_Recursive:	macro	string

__pos := strstr(string,"%<")				; token position

	if __pos>=0

		; Write part of string before % token
__substr := substr(string,0,__pos)
		dc.b	__substr

		; Retrive expression in brackets following % char
__endrel := strstr(substr(string,__pos+2,strlen(string)-(__pos+2)),">")
		if __endrel<0
			fatal "Unterminated format item"
		endif
__endpos := __pos+2+__endrel
__token := substr(string,__pos+2,__endpos-(__pos+2))
		__FSTRING_GenerateDecodedToken __token
__rest := substr(string,__endpos+1,strlen(string)-(__endpos+1))
		__FSTRING_GenerateDecodedString_Recursive __rest
	else
		dc.b	string
	endif

	endm

; ---------------------------------------------------------------
__FSTRING_GenerateDecodedToken:	macro	token

__type := substr(token,0,2)

	; Expression is an effective address (e.g. %<.w d0 hex> )
	if __type=".b"|__type=".w"|__type=".l"
__space := strstr(token," ")
__paramstart := __space+1
__paramrel := strstr(substr(token,__paramstart,strlen(token)-__paramstart)," ")
		if __paramrel>=0
__param := substr(token,__paramstart+__paramrel+1,strlen(token)-(__paramstart+__paramrel+1))
		else
__param := "hex"			; if param is ommited, set it to "hex"
		endif
		if __type=".b"
			dc.b	__param
		elseif __type=".w"
			dc.b	__param|1
		else
			dc.b	__param|3
		endif

	; Expression is an inline constant (e.g. %<endl> )
	else
		dc.b	token
	endif

	endm
