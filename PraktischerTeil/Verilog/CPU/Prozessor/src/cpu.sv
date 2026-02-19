// Target FGPA: Gowin GW5A-LV25MG121C1/l0

module topmodule (
	input  logic       clk,
	input  logic       rst,
	output logic [6:0] pc_trace,
	output logic       clk_trace,

	output logic [4:0] row_addr,
    output logic [5:0] col_addr,
    output logic display_oe,
    output logic latch,
    output logic display_clk,
    output logic [3:0] dout_a,
    output logic [3:0] dout_b,
	
	//SPI Controller	
	output logic spi_clk,
	output logic cs_n,
	output logic mosi,
	input  logic miso,

	//SPI Controller debug/observation signals
	output logic ctrl_miso,
	output logic ctrl_mosi,
	output logic ctrl_spi_clk,
	output logic ctrl_cs_n,
	output logic ctrl_clk,

	output logic button_up,
	output logic button_down,
	output logic button_left,
	output logic button_right

);

wire [31:0] instr_connect;
wire [15:0] controller_state;
wire spi_re;
wire imem_ce;
wire dmem_ce;
wire fbuf_re;
wire fbuf_we;
wire [31:0] pc;
wire dmem_read;
wire[3:0] dmem_we;
wire [31:0] dmem_rdata;
wire [31:0] bus_addr;
wire [31:0] bus_wdata;
wire [31:0] instr_addr;
wire [31:0] instr;
reg spi_ce;

assign button_left = ~controller_state[15];
assign button_down = ~controller_state[14];
assign button_right = ~controller_state[13];
assign button_up = ~controller_state[12];


ram_module dmem (
		.clk(clk),
		.we(dmem_we),
		.ce(dmem_ce),
		.re(dmem_read),
		.rst(rst),
		.addr(bus_addr),
		.data_in(bus_wdata),
		.data_out(dmem_rdata)
);

