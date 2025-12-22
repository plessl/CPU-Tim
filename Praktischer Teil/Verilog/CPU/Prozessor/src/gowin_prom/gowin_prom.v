//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12
//Part Number: GW5A-LV25MG121NC1/I0
//Device: GW5A-25
//Device Version: B
//Created Time: Mon Dec 22 17:04:40 2025

module Gowin_pROM (dout, clk, oce, ce, reset, ad);

output [31:0] dout;
input clk;
input oce;
input ce;
input reset;
input [4:0] ad;

wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO(dout[31:0]),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,gw_gnd,gw_gnd,gw_gnd,ad[4:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 32;
defparam prom_inst_0.RESET_MODE = "SYNC";

endmodule //Gowin_pROM
