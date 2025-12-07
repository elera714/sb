use16
ilk_degerler:
        mov     ax,0x7c0
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
;        mov     sp,0x1000

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

;        pusha
;        int     0x10
;        popa

        mov     [db11],8
        mov     [db12],7
        mov     [db13],6
        mov     [db14],5
        mov     [db15],4
        mov     [db16],3
        mov     [db17],2
        mov     [db18],1

        mov     al,[db11]
        mov     cl,[db12]
        mov     dl,[db13]
        mov     bl,[db14]
        mov     ah,[db15]
        mov     ch,[db16]
        mov     dh,[db17]
        mov     bh,[db18]


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
        mov     cl,[arge]
        nop
