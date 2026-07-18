bits 32
org 0x8000
section .text
    global _ready
_ready:
    mov ax,0x10
    mov es,ax
    mov edi,0x3FFF0000
    mov eax,0x00000000
    mov ecx,0x10000
    cld
    rep stosb
    mov edi,0x00000000
    mov eax,0x00000000
    mov ecx,0x4000
    rep stosb
    mov edi,0x3FFE0000
    mov eax,0x00000000
    mov ecx,0x10000
    rep stosb

    mov ax,0x10
    mov ds,ax
    mov ax,0x20
    mov es,ax
    mov ax,0x18
    mov ss,ax
    mov esp,0x0000FFF0
    
    mov word [0x80],0x0000   ;backtss
    mov word [0x82],0x0000
    mov dword [0x84],0x000FFF0 ;esp0
    mov word [0x88],0x0018 ;ss0
    mov word [0x8A],0x0000 
    mov dword [0x8C],0x00000000 ;esp1
    mov word [0x90],0x0000    ;ss1
    mov word [0x92],0x0000
    mov dword [0x94],0x00000000 ;esp2
    mov word [0x98],0x0000   ;ss2
    mov word [0x9A],0x0000
    mov dword [0x9C],0x00000000 ;cr3
    mov eax,_kernel_main
    mov dword [0xA0],eax  ;eip
    mov dword [0xA4],0x00000202 ;eflags
    mov dword [0xA8],0x00000000 ;eax
    mov dword [0xAC],0x00000000 ;ecx
    mov dword [0xB0],0x00000000 ;edx
    mov dword [0xB4],0x00000000 ;ebx
    mov dword [0xB8],0x0000FFF0 ;esp
    mov dword [0xBC],0x00000000 ;ebp
    mov dword [0xC0],0x00000000 ;esi
    mov dword [0xC4],0x00000000 ;edi
    mov word [0xC8],0x0020 ;es
    mov word [0xCA],0x0000
    mov word [0xCC],0x0008 ;cs
    mov word [0xCE],0x0000
    mov word [0xD0],0x0018 ;ss
    mov word [0xD2],0x0000
    mov word [0xD4],0x0010 ;ds
    mov word [0xD6],0x0000
    mov word [0xD8],0x0000 ;fs
    mov word [0xDA],0x0000
    mov word [0xDC],0x0000 ;gs
    mov word [0xDE],0x0000
    mov word [0xE0],0x0000 ;ldt
    mov word [0xE2],0x0000
    mov word [0xE4],0x0000
    mov word [0xE6],0x0068 ;i/o_addr

    mov dword [0x6038],0x00800067
    mov dword [0x603C],0x00008900

    call _pit_tss
    call _idt
    call _ldt_set

    mov al,0x0A
    or al,0x80
    out 0x70,al
    in al,0x71
    and al,0xF0
    or al,0x0B
    out 0x71,al
    mov al,0x0B
    or al,0x80
    out 0x70,al
    mov al,0x42
    out 0x71,al
    mov al,0x00
    out 0x70,al

    mov al,0x34
    out 0x43,al
    mov al,0xA9
    out 0x40,al
    mov al,0x04
    out 0x40,al

    mov al,0xF8
    out 0x21,al
    mov al,0xFE
    out 0xA1,al

    sti
    jmp 0x38:0


;=====kernel=====


_kernel_main:
    mov dword [0x2028],0x00010000
    mov eax,0x00012000
    call _creat_task
    mov ax,0x0070
    mov esi,msg1
    mov edi,0x0000
    mov ecx,37
    int 0x30
    mov ax,0x0007
    mov esi,line
    mov edi,0x1700
    mov ecx,80
    int 0x30
_kernel_main_loop:
    mov dword [0x604C],0x00008900
    call 0x48:0    ;task command
    jmp _kernel_main_loop
;================


_pit_tss:
    mov word [0x100],0x0038   ;backtss
    mov word [0x102],0x0000
    mov dword [0x104],0x0000FFF0 ;esp0
    mov word [0x108],0x0018 ;ss0
    mov word [0x10A],0x0000
    mov dword [0x10C],0x00000000
    mov word [0x110],0x0000
    mov word [0x112],0x0000
    mov dword [0x114],0x00000000
    mov word [0x118],0x0000
    mov word [0x11A],0x0000
    mov dword [0x11C],0x00000000 ;cr3
    mov eax,_PIT_INT
    mov dword [0x120],eax  ;eip
    mov dword [0x124],0x00004002 ;eflags
    mov dword [0x128],0x00000000 ;eax
    mov dword [0x12C],0x00000000 ;ecx
    mov dword [0x130],0x00000000 ;edx
    mov dword [0x134],0x00000000 ;ebx
    mov dword [0x138],0x0000FFF0 ;esp
    mov dword [0x13C],0x00000000 ;ebp
    mov dword [0x140],0x00000000 ;esi
    mov dword [0x144],0x00000000 ;edi
    mov word [0x148],0x0020 ;es
    mov word [0x14A],0x0000
    mov word [0x14C],0x0008 ;cs
    mov word [0x14E],0x0000
    mov word [0x150],0x0018 ;ss
    mov word [0x152],0x0000
    mov word [0x154],0x0010 ;ds
    mov word [0x156],0x0000
    mov word [0x158],0x0000 ;fs
    mov word [0x15A],0x0000
    mov word [0x15C],0x0000 ;gs
    mov word [0x15E],0x0000
    mov word [0x160],0x0000 ;ldt
    mov word [0x162],0x0000
    mov word [0x164],0x0000
    mov word [0x166],0x0068 ;i/o_addr

    mov dword [0x6040],0x01000067
    mov dword [0x6044],0x00008900

    mov word [0x2000],0x6048
    mov word [0x2002],0x0180
    ret
