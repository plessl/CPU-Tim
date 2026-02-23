# Dual Controller Implementation Guide

## Quick Reference

### Memory Map
- **P1 Controller**: `0x0003_0000` (existing)
- **P2 Controller**: `0x0003_0004` (new)

### Pin Assignments
| Controller | Signal | FPGA Pin | Current Use |
|------------|--------|----------|-------------|
| P1 | CS1N | F5 | Assigned |
| P1 | MOSI | G7 | Assigned |
| P1 | MISO | H8 | Assigned |
| P1 | SCLK | H5 | Assigned |
| P2 | CS2N | G5 | **Available** |
| P2 | MOSI | G8 | **Available** |
| P2 | MISO | H7 | **Available** |
| P2 | SCLK | J5 | **Available** |

## Implementation Strategy

### Approach: Independent Autonomous Polling

After analyzing the current implementation, the simplest approach is:

1. **Keep existing SPI controller design** - It autonomously polls continuously
2. **Add second identical instance** - For P2 controller
3. **No arbiter needed** - Both controllers poll independently
4. **Address-based selection** - FSM selects which controller state to read based on address

**Advantages**:
- Minimal code changes
- No modification to existing `spi_controller` module
- Both controllers poll at full rate
- Simple address decoding

**Trade-off**:
- Both controllers poll simultaneously (not round-robin)
- Slightly higher power consumption
- No synchronization between controllers

### Alternative: True Round-Robin (Not Recommended)

This would require:
- Modifying `spi_controller` to accept enable signal
- Adding arbiter state machine
- More complex implementation
- Reduced polling rate per controller

**Recommendation**: Use independent autonomous polling for simplicity.

## Code Changes Required

### 1. Top Module I/O Ports

**File**: [`cpu.sv`](../cpu.sv:3-35)

**Current**:
```systemverilog
module topmodule (
    input  logic       clk,
    input  logic       rst,
    // ...
    
    //SPI Controller	
    output logic spi_clk,
    output logic cs_n,
    output logic mosi,
    input  logic miso,
    // ...
);
```

**Modified**:
```systemverilog
module topmodule (
    input  logic       clk,
    input  logic       rst,
    // ...
    
    // P1 SPI Controller	
    output logic spi_clk_p1,
    output logic cs_n_p1,
    output logic mosi_p1,
    input  logic miso_p1,
    
    // P2 SPI Controller (NEW)
    output logic spi_clk_p2,
    output logic cs_n_p2,
    output logic mosi_p2,
    input  logic miso_p2,
    // ...
);
```

### 2. Wire Declarations

**File**: [`cpu.sv`](../cpu.sv:37-52)

**Add after line 38**:
```systemverilog
wire [15:0] controller_state;      // P1 (existing)
wire [15:0] controller_state_p2;   // P2 (NEW)
```

### 3. SPI Controller Instantiation

**File**: [`cpu.sv`](../cpu.sv:100-120)

**Current** (around line 100):
```systemverilog
spi_controller spi_ctrl(
    .clk(clk),
    .rst(rst),
    .miso(miso),
    .mosi(mosi),
    .cs_n(cs_n),
    .spi_clk(spi_clk),
    .controller_state(controller_state)
);
```

**Modified**:
```systemverilog
// P1 Controller (rename existing instance)
spi_controller spi_ctrl_p1(
    .clk(clk),
    .rst(rst),
    .miso(miso_p1),
    .mosi(mosi_p1),
    .cs_n(cs_n_p1),
    .spi_clk(spi_clk_p1),
    .controller_state(controller_state)
);

// P2 Controller (NEW)
spi_controller spi_ctrl_p2(
    .clk(clk),
    .rst(rst),
    .miso(miso_p2),
    .mosi(mosi_p2),
    .cs_n(cs_n_p2),
    .spi_clk(spi_clk_p2),
    .controller_state(controller_state_p2)
);
```

### 4. FSM Module Interface

**File**: [`cpu.sv`](../cpu.sv:644-664)

**Current**:
```systemverilog
module fsm (
    // ...
    input logic [15:0] controller_state
);
```

**Modified**:
```systemverilog
module fsm (
    // ...
    input logic [15:0] controller_state,     // P1
    input logic [15:0] controller_state_p2   // P2 (NEW)
);
```

### 5. FSM Instantiation

**File**: [`cpu.sv`](../cpu.sv:80-105)

**Current**:
```systemverilog
fsm machine(
    // ...
    .controller_state(controller_state)
);
```

**Modified**:
```systemverilog
fsm machine(
    // ...
    .controller_state(controller_state),      // P1
    .controller_state_p2(controller_state_p2) // P2 (NEW)
);
```

### 6. FSM MEMORY2 Stage - Address Decoding

**File**: [`cpu.sv`](../cpu.sv:1037-1047)

