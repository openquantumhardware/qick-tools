module tb;

parameter NCH 	= 13;

reg 		rstn		;
reg 		clk			;
wire [15:0]	mem_addr	;
wire [15:0]	mem_do		;
wire [31:0]	din			;
reg			din_last	;
wire [31:0]	dout		;
wire		dout_last	;
reg			SYNC_REG	;
reg  [1:0]	OUTSEL_REG	;

// Memory control.
reg			mem_we		;
reg [15:0]	mem_addra	;
reg [15:0]	mem_di		;

// Real/imaginary input data.
reg [15:0]	din_real;
reg [15:0]	din_imag;

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

assign din = {din_imag,din_real};

// DDS Top.
dds_top
	#(
		.NCH(NCH)
	)
	dds_top_i
	(
		// Reset and clock.
		.rstn		,
		.clk		,

		// Memory interface.
		.mem_addr	,
		.mem_do		,

		// Input data.
		.din		,
		.din_last	,

		// Output data.
		.dout		,
		.dout_last	,

		// Registers.
		.SYNC_REG	,
		.OUTSEL_REG
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
		.rstn		(rstn		),
		.clk		(clk		),

		// Resync.
		.sync		(sync_demux	),

		// Data input.
		.din		(dout		),
		.din_last	(dout_last	),
		.din_valid	(1'b1		),

		// Data output.
		.dout		(dout_demux	),
		.dout_valid	(valid_demux)
	);

// Main TB.
initial begin
	rstn		<= 0;
	OUTSEL_REG	<= 1;

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

// Generate TDM input data.
initial begin
	// Frequencies.
    real w[NCH];
	for (int i=0; i<NCH; i=i+1) begin
		w[i] = 0;
	end
	w[0] = 2*3.14*0.01;
	w[1] = 2*3.14*0.03;
	w[2] = 0;

	din_real <= 0;
	din_imag <= 0;
	din_last <= 0;

	// Send TDM data.
	for (int j=0; j<10000; j=j+1) begin
		for (int i=0; i<NCH-1; i = i + 1) begin
			@(posedge clk);
			din_real <= 0.95*(2**15)*$cos(w[i]*j);
			din_imag <= 0.95*(2**15)*$sin(w[i]*j);
			din_last <= 0;
		end
		@(posedge clk);
		din_real <= 0.95*(2**15)*$cos(w[NCH-1]*j);
		din_imag <= 0.95*(2**15)*$sin(w[NCH-1]*j);
		din_last <= 1;
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

