/*
 * Multi-channel DDS control. It uses a single-channel Xilinx DDS.
 * Input data contains TDM frequencies and phases. Underlaying DDS
 * is 16-bit for frequency/phase.
 *
 * DDS Control input format:
 *
 * |----------|------|----------|---------|
 * | 39 .. 33 |32    | 31 .. 16 | 15 .. 0 |
 * |----------|------|----------|---------|
 * | not used | sync | phase    | pinc    |
 * |----------|------|----------|---------|
 *
 */
module dds_tdm
	(
		// Reset and clock.
		input 	wire 		rstn		,
		input 	wire 		clk			,

		// Data input.
		input 	wire [15:0]	din_freq	,
		input 	wire [15:0]	din_phase	,
		input 	wire [15:0]	din_gain	,
		input 	wire [15:0]	din_cfg		,
		input 	wire		din_last	,

		// Data output.
		output 	wire [31:0]	dout		,
		output 	wire		dout_last	,
		output 	wire		dout_valid
	);

/*************/
/* Internals */
/*************/
// Gain latency.
wire signed [15:0]	gain_la;

// Cfg latency.
wire 		[15:0]	cfg_la;

// Input data.
wire 		[31:0]	dds_ctrl_din;
wire 		[39:0]	dds_ctrl_dout;
wire				dds_ctrl_last;
wire				dds_ctrl_valid;

// DDS outputs.
wire 		[31:0]	dds_dout;
wire 				dds_last;

// Random Generator outputs.
wire signed	[15:0]	rnd_real;
wire signed	[15:0]	rnd_imag;

// Product.
wire signed	[15:0]	dds_real;
wire signed	[15:0]	dds_imag;
wire signed [31:0]	prod_real;
wire signed [31:0]	prod_imag;
wire 		[15:0]	prod_real_round;
wire 		[15:0]	prod_imag_round;
wire		[31:0]	prod;
reg			[31:0]	prod_r1;

// Latency for last.
reg				    dds_last_r1;

/****************/
/* Architecture */
/****************/
latency_reg
	#(
		// Latency.
		.N(12),

		// Data width.
		.B(16)
	)
	latency_reg_gain_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(din_gain	),

		// Data output.
		.dout	(gain_la	)
	);

latency_reg
	#(
		// Latency.
		.N(12),

		// Data width.
		.B(16)
	)
	latency_reg_cfg_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(din_cfg	),

		// Data output.
		.dout	(cfg_la		)
	);

// Random Number Generator.
random_gen
	#(
		.W		(16	),
		.SEED	(0	)
	)
	random_gen_real_i
	(
		.rstn	(rstn		),
		.clk	(clk		),
		.dout	(rnd_real	)
	);

random_gen
	#(
		.W		(16	),
		.SEED	(1	)
	)
	random_gen_imag_i
	(
		.rstn	(rstn		),
		.clk	(clk		),
		.dout	(rnd_imag	)
	);

// Input data.
assign dds_ctrl_din = {din_phase,din_freq};

// DDS control block.
// Latency = 2.
dds_ctrl
	dds_ctrl_i
	(
		.rstn		(rstn	 		),
		.clk		(clk	 		),
		.din		(dds_ctrl_din	),
		.din_last	(din_last		),
		.dout		(dds_ctrl_dout	),
		.dout_last	(dds_ctrl_last	),
		.dout_valid	(dds_ctrl_valid	)
	);

// DDS IP.
// Latency = 10.
dds_0
	dds_i
	(
		.aclk					(clk			),
		.s_axis_phase_tvalid	(dds_ctrl_valid	),
		.s_axis_phase_tdata		(dds_ctrl_dout	),
		.s_axis_phase_tlast		(dds_ctrl_last	),
		.m_axis_data_tvalid		(				),
		.m_axis_data_tdata		(dds_dout		),
		.m_axis_data_tlast		(dds_last		)
	);

// Product.
assign dds_real			= (cfg_la[0] == 1'b1)? rnd_real : dds_dout[15:0];
assign dds_imag			= (cfg_la[0] == 1'b1)? rnd_imag : dds_dout[31:16];
assign prod_real		= gain_la*dds_real;
assign prod_imag		= gain_la*dds_imag;
assign prod_real_round	= prod_real[30 -: 16];
assign prod_imag_round	= prod_imag[30 -: 16];
assign prod				= {prod_imag_round, prod_real_round};

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Product.
		prod_r1		<= 0;

		// Latency for last.
		dds_last_r1	<= 0;
	end
	else begin
		// Product.
		prod_r1		<= prod;

		// Latency for last.
		dds_last_r1	<= dds_last;
	end
end

// Assign outputs.
assign dout			= prod_r1;
assign dout_last	= dds_last_r1;
assign dout_valid 	= 1'b1;

endmodule

