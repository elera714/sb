basla:
        mov     eax,0x7c0
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
        stc
        call    artir
        clc
        jmp     basla2
artir:
        mov     ax,0x0102
        nop
        test    ax,bx
        nop
        mov     [0],ax
        ;inc     ax
        inc     bx
        inc     cx
        inc     dx
;        inc     sp
        inc     bp
        ;inc     si
        inc     di
        ret

arge:
        nop
        test [ecx],dl
        nop