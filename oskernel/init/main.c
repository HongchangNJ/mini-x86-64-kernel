
#include "../include/linux/tty.h"
#include "../include/linux/kernel.h"
#include "../include/asm/io.h"

void kernel_main(void) {
    console_init();
    char* s = "linux";
    printk("%s\n", s);


    ushort cursor = 80 * 1 + 40;
    uchar low = cursor & 0xff;
    uchar height = cursor >> 8;

    out_byte(0x3d4, 0x0e);
    out_byte(0x3d5, height);

    out_byte(0x3d4, 0x0f);
    out_byte(0x3d5, low);

    while (true);
}