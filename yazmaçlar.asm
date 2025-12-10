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


        add     si,[bx]
        add     ax,[bx+si]
        add     bx,[si]
        add     bp,[bx]
        add     cx,[di]
        add     ax,[0x1010]
kesme:



;        pusha
;        int     0x10
;        popa


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

arge:
        nop
        mov     ax,[si]
        nop
