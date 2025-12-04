ilk_degerler:
        mov     ax,0x7c0
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

kesme:

        int     0x10


dongu:  jmp     kesme

db1     db      'merhaba'
db2     db      'merhaba'
db3     db      'esit'
db4     db      'esit degil'

arge:
        nop
        popa
        nop
