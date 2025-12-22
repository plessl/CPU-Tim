module led (
    input sys_clk,          // clk input
    input sys_rst,        // reset input
    output reg [1:0] led    // 
);

reg [23:0] counter;

always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        counter <= 24'd0;
    else if (counter < 24'd1349_9999)
        counter <= counter + 1'b1;
    else
        counter <= 24'd0;
end

always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        led <= 1'b1;
    /*else if (counter == 24'd1349_9999)
        led[1:0] <= {led[0],led[1]};*/
    else
        led <= counter[23:22];
end

endmodule