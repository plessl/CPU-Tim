/* Linker-Skript für RISC-V RV32
 *
 * Speicherlayout:
 *  - TEXT/RX  : 0x00000000 .. 0x00003FFF  (16 KiB)
 *  - DATA/RW  : 0x00010000 .. 0x00013FFF  (16 KiB)
 *  - FB/WO    : 0x00100000 .. 0x0010FFFF  (64 KiB)  (write-only, aus Sicht des Linkers: nur RW, aber keine Initialisierung)
 *
 * Hinweis: GNU ld kennt kein echtes "write-only"-Attribut. Das Segment wird als RW modelliert,
 *         und es werden keine Initialisierungsdaten (.data) dorthin gelegt.
 */

OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  TEXT (rx)  : ORIGIN = 0x00000000, LENGTH = 16K
  DATA (rw)  : ORIGIN = 0x00010000, LENGTH = 16K
  FB   (rw)  : ORIGIN = 0x00100000, LENGTH = 64K
}

SECTIONS
{
  /* ------------------------------------------------------------------ */
  /* Programmcode / Read-Only Daten in TEXT                              */
  /* ------------------------------------------------------------------ */
  . = ORIGIN(TEXT);

  .text : ALIGN(4)
  {
    KEEP(*(.init))
    KEEP(*(.vectors .vector .isr_vector .trap_vector))
    *(.text .text.*)
    *(.plt)
    *(.rodata .rodata.*)
    *(.srodata .srodata.*)
    KEEP(*(.fini))
  } > TEXT

  /* Optional: Exception-Handling- und Debug-Sections (falls vorhanden) */
  .eh_frame : ALIGN(4) { *(.eh_frame .eh_frame.*) } > TEXT
  .gcc_except_table : ALIGN(4) { *(.gcc_except_table .gcc_except_table.*) } > TEXT

  /* ------------------------------------------------------------------ */
  /* Initialisierte Daten in DATA                                        */
  /* LMA (Load Address) liegt in TEXT, VMA (Run Address) liegt in DATA   */
  /* ------------------------------------------------------------------ */
  . = ORIGIN(DATA);

  __data_start = .;

  .data : ALIGN(4)
  {
    *(.data .data.*)
    *(.sdata .sdata.*)
  } > DATA AT> TEXT

  __data_end = .;

  /* Quelle der Initialisierungsdaten im Flash/ROM (TEXT) */
  __data_load_start = LOADADDR(.data);
  __data_load_end   = LOADADDR(.data) + SIZEOF(.data);

  /* ------------------------------------------------------------------ */
  /* Uninitialisierte Daten (BSS) in DATA                                */
  /* ------------------------------------------------------------------ */
  __bss_start = .;

  .bss (NOLOAD) : ALIGN(4)
  {
    *(.bss .bss.*)
    *(.sbss .sbss.*)
    *(COMMON)
  } > DATA

  __bss_end = .;

  /* ------------------------------------------------------------------ */
  /* Heap/Stack (optional) in DATA                                       */
  /* ------------------------------------------------------------------ */
  . = ALIGN(8);
  __heap_start = .;

  /* Heap wächst nach oben; Stack nach unten vom Ende des DATA-Segments */
  __stack_top  = ORIGIN(DATA) + LENGTH(DATA);
  __stack_end  = __stack_top; /* Alias */

  /* ------------------------------------------------------------------ */
  /* Framebuffer: eigener Output-Abschnitt im FB-Segment                 */
  /* - NOLOAD: keine Initialisierung, keine Load-Image-Daten             */
  /* - hier nur explizit zu platzierende Sections (*.fb*)                */
  /* ------------------------------------------------------------------ */
  . = ORIGIN(FB);

  __fb_start = .;

  .framebuffer (NOLOAD) : ALIGN(4)
  {
    *(.fb .fb.*)
    *(.framebuffer .framebuffer.*)
  } > FB

  __fb_end = .;

  /* ------------------------------------------------------------------ */
  /* Linker-Sicherheitsnetze                                             */
  /* ------------------------------------------------------------------ */

  /* Keine ungewollten Sections */
  /DISCARD/ :
  {
    *(.comment)
    *(.note .note.*)
    *(.interp)
  }

  /* Assertions: Segmentgrößen prüfen */
  ASSERT(SIZEOF(.text) <= LENGTH(TEXT), "ERROR: .text/.rodata passt nicht in TEXT (16 KiB).")
  ASSERT((__data_end - __data_start) + (__bss_end - __bss_start) <= LENGTH(DATA),
         "ERROR: .data+.bss passt nicht in DATA (16 KiB).")
  ASSERT((__fb_end - __fb_start) <= LENGTH(FB), "ERROR: Framebuffer passt nicht in FB (64 KiB).")
}
