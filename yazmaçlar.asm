use16
ilk_degerler:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0x1000

kod_bolumu:
;        mov     cx,0x10
;        cmp     cl,0x20
;        jb      esit

esit_degil:
;        xor     ax,ax
;        mov     al,'0'
;        jmp     kesme

esit:
;        xor     ax,ax
;        mov     al,'1'


        mov     si,[bx]
        mov     ax,[bx+si]
        mov     bx,[si]
        mov     bp,[bx]
        mov     cx,[di]
        mov     ax,[0x1010]
        mov     dx,0
        mov     ax,10
kesme:
        div     [bolme]

dongu:  jmp     dongu

db1     db      'merhaba'
db2     db      'merhaba'
db3     db      'esit'
db4     db      'esit degil'

db11    db      1
db12    db      2
db13    db      3
db14    db      4
db15    db      5
db16    db      6
db17    db      7
db18    db      8

bolme   dw      3

use32
arge:
        nop
        add     eax,0xabcdef12
        nop


use64
        db      0x99
;        xor     r8,r8

        mov     rax,[r12 + r9]
        db      0x99