
dlistMain       .block                      ; [219 raster lines]
; - - - - - - - - - - - - - - - - - - -
;   [gfx: gfxSaturn]

                .byte AEMPTY8               ; 12 blank raster lines
                .byte AEMPTY4

                .byte $0E+ALMS              ; 38 gfx raster lines [Saturn image]
                    .addr gfxSaturn
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E+ADLI

; - - - - - - - - - - - - - - - - - - -
;   [charset: csetMountains]

                .byte AEMPTY1               ; 8 blank raster lines

                .byte $04+ADLI+AHSCR+ALMS   ; 32 scrolling raster lines [mountain range]
_setAddr1           .addr scrnMountain+$00
                .byte AEMPTY1

                .byte $04+ADLI+AHSCR+ALMS
_setAddr2           .addr scrnMountain+$0D
                .byte AEMPTY2

                .byte $04+ADLI+AHSCR+ALMS
_setAddr3           .addr scrnMountain+$07
                .byte AEMPTY4

                .byte $04+ADLI+AHSCR+ALMS
_setAddr4           .addr scrnMountain+$17

; - - - - - - - - - - - - - - - - - - -
;   [charset: csetCraters]

                .byte AEMPTY4               ; 4 blank raster lines

                .byte $04+AHSCR+ALMS        ; 96 scrolling raster lines [Playfield]
_setAddr5           .addr scrnPlayfield
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$080
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$100
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$180
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$200
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$280
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$300
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$380
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$400
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$480
                .byte $04+AHSCR+ALMS
                    .addr scrnPlayfield+$500
                .byte $04+ADLI+AHSCR+ALMS
                    .addr scrnPlayfield+$580

; - - - - - - - - - - - - - - - - - - -
;   [charset: csetMountains]

                .byte AEMPTY1               ; 1 blank raster line

                .byte $04+ADLI+AHSCR+ALMS   ; 8 scrolling raster lines [mountain range]
_setAddr6           .addr scrnMountain+$00

; - - - - - - - - - - - - - - - - - - -
;   [charset: csetAnim2]

                .byte AEMPTY1               ; 4 blank raster lines
                .byte AEMPTY1+ADLI
                .byte AEMPTY2

                .byte $04+ALMS              ; 16 raster lines [panel]
                    .addr scrnPanel
                .byte $04

; - - - - - - - - - - - - - - - - - - -

                .byte AVB+AJMP
                    .addr dlistMain

                .endblock

;--------------------------------------

scrnPanel       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF
                .byte $2B,$2C,$2D,$2E,$2F,$4A,$7F           ; SCORE:_
                .byte $40,$41,$47,$44,$49,$45               ; 017495
                .byte $FF,$FF
                .byte $60,$61,$61,$61,$64,$65,$66           ; TITAN
                .byte $FF,$FF
                .byte $30,$31,$32,$33,$34,$0A,$7F           ; SHIPS:_
                .byte $00,$07                               ; 07
                .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

                .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF
                .byte $B8,$B9,$BA,$BB,$8A,$7F,$7F           ; FUEL:__
                .byte $81,$82,$86,$88,$83,$82               ; 126832
                .byte $FF,$FF
                .byte $67,$68,$69,$68,$62,$62,$63           ; TITAN
                .byte $FF,$FF
                .byte $35,$36,$37,$36,$35,$2A,$7F           ; LEVEL:_
                .byte $20,$27                               ; 07
                .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
