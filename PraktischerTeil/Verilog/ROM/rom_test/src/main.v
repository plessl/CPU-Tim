module rom_module (
    input wire [31:0] addr,
    output wire[7:0] data
);

reg [31:0] mem [15:0];

initial begin
    $readmemh("rom_counter.mi", mem);
end

assign data = mem[addr][7:0];

endmodule



module topmodule(
    input wire sys_clk,
    input wire sys_rst,
    output wire[7:0] out,
    output reg clk_out
);

reg [31:0] counter;
reg [31:0] addr_connect;
reg [7:0] dout;

always @(posedge sys_clk) begin
    clk_out <= ~clk_out;
    if (!sys_rst) begin
        addr_connect <= counter;
        counter   <= counter + 1;
    end else begin
        counter   <= 0;
        addr_connect <= 0;
    end
end

always @(posedge sys_clk) begin
    $display(dout);
end

rom_module rom(
    .addr(addr_connect),
    .data(dout)
);

assign out = dout;

endmodule