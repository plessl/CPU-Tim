/*

iverilog -g2012 -o tb_LED_controller.vvp test/LED_controller_tb.sv LED_controller.sv
vvp tb_LED_controller.vvp

*/

module LED_controller (
    input logic clk,
    input logic rst,
    output logic[4:0] row_addr,
    output logic[5:0] col_addr,
    output logic oe,
    output logic re,
    output logic latch,
    output logic display_clk
);

localparam COLUMNS = 64;
localparam ROWS = 32;       //display_pixel_rows / 2 
localparam COUNTER_WIDTH = 7; //log2(clkdiv_counter)

reg[COUNTER_WIDTH-1:0] clkdiv_counter;

wire next_pixel;
wire last_col = (col_addr == 0);
wire last_row = (row_addr == 0);

logic pixel_tick;
logic pixel_tick_shift;

assign pixel_tick = (clkdiv_counter == {COUNTER_WIDTH{1'b0}});
assign pixel_tick_shift = (clkdiv_counter == {{1'b1, {COUNTER_WIDTH-1{1'b0}}}});
//assign re_tick = (clkdiv_counter == {{1'b0, {COUNTER_WIDTH-1{1'b1}}}});
assign re_tick = (clkdiv_counter == 7'b0111111);
assign re_tick_2 = (clkdiv_counter == 7'b1000000);
assign re_tick_3 = (clkdiv_counter == 7'b1000001);


typedef enum reg[1:0]{
    INIT = 0,
    FILL = 1,
    ACTIVATE = 2,
    PAUSE = 3
} statetype;

statetype state, next_state;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        clkdiv_counter <= '1;
        col_addr <= '1;
        row_addr <= '1;
        oe <= 0;
        latch <= 0;
        re <= 0;
    end else begin
 
        clkdiv_counter <= clkdiv_counter + 1'b1;
        //re <= pixel_tick_shift;
        //re <= re_tick_2 & (display_clk == 0);
        re <= re_tick_2; // & (display_clk == 0);

        if(pixel_tick) begin

            // Update FSM outputs
            state <= next_state;
            latch <= next_latch;
            oe <= next_oe;
            row_addr <= next_row_addr;
            col_addr <= next_col_addr;

        end
    end
end



always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        display_clk <= 0;
    end else begin
        if(pixel_tick_shift) begin
            display_clk <= ~display_clk;
        end
    end
end



logic [5:0] next_col_addr;
logic [4:0] next_row_addr;
logic next_oe;
logic next_latch;

always_comb begin

    next_state = state;
    next_col_addr = col_addr;
    next_row_addr = row_addr;
    next_oe = 0;
    next_latch = 0;

    unique case (state)
        
        INIT: begin
            next_state = FILL;
        end

        FILL: begin
            next_oe = 1;
            if(!last_col) begin
                next_col_addr = col_addr - 1'b1;
            end else begin
                next_latch = 1'b1;
                next_col_addr = 6'b111111;
                next_state = ACTIVATE;
            end
        end
        
        ACTIVATE: begin
            next_oe = 1;
            next_state = PAUSE;
        end

        PAUSE: begin 
            next_state = FILL;
            //next_oe = 1;
            if(!last_row) begin
                next_row_addr = row_addr - 1'b1;
            end else begin
                next_row_addr = '1;
            end
        end
        default:
            next_state = INIT; 
    endcase
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

    LED_controller led_inst(
        .clk(clk),
        .rst(rst),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .oe(oe),
        .re(re),
        .latch(latch),
        .display_clk(display_clk)
    );

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
