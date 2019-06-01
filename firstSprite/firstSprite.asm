
;----- Aliases/Labels ----------------------------------------------------------
; these are aliases for the Memory Mapped Registers we will use
INIDISP     = $2100     ; inital settings for screen
OBJSEL      = $2101     ; object size $ object data area designation
OAMADDL     = $2102     ; address for accessing OAM
OAMADDH     = $2103
OAMDATA     = $2104     ; data for OAM write
VMAINC      = $2115     ; VRAM address increment value designation
VMADDL      = $2116     ; address for VRAM read and write
VMADDH      = $2117
VMDATAL     = $2118     ; data for VRAM write
VMDATAH     = $2119     ; data for VRAM write
CGADD       = $2121     ; address for CGRAM read and write
CGDATA      = $2122     ; data for CGRAM write
TM          = $212c     ; main screen designation
NMITIMEN    = $4200     ; enable flaog for v-blank
RDNMI       = $4210     ; read the NMI flag status

.p816

.segment "SPRITEDATA"
SpriteData: .incbin "sprites.rom"
ColorData:  .incbin "palette.rom"

.segment "CODE"

.proc ResetHandler
      sei       ;disable interrupts
      clc       ;clear carry
      xce       ;clear emulation flag
      lda #$8f  ;force v-blanking
      sta INIDISP
      stz NMITIMEN  ;disable NMI

      stz VMADDL    ;set vram address to $0000
      stz VMADDH
      lda #$80
      sta VMAINC    ;increment VRAM address by q when writing to VMDATAH
      ldx #$00      ;set register X to 0 (we will use X as a loop counter and offset)

  VRAMLoop:
      lda SpriteData, X ;load bitplane 0/2 byte into accumulator
      sta VMDATAL       ;write byte in A to VRAMLoop
      inx               ;increment counter/offset (stored in X, remember?)
      lda SpriteData, X ;load bitplane 1/3 byte into accumulator
      sta VMDATAH       ;write accumulator to VRAM
      inx               ;increment counter/offset
      cpx #$80          ; check if we have written $80 bytes to VRAM
      bcc VRAMLoop      ;If X is smaller than $80, continue

      lda #$80
      sta CGADD          ;set CGRAM address to $80
      ldx #$00           ;reset counter/offset

  CGRAMLoop:
      lda ColorData, X    ;get the color low bytes
      sta CGDATA          ;store it in accumulator
      inx
      lda ColorData, X
      sta CGDATA
      inx
      cpx #$20             ;check whether 32/$20 bytes were transferred
      bcc CGRAMLoop

      .byte $42, $00        ;debugger breakpoint

      ;set up OAM data
      stz OAMADDL
      stz OAMADDH
      ;OAM data for first sprite
      lda # (256/2 - 8)     ;horizontal position of first sprites
      sta OAMDATA
      lda # (224/2 - 8)     ;vertical position of first sprite
      sta OAMDATA
      lda #$00              ;name of first sprite
      sta OAMDATA
      lda #$00              ;no flip, priority 0, palette 0
      sta OAMDATA

      lda #$10
      sta TM
      lda #$0f
      sta INIDISP
      lda #$81
      sta NMITIMEN

      jmp GameLoop
.endproc

.proc GameLoop
      wai

      jmp GameLoop
.endproc

.proc NMIHandler
      lda RDNMI
      rti
.endproc

.proc IRQHandler
      rti
.endproc

.segment "VECTOR"

.addr    $0000,       $0000,      $0000
.addr    NMIHandler,  $0000,      $0000
.word    $0000,       $0000
.addr    $0000,       $0000,      $0000
.addr    $0000,       ResetHandler, $0000
