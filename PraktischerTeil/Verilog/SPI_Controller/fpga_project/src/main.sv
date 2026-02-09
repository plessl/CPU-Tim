module spi_controller (
    input  logic        clk,   
    input  logic        rst, 
    output logic        spi_clk,
    output logic        cs_n,
    output logic        mosi,    
    input  logic        miso,   
    output logic        btn_valid,

    output logic ctrl_miso,
    output logic ctrl_mosi,
    output logic ctrl_spi_clk,
    output logic ctrl_att_n  

);
 
localparam wait_cntr_max = 4;
localparam word_cntr_max = 4;
localparam bit_cntr_max = 7;

logic [2:0] bit_cntr;
logic [3:0] word_cntr; 
logic [3:0] wait_cntr;

reg [7:0] send_msg [0:4];
reg [7:0] recv_msg [0:4];

initial begin
    send_msg[4] = 8'h00;
    send_msg[3] = 8'h00;
    send_msg[2] = 8'h00;
    send_msg[1] = 8'h42;
    send_msg[0] = 8'h01;
end

reg [7:0] btn_states;

typedef enum logic [2:0] {
    IDLE = 3'd1,
    PREPARE = 3'd2,
    SEND = 3'd3,
    WAIT = 3'd4
} state_t;

state_t state;

always @(posedge clk or posedge rst) begin
    if(rst)begin
        mosi <= '0;
        cs_n <= 1;
        spi_clk <= 1;
        state <= IDLE;
        btn_valid <= 0;
        bit_cntr <= '0;
        word_cntr <= '0;
        wait_cntr <= '0;
    end
    else begin
       case (state)
        IDLE: begin
            mosi <= '0;
            //cs_n <= 1;
            spi_clk <= 1;
            btn_valid <= 0;
            bit_cntr <= '0;
            word_cntr <= '0;

            if (wait_cntr < wait_cntr_max) begin
                wait_cntr <= wait_cntr + 1;
            end else begin
                wait_cntr <= '0;
                cs_n <= 0;
                state <= PREPARE;
            end
        end

        PREPARE: begin
            spi_clk <= 0;
            cs_n <= 0;
            mosi <= send_msg[word_cntr][bit_cntr];
            if (wait_cntr < wait_cntr_max) begin
                wait_cntr <= wait_cntr + 1;
            end else begin
                wait_cntr <= '0;
                state <= SEND;
            end
        end
        SEND: begin 
            spi_clk <= 1;
            cs_n <= 0;
            recv_msg[word_cntr][bit_cntr] <= miso;
            if(wait_cntr < wait_cntr_max) begin
                wait_cntr <= wait_cntr + 1;
            end 
            else begin
                wait_cntr <= 0;
                state <= PREPARE;
                if(bit_cntr == bit_cntr_max) begin
                    bit_cntr <= 0;
                    if(word_cntr == word_cntr_max)begin
                        word_cntr <= 0;
                        cs_n <= 1;
                        state <= IDLE; 
                    end else begin
                        word_cntr <= word_cntr +1;
                    end
                end else begin
                    bit_cntr <= bit_cntr+1;
                end
            end 
        end 
        default: 
            $display("ERROR********");
       endcase
    end
end

endmodule
