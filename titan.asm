
;----------------------------------------------------
;   Atari 8-bit game: Titan (prototype)
;----------------------------------------------------
;   Provided by: Lee Pappas of A.N.A.L.O.G. Computing
;   Recovered by: Kay Savetz
;   Author: Lee Pappas with Tom Hudson
;----------------------------------------------------


;   memory map
;--------------------------------------
;   [$80:D6]        zero-page

;   [$3000:33FF]    mntns   [charset]
;   [$3400:37FF]    craters [charset]

;   [$5000:53FF]    animat1 [charset]
;   [$5400:57FF]    animat2 [charset]

;   [$6000:60CC]    display list
;   [$60CD:6220]    interrupts
;   [$6221:6536]    titan code
;   [$6537:6729]    titan data

;   screen memory
; - - - - - - - - - - - - - - - - - - -
;   [$3800:3CBF]    saturn  [gfx]
;   [$4000:45FF]    playfield
;   [$4800:4BFF]    mountain range
;   [$606D:60CC]    panel
; - - - - - - - - - - - - - - - - - - -


                .include "equates/system_atari8.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

;--------------------------------------
;--------------------------------------
                * = $6000
;--------------------------------------

                .include "data/dlist.inc"
                .include "interrupts.asm"


;--------------------------------------
;
;--------------------------------------
START           .proc
                jsr SIOINV              ; SIO utility initialization

;   copy [$6542:655D] -> [$B7:D2]
                ldx #$1B
_next1          lda L6542,X
                sta zpB7,X

                dex
                bpl _next1

;   clear the playfield
                lda #$00
                tax
_next2          sta scrnPlayfield,X
                sta scrnPlayfield+$100,X
                sta scrnPlayfield+$200,X
                sta scrnPlayfield+$300,X
                sta scrnPlayfield+$400,X
                sta scrnPlayfield+$500,X
                sta scrnPlayfield+$B00,X
                sta scrnPlayfield+$C00,X
                sta scrnPlayfield+$D00,X
                sta scrnPlayfield+$E00,X
                sta scrnPlayfield+$F00,X

                dex
                bne _next2

;   initialize mountains
_next3          txa
                and #$7F                ; [0:127]... keep within bounds of the charset
                sta scrnMountain,X

                inx
                cpx #$B0
                bne _next3

;   initialize VBlank handler
                ldy #<irqVBlank
                ldx #>irqVBlank
                lda #$06
                jsr SETVBV

;   initialize DLI handler
                lda #<irqDLI
                sta VDSLST
                lda #>irqDLI
                sta VDSLST+1

;   enable VBI+DLI
                lda #$C0
                sta NMIEN

;   initialize the Display List
                lda #<dlistMain
                sta zpPtrDLIST
                lda #>dlistMain
                sta zpPtrDLIST+1

;   initialize Player/Missile graphics
                lda #>$4800
                sta PMBASE

                lda #$03                ; enable P/M
                sta GRACTL

;   initialize
                lda #$00
                sta zpSquadQty
                sta zp94
                sta zp91_r1_3

;   random selections
                lda RANDOM
                and #$1C                ; [0:7]*4+2
                ora #$02
                tay

                ldx #$02
_next4          lda array_7by4,Y             ; 3rd-element
                sta zpA4_3elem,X
                sta zpAD_3elem,X

                dey
                dex
                bpl _next4

;   ???
_next5          ldx #$02
                lda VCOUNT
                lsr                     ; /2
_next6          cmp zpRasterTrigger0,X  ; triggered?
                bne _1                  ;   no

;   raster triggered
                ldy zpSpr0PosX,X
                sty HPOSP0
                sty HPOSP1

                ldy palettePM0,X
                sty COLPM0
                ldy palettePM1,X
                sty COLPM1

_1              cmp zpRasterTrigger1,X  ; triggered?
                bne _2                  ;   no

                ldy zpSpr2PosX,X
                sty HPOSP2

                ldy palettePM2,X
                sty COLPM2

_2              cmp zpRasterTrigger2,X
                bne _3

                ldy zpSpr3PosX,X
                sty HPOSP3

_3              dex
                bpl _next6
                jmp _next5

                .endproc


;======================================
;
;======================================
GamePlay        .proc
                lda TRIG0
                cmp zpPrevTrigger       ; button state changed?
                sta zpPrevTrigger
                bcs _chkJoy             ;   no

;---  ---  ---  ---  ---  ---  ---  ---
;   process trigger action

;   ???
                tax
_next1          sta scrnPlayfield+$F00,X

                inx
                bne _next1

