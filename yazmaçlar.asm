use16
        jmp     ilk_degerler

        db      0x99
        cluster dw 0x1020
        db      0x99

ilk_degerler:
        mov     ax,0x7c0
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,(0x400-32)

        mov     ax,0x1020
        shr     ax,4
;        popf
;        jc      .odd_cluster

dongu:  jmp     dongu

db1     dw      1
db2     dw      0x1234
db3     db      3
db4     db      4
db5     db      5
db6     db      6
db7     db      7
db8     db      8


;use64
        db      0x99
;        xor     r8,r8

;        movzx   ecx,word[db1]

        mov     eax,0x100

;        mov     rax,[r12 + r9]
        db      0x99