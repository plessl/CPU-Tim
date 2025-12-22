`timescale 1ns/1ps

module fsm_led #(
    parameter integer CTRLEN = 27  // counter width
)(
    input  wire CLK,
    input  wire RST,    // async active-high reset
    input  wire start,  // start trigger
    output reg  led,
    output reg [3:0] debug
);
    // State encoding
    localparam IDLE = 1'b0;
    localparam ON   = 1'b1;

    reg state, state_n;
    reg led_n;
    reg [CTRLEN-1:0] cnt, cnt_n;

    // Combinational next-state and outputs
    always @* begin
        // defaults
        state_n = state;
        cnt_n   = cnt;
        led_n   = led;

        case (state)
            IDLE: begin
                led_n  = 1'b0;
                cnt_n = {CTRLEN{1'b0}};
                if (start)
                    state_n = ON;
            end

            ON: begin
                led_n = 1'b1;
                cnt_n = cnt + {{(CTRLEN-1){1'b0}}, 1'b1}; // increment by 1
                // wrap detection: overflow when next value is zero
                if (cnt_n == {CTRLEN{1'b0}})
                    state_n = IDLE;
            end

            default: begin
                led_n   = 1'b0;
                state_n = IDLE;
                cnt_n   = {CTRLEN{1'b0}};
            end
        endcase
    end

    // Sequential state and counter registers with async reset
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state <= IDLE;
            cnt   <= {CTRLEN{1'b0}};
            led   <= 1'b0;
            debug <= 1'b0;
        end else begin
            state <= state_n;
            cnt   <= cnt_n;
            led  <= led_n;
            debug <= cnt_n[3:0];
        end
    end
endmodule