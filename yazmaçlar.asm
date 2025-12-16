use16
        jmp     ilk_degerler

        db      0x99
        lba_c   db      0
        lba_h   db      0
        lba_s   db      0
        db      0x99
        cluster         dw      1

ilk_degerler:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0x1000

        mov     ax,0x1234
        mov     dx,0x1234
        mov     cx,0x1234
        mov     si,0
kod_bolumu:
        mov     [si+2],byte 1

;        mov     ch,al
;        mov     al,dl
;        mov     bl,cl

;        call    lba2chs

dongu:  jmp     kod_bolumu

db1     dw      1
db2     dw      0x1234
db3     db      3
db4     db      4
db5     db      5
db6     db      6
db7     db      7
db8     db      8


lba2chs:

        push    bx

        mov     ax,[cluster]
        add     ax,31
        push    ax
        mov     bl,18*2
        div     bl
        mov     [lba_c],al

        mov     al,ah
        mov     ah,0
        mov     bl,18
        div     bl
        mov     [lba_h],al

        pop     ax
        mov     bl,18
        div     bl
        inc     ah
        mov     [lba_s],ah

        pop     bx
        ret

;use64
        db      0x99
;        xor     r8,r8

;        mov     al,ah

        mov     [di+2],cx

;        mov     rax,[r12 + r9]
        db      0x99