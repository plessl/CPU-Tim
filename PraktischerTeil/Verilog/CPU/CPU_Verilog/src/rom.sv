module rom_module (
        input wire clk,
        input wire rst,
        input wire ce,
        input wire[15:0] addr,
        output reg [31:0] dout
    );

    reg [31:0] mem [16383:0];

    /*initial begin
        $readmemh("program.hex", mem);
    end*/

    wire [31:0] comb_read = mem[addr >> 2];

    always @(posedge clk or posedge rst) begin
        if(rst)
            dout <= 0;
        else begin
            if(ce) begin
                dout <= comb_read;
            end
        end
    end
    
endmodule