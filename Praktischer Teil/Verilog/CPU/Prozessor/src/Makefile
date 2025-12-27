.PHONY: all run gtkwave

all: sim

tb.vvp: test/tb.sv cpu.sv
	iverilog -g2012 -o tb.vvp test/tb.sv cpu.sv

sim: tb.vvp
	vvp tb.vvp

clean:
	rm -rf tb.vvp

show:
	gtkwave tb.vcd &

