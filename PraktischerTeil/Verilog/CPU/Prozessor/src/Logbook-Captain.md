# Logbuch des Captains

## Install verible tools for SystemVerilog (language server, linting, formattter, ...)

https://github.com/chipsalliance/homebrew-verible

`
brew tap chipsalliance/verible
brew install verible
`


### Game controller

Sources:

- https://hackaday.io/project/170365-blueretro/log/186471-playstation-playstation-2-spi-interface

```
TX: 0142000000
RX: FF415AFFFF
      ├┘  └┬─┘
      ID   └Buttons(L D R U St R3 L3 Se □ X O △ R1 L1 R2 L2)
```

SPI Protocol variant (mode 3):

- Clock polarity (CPOL): The clock is idle high (CPOL=1)
- Clock phase (CPHA): Data is captured on the second clock edge (CPHA=1), i.e. rising edge.
- Bytes are transferred LSB first




### Data sent by the controller, traced with logic analyzer


LEFT  | 7F FF | 0111 1111 1111 1111 ( bit ~15)
DOWN  | BF FF | 1011 1111 1111 1111  
RIGHT | DF FF | 1101 1111 1111 1111
UP    | EF FF | 1110 1111 1111 1111

SEL   | FE FF | 1111 1110 1111 1111
START | F7 FF | 1111 0111 1111 1111 

STICK1 | FD FF | 1111 1101 1111 1111
STICK2 | FB FF | 1111 1011 1111 1111

1 /   |  FF EF | 1111 1111 1110 1111
2    |  FF DF  | 1111 1111 1101 1111
3    |  FF BF  | 1111 1111 1011 1111 
4    |  FF 7F  | 1111 1111 0111 1111

L1   | FF FB  | 1111 1111 1111 1011
L2   | FF FE  | 1111 1111 1111 1110
R1   | FF F7  | 1111 1111 1111 0111
R2   | FF FD  | 1111 1111 1111 1101



## RISC-V RV32 (RVA32) ABI register mapping.

x-reg	ABI Name	Description
x0	zero	Hard-wired zero
x1	ra	Return address
x2	sp	Stack pointer
x3	gp	Global pointer
x4	tp	Thread pointer
x5	t0	Temporary
x6	t1	Temporary
x7	t2	Temporary
x8	s0 / fp	Saved register / Frame pointer
x9	s1	Saved register
x10	a0	Argument / Return value
x11	a1	Argument / Return value
x12	a2	Argument
x13	a3	Argument
x14	a4	Argument
x15	a5	Argument
x16	a6	Argument
x17	a7	Argument
x18	s2	Saved register
x19	s3	Saved register
x20	s4	Saved register
x21	s5	Saved register
x22	s6	Saved register
x23	s7	Saved register
x24	s8	Saved register
x25	s9	Saved register
x26	s10	Saved register
x27	s11	Saved register
x28	t3	Temporary
x29	t4	Temporary
x30	t5	Temporary
x31	t6	Temporary