;   ???
                lda #$02
                sta zpDEST

_next2          ldy zpDEST
                lda zp9B_3elem,Y
                tax
                sec
                sbc #$10
                lsr                     ; /4
                lsr
                sta zpRasterTrigger2,Y

;   ???
                lda zpSpr2PosX,Y
                sta zpSpr3PosX,Y

;   ???
                ldy #$0F
_next3          lda L66F1,Y
                sta scrnPlayfield+$F00,X

                dex
                dey
                bpl _next3

                dec zpDEST
                bpl _next2

;---  ---  ---  ---  ---  ---  ---  ---
;   read joystick

_chkJoy         lda PORTA
                ror                     ; UP deflection?
                bcs _2                  ;   no

_joyUP          ldx zpShip0PosY
                cpx #$38                ; Y at upper-limit?
                beq _2                  ;   yes

                inc zpShip0PosY
                inc zpShip1PosY
                inc zpShip2PosY

; - - - - - - - - - - - - - - - - - - -

_2              ror                     ; DOWN deflection?
                bcs _3                  ;   no

_joyDOWN        ldx zpShip0PosY
                cpx #$02
                beq _3

                dec zpShip0PosY
                dec zpShip1PosY
                dec zpShip2PosY

; - - - - - - - - - - - - - - - - - - -

_3              ror                     ; LEFT deflection?
                bcs _4                  ;   no

_joyLEFT        ldx zpC8
                cpx #$AD
                beq _4

                inc zpC8
                inc zpC9
                inc zpCA

; - - - - - - - - - - - - - - - - - - -

_4              ror                     ; RIGHT deflection?
                bcs _5                  ;   no

_joyRIGHT       ldx zpC8
                cpx #$75
                beq _5

                dec zpC8
                dec zpC9
                dec zpCA

;---  ---  ---  ---  ---  ---  ---  ---

_5              lda #$02                ; 2 additional ships
                sta zpSquadQty

_next4          ldx zpSquadQty
                lda #$FF
                eor zpC8,X
                lsr
                lsr

                clc
                tay
                adc zpA4_3elem,X
                sta zpSpr0PosX,X

                tya
                adc zpAD_3elem,X
                sta zpSpr2PosX,X

                lda zpC8,X
                tay
                sec
                sbc #$10
                lsr
                lsr
                sta zpRasterTrigger1,X

                ldx #$0F
_next5          lda L66E5,X
                sta scrnPlayfield+$E00,Y

                dey
                dex
                bpl _next5

;---  ---  ---  ---  ---  ---  ---  ---

;   process ships
                ldx zpSquadQty
                lda zpShip0PosY,X
                lsr
                sta zpDEST

                sec
                lda zpC8,X
                sbc zpDEST
                tay
                sta zp9B_3elem,X

                sec
                sbc #$10
                lsr
                lsr
                sta zpRasterTrigger0,X

                ldx #$0F
_next6          lda L66CC,X
                sta scrnPlayfield+$C00,Y
                lda L66D8,X
                sta scrnPlayfield+$D00,Y

                dey
                dex
                bpl _next6

                dec zpSquadQty
                bpl _next4

                ldx zp91_r1_3
                beq _7

                lda #$02
                sta zpPriority,X

                ldy zp92_r1_127
                ldx #$03
_next7          lda #$3F
                and scrnPlayfield+$B00,Y
                sta scrnPlayfield+$B00,Y

                iny
                dex
                bne _next7

                tya
                ldx zp91_r1_3
                cmp L6537-1,X
                bcs _6

                dey
                sty zp92_r1_127

                ldx #$03
_next8          lda #$C0
                and RANDOM
                ora scrnPlayfield+$B00,Y
                sta scrnPlayfield+$B00,Y

                iny
                dex
                bne _next8

                dec zpMissilePosX
                lda zpMissilePosX
                sta HPOSM3

                rts

_6              lda #$01
                sta zpPriority,X

;   reset ???
                lda #$00
                sta zp91_r1_3

                lda paletteMAX-1,X
                sta palettePF1-1,X
                sta paletteBkgnd-1,X

                rts

_7              lda RANDOM
                and #$7F                ; [0:127]
                bne _XIT

                sta zp92_r1_127         ; [1:127]

                lda RANDOM
                and #$03                ; [0:3]
                beq _XIT

                sta zp91_r1_3           ; [1:3]

                lda RANDOM
                ora #$80
                sta zpMissilePosX

_XIT            rts
                .endproc


