//
// Created by ziya on 22-6-23.
//

#include "../include/linux/tty.h"
#include "../include/linux/kernel.h"
#include "../include/asm/io.h"

void kernel_main(void) {
    console_init();

    char* s = "learn linux";

    printk("name: %s\n", s);



    while (true);
}