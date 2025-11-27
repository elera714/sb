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
dw      islevINT10,0
dw      islevINT11,0
dw      islevINT12,0
dw      islevINT13,0
dw      islevINT14,0
dw      islevINT15,0
dw      islevINT16,0
dw      islevINT17,0
dw      islevINT18,0
dw      islevINT19,0

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
islevINT10:
        mov     bx,10
        iret
islevINT11:
        mov     bx,11
        iret
islevINT12:
        mov     bx,12
        iret
islevINT13:
        mov     bx,13
        iret
islevINT14:
        mov     bx,14
        iret
islevINT15:
        mov     bx,15
        iret
islevINT16:
        mov     bx,ax
        mov     ax,0xb800
        mov     es,ax
        mov     ax,0
        mov     ax,[adres]
        mov     di,ax
        inc     ax
        inc     ax
        mov     [adres],ax
        mov     ax,bx
        mov     [di],al
        inc     di
        mov     al,15
        mov     [di],al
        iret

adres   dw      0

islevINT17:
        mov     bx,17
        iret
islevINT18:
        mov     bx,18
        iret
islevINT19:
        mov     bx,19
        iret