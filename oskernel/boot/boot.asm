[ORG 0x7c00]  ; 设置组织代码的起始地址为物理内存中的0x7c00

[SECTION .text]
[BITS 16]    ; 使用16位模式

global _start
_start:
    ; 设置屏幕模式为文本模式，清除屏幕
    mov ax, 3     ; 将3加载到寄存器ax中
    int 0x10      ; 触发BIOS中断0x10，用于设置视频模式

    mov ax, 0     ; 将0加载到寄存器ax中
    mov ss, ax    ; 设置堆栈段寄存器ss为0
    mov ds, ax    ; 设置数据段寄存器ds为0
    mov es, ax    ; 设置附加段寄存器es为0
    mov fs, ax    ; 设置附加段寄存器fs为0
    mov gs, ax    ; 设置附加段寄存器gs为0
    mov si, ax    ; 将0加载到源索引寄存器si中

    mov si, msg   ; 将msg的地址加载到si寄存器中
    call print    ; 调用print子程序

    jmp $         ; 无限循环

; 如何调用
; mov si, msg   ; 1 传入字符串
; call print     ; 2 调用print子程序
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

msg:
    db "hello, world", 10, 13, 0  ; 字符串"hello, world"，后面是换行和回车，以及字符串结束标志

times 510 - ($ - $$) db 0  ; 填充剩余空间，使代码长度达到510字节
db 0x55, 0xaa  ; 主引导记录标志，标识引导扇区
