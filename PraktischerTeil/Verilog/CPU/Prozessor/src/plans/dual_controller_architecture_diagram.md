# Dual Controller Architecture Diagrams

## System Overview

```mermaid
graph TB
    subgraph CPU["RISC-V CPU Core"]
        FSM[FSM Controller]
        RF[Register File]
        ALU[ALU]
    end
    
    subgraph Memory["Memory Subsystem"]
        ROM[ROM 64KB<br/>0x0000_0000]
        RAM[RAM 64KB<br/>0x0001_0000]
        FB[Framebuffer<br/>0x0002_0000]
    end
    
    subgraph Controllers["SPI Controllers"]
        SPI1[SPI Controller P1<br/>0x0003_0000]
        SPI2[SPI Controller P2<br/>0x0003_0004]
    end
    
    subgraph External["External Devices"]
        DS1[DualShock P1]
        DS2[DualShock P2]
        LED[LED Matrix 64x64]
    end
    
    FSM -->|Address/Data Bus| ROM
    FSM -->|Address/Data Bus| RAM
    FSM -->|Address/Data Bus| FB
    FSM -->|Address Decode| SPI1
    FSM -->|Address Decode| SPI2
    
    SPI1 <-->|SPI Protocol| DS1
    SPI2 <-->|SPI Protocol| DS2
    FB -->|Pixel Data| LED
```

## Memory Map Layout

```mermaid
graph LR
    subgraph Address_Space["32-bit Address Space"]
        ROM_RANGE["0x0000_0000<br/>to<br/>0x0000_FFFF<br/><br/>ROM<br/>64KB"]
        RAM_RANGE["0x0001_0000<br/>to<br/>0x0001_FFFF<br/><br/>RAM<br/>64KB"]
        FB_RANGE["0x0002_0000<br/>to<br/>0x0002_FFFF<br/><br/>Framebuffer<br/>64KB"]
        SPI_RANGE["0x0003_0000<br/>P1: +0x0000<br/>P2: +0x0004<br/><br/>SPI Controllers<br/>8 bytes"]
        RESERVED["0x0003_0008<br/>to<br/>0xFFFF_FFFF<br/><br/>Reserved"]
    end
```

## SPI Controller Data Flow

```mermaid
sequenceDiagram
    participant CPU as CPU FSM
    participant P1 as SPI Ctrl P1
    participant P2 as SPI Ctrl P2
    participant DS1 as DualShock P1
    participant DS2 as DualShock P2
    
    Note over P1,DS1: Continuous autonomous polling
    P1->>DS1: Poll (6 bytes SPI)
    DS1->>P1: Button state
    P1->>P1: Update controller_state
    
    Note over P2,DS2: Continuous autonomous polling
    P2->>DS2: Poll (6 bytes SPI)
    DS2->>P2: Button state
    P2->>P2: Update controller_state_p2
    
    Note over CPU: Software reads P1
    CPU->>CPU: LW from 0x0003_0000
    CPU->>P1: Read controller_state
    P1->>CPU: Return 16-bit state
    
    Note over CPU: Software reads P2
    CPU->>CPU: LW from 0x0003_0004
    CPU->>P2: Read controller_state_p2
    P2->>CPU: Return 16-bit state
```

## FSM Address Decoding Logic

```mermaid
flowchart TD
    START[Load Instruction<br/>LW rd, offset rs1] --> CALC[Calculate Address<br/>addr = rs1 + offset]
    CALC --> CHECK_RANGE{addr bits 31:16<br/>== 0x0003?}
    
    CHECK_RANGE -->|No| OTHER[Route to<br/>ROM/RAM/FB]
    CHECK_RANGE -->|Yes| SPI_DECODE{addr bit 2<br/>== 0?}
    
    SPI_DECODE -->|Yes bit2=0| P1[Read P1 Controller<br/>0x0003_0000<br/>tmp_rd = controller_state]
    SPI_DECODE -->|No bit2=1| P2[Read P2 Controller<br/>0x0003_0004<br/>tmp_rd = controller_state_p2]
    
    P1 --> WB[Writeback to rd]
    P2 --> WB
    OTHER --> WB
```

## Pin Connections

