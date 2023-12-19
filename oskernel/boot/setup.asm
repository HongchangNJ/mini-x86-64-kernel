[ORG 0x500]  ; 设置组织代码的起始地址为物理内存中的0x7c00

[SECTION .text]
[BITS 16]    ; 使用16位模式

global _start
_start:
    ;xchg bx, bx
    ;mov ax, 3     ; 将3加载到寄存器ax中，用于设置80x25文本模式并清除屏幕
    ;int 0x10      ; 触发BIOS中断0x10

    mov si, hello   ; 将msg的地址加载到si寄存器中
    call print    ; 调用print子程序

    jmp $         ; 无限循环

print:
    mov ah, 0x0e   ; 设置TTY模式，用于打印字符
    mov bh, 0      ; 页号（默认为0）
    mov bl, 0x01   ; 文本前景色（白色）

.loop:
    mov al, [si]   ; 将si指向的字符加载到al寄存器
    cmp al, 0      ; 比较al中的字符是否为零（字符串结束标志）
    jz .done       ; 如果是零，跳转到.done标签

    int 0x10       ; 触发BIOS中断0x10，用于在屏幕上打印字符

    inc si         ; 增加si寄存器的值，指向下一个字符
    jmp .loop      ; 无条件跳转到.loop标签

.done:
    ret            ; 返回

hello:
    db "hello, i am setup program", 10, 13, 0
