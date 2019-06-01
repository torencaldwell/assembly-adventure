.p816
.i16
.a8

.segment "CODE"

coins = $0010
lives = $0011

.proc   ResetHandler
        sei
        clc
        xce

        lda #$81
        sta $4200

        lda #$00   ;load 0 in the accumulator
        sta coins  ;store A in coins
        lda #$03   ;load 3 in the accumulator
        sta lives  ;store A in lives

        jmp GameLoop  ;start the game loop
.endproc

.proc GameLoop
      clc          ;start out with a clear carry flag
      lda coins    ;load the value in coins
      cmp #100     ;compare it to 100
      bcc FindCoin ;add a coin if it is < 100

      lda lives    ;load lives into accumulator
      adc #$01     ;add 1 with carry
      sta lives

      lda #$00     ;load 0 into accumulator
      sta coins    ;store it in coins



      jmp GameLoop ;loop back
.endproc

.proc FindCoin
      lda coins   ;load coins into accumulator
      adc #$01    ;add 1 with carry
      sta coins   ;store coins
      jmp GameLoop
.endproc


.segment "VECTOR"

.addr $0000, $0000, $1000000

.word $0000, $0000

.addr $0000, $0000, $0000
.addr $0000, ResetHandler, $0000
