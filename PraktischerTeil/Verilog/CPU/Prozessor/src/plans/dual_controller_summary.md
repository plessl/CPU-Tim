# Dual PS2 DualShock Controller Support - Implementation Summary

## Executive Summary

This document provides a comprehensive plan for adding support for a second PS2 DualShock controller to the RISC-V RV32I FPGA Core. The implementation uses independent autonomous polling for both controllers with address-based selection in the CPU FSM.

## Key Design Decisions

### 1. Independent Autonomous Polling (Selected Approach)
- **Both controllers poll continuously and independently**
- No arbiter or round-robin state machine needed
- Simpler implementation with minimal code changes
- Both controllers maintain full polling rate (~66Hz)
- Address decoding in FSM selects which controller state to read

### 2. Memory Mapping
- **P1 Controller**: `0x0003_0000` (existing)
- **P2 Controller**: `0x0003_0004` (new)
- Address bit 2 used for controller selection (0=P1, 1=P2)

### 3. Pin Assignments
All P2 pins verified as available:
- CS2N: G5
- MOSI: G8  
- MISO: H7
- SCLK: J5

## Implementation Overview

### Files to Modify

| File | Changes | Complexity |
|------|---------|------------|
| [`cpu.sv`](../cpu.sv) | Add P2 ports, wires, module instance, FSM decode | Medium |
| [`Prozessor.cst`](../Prozessor.cst) | Add P2 pin constraints, rename P1 signals | Low |
| [`PINOUT.md`](../PINOUT.md) | Clarify P1/P2 sections | Low |
| [`plans/architecture.md`](architecture.md) | Update memory map table | Low |
| [`README.md`](../README.md) | Update peripherals description | Low |

### New Files to Create

| File | Purpose |
|------|---------|
| `apps/test-dual-controller/` | Test application for dual controller |
| [`plans/dual_controller_design.md`](dual_controller_design.md) | Design rationale and architecture |
| [`plans/dual_controller_implementation_guide.md`](dual_controller_implementation_guide.md) | Step-by-step implementation guide |
| [`plans/dual_controller_architecture_diagram.md`](dual_controller_architecture_diagram.md) | Visual diagrams and flowcharts |

## Code Changes Summary

### 1. Top Module I/O (cpu.sv)
```systemverilog
// Change from:
output logic spi_clk, cs_n, mosi;
input  logic miso;

// To:
output logic spi_clk_p1, cs_n_p1, mosi_p1;
input  logic miso_p1;
output logic spi_clk_p2, cs_n_p2, mosi_p2;  // NEW
input  logic miso_p2;                        // NEW
```

### 2. Wire Declarations (cpu.sv)
```systemverilog
wire [15:0] controller_state;      // P1 (existing)
wire [15:0] controller_state_p2;   // P2 (NEW)
```

### 3. Module Instantiation (cpu.sv)
```systemverilog
// Rename existing instance to spi_ctrl_p1
// Add new instance spi_ctrl_p2 with P2 signals
```

### 4. FSM Interface (cpu.sv)
```systemverilog
module fsm (
    // ... existing ports ...
    input logic [15:0] controller_state,     // P1
    input logic [15:0] controller_state_p2   // P2 (NEW)
);
```

### 5. FSM Address Decoding (cpu.sv, MEMORY2 stage)
```systemverilog
if(bus_addr[31:16] == 16'h0003) begin
    if(bus_addr[2] == 1'b0) begin
        tmp_rd <= {16'b0, controller_state};      // P1
    end else begin
        tmp_rd <= {16'b0, controller_state_p2};   // P2 (NEW)
    end
end
```

### 6. Pin Constraints (Prozessor.cst)
```tcl
// Rename P1 signals: mosi -> mosi_p1, etc.
// Add P2 signals: mosi_p2, cs_n_p2, spi_clk_p2, miso_p2
```

## Software Interface

### C Code Example
```c
#define CONTROLLER_P1 ((volatile uint16_t*)0x00030000)
#define CONTROLLER_P2 ((volatile uint16_t*)0x00030004)

uint16_t p1_state = *CONTROLLER_P1;
uint16_t p2_state = *CONTROLLER_P2;
```

### Button Bit Definitions
```c
#define BTN_LEFT   (1 << 15)
#define BTN_DOWN   (1 << 14)
#define BTN_RIGHT  (1 << 13)
#define BTN_UP     (1 << 12)
// ... see controller_register_bits.md for full mapping
```

## Testing Strategy

