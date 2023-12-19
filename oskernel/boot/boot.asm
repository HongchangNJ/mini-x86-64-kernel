[ORG 0x7c00]  ; 设置组织代码的起始地址为物理内存中的0x7c00

[SECTION .data]
BOOT_MAIN_ADDR equ 0x500

[SECTION .text]
[BITS 16]    ; 使用16位模式

global _start
_start:
    mov ax, 3
    int 0x10

    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov si, ax

    ; 指定读取地址 ，从哪个扇区开始读，读几个扇区
    mov edi, BOOT_MAIN_ADDR;  读到0x500处
    mov ecx, 1 ; 从哪个扇区读
    mov bl, 2 ; 扇区数

    call read_from_hd

    mov si, jump_msg   ; 将msg的地址加载到si寄存器中
    call print    ; 调用print子程序

    jmp BOOT_MAIN_ADDR

; 从硬盘读取程序
read_from_hd:
    ; dx 中保存端口号
    ; 0x1f2端口 设置要读取的扇区数
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    ; 0x1f3 0-7位  LBA low
    inc dx
    mov al, cl
    out dx, al

    ; 0x1f4 8-15位 LBA mid
    inc dx
    mov al, ch
    out dx, al
    ; 0x1f5 16到23位 LBA high
    inc dx
    shr ecx, 16 ;ecx 右移16位，则原来的16到23变为0到8
    mov al, cl
    out dx, al

    ; 0x1f6 lba 24~27   Device寄存器： 0到3位四为用来存储LBA地址的24-27位
    ; 4~7位分表用来表示：4，主盘从盘。6,是否启用LBA。5和7固定为1
    inc dx
    shr ecx, 8
    and cl, 0b1111;  将ecx的第四位写入cl,最终写入al低四位
    mov al, 0b1110_0000 ; 高四位置为1110（4到7），4位代表
    or al, cl
    out dx, al

    ; 0x1f7 写入0x20
    inc dx
    mov al, 0x20
    out dx, al

    ; 设置循环次数:也就是扇区的个数
    mov cl, bl
.start_read:
    ; 读一个扇区
    ; 先保存外部loop的次数
    push cx

    ; 检测状态
    ;call wait_prepare
    mov dx, 0x1f7
    .not_ready:
    ;同一端口，写时表示写入命令字，读时表示读入硬盘状态
        nop
        in al, dx
        and al, 0b1000_1000 ;；第 3位为 1表示硬盘控制器已准备好数据传输
        ;；第 7位为1 表示硬盘忙
        cmp al, 0b0000_1000
        jnz .not_ready ;若未准备好，继续等. cmp指令在两个数值相等时，zero flag置为0


    ; 读取扇区数据
    call read_one_hd

    pop cx
    loop .start_read

.return:
    ret

read_one_hd:
    mov dx, 0x1f0
    mov cx, 256

.read_word:
    in ax, dx
    mov [edi], ax
    add edi, 2
    loop .read_word

    ret


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

jump_msg:
    db "jump to setup", 10, 13, 0

times 510 - ($ - $$) db 0  ; 填充剩余空间，使代码长度达到510字节
db 0x55, 0xaa  ; 主引导记录标志，标识引导扇区