```mermaid
graph LR
    subgraph FPGA["FPGA GW5A"]
        subgraph P1_Pins["P1 SPI Pins"]
            P1_CS[CS1N: F5]
            P1_MOSI[MOSI: G7]
            P1_MISO[MISO: H8]
            P1_CLK[SCLK: H5]
        end
        
        subgraph P2_Pins["P2 SPI Pins"]
            P2_CS[CS2N: G5]
            P2_MOSI[MOSI: G8]
            P2_MISO[MISO: H7]
            P2_CLK[SCLK: J5]
        end
        
        SPI1[SPI Controller P1]
        SPI2[SPI Controller P2]
        
        SPI1 --> P1_CS
        SPI1 --> P1_MOSI
        P1_MISO --> SPI1
        SPI1 --> P1_CLK
        
        SPI2 --> P2_CS
        SPI2 --> P2_MOSI
        P2_MISO --> SPI2
        SPI2 --> P2_CLK
    end
    
    P1_CS -.->|Cable| DS1_CS[DualShock P1<br/>CS]
    P1_MOSI -.->|Cable| DS1_MOSI[MOSI]
    DS1_MISO[MISO] -.->|Cable| P1_MISO
    P1_CLK -.->|Cable| DS1_CLK[CLK]
    
    P2_CS -.->|Cable| DS2_CS[DualShock P2<br/>CS]
    P2_MOSI -.->|Cable| DS2_MOSI[MOSI]
    DS2_MISO[MISO] -.->|Cable| P2_MISO
    P2_CLK -.->|Cable| DS2_CLK[CLK]
```

## Controller State Register Format

Both P1 and P2 use the same 16-bit format:

```
Bit 15: LEFT
Bit 14: DOWN
Bit 13: RIGHT
Bit 12: UP
Bit 11: START
Bit 10: R3
Bit 9:  L3
Bit 8:  SELECT
Bit 7:  SQUARE
Bit 6:  CROSS
Bit 5:  CIRCLE
Bit 4:  TRIANGLE
Bit 3:  R1
Bit 2:  L1
Bit 1:  R2
Bit 0:  L2

Note: All bits are active-high in software
      Hardware inverts the active-low signals from controller
```

## Implementation Phases

```mermaid
gantt
    title Dual Controller Implementation Timeline
    dateFormat YYYY-MM-DD
    section Hardware
    Modify cpu.sv top module     :a1, 2026-02-23, 1d
    Add P2 SPI controller        :a2, after a1, 1d
    Update FSM address decode    :a3, after a2, 1d
    section Constraints
    Update Prozessor.cst         :b1, after a1, 1d
    section Documentation
    Update PINOUT.md             :c1, after a3, 1d
    Update architecture.md       :c2, after c1, 1d
    Update README.md             :c3, after c2, 1d
    section Testing
    Create test application      :d1, after a3, 2d
    Simulation testing           :d2, after d1, 1d
    Hardware verification        :d3, after d2, 1d
```

## Software Usage Example

```mermaid
flowchart TD
    START[Start Game Loop] --> READ_P1[Read P1 Controller<br/>p1 = *0x00030000]
    READ_P1 --> READ_P2[Read P2 Controller<br/>p2 = *0x00030004]
    READ_P2 --> CHECK_P1{P1 Button<br/>Pressed?}
    
    CHECK_P1 -->|Yes| UPDATE_P1[Update P1 Position]
    CHECK_P1 -->|No| CHECK_P2
    
    UPDATE_P1 --> CHECK_P2{P2 Button<br/>Pressed?}
    CHECK_P2 -->|Yes| UPDATE_P2[Update P2 Position]
    CHECK_P2 -->|No| RENDER
    
    UPDATE_P2 --> RENDER[Render Both Players]
    RENDER --> DELAY[Delay]
    DELAY --> START
```

## Resource Utilization Estimate

| Resource | Current | After P2 | Increase |
|----------|---------|----------|----------|
| SPI Controller Modules | 1 | 2 | +100% |
| 16-bit Registers | 1 | 2 | +100% |
| FSM Logic | Baseline | +5% | Address decode |
| I/O Pins | 4 (P1) | 8 (P1+P2) | +4 pins |
| Total LUTs | ~X | ~X+50 | Minimal |

Note: Second SPI controller is identical to first, so resource usage is predictable and minimal.

## Timing Considerations

```mermaid
gantt
    title SPI Polling Timeline (Both Controllers)
    dateFormat HH:mm:ss.SSS
    axisFormat %M:%S.%L
    
    section P1 Controller
    P1 Transaction 1    :p1a, 00:00:00.000, 10ms
    P1 Idle            :p1b, after p1a, 5ms
    P1 Transaction 2    :p1c, after p1b, 10ms
    
    section P2 Controller
    P2 Transaction 1    :p2a, 00:00:00.000, 10ms
    P2 Idle            :p2b, after p2a, 5ms
    P2 Transaction 2    :p2c, after p2b, 10ms
```

**Note**: Both controllers poll independently and simultaneously. Polling rate: ~66Hz per controller (15ms per transaction).

## Address Decode Truth Table

| Address | Bit 31:16 | Bit 2 | Selected Controller | Data Source |
|---------|-----------|-------|---------------------|-------------|
| 0x0003_0000 | 0x0003 | 0 | P1 | controller_state |
| 0x0003_0004 | 0x0003 | 1 | P2 | controller_state_p2 |
| 0x0003_0008 | 0x0003 | - | Reserved | - |
| 0x0001_xxxx | 0x0001 | - | RAM | dmem_rdata |
| 0x0002_xxxx | 0x0002 | - | Framebuffer | - |
