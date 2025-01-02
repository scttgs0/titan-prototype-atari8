
;--------------------------------------
; System equates
;--------------------------------------

FMSZPG          = $0043

MEMLO           = $02E7
DVSTAT          = $02EA

DDEVIC          = $0300
DUNIT           = $0301

DCOMND          = $0302
dcFORMAT    = $21
dcPUT       = $50
dcREAD      = $52
dcSTATUS    = $53
DSTATS          = $0303
dsRECEIVE   = $40
dsSEND      = $80

DBUFLO          = $0304
DBUFHI          = $0305

DTIMLO          = $0306

DBYTLO          = $0308
DBYTHI          = $0309

DAUX1           = $030A
DAUX2           = $030B

DSKINV          = $E453
SIOV            = $E459


;--------------------------------------
; Code equates
;--------------------------------------

L12D6                   = $12D6
retryCount              = $12FF
L1301                   = $1301
L130C                   = $130C
L130D                   = $130D
L1311                   = $1311
L1319                   = $1319
L1329                   = $1329         ; [8-bytes]
L1331                   = $1331         ; [8-bytes]
L1339                   = $1339
L1349                   = $1349


;--------------------------------------
;--------------------------------------
                * = $0700
;--------------------------------------

;   boot record
BFLG            .byte $00
BRCNT           .byte $03
BLDADDR         .word $0700
BINTAD          .word $1540


;--------------------------------------
;
;--------------------------------------
vecSTART        jmp START


;--------------------------------------
;--------------------------------------

L0709           .byte $04
L070A           .byte $03,$00
L070C           .word $1D00

qtySmallSectors .byte $01
startSector     .word $0004             ; [DOS.SYS] sectors [4:46]
sectorDataSize  .byte $7D               ; 125 bytes = 128-3
diskBuf         .word $07CB


;--------------------------------------
;
;--------------------------------------
START           .proc
                ldy qtySmallSectors
                beq _1

;   initialize the disk buffer
                lda diskBuf
                sta FMSZPG
                sta DBUFLO
                lda diskBuf+1
                sta FMSZPG+1
                sta DBUFHI

                lda startSector+1
                ldy startSector
_next1          clc
                ldx qtySmallSectors
                jsr PerformSIO
                bmi _1

                ldy sectorDataSize
                lda (FMSZPG),Y
                and #$03
                pha

                iny
                ora (FMSZPG),Y
                beq _2

                lda (FMSZPG),Y
                tay
                jsr AdvanceBuffers

                pla
                jmp _next1

_1              lda #$C0
                bne _3

_2              pla
_3              asl
                tay

                rts
                .endproc


;======================================
;
;======================================
AdvanceBuffers  .proc
                clc
                lda FMSZPG
                adc sectorDataSize
                sta DBUFLO
                sta FMSZPG

                lda FMSZPG+1
                adc #$00
                sta DBUFHI
                sta FMSZPG+1

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A:Y         sector number
;   X           quantity of small sectors
;======================================
PerformSIO      .proc
                sta DAUX2
                sty DAUX1

                lda #dcREAD
                ldy #dsRECEIVE
                bcc _1

                lda #dcPUT
                ldy #dsSEND
_1              sta DCOMND
                sty DSTATS

                lda #'1'                ; drive "D1:"
                ldy #$0F                ; 15-second timeout
                sta DDEVIC
                sty DTIMLO

                lda #$03
                sta retryCount

                lda #>$0080             ; 128-byte transfer
                ldy #<$0080

                dex                     ; small sector?
                beq _2                  ;   yes

                lda #>$0100             ; 256-byte transfer
                ldy #<$0100
_2              sta DBYTHI
                sty DBYTLO

_next1          jsr SIOV
                bpl _done

                dec retryCount
                bmi _done

;   data-direction = RECEIVE for READ & FORMAT commands... otherwise, use SEND
                ldx #dsRECEIVE
                lda #dcREAD
                cmp DCOMND
                beq _3

                lda #dcFORMAT
                cmp DCOMND
                beq _3

                ldx #dsSEND
_3              stx DSTATS

                jmp _next1

_done           ldx L1301
                lda DSTATS
                rts
                .endproc


;--------------------------------------
;--------------------------------------
;   disk buffer load address
;   content will get overwritten

L07CB           .byte $AA,$08,$14,$0B
                .byte $BE,$0A,$CB,$09
                .byte $00,$0B,$A6,$0B
                .byte $07,$85,$44


;--------------------------------------
;--------------------------------------
L07DA           lda L070A
                sta L12D6

                lda L070C
                sta FMSZPG
                lda L070C+1
                sta FMSZPG+1

                lda L070A
                sta L130C

                ldx #$07
_next1          stx L130D

                asl L130C
                bcs _1

                lda #$00
                sta L1311,X
                sta L1329,X
                sta L1331,X
                beq _3

_1              ldy #$05
                lda #$00
                sta (FMSZPG),Y

                inx
                stx DUNIT

                lda #dcSTATUS
                sta DCOMND

                jsr DSKINV

                ldy #$02
                lda DVSTAT
                and #$20
                bne _2

                dey
_2              tya
                ldx L130D
                sta L1311,X

                lda FMSZPG
                sta L1329,X
                lda FMSZPG+1
                sta L1331,X

                jsr AdvanceSectorBuf

                dey
                beq _3

                jsr AdvanceSectorBuf

_3              dex
                bpl _next1

                ldy L0709
                ldx #$00
_next2          lda #$00

                dey
                bpl _4

                tya
_4              sta L1319,X

                tya
                bmi _5

                lda FMSZPG
                sta L1339,X
                lda FMSZPG+1
                sta L1349,X

                jsr AdvanceSectorBuf

_5              inx
                cpx #$10
                bne _next2

                lda FMSZPG
                sta MEMLO
                lda FMSZPG+1
                sta MEMLO+1

                jmp L087E


;======================================
;
;======================================
AdvanceSectorBuf .proc
                clc
                lda FMSZPG
                adc #<$0080
                sta FMSZPG
                lda FMSZPG+1
                adc #>$0080
                sta FMSZPG+1

                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
L087E           ldy #$7F
