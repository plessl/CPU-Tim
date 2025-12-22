//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12
//Part Number: GW5A-LV25MG121NC1/I0
//Device: GW5A-25
//Device Version: B
//Created Time: Sun Dec 21 12:18:25 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_SDPB your_instance_name(
        .dout(dout), //output [31:0] dout
        .clka(clka), //input clka
        .cea(cea), //input cea
        .clkb(clkb), //input clkb
        .ceb(ceb), //input ceb
        .oce(oce), //input oce
        .reset(reset), //input reset
        .ada(ada), //input [4:0] ada
        .din(din), //input [31:0] din
        .adb(adb), //input [4:0] adb
        .byte_ena(byte_ena) //input [3:0] byte_ena
    );

//--------Copy end-------------------