**Current**:
```systemverilog
if(bus_addr[31:16] == 16'h0003) begin
    spi_ce <= 1'b0;
    spi_re <= 1'b0;
    tmp_rd <= {16'b0, controller_state};
    
    `ifdef ENABLE_TRACE
    `ifndef SYNTHESIS
    $display("Read from SPI: addr = 0x%h , data 0x%h", bus_addr, controller_state);
    `endif
    `endif
end
```

**Modified**:
```systemverilog
if(bus_addr[31:16] == 16'h0003) begin
    spi_ce <= 1'b0;
    spi_re <= 1'b0;
    
    // Address decoding: bit 2 selects controller
    // 0x0003_0000 -> P1 (bit 2 = 0)
    // 0x0003_0004 -> P2 (bit 2 = 1)
    if(bus_addr[2] == 1'b0) begin
        tmp_rd <= {16'b0, controller_state};
        `ifdef ENABLE_TRACE
        `ifndef SYNTHESIS
        $display("Read from SPI P1: addr = 0x%h , data 0x%h", bus_addr, controller_state);
        `endif
        `endif
    end else begin
        tmp_rd <= {16'b0, controller_state_p2};
        `ifdef ENABLE_TRACE
        `ifndef SYNTHESIS
        $display("Read from SPI P2: addr = 0x%h , data 0x%h", bus_addr, controller_state_p2);
        `endif
        `endif
    end
end
```

### 7. Debug Signal Assignments (Optional)

**File**: [`cpu.sv`](../cpu.sv:54-58)

**Current**:
```systemverilog
assign button_left = ~controller_state[15];
assign button_down = ~controller_state[14];
assign button_right = ~controller_state[13];
assign button_up = ~controller_state[12];
```

**Keep as-is** (these are P1 debug outputs) or extend for P2:
```systemverilog
// P1 debug outputs (existing)
assign button_left = ~controller_state[15];
assign button_down = ~controller_state[14];
assign button_right = ~controller_state[13];
assign button_up = ~controller_state[12];

// P2 debug outputs (optional - would need new top-level ports)
// assign button_left_p2 = ~controller_state_p2[15];
// assign button_down_p2 = ~controller_state_p2[14];
// assign button_right_p2 = ~controller_state_p2[13];
// assign button_up_p2 = ~controller_state_p2[12];
```

## Pin Constraint Changes

### File: [`Prozessor.cst`](../Prozessor.cst)

**Add after line 32** (after P1 SPI pins):

```tcl
// P2 SPI Controller pins
IO_LOC "mosi_p2" G8;
IO_PORT "mosi_p2" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "cs_n_p2" G5;
IO_PORT "cs_n_p2" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "spi_clk_p2" J5;
IO_PORT "spi_clk_p2" IO_TYPE=LVCMOS33 PULL_MODE=NONE DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "miso_p2" H7;
IO_PORT "miso_p2" IO_TYPE=LVCMOS33 PULL_MODE=UP BANK_VCCIO=3.3;
```

**Also rename P1 signals** for consistency:
```tcl
// Change:
IO_LOC "mosi" G7;
// To:
IO_LOC "mosi_p1" G7;

// Change:
IO_LOC "cs_n" F5;
// To:
IO_LOC "cs_n_p1" F5;

// Change:
IO_LOC "spi_clk" H5;
// To:
IO_LOC "spi_clk_p1" H5;

// Change:
IO_LOC "miso" H8;
// To:
IO_LOC "miso_p1" H8;
```

## Documentation Updates

### 1. PINOUT.md

Update the PS2 controller section to clarify P1 vs P2:

```markdown
## Mapping of PS2 Dual Shock Controllers

### Player 1 (P1)
P1  | CS1N |  F5
    | MOSI |  G7
    | MISO |  H8
    | SCLK |  H5
    | GND  | GND
    | 3V3  | 3V3

### Player 2 (P2)
P2  | CS2N |  G5
    | MOSI |  G8
    | MISO |  H7
    | SCLK |  J5
    | GND  | GND
    | 3V3  | 3V3
```

### 2. architecture.md

Update memory map table:

```markdown
| Address Range | Device | Description |
|---------------|--------|-------------|
| `0x0000_0000` - `0x0000_FFFF` | **ROM** | Instruction Memory (imem) |
| `0x0001_0000` - `0x0001_FFFF` | **RAM** | Data Memory (dmem) |
| `0x0002_0000` - `0x0002_FFFF` | **Framebuffer** | 64x64 LED Matrix Buffer |
| `0x0003_0000` | **SPI Controller P1** | Player 1 Dualshock 2 Controller (16-bit) |
| `0x0003_0004` | **SPI Controller P2** | Player 2 Dualshock 2 Controller (16-bit) |
| `0x0003_0008` - `0x0003_FFFF` | Reserved | Future expansion |
```

### 3. README.md

Update peripherals section:

```markdown
### Peripherals
- **SPI Controllers**: Two independent SPI controllers continuously poll PS2 Dualshock 2 game controllers
  - **P1 Controller**: Memory-mapped at `0x0003_0000`
  - **P2 Controller**: Memory-mapped at `0x0003_0004`
- **LED Matrix Controller**: Drives a HUB75E-compatible 64x64 LED matrix using a dual-ported framebuffer.
```

