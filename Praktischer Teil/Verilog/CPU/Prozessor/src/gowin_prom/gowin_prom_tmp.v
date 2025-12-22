//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12
//Part Number: GW5A-LV25MG121NC1/I0
//Device: GW5A-25
//Device Version: B
//Created Time: Mon Dec 22 17:04:40 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_pROM your_instance_name(
        .dout(dout), //output [31:0] dout
        .clk(clk), //input clk
        .oce(oce), //input oce
        .ce(ce), //input ce
        .reset(reset), //input reset
        .ad(ad) //input [4:0] ad
    );

//--------Copy end-------------------
