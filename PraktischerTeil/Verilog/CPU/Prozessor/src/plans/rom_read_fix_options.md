# ROM Data Read Fix - Options Analysis

## Problem Summary
The CPU cannot read data from ROM (0x0000_xxxx range), only from RAM (0x0001_xxxx). This breaks the boot code's `.data` section copy from ROM to RAM.

## Option 1: Software Workaround (RECOMMENDED - Least Invasive)

### Approach
Eliminate the need for ROM data reads by changing the linker script to place `.data` directly in RAM and initialize it to zero.

### Changes Required

#### 1. Update Linker Script (`test/unit/link.ld`)
```ld
SECTIONS
{
    .text : {
        *(.text*)
    } > ROM

    /* Place .data directly in RAM, don't load from ROM */
    .data : {
        __data_start = .;
        *(.data*)
        __data_end = .;
    } > RAM AT> RAM  /* Changed from AT> ROM */

    .bss : {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    } > RAM
}
```

#### 2. Update Boot Code (`test/unit/boot.s`)
```assembly
_start:
    /* Set up stack */
    la      sp, __stack_top

    /* Set up global pointer */
    .option push
    .option norelax
    la      gp, __global_pointer$
    .option pop

    /* REMOVE the .data copy loop - not needed anymore */
    /* Data is already in RAM */

    /* Zero .bss */
    la      a1, __bss_start
    la      a2, __bss_end
3:
    beq     a1, a2, 4f
    sw      zero, 0(a1)
    addi    a1, a1, 4
    j       3b
4:
    /* Call main */
    call    main

hang:
    j       hang
```

#### 3. Compiler Flags
No changes needed - the existing flags work fine.

### Pros
- ✅ **Zero hardware changes** - no CPU modifications needed
- ✅ **Simplest solution** - just linker script and boot code changes
- ✅ **Works immediately** - no debugging of new hardware features
- ✅ **Standard practice** - many embedded systems do this
- ✅ **Faster boot** - no copy loop needed

### Cons
- ❌ **Wastes RAM** - initialized data takes up RAM space
- ❌ **Larger binary** - `.data` values must be in the binary to initialize RAM
- ❌ **Not true Harvard architecture** - can't have read-only data in ROM

### Impact
- RAM usage: Minimal (most programs have small `.data` sections)
- ROM usage: Slightly larger (must include `.data` initialization values)
- Boot time: Faster (no copy loop)

---

## Option 2: Reuse Instruction Port (Medium Invasiveness)

### Approach
Use the existing ROM instruction port (`instr`) for data reads when accessing ROM addresses.

### Changes Required

#### In FSM Module - EXECUTE State
```systemverilog
7'b0000011: begin  // Load
    set_rd_flag <= 0;
    bus_addr <= regfile[rs1] + imm;
    
    if(((regfile[rs1] + imm) >> 16) == 16'h0000) begin
        imem_ce <= 1;  // Enable ROM
    end
    else if(((regfile[rs1] + imm) >> 16) == 16'h0001) begin
        dmem_ce <= 1;
        dmem_read <= 1;
    end
    else if(((regfile[rs1] + imm) >> 16) == 16'h0003) begin
        spi_ce <= 1;
        spi_re <= 1;
    end
end
```

#### In FSM Module - MEMORY1 State
```systemverilog
7'b0000011: begin  // Load
    if(bus_addr[31:16] == 16'h0000) begin
        imem_ce <= 1;  // Keep ROM enabled
    end
    else if(bus_addr[31:16] == 16'h0001) begin
        dmem_ce <= 1;
        dmem_read <= 1;
    end
end
```

#### In FSM Module - MEMORY2 State
```systemverilog
7'b0000011: begin  // Load
    set_rd_flag <= 1;
    
    if(bus_addr[31:16] == 16'h0000) begin  // ROM read
        case (funct3)
            3'b000: begin  // lb
                case (bus_addr[1:0])
                    2'b00: tmp_rd <= {{24{instr[7]}}, instr[7:0]};
                    2'b01: tmp_rd <= {{24{instr[15]}}, instr[15:8]};
                    2'b10: tmp_rd <= {{24{instr[23]}}, instr[23:16]};
                    2'b11: tmp_rd <= {{24{instr[31]}}, instr[31:24]};
                endcase
            end
            3'b001: begin  // lh
                case (bus_addr[1:0])
                    2'b00: tmp_rd <= {{16{instr[15]}}, instr[15:0]};
                    2'b10: tmp_rd <= {{16{instr[31]}}, instr[31:16]};
                endcase
            end
            3'b010: tmp_rd <= instr;  // lw
            3'b100: begin  // lbu
                case (bus_addr[1:0])
                    2'b00: tmp_rd <= {24'b0, instr[7:0]};
                    2'b01: tmp_rd <= {24'b0, instr[15:8]};
                    2'b10: tmp_rd <= {24'b0, instr[23:16]};
                    2'b11: tmp_rd <= {24'b0, instr[31:24]};
                endcase
            end
            3'b101: begin  // lhu
                case (bus_addr[1:0])
                    2'b00: tmp_rd <= {16'b0, instr[15:0]};
                    2'b10: tmp_rd <= {16'b0, instr[31:16]};
                endcase
            end
        endcase
    end
    else if(bus_addr[31:16] == 16'h0003) begin
        // ... existing SPI code
    end
    else if(bus_addr[31:16] == 16'h0001) begin
        // ... existing RAM code
    end
end
```

