module ram_module(
    input wire clk,
    input wire we,
    input wire ce,
    input wire rst,
    input wire[15:0] addr,
    input wire[31:0] data_in,
    output wire[31:0] data_out
);

reg [31:0] mem [16383:0];

assign data_out = (ce & !we) ? mem[addr >> 2] : 32'b0;

always @(posedge clk) begin
    if(ce & we)
        mem[addr >> 2] <= data_in;
end
    
endmodule