
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; DLI interrupt handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqDLI          pha
                txa
                pha

                sta WSYNC

;   determine which partition we are updating
                ldx zpPartition         ; [0:7]
                inc zpPartition

;   colors for this partition
                lda paletteBkgnd-1,X
                sta COLBK
                lda palettePF0,X
                sta COLPF0
                lda palettePF1,X
                sta COLPF1
                lda palettePF2,X
                sta COLPF2

;   charset for this partition
                lda charsets,X
                sta CHBASE

;   horizontal scroll
                lda zpScrollX,X
                sta HSCROL

;   graphic priority
                lda zpPriority,X
                sta PRIOR

;   enable single-line P/M, DMA fetch, wide playfield
                lda #$3F
                sta DMACTL

                pla
                tax
                pla
                rti


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; VBlank interrupt handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqVBlank       cli

;   enable single-line P/M, DMA fetch, narrow playfield
                lda #$3D
                sta DMACTL

                lda #$01
                sta PRIOR

;   initialize all colors
                ldx #$08
_next1          lda zpPalette,X
                sta COLPM0,X

                dex
                bpl _next1

                lda KBCODE
                sta zpLastKeystroke

;   enable DList
                lda zpPtrDLIST
                sta DLISTL
                lda zpPtrDLIST+1
                sta DLISTH

;   cycle PF3 color
                inc RTCLOK+2
                lda RTCLOK+2
                asl
                asl
                and #$F0
                ora #$08
                sta COLPF3

;   reset the DLI partition counter
                lda #$00
                sta zpPartition

                jsr GamePlay
                jsr Animate

                ldx #$02
_next2          lda zpSpr3PosX,X
                beq _1

                inc zpSpr3PosX,X
                beq _1

                inc zpSpr3PosX,X

_1              dex
                bpl _next2

                lda zp94
                beq _2

                dec zp94
                jsr L641B

_2              ldx #$02
_next3          lda paletteMIN,X
                cmp palettePF1,X
                beq _3

                dec palettePF1,X
                dec paletteBkgnd,X

_3              dex
                bpl _next3

                dec zpScrollX+5
                bpl _4

                lda #$03
                sta zpScrollX+5

                inc dlistMain._setAddr6
                bpl _4

                lda #$00
                sta dlistMain._setAddr6

_4              dec zpBD
                bne _5

                lda #$05
                sta zpBD

                dec zpScrollX
                bpl _5

                lda #$03
                sta zpScrollX

                inc dlistMain._setAddr1
                bpl _5

                lda #$00
                sta dlistMain._setAddr1

_5              dec zpBE
                bne _6

                lda #$04
                sta zpBE

                dec zpScrollX+1
                bpl _6

                lda #$03
                sta zpScrollX+1

                inc dlistMain._setAddr2
                bpl _6

                lda #$00
                sta dlistMain._setAddr2

_6              dec zpBF
                bne _7

                lda #$03
                sta zpBF

                dec zpScrollX+2
                bpl _7

                lda #$03
                sta zpScrollX+2

                inc dlistMain._setAddr3
                bpl _7

                lda #$00
                sta dlistMain._setAddr3

_7              dec zpC0
                bne _XIT

                lda #$02
                sta zpC0

                dec zpScrollX+3
                bpl _8

                lda #$03
                sta zpScrollX+3

                inc dlistMain._setAddr4
                bpl _8

                lda #$00
                sta dlistMain._setAddr4

_8              dec zpScrollX+4
                bpl _XIT

                lda #$03
                sta zpScrollX+4

                ldx #$00
_next4          inc dlistMain._setAddr5,X
                lda dlistMain._setAddr5,X
                and #$BF
                sta dlistMain._setAddr5,X
                sta zpDEST
                lda dlistMain._setAddr5+1,X
                sta zpDEST+1

                lda RANDOM
                and #$3F                ; [0:63]
                tay

                lda L668C_64elem,Y
                ldy #$00
                sta (zpDEST),Y
                ldy #$40
                sta (zpDEST),Y

                inx
                inx
                inx
                cpx #$24
                bne _next4

                inc zp94

_XIT            jmp XITVBV
