//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12.01 
//Created Time: 2026-01-23 20:31:06
create_clock -name clk -period 20 -waveform {0 10} [get_nets {clk}]
