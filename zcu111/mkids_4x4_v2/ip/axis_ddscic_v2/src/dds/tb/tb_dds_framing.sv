module tb;

parameter NCH 	= 13;

reg 		rstn			;
reg 		clk				;

// DDS Framing.
wire [15:0]	mem_addr		;
wire [15:0]	mem_do			;
reg			last_i			;
wire [15:0]	dds_freq		;
wire		dds_last		;
wire		dds_reset		;
reg			SYNC_REG		;

// DDS TDM.
wire [31:0]	dds_tdm_dout	;
wire		dds_tdm_last	;
wire		dds_tdm_valid	;

// Memory control.
reg			mem_we			;
reg [15:0]	mem_addra		;
reg [15:0]	mem_di;

// TDM-demux for debugging.
reg					sync_demux;
wire [NCH*32-1:0]	dout_demux;
wire			    valid_demux;

wire [15:0]			dout_real_ii [NCH];
wire [15:0]			dout_imag_ii [NCH];

genvar i;
generate
	for (i=0; i<NCH; i=i+1) begin
		assign dout_real_ii[i] = dout_demux[2*i*16 +: 16];
		assign dout_imag_ii[i] = dout_demux[(2*i+1)*16 +: 16];
	end
endgenerate
// TB control.
reg			tb_load_mem	= 0;

// DDS framing block.
dds_framing
	#(
		.NCH(NCH)
	)
	dds_framing_i
	(
		// Reset and clock.
		.rstn		,
		.clk		,

		// Memory interface.
		.mem_addr	,
		.mem_do		,

		// Input tlast for framing.
		.last_i		,

		// Output for dds control
		.dds_freq	,
		.dds_last	,
		.dds_reset	,

		// Registers.
		.SYNC_REG
	);

dds_tdm
	#(
		.NCH(NCH)
	)
	dds_tdm_i	
	(
		// Reset and clock.
		.rstn		(rstn			),
		.clk		(clk			),

		// Accumulator reset.
		.rst_acc	(dds_reset		),

		// Data input.
		.din		(dds_freq		),
		.din_last	(dds_last		),

		// Data output.
		.dout		(dds_tdm_dout	),
		.dout_last	(dds_tdm_last	),
		.dout_valid	(dds_tdm_valid	)
	);

// BRAM.
bram_dp
	#(
		// Memory address size.
		.N(16),
		// Data width.
		.B(16)
	)
	bram_i
	(
		.clka    (clk		),
		.clkb    (clk		),
		.ena     (1'b1		),
		.enb     (1'b1		),
		.wea     (mem_we	),
		.web     (1'b0		),
		.addra   (mem_addra	),
		.addrb   (mem_addr	),
		.dia     (mem_di	),
		.dib     (			),
		.doa     (			),
		.dob     (mem_do	)
	);

tdm_demux
    #(
        .NCH(NCH),
        .B	(32	)
    )
	tdm_demux_i
	(
		// Reset and clock.
		.rstn		(rstn			),
		.clk		(clk			),

		// Resync.
		.sync		(sync_demux		),

		// Data input.
		.din		(dds_tdm_dout	),
		.din_last	(dds_tdm_last	),
		.din_valid	(dds_tdm_valid	),

		// Data output.
		.dout		(dout_demux		),
		.dout_valid	(valid_demux	)

	);

// Main TB.
initial begin
	rstn	<= 0;

	#300;

	@(posedge clk);
	rstn	<= 1;

	#200;

	tb_load_mem	<= 1;
end

// Initialize memory contents.
initial begin
	// Frequencies.
    real w[NCH];
	for (int i=0; i<NCH; i=i+1) begin
		w[i] = 0;
	end
	w[0] = 1;
	w[1] = 3.3;
	w[7] = 5.6;

	mem_we 		<= 1'b0;
	mem_addra	<= 0;
	mem_di		<= 0;

	wait(tb_load_mem);

	@(posedge clk);
	mem_we		<= 1'b1;
	mem_di 		<= freq_calc(100, w[0]);

	// Load memory with frequencies.
	for (int j=1; j<NCH; j = j+1) begin
		@(posedge clk);
		mem_we		<= 1'b1;
		mem_addra	<= mem_addra + 1;
		mem_di 		<= freq_calc(100, w[j]);
	end

	@(posedge clk);
	mem_we	<= 1'b0;
end

// Tlast generator.
initial begin
	last_i	<= 0;
	while(1) begin
		for (int i=0; i<NCH-1; i = i + 1) begin
			@(posedge clk);
			last_i <= 0;
		end
		@(posedge clk);
		last_i <= 1;
	end
end

// Force framing.
initial begin
	SYNC_REG	<= 1'b0;
	sync_demux	<= 1'b0;

	#1000;

	@(posedge clk);
	SYNC_REG	<= 1'b1;
	sync_demux	<= 1'b1;

	@(posedge clk);
	SYNC_REG	<= 1'b0;

	#520;

	@(posedge clk);
	sync_demux	<= 1'b0;
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end

// Function to compute frequency register.
function [15:0] freq_calc;
    input real fclk;
    input real f;
    
	// All input frequencies are in MHz.
	real temp;
	temp = f/fclk*2**16;
	freq_calc = int'(temp);
endfunction

endmodule