;======================================
;
;======================================
L641B           .proc
;   random [1:9]
_next0          lda RANDOM
                and #$0F                ; [0:15]
                beq _next0              ; =0? [ignore]

                cmp #$0A                ; >=10? [ignore]
                bcs _next0

;   push bit0 (even/odd)
                ror
                php

;   set playfield pointers
                clc
                adc dlistMain._setAddr5+1
                sta zpPlayfieldSRC+1
                sta zpPlayfieldDEST+1

                lda dlistMain._setAddr5
                adc #$38                ; +56
                and #$3F                ; clamp[0:63]

;   pop bit0 (even/odd)
                plp
                bcc _1

                ora #$80
_1              sta zpPlayfieldSRC
                ora #$40
                sta zpPlayfieldDEST

;   examine playfield
                ldy #$00
                lda (zpPlayfieldSRC),Y
                ldx #$0C
_next1          cmp L668C_64elem,X      ; match?
                beq _match              ;   yes

                dex
                bpl _next1

                rts

; - - - - - - - - - - - - - - - - - - -

_match          sty zpPreserveRegY

                ldy #$80
                lda (zpPlayfieldSRC),Y
                ldx #$0C
_next2          cmp L668C_64elem,X
                beq _3

                dex
                bpl _next2

                rts

_3              lda RANDOM
                and #$03
                bne _4

                lda #$80
                sta zpPreserveRegY

_4              lda RANDOM
                and #$F8
                tax
                cmp #$70
                bcc _5

                lda #$80
                sta zpPreserveRegY

_5              lda #$02
                sta zpDEST

_next3          ldy #$00
_next4          lda L658C_256elem,X
                beq _6

                ora zpPreserveRegY
                sta (zpPlayfieldSRC),Y
                sta (zpPlayfieldDEST),Y

_6              inx
                iny
                cpy #$04
                bne _next4

                lda zpPlayfieldSRC
                eor #$80
                sta zpPlayfieldSRC

                lda zpPlayfieldDEST
                eor #$80
                sta zpPlayfieldDEST
                bmi _7

                inc zpPlayfieldSRC+1
                inc zpPlayfieldDEST+1

_7              dec zpDEST
                bne _next3

                rts
                .endproc


;======================================
;
;======================================
Animate         .proc
                lda RTCLOK+2            ; jiffy count*16
                asl
                asl
                asl
                asl
                bcc _1

;   initialize SRC pointers
                eor #$F0                ; flip bits in upper-nibble
_1              sta zpAnimSRC1
                sta zpAnimSRC2
                lda #>csetAnim1+$100
                sta zpAnimSRC1+1
                lda #>csetAnim1+$300
                sta zpAnimSRC2+1

;   copy 32 bytes (16 each)
                ldy #$0F
_next1          lda (zpAnimSRC1),Y
                sta csetCraters+$310,Y
                lda (zpAnimSRC2),Y
                sta csetCraters+$300,Y

                dey
                bpl _next1

;   tick
                inc zpAnimTimer
                lda zpAnimTimer
                tax
                and #$01                ; even/odd ticks
                beq _3

; - - - - - - - - - - - - - - - - - - -
;   odd tick (anim all four)

                txa                     ; tick*8
                asl
                asl
                asl
                and #$F0                ; isolate upper-nibble
                bpl _2

;   initialize SRC pointers
                eor #$F0                ; flip bits in upper-nibble
_2              sta zpAnimSRC1
                sta zpAnimSRC2
                ora #$80
                sta zpAnimSRC3
                sta zpAnimSRC4

                lda #>csetAnim1+$200
                sta zpAnimSRC1+1
                lda #>csetAnim1
                sta zpAnimSRC2+1
                lda #>csetAnim1+$200
                sta zpAnimSRC3+1
                lda #>csetAnim1
                sta zpAnimSRC4+1

                ldy #$0F
_next2          lda (zpAnimSRC1),Y
                sta csetCraters+$0C0,Y
                lda (zpAnimSRC2),Y
                sta csetCraters+$1C0,Y
                lda (zpAnimSRC3),Y
                sta csetCraters+$1D0,Y
                lda (zpAnimSRC4),Y
                sta csetCraters+$3D0,Y

                dey
                bpl _next2

                rts

; - - - - - - - - - - - - - - - - - - -
;   even tick (anim only 3&4)

_3              txa                     ; tick*8
                asl
                asl
                asl

;   initialize SRC pointers
                ora #$80
                sta zpAnimSRC3
                sta zpAnimSRC4

                lda #>csetAnim2+$200
                sta zpAnimSRC3+1
                lda #>csetAnim2
                sta zpAnimSRC4+1

                ldy #$0F