### 1. Simulation Testing
- Compile with test application
- Run simulation with `make sim`
- Verify waveforms show both SPI controllers polling
- Verify address decoding (0x0003_0000 vs 0x0003_0004)
- Check trace output for correct controller reads

### 2. Hardware Testing
- Connect two PS2 DualShock controllers
- Load test application to FPGA
- Verify independent control of two cursors/players
- Test all buttons on both controllers

### 3. Regression Testing
- Verify existing P1-only applications still work
- Test backward compatibility
- Ensure no performance degradation

## Benefits

1. **Multiplayer Support**: Enable 2-player games
2. **Simple Implementation**: Minimal code changes (~50 lines)
3. **No Performance Impact**: Both controllers poll at full rate
4. **Backward Compatible**: Existing P1 code unchanged
5. **Extensible**: Easy to add P3/P4 controllers later

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Pin conflicts | High | Verified all P2 pins available |
| Timing issues | Medium | Independent polling, no shared resources |
| Resource usage | Low | Second controller identical to first |
| Polling interference | Low | Controllers poll independently |

## Resource Utilization

| Resource | Increase | Notes |
|----------|----------|-------|
| LUTs | ~50 | Second SPI controller module |
| Registers | ~20 | Controller state and FSM |
| I/O Pins | +4 | P2 SPI signals |
| Block RAM | 0 | No additional memory |

## Timeline Estimate

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Hardware modifications | 2-3 hours | None |
| Pin constraints | 30 minutes | Hardware complete |
| Documentation updates | 1 hour | Hardware complete |
| Test application | 1-2 hours | Hardware complete |
| Simulation testing | 1 hour | Test app complete |
| Hardware verification | 1 hour | Simulation pass |
| **Total** | **6-8 hours** | - |

## Documentation Created

1. **[`dual_controller_design.md`](dual_controller_design.md)** - Design rationale, architecture, and detailed analysis
2. **[`dual_controller_implementation_guide.md`](dual_controller_implementation_guide.md)** - Step-by-step implementation instructions with code snippets
3. **[`dual_controller_architecture_diagram.md`](dual_controller_architecture_diagram.md)** - Mermaid diagrams showing system architecture, data flow, and timing
4. **[`dual_controller_summary.md`](dual_controller_summary.md)** - This document

## Next Steps

### For Review and Approval
1. Review the design documents
2. Verify pin assignments are correct
3. Approve the implementation approach
4. Confirm memory map addresses

### For Implementation (Code Mode)
1. Modify [`cpu.sv`](../cpu.sv) with P2 support
2. Update [`Prozessor.cst`](../Prozessor.cst) with pin constraints
3. Update documentation files
4. Create test application
5. Run simulation and verify
6. Test on hardware

## Questions for Clarification

Before proceeding with implementation, please confirm:

1. ✅ **Memory Address**: Is `0x0003_0004` acceptable for P2 controller?
2. ✅ **Pin Assignments**: Are the P2 pins (G5, G8, H7, J5) correct per PINOUT.md?
3. ✅ **Polling Strategy**: Is independent autonomous polling (not round-robin) acceptable?
4. ❓ **Debug Outputs**: Should we add P2 debug button outputs to top module?
5. ❓ **Test Application**: What type of test application would you prefer (dual cursor, simple game, etc.)?

## References

### Design Documents
- [`dual_controller_design.md`](dual_controller_design.md) - Complete design specification
- [`dual_controller_implementation_guide.md`](dual_controller_implementation_guide.md) - Implementation instructions
- [`dual_controller_architecture_diagram.md`](dual_controller_architecture_diagram.md) - Visual diagrams

### Existing Documentation
- [`cpu.sv`](../cpu.sv) - Main hardware implementation
- [`PINOUT.md`](../PINOUT.md) - Pin assignments
- [`Prozessor.cst`](../Prozessor.cst) - FPGA constraints
- [`plans/architecture.md`](architecture.md) - System architecture
- [`plans/controller_register_bits.md`](controller_register_bits.md) - Button mapping
- [`README.md`](../README.md) - Project overview

### Example Applications
- [`apps/show-controller/`](../apps/show-controller/) - Single controller example
- [`apps/snake-simple/`](../apps/snake-simple/) - Game using controller

## Conclusion

The dual controller implementation is straightforward and low-risk. The design uses independent autonomous polling for simplicity, requiring minimal code changes (~50 lines) while maintaining full functionality and performance. All necessary documentation has been created to guide the implementation.

**Recommendation**: Proceed with implementation in Code mode once the plan is approved.
