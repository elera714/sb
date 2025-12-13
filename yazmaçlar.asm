use16
ilk_degerler:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0x1000

kod_bolumu:
        mov     si,db1
        mov     ax,[si+2]
        mov     [db2],ax

dongu:  jmp     kod_bolumu

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
        shr      ax,4
;        mov     rax,[r12 + r9]
        db      0x99