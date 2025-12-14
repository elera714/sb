use16
ilk_degerler:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0x1000

        mov     bx,0x1234
        mov     cx,0x5678
        xchg    bx,cx
kod_bolumu:

        mov     al,ah

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

        mov     al,ah

;        mov     rax,[r12 + r9]
        db      0x99