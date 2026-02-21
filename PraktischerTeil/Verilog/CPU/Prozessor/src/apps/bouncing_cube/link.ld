ENTRY(_start)

MEMORY
{
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 16K
  RAM (rw)  : ORIGIN = 0x00010000, LENGTH = 16K
  FB  (rwx) : ORIGIN = 0x00020000, LENGTH = 16K   /* frame buffer RAM-like */
}

SECTIONS
{
  /* ------------------------------------------------------------
   * Code + constants in ROM (raw binary image)
   * ------------------------------------------------------------ */
  .text :
  {
    KEEP(*(.init))
    KEEP(*(.text.startup*))
    *(.text .text.*)
    *(.rodata .rodata.*)
    *(.srodata .srodata.*)
    KEEP(*(.fini))
  } > ROM

  /* ------------------------------------------------------------
   * Writable data in RAM, load image stored in ROM after .text
   * But we'll initialize it from the binary, not copy at runtime
   * ------------------------------------------------------------ */
  .data : AT(ADDR(.text) + SIZEOF(.text))
  {
    __data_start = .;
    *(.data .data.*)
    *(.sdata .sdata.*)
    __data_end = .;
  } > RAM

  /* The .data section will be in the binary at the ROM location */
  /* but the build process will extract it and place it in ram.mi */

  /* ------------------------------------------------------------
   * Zero-initialized data in RAM
   * ------------------------------------------------------------ */
  .bss (NOLOAD) :
  {
    __bss_start = .;
    *(.bss .bss.*)
    *(.sbss .sbss.*)
    *(COMMON)
    __bss_end = .;
  } > RAM

  /* ------------------------------------------------------------
   * Framebuffer in dedicated RAM-like region
   * ------------------------------------------------------------ */
  .framebuffer (NOLOAD) :
  {
    __fb_start = .;
    *(.framebuffer .framebuffer.*)
    __fb_end = .;
  } > FB

  /* ------------------------------------------------------------
   * Symbols for startup code
   * ------------------------------------------------------------ */

  /* Stack grows down from top of RAM */
  __stack_top = ORIGIN(RAM) + LENGTH(RAM);

  /* Global pointer for small-data (RISC-V ABI convention) */
  __global_pointer$ = ORIGIN(RAM) + 0x800;

  /* ------------------------------------------------------------
   * Discard unused / unwanted sections
   * ------------------------------------------------------------ */
  /DISCARD/ :
  {
    *(.comment*)
    *(.note*)
    *(.eh_frame*)
  }
}