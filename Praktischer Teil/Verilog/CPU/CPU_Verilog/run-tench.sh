#!/bin/sh
iverilog -g2012 -o build/tb.vvp src/tb.sv src/cpu.sv
vvp build/tb.vvp
gtkwave build/tb.vcd &