#### In FSM Module - Add Signal
```systemverilog
// At top of FSM module, add to port list:
input  logic [31:0] instr,  // Already exists for instruction fetch
```

#### In Top Module - Update Connection
```systemverilog
// Already connected - no changes needed!
fsm machine(
    .instr(instr),  // Already connected
    // ...
);
```

### Pros
- ✅ **Reuses existing hardware** - no new ROM port needed
- ✅ **Minimal changes** - just FSM logic updates
- ✅ **True Harvard architecture** - ROM for code and const data
- ✅ **Efficient RAM usage** - const data stays in ROM

### Cons
- ❌ **Potential timing issue** - `instr_addr` vs `bus_addr` conflict
- ❌ **Can't fetch instruction and read data simultaneously**
- ❌ **More complex FSM** - additional state management

### Risks
- If an instruction fetch happens while doing a data read from ROM, the addresses will conflict
- Need to ensure `instr_addr` is set to `bus_addr` during ROM data reads

---

## Option 3: Add Dedicated Data ROM Port (Most Invasive)

### Approach
Add a second ROM port specifically for data reads.

### Changes Required

#### In ROM Module
```systemverilog
module rom_module (
    input  logic        clk,
    input  logic        ce,
    input  logic        oce,
    input  logic        rst,
    input  logic [31:0] addr,
    output logic [31:0] dout,
    
    // Add data port
    input  logic        data_ce,
    input  logic [31:0] data_addr,
    output logic [31:0] data_out
);

reg [31:0] rom_mem [4095:0];

initial begin
    $readmemh("rom.mi", rom_mem);
end

assign dout = ce ? rom_mem[addr >> 2] : 32'b0;
assign data_out = data_ce ? rom_mem[data_addr >> 2] : 32'b0;

endmodule
```

#### In Top Module
```systemverilog
wire rom_data_ce;
wire [31:0] rom_data_addr;
wire [31:0] rom_data_out;

rom_module imem (
    .clk(clk),
    .rst(rst),
    .ce(imem_ce),
    .oce(1'b1),
    .addr(instr_addr),
    .dout(instr),
    
    // Data port
    .data_ce(rom_data_ce),
    .data_addr(bus_addr),
    .data_out(rom_data_out)
);

// Add bus multiplexer
wire [31:0] bus_rdata_mux;
assign bus_rdata_mux = (bus_addr[31:16] == 16'h0000) ? rom_data_out : dmem_rdata;

fsm machine(
    .bus_rdata(bus_rdata_mux),  // Changed
    .rom_data_ce(rom_data_ce),  // New
    // ...
);
```

#### In FSM Module
Similar to Option 2, but use `rom_data_ce` instead of `imem_ce`.

### Pros
- ✅ **Clean separation** - instruction and data paths independent
- ✅ **No timing conflicts** - can fetch and read data simultaneously
- ✅ **True dual-port ROM** - proper Harvard architecture

### Cons
- ❌ **Most invasive** - requires ROM module changes
- ❌ **More hardware** - additional ROM port (may not synthesize well)
- ❌ **Complexity** - bus multiplexing logic needed

---

## Recommendation: Option 1 (Software Workaround)

### Why?
1. **Zero risk** - no hardware changes means no new bugs
2. **Immediate solution** - just update linker script and boot code
3. **Standard practice** - most embedded systems initialize RAM from flash/ROM at startup, but the data lives in RAM
4. **Minimal impact** - typical programs have small `.data` sections (a few hundred bytes at most)

### When to Consider Option 2 or 3?
- If you have **large const data** (lookup tables, fonts, images) that should stay in ROM
- If you need to **save RAM** for runtime data
- If you want a **true Harvard architecture** with ROM-based constants

### Implementation for Option 1

I can help you:
1. Update the linker script to place `.data` in RAM
2. Simplify the boot code to remove the ROM copy loop
3. Rerun the tests to verify everything works

This will take about 5 minutes and has zero risk of breaking anything.

### Alternative: Hybrid Approach

You could also:
- Use Option 1 for now (quick fix)
- Implement Option 2 later if you need ROM-based const data
- Use compiler attributes to mark specific data as const and place it in a special ROM section

Would you like me to implement Option 1 (software workaround)?
