# Implementing ROM Data Reads for Traditional Boot

## Overview

To support the traditional boot approach where `.data` is copied from ROM to RAM, the CPU needs to be able to read data from ROM (0x0000_xxxx range), not just instructions.

## Current Situation

- ✅ All tests pass with pre-initialized RAM approach
- ❌ CPU cannot read data from ROM
- ✅ RAM has 1-cycle read latency (fixed)

## Required Changes for ROM Data Reads

### Option A: Reuse Instruction Port (RECOMMENDED)

This approach reuses the existing ROM instruction port for data reads when accessing ROM addresses.

#### Change 1: FSM Module - Add ROM Read Support in EXECUTE

**File**: [`cpu.sv`](../cpu.sv:876)

```systemverilog
7'b0000011: begin  // Load
    set_rd_flag <= 0;
    bus_addr <= regfile[rs1] + imm;
    
    // Add ROM read support
    if(((regfile[rs1] + imm) >> 16) == 16'h0000) begin
        // Reading from ROM - use instruction port
        imem_ce <= 1;
        // Set instr_addr to the data address
        // Note: This will conflict with instruction fetch!
        // We need to multiplex instr_addr
    end
    else if(((regfile[rs1] + imm) >> 16) == 16'h0001) begin
        dmem_ce <= 1;
        dmem_read <= 1;
    end
    else if(((regfile[rs1] + imm) >> 16) == 16'h0003) begin
        spi_ce <= 1'b1;
        spi_re <= 1'b1;
    end
end
```

**Problem**: This creates a conflict - `instr_addr` is used for instruction fetch, but we need it for data read. We need to multiplex it.

#### Change 2: FSM Module - Add Address Multiplexing

**File**: [`cpu.sv`](../cpu.sv:650)

Add a new signal and logic to multiplex the instruction address:

```systemverilog
// In FSM module ports
output logic [31:0] instr_addr,
output logic        data_read_from_rom,  // New signal

// In FSM module logic
reg data_read_from_rom_reg;

// In EXECUTE state for loads from ROM
if(((regfile[rs1] + imm) >> 16) == 16'h0000) begin
    data_read_from_rom_reg <= 1;
    // instr_addr will be set to bus_addr in FETCH
end

// In FETCH state
if (data_read_from_rom_reg) begin
    instr_addr <= bus_addr;  // Use data address instead of PC
    imem_ce <= 1;
end else begin
    instr_addr <= pc;  // Normal instruction fetch
    imem_ce <= 1;
end

// Clear flag after use
if (state == WRITEBACK) begin
    data_read_from_rom_reg <= 0;
end
```

**Problem**: This is getting complex and creates timing issues.

#### Change 3: FSM Module - Handle ROM Data in MEMORY2

**File**: [`cpu.sv`](../cpu.sv:1038)

```systemverilog
MEMORY2: begin
    state <= WRITEBACK;
    case(opcode) 
        7'b0000011: begin  // Load
            set_rd_flag <= 1;
            
            // Add ROM read handling
            if(bus_addr[31:16] == 16'h0000) begin
                // Reading from ROM - data is in 'instr' signal
                case (funct3)
                    3'b010: tmp_rd <= instr;  // lw
                    3'b000: begin  // lb
                        case (bus_addr[1:0])
                            2'b00: tmp_rd <= {{24{instr[7]}}, instr[7:0]};
                            2'b01: tmp_rd <= {{24{instr[15]}}, instr[15:8]};
                            2'b10: tmp_rd <= {{24{instr[23]}}, instr[23:16]};
                            2'b11: tmp_rd <= {{24{instr[31]}}, instr[31:24]};
                        endcase
                    end
                    // Add other load types (lh, lbu, lhu)
                endcase
            end
            else if(bus_addr[31:16] == 16'h0003) begin
                // SPI read (existing code)
            end
            else if(bus_addr[31:16] == 16'h0001) begin
                // RAM read (existing code)
            end
        end
    end
end
```

### Complexity Analysis

This approach has several issues:

1. **Address Multiplexing**: Need to switch `instr_addr` between PC and `bus_addr`
2. **Timing Conflicts**: Can't fetch next instruction while reading data from ROM
3. **State Machine Complexity**: Need additional states or flags
4. **Testing**: Need to verify no regressions in instruction fetch

### Alternative: Keep Current Approach

The current approach (pre-initialized RAM) is simpler and has several advantages:

**Pros**:
- ✅ No CPU changes needed
- ✅ Simpler boot code
- ✅ Faster boot (no copy loop)
- ✅ No timing conflicts
- ✅ All tests pass

**Cons**:
- ❌ RAM must be initialized from binary
- ❌ Can't have true read-only const data in ROM

### Recommendation

**Keep the current approach** unless you have a specific need for ROM-based const data. The benefits outweigh the drawbacks for most embedded applications.

If you DO need ROM data reads (for large lookup tables, fonts, etc.), I recommend:

1. Implement Option 2 from [`rom_read_fix_options.md`](plans/rom_read_fix_options.md)
2. Add a dedicated MEMORY3 state for ROM reads to avoid timing conflicts
3. Thoroughly test with the unit test suite

### Current Status

✅ **All 9 unit tests pass**
✅ **Integration test passes**  
✅ **Function calls work correctly**
✅ **Global variables work correctly**
✅ **Stack management works correctly**

The processor core is now fully functional for C programs with function calls and global variables!