## Test Application

### File: `apps/test-dual-controller/main.c`

```c
#include <stdint.h>

#define FRAMEBUFFER ((volatile uint8_t*)0x00020000)
#define CONTROLLER_P1 ((volatile uint16_t*)0x00030000)
#define CONTROLLER_P2 ((volatile uint16_t*)0x00030004)

// Button bit definitions (active-high)
#define BTN_SELECT   (1 << 0)
#define BTN_L3       (1 << 1)
#define BTN_R3       (1 << 2)
#define BTN_START    (1 << 3)
#define BTN_UP       (1 << 12)
#define BTN_RIGHT    (1 << 13)
#define BTN_DOWN     (1 << 14)
#define BTN_LEFT     (1 << 15)

void draw_pixel(int x, int y, uint8_t color) {
    if (x >= 0 && x < 64 && y >= 0 && y < 64) {
        FRAMEBUFFER[y * 64 + x] = color;
    }
}

void clear_screen(void) {
    for (int i = 0; i < 64 * 64; i++) {
        FRAMEBUFFER[i] = 0;
    }
}

int main(void) {
    int p1_x = 16, p1_y = 32;  // P1 position
    int p2_x = 48, p2_y = 32;  // P2 position
    
    clear_screen();
    
    while (1) {
        uint16_t p1_state = *CONTROLLER_P1;
        uint16_t p2_state = *CONTROLLER_P2;
        
        // Clear previous positions
        draw_pixel(p1_x, p1_y, 0);
        draw_pixel(p2_x, p2_y, 0);
        
        // Update P1 position (red)
        if (p1_state & BTN_UP)    p1_y = (p1_y > 0) ? p1_y - 1 : 0;
        if (p1_state & BTN_DOWN)  p1_y = (p1_y < 63) ? p1_y + 1 : 63;
        if (p1_state & BTN_LEFT)  p1_x = (p1_x > 0) ? p1_x - 1 : 0;
        if (p1_state & BTN_RIGHT) p1_x = (p1_x < 63) ? p1_x + 1 : 63;
        
        // Update P2 position (blue)
        if (p2_state & BTN_UP)    p2_y = (p2_y > 0) ? p2_y - 1 : 0;
        if (p2_state & BTN_DOWN)  p2_y = (p2_y < 63) ? p2_y + 1 : 63;
        if (p2_state & BTN_LEFT)  p2_x = (p2_x > 0) ? p2_x - 1 : 0;
        if (p2_state & BTN_RIGHT) p2_x = (p2_x < 63) ? p2_x + 1 : 63;
        
        // Draw new positions
        draw_pixel(p1_x, p1_y, 0b100);  // Red for P1
        draw_pixel(p2_x, p2_y, 0b001);  // Blue for P2
        
        // Small delay
        for (volatile int i = 0; i < 100000; i++);
    }
    
    return 0;
}
```

## Verification Checklist

### Pre-Implementation
- [ ] Verify P2 pins (G5, G8, H7, J5) are not used elsewhere
- [ ] Review current SPI controller implementation
- [ ] Confirm memory map addresses don't conflict

### During Implementation
- [ ] Rename P1 signals for consistency
- [ ] Add P2 module instantiation
- [ ] Update FSM address decoding
- [ ] Add pin constraints
- [ ] Update documentation

### Post-Implementation
- [ ] Compile without errors
- [ ] Simulate with test application
- [ ] Verify waveforms show both controllers polling
- [ ] Test address decoding (0x0003_0000 vs 0x0003_0004)
- [ ] Verify independent button states
- [ ] Test on hardware with two controllers

## Common Issues and Solutions

### Issue 1: Pin Conflicts
**Symptom**: Synthesis fails with pin assignment errors
**Solution**: Verify pins in PINOUT.md match Prozessor.cst exactly

### Issue 2: Wrong Controller Data
**Symptom**: Reading P2 returns P1 data
**Solution**: Check address decoding logic (bit 2 of address)

### Issue 3: No Data from P2
**Symptom**: P2 always reads 0x0000
**Solution**: Verify P2 SPI controller instantiation and wiring

### Issue 4: Simulation Errors
**Symptom**: Undefined signals in simulation
**Solution**: Ensure all new signals are declared and connected

## Summary of Changes

| File | Lines Changed | Description |
|------|---------------|-------------|
| [`cpu.sv`](../cpu.sv) | ~30 lines | Add P2 ports, wires, module, FSM updates |
| [`Prozessor.cst`](../Prozessor.cst) | ~12 lines | Add P2 pin constraints, rename P1 |
| [`PINOUT.md`](../PINOUT.md) | ~5 lines | Clarify P1/P2 sections |
| [`plans/architecture.md`](architecture.md) | ~3 lines | Update memory map |
| [`README.md`](../README.md) | ~3 lines | Update peripherals description |
| `apps/test-dual-controller/` | New | Test application |

**Total Estimated Changes**: ~50 lines of code + documentation
