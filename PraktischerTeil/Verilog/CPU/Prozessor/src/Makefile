.PHONY: all run gtkwave schematic schematic-minimal schematic-all clean-schematic

all: sim

tb.vvp: test/tb.sv cpu.sv
	iverilog -g2012 -o tb.vvp test/tb.sv cpu.sv

sim: tb.vvp
	vvp tb.vvp

# Generate flattened schematic
schematic:
	yosys gen_schematic.ys
	dot -Tpdf -Grankdir=LR -Gsplines=ortho cpu_flat_schematic.dot -o cpu_flat.pdf
	@echo "Generated: cpu_flat.pdf"

# Generate minimal optimized schematic
schematic-minimal:
	yosys gen_simple_schematic.ys
	dot -Tpdf -Grankdir=LR -Gsplines=ortho cpu_minimal_schematic.dot -o cpu_minimal.pdf
	@echo "Generated: cpu_minimal.pdf"

# Generate all schematics (flat + minimal + SVG)
schematic-all:
	./gen_all_schematics.sh

clean:
	rm -rf tb.vvp

clean-schematic:
	rm -f *.dot cpu_flat.pdf cpu_minimal.pdf cpu_flat.svg cpu_flat.v

show:
	gtkwave tb.vcd &

