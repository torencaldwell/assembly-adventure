


.p816
.i16
.a8

.segment "CODE"
.proc   ResetHandler
        sei
        clc
        xce

        lda #$81
        sta $4200

        jmp GameLoop
.endproc

.proc GameLoop
      wai
      jmp GameLoop
.endproc

.proc NMIHandler
      lda $4210
      rti
.endproc


.segment "VECTOR"

.addr $0000, $0000, $1000000
.addr NMIHandler, $0000, $1000000

.word $0000, $0000

.addr $0000, $0000, $0000
.addr $0000, ResetHandler, $0000
