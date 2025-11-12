basla:
        mov     ax,0x7c0
        mov     cx,2
        mov     dx,3
        mov     bx,4
        mov     sp,5
        mov     bp,6
        mov     si,7
        mov     di,8

        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0x1000

;        push    eax
;        push    ecx
;        push    edx
;        push    ebx
        push    esp
;        push    ebp
;        push    esi
;        push    edi
basla2:
        nop
;        call    ax_artir
        jmp     basla2
;
;ax_artir:
;        inc     ax
;        ret