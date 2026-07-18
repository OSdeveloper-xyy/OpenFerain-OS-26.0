ENTRY(main_func)
SECTIONS 
{
    . = 0;
    .entry : {
        KEEP(*(.entry))
    }
    .text : {
        *(.text*)
    }
    .rodata : {
        *(.rodata*)
    }
    .data : {
        *(.data*)
    }
    .bss (NOLOAD) : {
        *(.bss*)
        *(COMMON)
    }
    /DISCARD/ : {
        *(.comment*)
        *(.note*)
        *(.eh_frame*)
    }
}