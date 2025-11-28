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
        mov     ax,0xba10
        mov     gs,ax

;        mov     bx,[0x1000]
        mov     al,'A'
        mov     ax,0
        mov     bl,1
kesme:
        add     ax,bx
        jmp     kesme


;        mov     ax,5
;        imul    ax,10

;        db      0x99


;        mov     [0xb800],byte 5
;        mov     [0xb800],byte 5

;        mov     ax,[0]

        int     0x10

        inc     ax
        jmp     kesme

arge:
        nop
        imul    ax,1
        nop