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

i0:
;        mov     bx,[0x1000]
        mov     al,'A'
kesme:

;        mov     ax,[0]

        int     0x10
        inc     ax

;        inc     al
        cmp     al,'Z'
        jz      i0


        jmp     kesme

arge:
        nop
        mov     [0x1010], dword 1
        nop