rom_module imem (
		.clk(clk),
		.rst(rst),
		.ce(imem_ce),
		.oce(1'b1),
		.addr(instr_addr),
		.dout(instr)
);

fsm machine(
		.clk(clk),
		.rst(rst),

		// instruction memory
		.imem_ce(imem_ce),
		.instr_addr(instr_addr),
		.instr(instr),
		.pc(pc),

		//data memory
		.bus_addr(bus_addr),
		.bus_rdata(dmem_rdata),
		.dmem_ce(dmem_ce),
		.dmem_read(dmem_read),
		.dmem_we(dmem_we),
		.bus_wdata(bus_wdata),
        .fbuf_we(fbuf_we),

		// SPI controller
		.spi_ce(spi_ce),
		.spi_re(spi_re),
		.controller_state(controller_state)
);

framebuffer fb_inst(
    	.clk(clk),
    	.rst(rst),
    	.din(bus_wdata),
    	.ce(1'b1),
    	.re(fbuf_re),
    	.waddr(bus_addr),
    	.we(fbuf_we),
		// row: 5 bit, col: 6bit, word aligned: 2 bits zero
    	.raddr_a({15'b0, 4'b1000, row_addr, col_addr, 2'b0}),
    	.raddr_b({15'b0, 4'b1001, row_addr, col_addr, 2'b0}),
    	.dout_a(dout_a),
    	.dout_b(dout_b)
);

always @(posedge clk) begin
	pc_trace <= pc[6:0];
	clk_trace <= ~clk_trace;
end


LED_Controller led_inst(
        .clk(clk),
        .rst(rst),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .display_oe(display_oe),
        .fbuf_re(fbuf_re),
        .latch(latch),
        .display_clk(display_clk)
);

spi_controller spi_inst (
    .clk(clk),
    .rst(rst),
    .spi_clk(spi_clk),
    .cs_n(cs_n),
    .mosi(mosi),
    .miso(miso),
	.controller_state(controller_state),

    .ctrl_miso(ctrl_miso),
    .ctrl_mosi(ctrl_mosi),
    .ctrl_spi_clk(ctrl_spi_clk),
    .ctrl_cs_n(ctrl_cs_n),
    .ctrl_clk(ctrl_clk)
);

endmodule

module spi_controller (
    input  logic        clk,   
    input  logic        rst, 
    output logic        spi_clk,
    output logic        cs_n,
    output logic        mosi,    
    input  logic        miso,
	output logic[15:0] controller_state,

	// tracing signals for debugging/observation
    output logic ctrl_miso,
    output logic ctrl_mosi,
    output logic ctrl_spi_clk,
    output logic ctrl_cs_n,
    output logic ctrl_clk

);

reg miso_reg;

always @(posedge clk) begin
    miso_reg <= miso;
    ctrl_spi_clk <= spi_clk;
    ctrl_mosi    <= mosi;
    ctrl_cs_n    <= cs_n;
    ctrl_clk     <= ~spi_clk; // TODO: was clk;
end


assign ctrl_miso = miso_reg;

/*
`ifndef SYNTHESIS
    localparam wait_cntr_max = 16;
    localparam idle_delay = 100;
    localparam word_gap_cycles = 32;
`else*/
    localparam wait_cntr_max = 100; //100
	localparam cs2clk_delay = 500;
    localparam word_gap_cycles = 1000; //1000
    localparam idle_delay = 5000; //5000
//`endif

localparam word_cntr_max = 4;
localparam bit_cntr_max = 7;
logic [2:0] bit_cntr;
logic [3:0] word_cntr; 
logic [$clog2(word_gap_cycles+1)-1:0] wait_cntr;
logic [$clog2(idle_delay+1)-1:0] idle_cntr;

logic [7:0] send_msg [5:0];
logic [7:0] recv_msg [5:0];

// create data strcuture for simulation
`ifndef SYNTHESIS

logic [7:0] sim_recv_msg [5:0];
initial begin
	sim_recv_msg[0] = 8'hFF;
    sim_recv_msg[1] = 8'h41;
    sim_recv_msg[2] = 8'h5A;
    sim_recv_msg[3] = 8'hEF;
    sim_recv_msg[4] = 8'hFF;
end

`endif

typedef enum logic [2:0] {
    IDLE = 3'd1,
	CSDELAY = 3'd2,
    PREPARE = 3'd3,
    SEND = 3'd4,
    WAIT = 3'd5
} state_t;

state_t state;

always @(posedge clk or posedge rst) begin
    if(rst)begin
        mosi <= '0;
        cs_n <= 1;
        spi_clk <= 1;
        state <= IDLE;
        bit_cntr <= '0;
        word_cntr <= '0;
        wait_cntr <= '0;
        idle_cntr <= '0;
		controller_state <= 16'h0000;
        // Initialize send_msg in reset to ensure proper synthesis
        send_msg[0] <= 8'h01;
        send_msg[1] <= 8'h42;
        send_msg[2] <= 8'h00;
        send_msg[3] <= 8'h00;
        send_msg[4] <= 8'h00;
        send_msg[5] <= 8'h00;
    end
    else begin
    case (state)
        IDLE: begin
            mosi <= '0;
            cs_n <= 1;
            spi_clk <= 1;
            bit_cntr <= '0;
            word_cntr <= '0;
            wait_cntr <= '0;

            if (idle_cntr < idle_delay) begin
                idle_cntr <= idle_cntr + 1'b1;
            end else begin
                idle_cntr <= '0;
                cs_n <= 0;
                state <= CSDELAY;
            end
        end

		CSDELAY: begin
			cs_n <= 0;
			spi_clk <= 1;
			mosi <= 0;
			if (wait_cntr < cs2clk_delay) begin
				wait_cntr <= wait_cntr + 1'b1;
			end else begin
				wait_cntr <= '0;
				state <= PREPARE;
			end
		end

        PREPARE: begin
            spi_clk <= 0;
            cs_n <= 0;
            mosi <= send_msg[word_cntr][bit_cntr];
            if (wait_cntr < wait_cntr_max) begin
                wait_cntr <= wait_cntr + 1'b1;
            end else begin
                wait_cntr <= '0;
                state <= SEND;
            end
        end
        SEND: begin 
            spi_clk <= 1;
            cs_n <= 0;
            // Sample MISO early in the HIGH phase (shortly after rising edge)
            // For CPHA=1, data is valid after the rising edge
            if (wait_cntr == 1) begin
                recv_msg[word_cntr][bit_cntr] <= miso;
            end
            if(wait_cntr < wait_cntr_max) begin
                wait_cntr <= wait_cntr + 1'b1;
            end 
            else begin
                wait_cntr <= 0;
                if(bit_cntr < bit_cntr_max) begin
                    bit_cntr <= bit_cntr + 1'b1;
                    state <= PREPARE;
                end else begin
                    bit_cntr <= 0;
                    state <= WAIT;
                end
            end 
        end
        WAIT: begin
            spi_clk <= 1;
            if(wait_cntr < word_gap_cycles)begin
                wait_cntr <= wait_cntr + 1'b1;
            end else begin
                wait_cntr <= 0;
                if(word_cntr < word_cntr_max) begin
                    state <= PREPARE;
                    word_cntr <= word_cntr + 1'b1;
                end else begin
					// received all data, update controller state and start over
					// bits are active low, hence store bits inverted to make it easier to query in code
                    state <= IDLE;
					controller_state <= ~{recv_msg[3], recv_msg[4]};
                    word_cntr <= 0;
                end
            end
        end
        default: 
            $display("ERROR********");
    endcase
    end
end

endmodule

// Single-port synchronous block RAM with byte-enables for writes
// read has one cycle latency, compare with SUG949E p.67

// TODO: actually, is two cycles latency in my counting. Keep as is for the moment to fix the processer implementation first but check later, whether we can optimize this by moving to a one cycle latency design.

module ram_module (
	input  logic        clk,
	input  logic        re,
	input  logic [3:0]  we,
	input  logic        ce,
	input  logic        rst,
	input  logic [31:0] addr,
	input  logic [31:0] data_in,
	output logic [31:0] data_out
);

reg [31:0] ram_mem [4095:0];
reg [31:0] dout_reg;

// note we cannot just shift the address by >> 2 as before, because the RAM has only 4096 entries
// if we shift >>2 the higher address bits from the address map (0x0001 <=) move into the index space
// and create an out of bound access
wire [31:0] index = {18'b0, addr[15:2]};

// readmem (index of first word, index of last word; both are zero-indexed)
initial begin
	$readmemh("ram.mi", ram_mem);
end

always @(posedge clk) begin
	if(ce) begin
		if (we[0]) ram_mem[index][7:0] <= data_in[7:0];
		if (we[1]) ram_mem[index][15:8] <= data_in[15:8];
		if (we[2]) ram_mem[index][23:16] <= data_in[23:16];
		if (we[3]) ram_mem[index][31:24] <= data_in[31:24];
	end
end

always @(posedge clk) begin
	if(rst) begin
		dout_reg <= 32'b0;
	end
	else begin
		if (re && ce) begin
			dout_reg <= ram_mem[index];
		end
	end
end

always @(posedge clk) begin
	if(rst) begin
		data_out <= 32'b0;
	end
	else begin
		// TODO: check whether we want to gate this update with RE or RE&CE signal here. Compare with SUG949E p.67
		// currently we update data_out on every clock when not in reset.
		if(re && ce) begin
			data_out <= dout_reg;
		end
	end
end


endmodule


module rom_module (
	input  logic        clk,
	input  logic        ce,
	input  logic        oce,
	input  logic        rst,
	input  logic [31:0] addr,
	output logic [31:0] dout
);

reg [31:0] rom_mem [4095:0];


initial begin
//	$readmemh("rom.mi", rom_mem, 0, 7);
	$readmemh("rom.mi", rom_mem);
	
	$display("ROM loaded: first instruction = %h", rom_mem[0]);

end

assign dout = ce ? rom_mem[addr >> 2] : 32'b0;

endmodule

// The framebuffer module implements a simple memory-mapped framebuffer with two separate read ports (dout_a and dout_b) for the LED controller. The design tool should infer a dual-ported block RAM from this module. The two read ports are needed because the LED controller requires to read two pixels concurrently that belong to rows i and i+32. The write port is shared for both memory areas (mem_a and mem_b) as the CPU only writes one pixel at a time, but the read ports are separate to allow concurrent access by the LED controller. The framebuffer has a latency of two cycles on reads, hence the LED controller needs to request data one cycle before it needs to use it.

module framebuffer(
    input logic clk,
    input logic rst,
    input logic [31:0] din,
    input logic ce,
    input logic re,
    input logic [31:0] waddr,
    input logic we,
    input logic [31:0] raddr_a,
    input logic [31:0] raddr_b,
    output logic [3:0] dout_a,
    output logic [3:0] dout_b
);

reg [31:0] mem_a [4095:0];
reg [31:0] mem_b [4095:0];

reg [3:0] dout_a_reg;
reg [3:0] dout_b_reg;

initial begin
    $readmemb("led.mi", mem_a, 0, 4095);
    $readmemb("led.mi", mem_b, 0, 4095);
//    $readmemb("led.mi", mem_a);
//    $readmemb("led.mi", mem_b);

end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        dout_a_reg <= 0;
        dout_b_reg <= 0;
    end else begin
        if (we) begin
            mem_a[waddr[13:2]] <= din;
            mem_b[waddr[13:2]] <= din;
        end
        if (re) begin
            dout_a_reg <= mem_a[raddr_a[13:2]][3:0];
            dout_b_reg <= mem_b[raddr_b[13:2]][3:0];
        end
    end
end

always @(posedge clk) begin
	if(rst) begin
		dout_a <= 0;
		dout_b <= 0;
	end
	else begin
		dout_a <= dout_a_reg;
		dout_b <= dout_b_reg;
	end
end

endmodule

// frambuffer has two cycles latency on read, hence we need to wait for one cycle after requesting read (FETCH) 

module LED_Controller #(
    parameter WIDTH = 64,
    parameter HEIGHT = 64,
    parameter ROWS = 32,
    parameter COLUMNS = 64
)
(
    input  logic clk,
    input  logic rst,
    output logic[4:0] row_addr,
    output logic[5:0] col_addr,
    output logic display_oe,
    output logic fbuf_re,
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
	DATAWAIT = 4'd1,
    SHIFT1 = 4'd2,
    SHIFT2 = 4'd3,
    LATCH = 4'd4,
    OE = 4'd5,
    WAIT = 4'd6
    
} controller_statetype;

controller_statetype con_state;

localparam WAIT_CYCLES  =  6;
localparam LATCH_CYCLES = 4;
localparam OE_CYCLES = 8;

logic[7:0] latch_cntr;
logic[7:0] oe_cntr;
logic[7:0] wait_cntr;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        con_state <= FETCH;
        display_clk <= 1'b0;
        row_addr <= 0;
        col_addr <= '0;
        display_oe <= 1'b1;
        fbuf_re <= 1'b0;
        latch <= 1'b0;
        wait_cntr <= '0;
    end
    else begin
        case (con_state)

            FETCH: begin
                display_clk <= 1'b0;
                col_addr <= col_addr;
                row_addr <= row_addr;
                con_state <= DATAWAIT;
                fbuf_re <= 1'b1;
                display_oe <= 1'b1;
                latch <= 1'b0;
            end

			DATAWAIT: begin
				display_clk <= 1'b0;
				col_addr <= col_addr;
				row_addr <= row_addr;
				con_state <= SHIFT1;
				fbuf_re <= 1'b0;
				display_oe <= 1'b1;
				latch <= 1'b0;
			end

            SHIFT1: begin
                display_clk <= 1'b1;
                display_oe <= 1'b1;
                fbuf_re <= 1'b1;
                con_state <= SHIFT2;
            end

            SHIFT2: begin           
                display_clk <= 1'b0;
                fbuf_re <= 1'b0;
                if(col_addr == COLUMNS - 1) begin
                    con_state <= LATCH;
					latch_cntr <= LATCH_CYCLES;
                    display_oe <= 1'b1;
                    col_addr <= '0;
                end else begin
                    con_state <= FETCH;
                    col_addr <= col_addr + 1'b1;
                    display_oe <= 1'b1;
                end
            end

            LATCH: begin
                latch <= 1'b1;
                display_clk <= 1'b0;
                display_oe <= 1'b1;
				if(latch_cntr > 1) begin
					latch_cntr <= latch_cntr - 1'b1;
					con_state <= LATCH;
				end else begin
					oe_cntr <= OE_CYCLES;
	                con_state <= OE;
				end
            end

            OE: begin
                latch <= 1'b0;
                display_clk <= 1'b0;
                display_oe <= 1'b0;

				if(oe_cntr > 1) begin
					oe_cntr <= oe_cntr - 1'b1;
					con_state <= OE;
				end else begin
					con_state <= WAIT;
				end

				//if(row_addr == ROWS - 1) begin
                //    row_addr <= '0;
                //end else begin
                //    row_addr <= row_addr + 1'b1;
                //end
                //con_state <= WAIT;

            end

            WAIT: begin
                display_clk <= 1'b0;
                latch <= 1'b0;
                display_oe <= 1'b1;
                if(wait_cntr < WAIT_CYCLES - 1) begin
                    wait_cntr <= wait_cntr + 1'b1;
                    con_state <= WAIT;
                end else begin
                    wait_cntr <= '0;
                    display_oe <= 1'b1;
                    con_state <= FETCH;

					if(row_addr == ROWS - 1) begin
                    	row_addr <= '0;
                	end else begin
                    	row_addr <= row_addr + 1'b1;
                	end
                
                end
            end

        endcase
    end
end
endmodule

module fsm (
	input  logic        clk,
	input  logic        rst,

	output logic        imem_ce,
	output logic [31:0] instr_addr,
	input  logic [31:0] instr,
	output logic [31:0] pc,

	output logic [31:0] bus_addr,
	input  logic [31:0] bus_rdata,
	output logic        dmem_ce,
	output logic        dmem_read,
	output logic        fbuf_we,
	output logic [3:0]  dmem_we,
	output logic [31:0] bus_wdata,
	output logic        spi_ce,
	output logic        spi_re,	

	input logic [15:0] controller_state
);

	typedef enum reg[2:0]{
		FETCH = 0,
		DECODE = 1,
		EXECUTE = 2,
		MEMORY1 = 3,
		MEMORY2 = 4,
		WRITEBACK = 5
	} statetype;

	reg [31:0] pc_next;
	statetype state;
	reg [31:0] regfile [31:0];
	reg [4:0]  rd, rs1, rs2;
	reg [31:0] imm;
	reg [6:0]  opcode;
	reg [2:0]  funct3;
	reg [6:0] funct7;

	reg [31:0] tmp_rd;
	reg [4:0] shift_amt;
	reg [31:0] tmp_bus_wdata;

	reg set_rd_flag;
	
	integer i;
	integer d;

	wire [31:0] x0 = regfile[0];
	wire [31:0] x1 = regfile[1];
	wire [31:0] x2 = regfile[2];
	wire [31:0] x3 = regfile[3];
	wire [31:0] x4 = regfile[4];
	wire [31:0] x5 = regfile[5];
	wire [31:0] x6 = regfile[6];
	wire [31:0] x7 = regfile[7];
	wire [31:0] x8 = regfile[8];
	wire [31:0] x9 = regfile[9];
	wire [31:0] x10 = regfile[10];
	wire [31:0] x11 = regfile[11];
	wire [31:0] x12 = regfile[12];
	wire [31:0] x13 = regfile[13];
	wire [31:0] x14 = regfile[14];
	wire [31:0] x15 = regfile[15];
	wire [31:0] x16 = regfile[16];
	wire [31:0] x17 = regfile[17];
	wire [31:0] x18 = regfile[18];
	wire [31:0] x19 = regfile[19];
	wire [31:0] x20 = regfile[20];
	wire [31:0] x21 = regfile[21];
	wire [31:0] x22 = regfile[22];
	wire [31:0] x23 = regfile[23];
	wire [31:0] x24 = regfile[24];
	wire [31:0] x25 = regfile[25];
	wire [31:0] x26 = regfile[26];
	wire [31:0] x27 = regfile[27];
	wire [31:0] x28 = regfile[28];
	wire [31:0] x29 = regfile[29];
	wire [31:0] x30 = regfile[30];
	wire [31:0] x31 = regfile[31];

//	reg [31:0] ir; // instruction register

//	wire [31:0] opcode_wire = ir[6:0];
	
	always @(posedge clk) begin
		if(rst)begin
			state <= FETCH;
			pc <= 0;
			tmp_rd <= 0;
			set_rd_flag <= 0;
			instr_addr <= 0;
			dmem_read <= 0;
			dmem_we <= 4'b0000;
			dmem_ce <= 0;
			fbuf_we <= 0;
			spi_ce <= 0;
			spi_re <= 0;
			imem_ce <= 1;
			bus_addr <= 0;
			pc_next <= 0;
			for (i = 0; i < 32; i = i + 1)
				regfile[i] <= 0;
		end
		else begin
			fbuf_we <= 0;
			dmem_ce <= 0;
			dmem_read <= 0;
			dmem_we <= 4'b0000;
			spi_ce <= 0;
			spi_re <= 0;
			imem_ce <= 1;

			case (state)
				FETCH: begin
					//ir <= instr;
					instr_addr <= pc;
					pc_next <= pc + 4;
					state <= DECODE;
				end
				DECODE: begin
					opcode <= instr[6:0];
					rd <= instr[11:7];
					funct3 <= instr[14:12];
					rs1 <= instr[19:15];
					rs2 <= instr[24:20];
					funct7 <= instr[31:25];

					case (instr[6:0])
						7'b0010011:     //I type arithmetic
							imm <= {{20{instr[31]}}, instr[31:20]};
						7'b0000011:     //I type load
							imm <= {{20{instr[31]}}, instr[31:20]};
						7'b0100011:     //S type
							imm <= {{20{instr[31]}}, instr[31:25], instr[11:7]};
						7'b1100011:     //B type
							imm <= {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
						7'b1101111:     //J type jal
							imm <= {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
						7'b1100111:     // I type jalr
							imm <= {{20{instr[31]}}, instr[31:20]};
						7'b0110111:     //U type lui
							imm <= {instr[31:12], 12'b0};
						7'b0010111:     //U type auipc
							imm <= {instr[31:12], 12'b0};
						default:
							imm <= 32'b0;
					endcase
					state <= EXECUTE;
				end
				EXECUTE: begin
					case (opcode)
						7'b0110011: begin        //R type
							set_rd_flag <= 1;
							shift_amt <= regfile[rs2][4:0];
							case (funct3)
								3'b000: begin
									case (funct7)
										7'b0000000:
											tmp_rd <= regfile[rs1] + regfile[rs2];   //add
										7'b0100000:
											tmp_rd <= regfile[rs1] - regfile[rs2];   //sub
										default:
											tmp_rd <= 32'b0;
									endcase
								end
								3'b100:
									tmp_rd <= regfile[rs1] ^ regfile[rs2];   //xor
								3'b110:
									tmp_rd <= regfile[rs1] | regfile[rs2];   //or
								3'b111:
									tmp_rd <= regfile[rs1] & regfile[rs2];   //and
								3'b001:
									tmp_rd <= regfile[rs1] << shift_amt;  //sll
								3'b101: begin
									case (funct7)
										7'b0000000:
											tmp_rd <= regfile[rs1] >> shift_amt;  //srl
										7'b0100000:
											tmp_rd <= $signed(regfile[rs1]) >>> shift_amt;  //sra
										default:
											tmp_rd <= 32'b0;
									endcase
								end

								3'b010:
									tmp_rd <= ($signed(regfile[rs1]) < $signed(regfile[rs2]))?1:0;   //slt
								3'b011:
									tmp_rd <= ($unsigned(regfile[rs1]) < $unsigned(regfile[rs2]))?1:0; //sltu
								default:
									tmp_rd <= 32'b0;
							endcase
						end

						7'b0010011: begin       //I type arithmetic
							set_rd_flag <= 1;
							case (funct3)
								3'b000:
									tmp_rd <= regfile[rs1] + imm;    //addi
								3'b100:
									tmp_rd <= regfile[rs1] ^ imm;    //xori
								3'b110:
									tmp_rd <= regfile[rs1] | imm;    //ori
								3'b111:
									tmp_rd <= regfile[rs1] & imm;    //andi
								3'b001:
									tmp_rd <= regfile[rs1] << imm[4:0];   //slli
								3'b101: begin
										case (imm[11:5])
											7'b0000000:
												tmp_rd <= regfile[rs1] >> imm[4:0];   //srli
											7'b0100000:
												tmp_rd <= $signed(regfile[rs1]) >>> imm[4:0];     //srai (arithmetic, use signed)
											default:
												tmp_rd <= 32'b0;
										endcase
									end
								3'b010:
									tmp_rd <= ($signed(regfile[rs1]) < $signed(imm))?1:0;    //slti
								3'b011:
									tmp_rd <= ($unsigned(regfile[rs1]) < $unsigned(imm))?1:0;   //sltiu
								default:
									tmp_rd <= 32'b0;
							endcase
						end
						7'b0000011: begin	// Load
							set_rd_flag <= 0;
							bus_addr <= regfile[rs1] + imm;
							//if(bus_addr[31:15] == 16'h0001) begin
							if(((regfile[rs1] + imm) >> 16) == 16'h0001) begin
								dmem_ce <= 1;
								dmem_read <= 1;
							end
							if(((regfile[rs1] + imm) >> 16) == 16'h0003)begin
								spi_ce <= 1'b1;
								spi_re <= 1'b1;
								$display("EX: prepare read from SPI at addr 0x%h", regfile[rs1] + imm);
							end
						end
						7'b0100011: begin   //S type
							set_rd_flag <= 0;
							bus_addr <= regfile[rs1] + imm;
							tmp_bus_wdata <= regfile[rs2];
							// store to data memory
							//if(bus_addr[31:15] == 16'h0001) begin
							if(((regfile[rs1] + imm) >> 16) == 16'h0001) begin
								dmem_ce <= 1;
							end
							// store to framebuffer
							if(((regfile[rs1] + imm) >> 16) == 16'h0002) begin
							//if(bus_addr[31:15] == 16'h0002)begin
								//TODO: Test ob das zu früh ist, da wir erst in MEM1 das We-Signal aktivieren, oder ob wir das hier schon machen müssen
								fbuf_we <= 1'b0;
							end
						end

						7'b1100011: begin   //B type
							set_rd_flag <= 0;
							pc_next <= pc + 4;
							case (funct3)
								3'b000:
									if((regfile[rs1]) == (regfile[rs2])) pc_next <= pc+imm;   //beq
								3'b001:
									if((regfile[rs1]) != (regfile[rs2])) pc_next <= pc+imm;   //bne
								3'b100:
									if($signed(regfile[rs1]) < $signed(regfile[rs2])) pc_next <= pc+imm;    //blt (signed)
								3'b101:
									if($signed(regfile[rs1]) >= $signed(regfile[rs2])) pc_next <= pc+imm;   //bge (signed)
								3'b110:
									if($unsigned(regfile[rs1]) < $unsigned(regfile[rs2])) pc_next <= pc+imm;    //bltu
								3'b111:
									if($unsigned(regfile[rs1]) >= $unsigned(regfile[rs2])) pc_next <= pc+imm;   //bgeu
								default:
									pc_next <= pc+4;
							endcase
						end

						7'b1101111: begin       //jal
							set_rd_flag <= 1;
							tmp_rd <= pc + 4;
							pc_next <= pc + imm;
						end
						7'b1100111: begin       //jalr
							set_rd_flag <= 1;
							tmp_rd <= pc + 4;
							pc_next <= (regfile[rs1] + imm) & ~32'b1;
						end
						7'b0110111: begin      //lui
							set_rd_flag <= 1;
							tmp_rd <= imm;
						end
						7'b0010111: begin
							set_rd_flag <= 1;
							tmp_rd <= pc + imm;    //auipc
						end
						default: begin
							set_rd_flag <= 0;
							$display("illegal instruction");
						end
					endcase
					state <= MEMORY1;
				end
				MEMORY1: begin
					state <= MEMORY2;
					case (opcode)
					7'b0000011: begin  // Load
						// keep values for dmem_ce and dmem_read from EXECUTE stage, only active if read from data memory (not framebuffer)
						// TODO: Check where we need to keep signals active for whole MEM stage
						dmem_ce <= 1;
						dmem_read <= 1;

						`ifndef SYNTHESIS

						if(spi_ce && spi_re) begin
							$display("MEM1: prepare read from SPI at addr 0x%h", bus_addr);
						end

						`endif

					end
					7'b0100011: begin	// Store
						// if address in framebuffer range
						// TODO: convert to configurable address range later.
						if(bus_addr[31:16] == 16'h0002) begin
							fbuf_we <= 1'b1;
							bus_wdata <= tmp_bus_wdata;
							$display("Store to framebuffer at addr %h data %h", bus_addr, tmp_bus_wdata);
						end else begin
						dmem_ce <= 1;
						dmem_read <= 0;
						case (funct3)
							3'b000: begin      //sb
								case (bus_addr[1:0])
									2'b00: begin
										dmem_we <= 4'b0001;
										bus_wdata <= {24'b0, tmp_bus_wdata[7:0]};
									end
									2'b01: begin
										dmem_we <= 4'b0010;
										bus_wdata <= {6'b0, tmp_bus_wdata[7:0], 8'b0};
									end
									2'b10: begin
										dmem_we <= 4'b0100;
										bus_wdata <= {8'b0, tmp_bus_wdata[7:0], 16'b0};
									end
									2'b11: begin
										dmem_we <= 4'b1000;
										bus_wdata <= {tmp_bus_wdata[7:0], 24'b0};
									end
									default: bus_wdata <= 0;
								endcase
							end
							3'b001:  begin   //sh
								case (bus_addr[1:0])
									2'b00: begin
										dmem_we <= 4'b0011;
										bus_wdata <= {16'b0, tmp_bus_wdata[15:0]};
									end
									2'b10: begin
										dmem_we <= 4'b1100;
										bus_wdata <= {tmp_bus_wdata[15:0], 16'b0};
									end
									default: bus_wdata <= 0;
								endcase
							end
							3'b010: begin	//sw
								if (bus_addr[1:0] == 2'b00)begin
									dmem_we <= 4'b1111;
									bus_wdata <= tmp_bus_wdata;
								end
								else 
									bus_wdata <= 32'b0;
							end
							default:
								bus_wdata <= 0;
						endcase
						end
					end
					default:
						$display("undefined");
					endcase
				end
				MEMORY2: begin
					state <= WRITEBACK;
					case(opcode) 
						7'b0000011: begin  // Load
						set_rd_flag <= 1;
						if(bus_addr[31:16] == 16'h0003) begin
							spi_ce <= 1'b0;
							spi_re <= 1'b0;
							tmp_rd <= {16'b0, controller_state};
							
							`ifndef SYNTHESIS
							$display("Read from SPI: addr = 0x%h , data 0x%h", bus_addr, controller_state);
							`endif

						end else begin
						case (funct3)
							3'b000: begin     //lb
								case (bus_addr[1:0])
									2'b00:
										tmp_rd <= {{24{bus_rdata[7]}}, bus_rdata[7:0]};
									2'b01:
										tmp_rd <= {{24{bus_rdata[15]}}, bus_rdata[15:8]};
									2'b10:
										tmp_rd <= {{24{bus_rdata[23]}}, bus_rdata[23:16]};
									2'b11:
										tmp_rd <= {{24{bus_rdata[31]}}, bus_rdata[31:24]};
									default:
										tmp_rd <= 32'b0;
								endcase
							end
							3'b001: begin     //lh
								case (bus_addr[1:0])
									2'b00:
										tmp_rd <= {{16{bus_rdata[15]}}, bus_rdata[15:0]};
									2'b10:
										tmp_rd <= {{16{bus_rdata[31]}}, bus_rdata[31:16]};
									default:
										tmp_rd <= 32'b0;
								endcase
							end
							3'b010:       //lw
									tmp_rd <= bus_rdata;
							3'b100: begin     //lbu
								case (bus_addr[1:0])
									2'b00:
										tmp_rd <= {24'b0, bus_rdata[7:0]};
									2'b01:
										tmp_rd <= {24'b0, bus_rdata[15:8]};
									2'b10:
										tmp_rd <= {24'b0, bus_rdata[23:16]};
									2'b11:
										tmp_rd <= {24'b0, bus_rdata[31:24]};
									default:
										tmp_rd <= 32'b0;
								endcase
							end
							3'b101: begin	//lhu
								case (bus_addr[1:0])
									2'b00:
										tmp_rd <= {16'b0, bus_rdata[15:0]};
									2'b10:
										tmp_rd <= {16'b0, bus_rdata[31:16]};
									default:
										tmp_rd <= 32'b0;
								endcase
							end
							default:
								tmp_rd <= 32'b0;
						endcase
						end
					end
					endcase
				end
				WRITEBACK: begin
					dmem_ce <= 0;
					dmem_we <= 4'b0000;
					dmem_read <= 0;
					spi_ce <= 0;
					spi_re <= 0;
					bus_wdata <= 0;
					bus_addr <= 0;
					pc <= pc_next;
					if(set_rd_flag && (rd != 0)) regfile[rd] <= tmp_rd;
					set_rd_flag <= 0;
					state <= FETCH;
					`ifndef SYNTHESIS
					show_instruction(instr);
					`endif
					/*for (d = 0; d < 32; d = d + 1)
						$display("register: %d, value: %d", d, regfile[d]);
					*/
				end
			default:
				$display("fvcdfdcdc");
			endcase
		end
	end

`ifndef SYNTHESIS
task show_instruction;
		input [31:0] instr;
		reg [6:0] opcode;
		reg [4:0] rd, rs1, rs2;
		reg [31:0] imm;
		reg [2:0] funct3;
		reg [6:0] funct7;

		begin
			opcode = instr[6:0];
			rd = instr[11:7];
			funct3 = instr[14:12];
			rs1 = instr[19:15];
			rs2 = instr[24:20];
			funct7 = instr[31:25];

			case (opcode)
				7'b0010011:     //I type arithmetic
					imm = {{20{instr[31]}}, instr[31:20]};
				7'b0000011:     //I type load
					imm = {{20{instr[31]}}, instr[31:20]};
				7'b0100011:     //S type
					imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
				7'b1100011:     //B type
					imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
				7'b1101111:     //J type jal
					imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
				7'b1100111:     // I type jalr
					imm = {{20{instr[31]}}, instr[31:20]};
				7'b0110111:     //U type lui
					imm = {instr[31:12], 12'b0};
				7'b0010111:     //U type auipc
					imm = {instr[31:12], 12'b0};
				default:
					imm = 32'b0;
			endcase

			case (opcode)
				7'b0110011: begin
					case (funct3)
						3'b000: begin
							case (funct7)
								7'b0000000:
									$display("add x%d, x%d, x%d", rd, rs1, rs2);
								7'b0100000:
									$display("sub x%d, x%d, x%d", rd, rs1, rs2);
								default:
									$display("illegal instruction");
							endcase
						end
						3'b100:
							$display("xor x%d, x%d, x%d", rd, rs1, rs2);
						3'b110:
							$display("or x%d, x%d, x%d", rd, rs1, rs2);
						3'b111:
							$display("and x%d, x%d, x%d", rd, rs1, rs2);
						3'b001:
							$display("sll x%d, x%d, x%d", rd, rs1, rs2);
						3'b101: begin
							case (funct7)
								7'b0000000:
									$display("srl x%d, x%d, x%d", rd, rs1, rs2);
								7'b0100000:
									$display("sra x%d, x%d, x%d", rd, rs1, rs2);
								default:
									$display("illegal instruction");
							endcase
						end
						3'b010:
							$display("slt x%d, x%d, x%d", rd, rs1, rs2);
						3'b011:
							$display("sltu x%d, x%d, x%d", rd, rs1, rs2);
						default:
							$display("illegal instruction");
					endcase
				end
				7'b0010011: begin
					case (funct3)
						3'b000:
							$display("addi x%d, x%d, %d", rd, rs1, imm);
						3'b100:
							$display("xori x%d, x%d, %d", rd, rs1, imm);
						3'b110:
							$display("ori x%d, x%d, %d", rd, rs1, imm);
						3'b111:
							$display("andi x%d, x%d, %d", rd, rs1, imm);
						3'b001: begin
							case (imm[11:5])
								7'b000:
									$display("slli x%d, x%d, %d", rd, rs1, imm);
								default: $display("xori x%d, x%d, %d", rd, rs1, imm);
							endcase
						end
						3'b101: begin
							case (imm[11:5])
								7'b0000000:
									$display("srli x%d, x%d, %d", rd, rs1, imm);
								7'b0100000:
									$display("srai x%d, x%d, %d", rd, rs1, imm);
								default: $display("illegal instruction");
							endcase
						end
						3'b010:
							$display("slti x%d, x%d, %d", rd, rs1, imm);
						3'b011:
							$display("sltiu x%d, x%d, %d", rd, rs1, imm);
						default: $display("illegal instruction");
					endcase
				end
				7'b0000011: begin
					case (funct3)
						3'b000:
							$display("lb x%d, x%d, %d", rd, rs1, imm);
						3'b001:
							$display("lh x%d, x%d, %d", rd, rs1, imm);
						3'b010:
							$display("lw x%d, x%d, %d", rd, rs1, imm);
						3'b100:
							$display("lbu x%d, x%d, %d", rd, rs1, imm);
						3'b101:
							$display("lhu x%d, x%d, %d", rd, rs1, imm);
						default: $display("illegal instruction");
					endcase
				end
				7'b0100011: begin
					case (funct3)
						3'b000:
							$display("sb x%d, x%d, %d", rs1, rs2, imm);
						3'b001:
							$display("sh x%d, x%d, %d", rs1, rs2, imm);
						3'b010:
							$display("sw x%d, x%d, %d", rs1, rs2, imm);
						default: $display("illegal instruction");
					endcase
				end
				7'b1100011: begin
					case (funct3)
						3'b000:
							$display("beq x%d, x%d, %d", rs1, rs2, imm);
						3'b001:
							$display("bne x%d, x%d, %d", rs1, rs2, imm);
						3'b100:
							$display("blt x%d, x%d, %d", rs1, rs2, imm);
						3'b101:
							$display("bge x%d, x%d, %d", rs1, rs2, imm);
						3'b110:
							$display("bltu x%d, x%d, %d", rs1, rs2, imm);
						3'b111:
							$display("bgeu x%d, x%d, %d", rs1, rs2, imm);
						default:  $display("illegal instruction");
					endcase
				end
				7'b1101111:
					$display("jal x%d, %d", rd, imm);
				7'b1100111:
					$display("jalr x%d, x%d, %d", rd, rs1, imm);
				7'b0110111:
					$display("lui x%d, %d", rd, imm);
				7'b0010111:
					$display("auipc x%d, %d", rd, imm);
				default:
					$display("illegal instruction");
			endcase
		end
	endtask
`endif
endmodule

`default_nettype wire
