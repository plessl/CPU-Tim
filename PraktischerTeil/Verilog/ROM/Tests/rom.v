module rom_module(
    input wire clk,
    input wire ce,
    input wire oce,
    input wire rst,
    input wire[31:0] addr,
    output reg[31:0] dout
);

reg [31:0] mem [1023:0];

inital begin
    $readmemh("rom.hex", mem);
end

always @(posedge clk) begin
    if(rst)begin
        dout <= 0;
    end
    else begin
        if(ce)begin
            dout <= mem[addr];
        end
    end
end
endmodule