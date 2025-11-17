basla:
        mov     ax,0x7c0
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0x1000

        mov     ax,10
        mov     bx,10
        mov     cx,10
        mov     dx,10
;        mov     sp,10
        mov     bp,10
        mov     si,10
        mov     di,10
basla2:
        nop
        call    artir
        nop
        jmp     basla2

        nop
artir:
        inc     ax
        inc     bx
        inc     cx
        inc     dx
;        inc     sp
        inc     bp
        inc     si
        inc     di
        ret
