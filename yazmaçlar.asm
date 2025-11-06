basla:
        mov     ax,0x10
        mov     bx,0x11
        mov     cx,0x12
        mov     dx,0x13
        mov     si,0x14
        mov     di,0x15
        mov     bp,0x16
        mov     sp,0x17

basla2:
        ;mov     cs,ax
        mov     ds,bx
        mov     es,si
        mov     ss,bp
        mov     fs,sp
        mov     gs,di

        inc     ax
        inc     bx
        inc     cx
        inc     dx
        inc     si
        inc     di
        inc     bp
        inc     sp

        jmp     basla2
