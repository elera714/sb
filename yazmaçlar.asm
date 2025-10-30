basla:
        mov     ax,0x10
        mov     bx,0x10
        mov     cx,0x10
        mov     dx,0x10
        mov     si,0x10
        mov     di,0x10
        mov     bp,0x10
        mov     sp,0x10

tekrar:

        dec     ax
        dec     bx
        dec     cx
        dec     dx
        dec     si
        dec     di
        dec     bp
        dec     sp

jmp     tekrar


;mov     cs,ax
;mov     ds,bx
;mov     es,si
;mov     ss,bp
;mov     fs,sp
;mov     gs,di
