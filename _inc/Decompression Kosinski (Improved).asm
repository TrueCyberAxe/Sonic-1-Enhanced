; ===========================================================================
; ---------------------------------------------------------------------------
; Kosinski decompression routine
;
; Created by vladikcomper
; Further optimizations and comments by carljr
; Special thanks to flamewing and MarkeyJester
; ---------------------------------------------------------------------------

_Kos_RunBitStream macro

        dbra    d2,@skip\@

        moveq   #16-1,d2                        ;  4 set bit counter back to 16, minus 1

        ; move.b  (a0)+,d1                        ;  8 -.
        ; move.b  (a4,d1.w),d0                    ; 14  :
        ; lsl.w   #8,d0                           ; 22 -' d0.8-15  <- [a0++] (x-mirror, process left to right)
        ; move.b  (a0)+,d1                        ;  8 -.
        ; move.b  (a4,d1.w),d0                    ; 14 -' d0.0-7   <- [a0++] (x-mirror, process left to right)

        move.b  (a0)+,d1            ;  8
        move.b  (a4,d1.w),(sp)      ; 18
        move.w  (sp),d0             ;  8
        move.b  (a0)+,d1            ;  8
        move.b  (a4,d1.w),d0        ; 14

@skip\@

        endm

; ---------------------------------------------------------------------------

KosDec:

        ; INPUT:
        ;   a0 -> source (compressed data)
        ;   a1 -> destination

        ; TRASHES: a3, d0-d2, d4-d7

        moveq   #7,d7                           ; used to mask bits 0-2 twice below
        moveq   #0,d1                           ; clear bits 8-15 (index into x-mirror table)
        moveq   #-1,d4                          ; used in "dictionary reference long" for displacement
        moveq   #-1,d6                          ; used in "dictionary reference short" for displacement

        lea     KosDec_ByteMap(pc),a4           ;  8 x-mirror table (left to right faster to traverse)

        moveq   #16-1,d2                        ;  4 set bit count to 16, minus 1

        move.b  (a0)+,d1                        ;  8 -.
        move.b  (a4,d1.w),d0                    ; 14  :
        lsl.w   #8,d0                           ; 22 -' d0.8-15  <- [a0++] (x-mirror, process left to right)
        move.b  (a0)+,d1                        ;  8 -.
        move.b  (a4,d1.w),d0                    ; 14 -' d0.0-7   <- [a0++] (x-mirror, process left to right)

        bra.s   KosDec_FetchNewCode             ; 10

KosDec_FetchCodeLoop:

    ; code 1 (uncompressed byte)

        _Kos_RunBitStream

        move.b  (a0)+,(a1)+                     ; move 1 uncompressed byte to destination
KosDec_FetchNewCode:
        add.w   d0,d0                           ;  4 get a bit from the bitstream
        bcs.s   KosDec_FetchCodeLoop            ; 10/8 if code == 1, branch

    ; codes %00 and %01

        _Kos_RunBitStream

        add.w   d0,d0                           ; get a bit from the bitstream
        bcs.s   KosDec_Code_01                  ; if code == %01, "dictionary reference long" / special

        ; if code == %00, "dictionary reference short"; next 2 bits are count, minus 2 (0-3 -> 2-5)

        _Kos_RunBitStream

        moveq   #0,d4                           ; d4 will contain copy count

        add.w   d0,d0                           ;  4 get a bit from the bitstream
        addx.b  d4,d4                           ;  4

        _Kos_RunBitStream

        add.w   d0,d0                           ;  4 get a bit from the bitstream
        addx.b  d4,d4                           ;  4

        _Kos_RunBitStream

        move.b  (a0)+,d6                        ; d6.w = !!!!!!!! DDDDDDDD

        lea     (a1,d6),a3                      ; 12 a3 -> [a1.l + d6.w]
KosDec_StreamCopy:
        move.b  (a3)+,(a1)+                     ; do 1 extra copy (to compensate for +1 to copy counter)
			KosDec_copy:
        move.b  (a3)+,(a1)+
        dbra     d4,KosDec_copy

        bra.s   KosDec_FetchNewCode

; ---------------------------------------------------------------------------

KosDec_Code_01:

        ; code %01 (dictionary reference long / special)

        _Kos_RunBitStream

        move.b  (a0)+,d1                        ;  8 d1.w = ........ LLLLLLLL
        move.b  (a0)+,d4                        ;  8 d4.w = !!!!!!!! HHHHHCCC

        move.w  d4,d5                           ;  4 d5.w = !!!!!!!! HHHHHCCC
        lsl.w   #5,d5                           ; 16      = !!!HHHHH CCC.....
        move.b  d1,d5                           ;  4      = !!!HHHHH LLLLLLLL

        lea     (a1,d5),a3                      ; 12 a3 -> [a1.l + d5.w]

        and.w   d7,d4                           ; d4.w = ........ .....CCC
        bne.s   KosDec_StreamCopy       ; if CCC != 0 (1-7 -> 3-9), branch

        ; if CCC == 0, special mode (extended counter)

        move.b  (a0)+,d4                        ; d4.w <- count_m1 (#/bytes to move, minus 1)

        subq.b  #1,d4                           ;  4   count_m1 <= 1 ?
        bls.s   KosDec_Quit                     ; 10/8 yes, so 0 = quit, 1 = fetch a new code (!)

        move.w  d4,d1                           ;  4 d1.w =      count_m1 - 1
        not.w   d1                              ;  4      =      -1 * count_m1
        and.w   d7,d1                           ;  4      =     (-1 * count_m1) % 8 (isolate lower 3 bits)
        add.w   d1,d1                           ;  4      = 2 * (-1 * count_m1) % 8 (each instruction = 2 bytes)

        lsr.b   #3,d4                           ; 12 d4.w = (count_m1 - 1) / 8

        move.b  (a3)+,(a1)+                     ; 12 do 1 extra copy (to compensate for +1 to copy counter)

        jmp     KosDec_largecopy(pc,d1.w)       ; 12

KosDec_largecopy:

        rept 8
        move.b  (a3)+,(a1)+                     ; 12
        endr
        dbf     d4,KosDec_largecopy
KosDec_Quit:
        bcc.w   KosDec_FetchNewCode             ; 10/12 if count_m1 == 1 fetch a new code (!)

        rts

; ---------------------------------------------------------------------------
; A look-up table to invert bits order in desc. field bytes
; ---------------------------------------------------------------------------

KosDec_ByteMap:

        dc.b    $00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
        dc.b    $08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
        dc.b    $04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
        dc.b    $0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
        dc.b    $02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
        dc.b    $0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
        dc.b    $06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
        dc.b    $0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
        dc.b    $01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
        dc.b    $09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
        dc.b    $05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
        dc.b    $0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
        dc.b    $03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
        dc.b    $0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
        dc.b    $07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
        dc.b    $0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF

; ===========================================================================
