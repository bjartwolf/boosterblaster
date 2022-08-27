
#import "../../lib/zp.asm"
#import "../../lib/io.asm"
#import "../../lib/kernal.asm"

//-----------------------------------------------------------------------------------
:BasicUpstart2(main)

.pc = $fe "Zeropage" virtual
//-----------------------------------------------------------------------------------
src: .word 0

.pc = $0900 "Data"
//-----------------------------------------------------------------------------------
hellotxt:
    .text "HELLO WORLD"
    .byte 13,0


.pc = $0a00 "Main"
//-----------------------------------------------------------------------------------
main: {    
    lda #BLACK
    sta VIC.BORDER
    sta VIC.BACKGROUND 
    jsr KERNAL.CLEAR_SCREEN

    // Simple print using a pointer to a string
    ldx #<hellotxt
    lda #>hellotxt    
    jsr print

    // same as above but using a macro that inserts code
    :PrintPtr(hellotxt)

    // set the X and Y character position on screen using a macro
    :SetPrintXY(5,5)
    :PrintString("HELLO BOOSTER!")

    // and combined macro for both text and position!
    :PrintXY("C64 RULEZ",10,10)

    // but printing using the kernal is slow (uses around 84 raster lines!)
loop:
    lda #100
!:  cmp $d012 // wait for raster to arrive at line 100 on screen
    bne !-
    
    inc VIC.BORDER 
    :PrintXY("KERNAL IS SLOW!",10,10)
    dec VIC.BORDER 
    lda $d012

    jmp loop
}


//-----------------------------------------------------------------------------------
.macro PrintPtr(textptr) {
    ldx #<textptr
    lda #>textptr
    jsr print
}

//-----------------------------------------------------------------------------------
.macro PrintString(text) {
    jmp !+
txt:
    .text text
    .byte 13,0
!:
    :PrintPtr(txt)
}

//-----------------------------------------------------------------------------------
.macro PrintXY(text,x,y) {
    :SetPrintXY(x,y)
    :PrintString(text)
}

//-----------------------------------------------------------------------------------
// Prints on the screen using the Kernal screen function
//-----------------------------------------------------------------------------------
print: {
    stx src
    sta src+1
    ldy #0
loop:
    lda (src),y
    beq end
    jsr KERNAL.CHROUT
    iny
    jmp loop
end:
    rts
}

//-----------------------------------------------------------------------------------
// Uses the KERNAL PLOT function to set cursor X,Y position
//-----------------------------------------------------------------------------------
.macro SetPrintXY(x,y) {
    ldx #x
    ldy #y
    clc // set values
    jsr KERNAL.PLOT
}
