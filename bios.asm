YM_EKRAN_ADDR   equ     0xB800          ; yazý mod ekran adresi

;bios kesmeleri
dw      islevINT00,0
dw      islevINT01,0
dw      islevINT02,0
dw      islevINT03,0
dw      islevINT04,0
dw      islevINT05,0
dw      islevINT06,0
dw      islevINT07,0
dw      islevINT08,0
dw      islevINT09,0
dw      islevINT0A,0
dw      islevINT0B,0
dw      islevINT0C,0
dw      islevINT0D,0
dw      islevINT0E,0
dw      islevINT0F,0
dw      islevINT10,0
dw      islevINT11,0
dw      islevINT12,0
dw      islevINT13,0

islevINT00:
        mov     bx,0
        iret
islevINT01:
        mov     bx,1
        iret
islevINT02:
        mov     bx,2
        iret
islevINT03:
        mov     bx,3
        iret
islevINT04:
        mov     bx,4
        iret
islevINT05:
        mov     bx,5
        iret
islevINT06:
        mov     bx,6
        iret
islevINT07:
        mov     bx,7
        iret
islevINT08:
        mov     bx,8
        iret
islevINT09:
        mov     bx,9
        iret
islevINT0A:
        mov     bx,10
        iret
islevINT0B:
        mov     bx,11
        iret
islevINT0C:
        mov     bx,12
        iret
islevINT0D:
        mov     bx,13
        iret
islevINT0E:
        mov     bx,14
        iret
islevINT0F:
        mov     bx,15
        iret
islevINT10:
        push    es
        push    ax
        push    dx
        push    di
        push    ax
        push    bx

        push    ax
        mov     ax,YM_EKRAN_ADDR
        mov     es,ax

        mov     ax,[gosterge_y]
        imul    ax,80
        mov     di,ax
        mov     ax,[gosterge_x]
        add     di,ax
        imul    di,2

        pop     ax
        mov     [di],al
        inc     di
        mov     al,15
        mov     [di],al

        mov     ax,[gosterge_y]
        mov     bx,ax
        mov     ax,[gosterge_x]
        inc     ax
        cmp     al,80
;        cmp     ax,0x0050      ; 0x83 0xf8 0x50 olarak yorumlanýyor. 0x3d deðil!!
;        db      0x99
        jz      i2
        jmp     i3
i2:
        mov     ax,0
        inc     bx
i3:
        mov     [gosterge_x],ax
        mov     ax,bx
        mov     [gosterge_y],ax

        pop     bx
        pop     ax
        pop     di
        pop     dx
        pop     ax
        pop     es
        iret

gosterge_x      dw      0
gosterge_y      dw      4

islevINT11:
        mov     bx,17
        iret
islevINT12:
        mov     bx,18
        iret
islevINT13:
        stc
        iret
        push    ax
        push    dx

        mov     ax,YM_EKRAN_ADDR
        mov     es,ax

        xor     ax,ax
        xor     di,di
        xor     cx,cx
.tekrar:
        mov     al,'!'
        mov     [di],al
        inc     di
        mov     al,0x4F
        mov     [di],al
        inc     di
;        inc     cx
;        cmp     cx,10
;        je      .hata
;        jmp     .tekrar

.hata:
;        jmp     .hata
        pop     dx
        pop     ax

        stc
        iret

        iret