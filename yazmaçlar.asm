basla:
        mov     ax,0x100
        mov     bx,0x100
        mov     cx,0x100
        mov     dx,0x100
        mov     si,0x100
        mov     di,0x100
        mov     bp,0x100
        mov     sp,0x100

basla2:
        ;mov     cs,ax
        mov     ds,bx
        mov     es,si
        mov     ss,bp
        mov     fs,sp
        mov     gs,di


        dec     eax
        dec     ebx
        dec     ecx
        dec     edx
        dec     esi
        dec     edi
        dec     ebp
        dec     esp


;        mov     dx,0x50
;        out     dx,ax
;        in      ax,dx

        jmp     basla2
