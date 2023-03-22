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
		input 	wire [15:0]	din			,
		input 	wire		din_last	,

		// Data output.
		output 	wire [31:0]	dout		,
		output 	wire		dout_last	,
		output 	wire		dout_valid
	);

/*************/
/* Internals */
/*************/
// Input data.
wire [31:0]	dds_ctrl_din;
wire [39:0]	dds_ctrl_dout;
wire		dds_ctrl_last;
wire		dds_ctrl_valid;

/****************/
/* Architecture */
/****************/
// Input data.
assign dds_ctrl_din = {{16{1'b0}},din};

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
		.m_axis_data_tdata		(dout			),
		.m_axis_data_tlast		(dout_last		)
	);

// Assign outputs.
assign dout_valid = 1'b1;

endmodule

