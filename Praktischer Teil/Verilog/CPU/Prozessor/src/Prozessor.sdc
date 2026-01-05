//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12 
//Created Time: 2026-01-02 16:49:51
create_clock -name clk -period 160 -waveform {0 80} [get_nets {clk}]
