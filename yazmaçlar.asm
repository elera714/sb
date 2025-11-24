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

kesme:
        mov     ax,0x1234
        int     0x10

        mov     ax,0x99
bekle:
        dec     ax
        test    al,al
        jz      kesme
        jmp     bekle

arge:
        nop
        dec     ax
        nop