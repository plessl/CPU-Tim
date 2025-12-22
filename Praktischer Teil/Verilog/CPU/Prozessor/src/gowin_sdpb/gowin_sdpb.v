//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12
//Part Number: GW5A-LV25MG121NC1/I0
//Device: GW5A-25
//Device Version: B
//Created Time: Sun Dec 21 12:18:25 2025

module Gowin_SDPB (dout, clka, cea, clkb, ceb, oce, reset, ada, din, adb, byte_ena);

output [31:0] dout;
input clka;
input cea;
input clkb;
input ceb;
input oce;
input reset;
input [4:0] ada;
input [31:0] din;
input [4:0] adb;
input [3:0] byte_ena;

wire [3:0] sdpx9b_inst_0_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;
/Users/theilmann/Jahresarbeit/Prozessor/src/gowin_sdpb/gowin_sdpb_tmp.v
SDPX9B sdpx9b_inst_0 (
    .DO({sdpx9b_inst_0_dout_w[3:0],dout[31:0]}),
    .CLKA(clka),
    .CEA(cea),
    .CLKB(clkb),
    .CEB(ceb),
    .OCE(oce),
    .RESET(reset)/Users/theilmann/Jahresarbeit/Prozessor/src/gowin_prom/gowin_prom.ipc,
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,ada[4:0],gw_gnd,byte_ena[3:0]}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[31:0]}),
    .ADB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,adb[4:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam sdpx9b_inst_0.READ_MODE = 1'b1;
defparam sdpx9b_inst_0.BIT_WIDTH_0 = 36;
defparam sdpx9b_inst_0.BIT_WIDTH_1 = 36;
defparam sdpx9b_inst_0.BLK_SEL_0 = 3'b000;
defparam sdpx9b_inst_0.BLK_SEL_1 = 3'b000;
defparam sdpx9b_inst_0.RESET_MODE = "ASYNC";

endmodule //Gowin_SDPB
