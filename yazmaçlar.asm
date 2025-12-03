ilk_degerler:
        mov     ax,0x7c0
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0x1000

kod_bolumu:
        mov     si,db1
        mov     di,db2
        cld
        push    si di
        mov     cx,7
        rep     cmpsb
        pop     di si
        je      esit

esit_degil:
        xor     ax,ax
        mov     al,'0'
        jmp     kesme

esit:
        xor     ax,ax
        mov     al,'1'

kesme:
        int     0x10

dongu:  jmp     dongu

arge:
        nop
        use32
        jmp     0x1010
        nop

db1     db      'merhaba'
db2     db      'merhaba'
db3     db      'esit'
db4     db      'esit degil'