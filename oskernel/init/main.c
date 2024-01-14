
#include "../include/linux/tty.h"
#include "../include/linux/kernel.h"
#include "../include/asm/io.h"

void kernel_main(void) {
    console_init();
    char* s = "linux";
    printk("%s\n", s);

    uchar cursor_position_high = 0;
    uchar cursor_position_low = 0;

    out_byte(0x3D4, 0x0e);
    cursor_position_high = in_byte(0x3D5);

    out_byte(0x3D4, 0x0f);
    cursor_position_low = in_byte(0x3D5);

    ushort position = cursor_position_high << 8 | cursor_position_low;
    printk("%d, %d, %d\n", cursor_position_high, cursor_position_low, position);

    while (true);
}