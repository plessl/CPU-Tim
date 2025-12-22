# Makefile for CPU Verilog testbenches
# Supports iverilog simulation and yosys synthesis

# Directories
SRC_DIR = src
TEST_DIR = test
BUILD_DIR = build

# Source files
CPU_SRC = $(SRC_DIR)/cpu.v
RAM_SRC = $(SRC_DIR)/ram.v
ROM_SRC = $(SRC_DIR)/rom.v

# Test files
TB_RAM = $(TEST_DIR)/tb_ram.v
TB_ROM = $(TEST_DIR)/tb_rom.v
TB_FSM = $(TEST_DIR)/tb_fsm.v
TB_CPU = $(TEST_DIR)/tb.v

# Executables
IVERILOG = iverilog
VVP = vvp
YOSYS = yosys
GTKWAVE = gtkwave

# Build directory creation
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Default target - run all tests
.PHONY: all
all: test

# Run all tests
.PHONY: test
test: test_ram test_rom test_fsm test_cpu
	@echo "=========================================="
	@echo "All tests completed!"
	@echo "=========================================="

# Individual test targets
.PHONY: test_ram
test_ram: $(BUILD_DIR)
	@echo "=========================================="
	@echo "Running RAM testbench..."
	@echo "=========================================="
	$(IVERILOG) -g2012 -o $(BUILD_DIR)/tb_ram.vvp $(TB_RAM) $(CPU_SRC)
	$(VVP) $(BUILD_DIR)/tb_ram.vvp
	@mv tb_ram.vcd $(BUILD_DIR)/ 2>/dev/null || true

.PHONY: test_rom
test_rom: $(BUILD_DIR)
	@echo "=========================================="
	@echo "Running ROM testbench..."
	@echo "=========================================="
	$(IVERILOG) -g2012 -o $(BUILD_DIR)/tb_rom.vvp $(TB_ROM) $(CPU_SRC)
	$(VVP) $(BUILD_DIR)/tb_rom.vvp
	@mv tb_rom.vcd $(BUILD_DIR)/ 2>/dev/null || true

.PHONY: test_fsm
test_fsm: $(BUILD_DIR)
	@echo "=========================================="
	@echo "Running FSM testbench..."
	@echo "=========================================="
	$(IVERILOG) -g2012 -o $(BUILD_DIR)/tb_fsm.vvp $(TB_FSM) $(CPU_SRC)
	$(VVP) $(BUILD_DIR)/tb_fsm.vvp
	@mv tb_fsm.vcd $(BUILD_DIR)/ 2>/dev/null || true

.PHONY: test_cpu
test_cpu: $(BUILD_DIR)
	@echo "=========================================="
	@echo "Running CPU integration testbench..."
	@echo "=========================================="
	$(IVERILOG) -g2012 -o $(BUILD_DIR)/tb_cpu.vvp $(TB_CPU) $(CPU_SRC)
	$(VVP) $(BUILD_DIR)/tb_cpu.vvp
	@mv tb_cpu.vcd $(BUILD_DIR)/ 2>/dev/null || true

# Yosys synthesis targets
.PHONY: synth
synth: synth_cpu synth_ram synth_rom

.PHONY: synth_cpu
synth_cpu: $(BUILD_DIR)
	@echo "=========================================="
	@echo "Synthesizing CPU with Yosys..."
	@echo "=========================================="
	$(YOSYS) -p "read_verilog -sv $(CPU_SRC); hierarchy -check -top topmodule; proc; opt; stat" > $(BUILD_DIR)/synth_cpu.log

.PHONY: synth_ram
synth_ram: $(BUILD_DIR)
	@echo "=========================================="
	@echo "Synthesizing RAM with Yosys..."
	@echo "=========================================="
	$(YOSYS) -p "read_verilog -sv $(CPU_SRC); hierarchy -check -top ram_module; proc; opt; stat" > $(BUILD_DIR)/synth_ram.log

.PHONY: synth_rom
synth_rom: $(BUILD_DIR)
	@echo "=========================================="
	@echo "Synthesizing ROM with Yosys..."
	@echo "=========================================="
	$(YOSYS) -p "read_verilog -sv $(CPU_SRC); hierarchy -check -top rom_module; proc; opt; stat" > $(BUILD_DIR)/synth_rom.log

.PHONY: synth_fsm
synth_fsm: $(BUILD_DIR)
	@echo "=========================================="
	@echo "Synthesizing FSM with Yosys..."
	@echo "=========================================="
	$(YOSYS) -p "read_verilog -sv $(CPU_SRC); hierarchy -check -top fsm; proc; opt; stat" > $(BUILD_DIR)/synth_fsm.log

# View waveforms with gtkwave (if available)
.PHONY: wave_ram
wave_ram:
	$(GTKWAVE) $(BUILD_DIR)/tb_ram.vcd &

.PHONY: wave_rom
wave_rom:
	$(GTKWAVE) $(BUILD_DIR)/tb_rom.vcd &

.PHONY: wave_fsm
wave_fsm:
	$(GTKWAVE) $(BUILD_DIR)/tb_fsm.vcd &

.PHONY: wave_cpu
wave_cpu:
	$(GTKWAVE) $(BUILD_DIR)/tb_cpu.vcd &

# Clean build artifacts
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -f *.vcd *.vvp

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all         - Run all tests (default)"
	@echo "  test        - Run all tests"
	@echo "  test_ram    - Run RAM testbench"
	@echo "  test_rom    - Run ROM testbench"
	@echo "  test_fsm    - Run FSM testbench"
	@echo "  test_cpu    - Run CPU integration test"
	@echo "  synth       - Synthesize all modules with Yosys"
	@echo "  synth_cpu   - Synthesize CPU with Yosys"
	@echo "  synth_ram   - Synthesize RAM with Yosys"
	@echo "  synth_rom   - Synthesize ROM with Yosys"
	@echo "  synth_fsm   - Synthesize FSM with Yosys"
	@echo "  wave_*      - View waveform for specific test (requires GTKWave)"
	@echo "  clean       - Remove build artifacts"
	@echo "  help        - Show this help message"