_next3          lda (zpAnimSRC3),Y
                sta csetCraters+$3E0,Y
                lda (zpAnimSRC4),Y
                sta csetCraters+$3F0,Y

                dey
                bpl _next3

                rts
                .endproc


;--------------------------------------
;--------------------------------------

L6537           .byte $4A,$54,$60       ; 74,84,96

charsets        .byte >csetMountains
                .byte >csetMountains
                .byte >csetMountains
                .byte >csetMountains
                .byte >csetCraters
                .byte >csetMountains
                .byte >csetAnim2
                .byte >csetAnim2

;   copied to [$B7:D2]
L6542           .byte $0F,$14,$F2,$16,$34,$00               ; [$B7] palette [PM3,PF0,PF1,PF2,PF3,BKGND]
                .byte $05                                   ; [$BD]
                .byte $04                                   ; [$BE]
                .byte $03                                   ; [$BF]
                .byte $02                                   ; [$C0]
                .byte $03,$03,$03,$03,$03,$03,$01,$91,$A1   ; [$C1:C9] zpScrollX
                .byte $B1                                   ; [$CA]
                .byte $06                                   ; [$CB]
                .byte $06                                   ; [$CC]
                .byte $06                                   ; [$CD]
                .byte $01,$01,$01,$01,$02,$04,$00,$00,$00   ; [$CE:D6] zpPriority

paletteBkgnd    .byte $20,$22,$24,$26,$26,$22,$82,$00,$00
palettePF0      .byte $24,$26,$28,$2A,$00,$24,$00,$0A,$00
palettePF1      .byte $20,$22,$24,$26,$34,$22,$00,$38,$00
palettePF2      .byte $34,$34,$34,$34,$34,$34,$34,$5A,$00

paletteMIN      .byte $20,$22,$24
paletteMAX      .byte $29,$2B,$2D

L658C_256elem   .byte $48,$49,$4A,$4B,$08,$09,$0A,$0B,$2C,$2D,$2E,$2F,$6C,$6D,$6E,$6F
                .byte $30,$31,$32,$33,$70,$71,$72,$73,$34,$35,$36,$37,$74,$75,$76,$77
                .byte $44,$45,$46,$47,$04,$05,$06,$07,$4C,$4D,$4E,$00,$00,$0D,$00,$00
                .byte $4F,$50,$51,$52,$00,$10,$11,$00,$15,$16,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$78,$79,$00,$00,$00,$00,$00,$00
                .byte $01,$02,$00,$00,$00,$00,$00,$00,$28,$29,$2A,$2B,$68,$69,$6A,$6B
                .byte $24,$25,$25,$64,$42,$65,$65,$43,$40,$41,$00,$00,$42,$43,$00,$00
                .byte $62,$63,$00,$00,$60,$61,$00,$00,$18,$19,$00,$00,$38,$39,$00,$00
                .byte $1C,$1D,$1E,$1F,$3C,$3D,$3E,$3F,$24,$64,$00,$00,$13,$14,$00,$00
                .byte $3A,$3B,$00,$00,$7A,$7B,$00,$00,$7C,$7D,$00,$00,$7E,$7F,$00,$00
                .byte $24,$64,$00,$00,$42,$43,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

L668C_64elem    .byte $20,$21,$22,$12,$03,$0C,$0E,$55
                .byte $5D,$5E,$5F,$23,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00

L66CC           .byte $00,$00,$00,$20,$30,$38,$1C,$0E,$7F,$FC,$F0,$C0
L66D8           .byte $00,$00,$00,$00,$00,$C0,$E0,$70,$00,$00,$00,$00,$00
L66E5           .byte $00,$00,$00,$20,$30,$38,$7C,$7E,$7F,$FC,$F0,$C0
L66F1           .byte $00,$00,$00,$00,$00,$00,$06,$0F,$0F,$0F,$06,$00,$00,$00,$00,$00

palettePM0      .byte $88,$8A,$88
palettePM1      .byte $04,$84,$04
palettePM2      .byte $00,$00,$00

array_7by4      .byte $32,$3C,$32,$00   ;[0]
                .byte $32,$3C,$46,$00   ;[1]
                .byte $3C,$3C,$3C,$00   ;[2]
                .byte $32,$46,$32,$00   ;[3]
                .byte $46,$3C,$32,$00   ;[4]
                .byte $3C,$32,$3C,$00   ;[5]
                .byte $46,$32,$46,$00   ;[6]
                .byte $3C,$32,$46,$00   ;[7]


;--------------------------------------
;--------------------------------------
                * = $02E0
;--------------------------------------

                .addr START