_idt:
    mov ax,_SERVER
    mov word [0x6988],ax
    mov word [0x698A],0x0008
    mov dword [0x698C],0x0000EE00
    ret
_SERVER:
    cmp ah,0x00  ;load base
    je _LOAD_BASE
_LOAD_BASE:
    mov eax,0x00000000
    mov ax,ds

    push ds
    mov bx,0x10
    mov ds,bx

    and ax,0xF8  ;Discard low 3 bit
    shr eax,4  ;task n(index 1)
    sub eax,1
    shl eax,2
    add eax,0x10000
    mov edi,eax
    mov dword eax,[edi]
    pop ds
    iret
_PIT_INT:
    mov word [0x100],0x0038 ;kernel
    mov word [0x120],_PIT_INT
    pushf
    pop eax
    or eax,0x00004000 ;set eflags.nt = 1
    push eax
    popf
    mov al,0x20
    out 0x20,al
    iret
    jmp _PIT_INT
_creat_task:
    mov dword ebx,[0x2028]  ;save base table bp
    mov dword [ebx],eax ;save base
    add ebx,4
    mov dword [0x2028],ebx


    mov word bx,[0x2000]
    mov word [bx],0x0067
    add bx,2
    mov word dx,[0x2002]
    mov word [bx],dx
    add bx,2
    mov dword [bx],0x00008900
    add bx,4
    mov word [0x2000],bx
    add dx,0x80
    mov word [0x2002],dx

    call _ldt_creat
    call _tss_creat
    mov word bx,[0x2020]
    mov word [bx],0x0000
    add bx,2
    mov word dx,[0x2000]
    sub dx,0x6008
    mov word [bx],dx
    add bx,2
    mov dword [bx],0x0000E500
    add bx,4
    mov word [0x2020],bx
    ret
_tss_creat:
    mov word bx,[0x2002]
    sub bx,0x80
    mov dx,bx
    mov word [bx],0x0038 ;backtss
    mov word [bx+2],0x0000
    mov dword [bx+4],0x0000FFF0 ;esp0
    mov word [bx+8],0x0018 ;ss0
    mov word [bx+10],0x0000
    mov dword [bx+12],0x00000000 ;esp1
    mov word [bx+16],0x0000  ;ss1
    mov word [bx+18],0x0000
    mov dword [bx+20],0x00000000 ;esp2
    mov word [bx+24],0x0000  ;ss2
    mov word [bx+26],0x0000
    mov dword [bx+28],0x00000000 ;cr3
    mov dword [bx+32],0x00000000 ;eip
    mov dword [bx+36],0x00000202 ;eflags
    mov dword [bx+40],0x00000000 ;eax
    mov dword [bx+44],0x00000000 ;ecx
    mov dword [bx+48],0x00000000 ;edx
    mov dword [bx+52],0x00000000 ;ebx
    mov dword [bx+56],0x0000FFF0 ;esp
    mov dword [bx+60],0x00000000 ;ebp
    mov dword [bx+64],0x00000000 ;esi
    mov dword [bx+68],0x00000000 ;edi
    add cx,8
    mov word [bx+72],cx ;es
    mov word [bx+74],0x0000
    sub cx,8
    mov word [bx+76],cx ;cs
    mov word [bx+78],0x0000
    mov word [bx+80],0x002B ;ss
    mov word [bx+82],0x0000
    add cx,8
    mov word [bx+84],cx ;ds
    mov word [bx+86],0x0000
    mov word [bx+88],0x0000 ;fs
    mov word [bx+90],0x0000
    mov word [bx+92],0x0000 ;gs
    mov word [bx+94],0x0000
    mov word [bx+96],0x0030 ;ldt
    mov word [bx+98],0x0000
    mov word [bx+100],0x0000
    mov word [bx+102],0x0068 ;i/o_addr

    ret
_ldt_creat:
    mov word bx,[0x2010]
    mov cx,bx
    sub cx,0x1C00
    or cx,0x7 ;ti=1,dpl=3
    mov edx,eax
    shr edx,16

    mov word [bx],0x0FFF
    add bx,2
    mov word [bx],ax
    add bx,2
    mov byte [bx],dl
    add bx,1
    mov byte [bx],0xFA
    add bx,1
    mov byte [bx],0x40
    add bx,1
    mov byte [bx],dh
    add bx,1

    mov word [bx],0x0FFF
    add bx,2
    mov word [bx],ax
    add bx,2
    mov byte [bx],dl
    add bx,1
    mov byte [bx],0xF2
    add bx,1
    mov byte [bx],0x40
    add bx,1
    mov byte [bx],dh
    add bx,1

    mov word [0x2010],bx
    ret
_ldt_set:
    mov dword [0x1C00],0x00000000
    mov dword [0x1C04],0x00000000

    mov word [0x2010],0x1C08
    ret
msg1 db '**Welcome to OpenFerain 26.0 system**'
msg2 db 'If you can see this,pit ok'
line db '________________________________________________________________________________'
times 4096 - ($ - $$) db 0