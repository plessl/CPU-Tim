
## Board pinout 


CLK | E2
RST | H11


IO_PORT "rst" IO_TYPE=LVCMOS33 PULL_MODE=DOWN BANK_VCCIO=3.3;
IO_LOC "clk" E2;
IO_PORT "clk" IO_TYPE=LVCMOS33 PULL_MODE=NONE BANK_VCCIO=3.3;





## Mapping of TANG FPGA Board Connector to FPGA Pins

|Header|FPGA PIN | 
|   40 | J11 |
|   38 |  F7 | 
|   36 |  J8 | 
|   34 |  L9 | 
|   32 | L10 | 
|   30 |  K7 | 
|   28 |  H1 | 
|   26 |  G4 | 
|   24 |  J1 | 
|   22 |  E3 | 
|   20 |  E1 | 
|   18 |  E2 | 


## Mapping of PS2 Dual Shock Controller


P1  | CS1N |  F5
    | MOSI |  G7
    | MISO |  H8
    | SCLK |  H5
    | GND  | GND
    | 3V3  | 3V3

P2  | CS2N |  G5
    | MOSI |  G8
    | MISO |  H7
    | SCLK |  J5
    | GND  | GND
    | 3V3  | 3V3


## HUB75E PMOD (matrix display, connected to first two ports of board, closest to USB connectre)

DISPLAY_CLK | L11 | none
LATCH       | K11  | none
DISPLAY_OE          | K5  | none
A (row_addr[0]) | A10 | none
B (row_addr[1]) | A11 | none
C (row_addr[2]) | E10 | none
D (row_addr[3]) | E11 | none
E (row_addr[4]) | C11 | none


dout_a[0] | D10
dout_a[1] | G11
dout_a[2] | G10

dout_b[0] | C10
dout_b[1] | B11
dout_b[2] | B10


IO_LOC "dout_b[2]" B10;
IO_PORT "dout_b[2]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "dout_b[1]" B11;
IO_PORT "dout_b[1]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "dout_b[0]" C10;
IO_PORT "dout_b[0]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "dout_a[2]" G10;
IO_PORT "dout_a[2]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "dout_a[1]" G11;
IO_PORT "dout_a[1]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "dout_a[0]" D10;
IO_PORT "dout_a[0]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;



IO_LOC "display_clk" L11;
IO_PORT "display_clk" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "latch" K11;
IO_PORT "latch" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "display_oe" K5;
IO_PORT "display_oe" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "row_addr[4]" C11;
IO_PORT "row_addr[4]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "row_addr[3]" E11;
IO_PORT "row_addr[3]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "row_addr[2]" E10;
IO_PORT "row_addr[2]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "row_addr[1]" A11;
IO_PORT "row_addr[1]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "row_addr[0]" A10;
IO_PORT "row_addr[0]" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;