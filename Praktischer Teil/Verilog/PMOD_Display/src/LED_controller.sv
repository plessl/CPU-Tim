/*
iverilog -g2012 -o LED_controller_tb.vvp test/LED_controller_tb.sv LED_controller.sv
vvp LED_controller_tb.vvp
*/

module LED_Controller #(
    parameter WIDTH = 64,
    parameter HEIGHT = 64,
    parameter ROWS = 32,
    parameter COLUMNS = 64
)
(
    input wire clk,
    input wire rst,
    output logic[4:0] row_addr,
    output logic[5:0] col_addr,
    output logic oe,
    output logic re,
    output logic latch,
    output logic display_clk
);
/*
reg [4:0] row_counter;
reg [5:0] col_counter;
*/
typedef enum reg [3:0]
{   
    FETCH = 4'd0,
    SHIFT1 = 4'd1,
    SHIFT2 = 4'd2,
    LATCH_HIGH = 4'd3,
    LATCH_LOW = 4'd4,
    WAIT = 4'd5
    
} controller_statetype;

controller_statetype con_state;

localparam WAIT_CYCLES  =  16'd3;

logic[15:0] wait_cntr;

always @(posedge clk or posedge rst) begin
    if(rst)begin
        con_state <= FETCH;
        display_clk <= 1'b0;
        row_addr <= '1;
        col_addr <= '1;
        oe <= 1'b1;
        re <= 1'b0;
        latch <= 1'b0;
        wait_cntr <= '0;
        end
        else begin
        case (con_state)
            FETCH: begin
                display_clk <= 1'b0;
                col_addr <= col_addr;
                row_addr <= row_addr;
                con_state <= SHIFT1;
                re <= 1'b1;
                oe <= 1'b1;
                latch <= 1'b0;
            end
            SHIFT1: begin
                display_clk <= 1'b1;
                oe <= 1'b1;
                re <= 1'b1;
                con_state <= SHIFT2;
            end
            SHIFT2: begin           
                display_clk <= 1'b0;
                re <= 1'b0;
                if(col_addr == COLUMNS - 1) begin
                    con_state <= LATCH_HIGH;
                    oe <= 1'b1;
                    col_addr <= '0;
                end else begin
                    con_state <= FETCH;
                    col_addr <= col_addr + 1'b1;
                    oe <= 1'b1;
                end
            end
            LATCH_HIGH: begin
                latch <= 1'b1;
                display_clk <= 1'b0;
                oe <= 1'b1;
                con_state <= LATCH_LOW;
            end
            LATCH_LOW: begin
                latch <= 1'b1;
                display_clk <= 1'b0;
                oe <= 1'b1;
                row_addr <= row_addr + 1'b1;
                con_state <= WAIT;
            end
            WAIT: begin
                display_clk <= 1'b0;
                latch <= 1'b0;
                oe <= 1'b0;
                if(wait_cntr < WAIT_CYCLES - 1) begin
                    wait_cntr <= wait_cntr + 1'b1;
                    con_state <= WAIT;
                end else begin
                    wait_cntr <= '0;
                    oe <= 1'b1;
                    con_state <= FETCH;
                end
            end
        endcase
    end
end
endmodule

module framebuffer(
    input logic clk,
    input logic rst,
    input logic [3:0] din,
    input logic ce,
    input logic re,
    input logic [11:0] waddr,
    input logic we,
    input logic [11:0] raddr_a,
    input logic [11:0] raddr_b,
    output logic [3:0] dout_a,
    output logic [3:0] dout_b
);

reg [3:0] mem_a [4095:0];
reg [3:0] mem_b [4095:0];

initial begin
    $readmemb("led.mi", mem_a, 0, 4095);
    $readmemb("led.mi", mem_b, 0, 4095);
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        dout_a <= '0;
        dout_b <= '0;
    end else begin
        if (we && ce) begin
            mem_a[waddr] <= din;
            mem_b[waddr] <= din;
        end
        if (re && ce) begin
            dout_a <= mem_a[raddr_a];
            dout_b <= mem_b[raddr_b];
        end
    end
end

endmodule


module top(
    input logic clk,
    input logic rst,
    output logic [4:0] row_addr,
    output logic [5:0] col_addr,
    output logic oe,
    output logic latch,
    output logic display_clk,
    output logic [3:0] dout_a,
    output logic [3:0] dout_b
);

    logic re;    

    LED_Controller led_inst(
        .clk(clk),
        .rst(rst),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .oe(oe),
        .re(re),
        .latch(latch),
        .display_clk(display_clk)
    );


    /*    
    Gowin_CLKDIV your_instance_name(
        .clkout(clk), //output clkout
        .hclkin(sys_clk), //input hclkin
        .resetn(~rst) //input resetn
    );
    */

    framebuffer fb_inst(
        .clk(clk),
        .rst(rst),
        .din('0),
        .ce(1'b1),
        .re(re),
        .waddr('0),
        .we(1'b0),
        .raddr_a({1'b0, row_addr, col_addr}),
        .raddr_b({1'b1, row_addr, col_addr}),
        .dout_a(dout_a),
        .dout_b(dout_b)
    );

endmodule

