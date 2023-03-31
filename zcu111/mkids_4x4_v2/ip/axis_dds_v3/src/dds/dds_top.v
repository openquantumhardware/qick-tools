/*
 * TDM-muxed DDS. Memory provides frequency, phase and gain for
 * each signal. Memory format is as follows:
 *
 * |----------|----------|----------|---------|
 * | 63 .. 48 | 47 .. 32 | 31 .. 16 | 15 .. 0 |
 * |----------|----------|----------|---------|
 * | cfg      | gain     | phase    | pinc    |
 * |----------|----------|----------|---------|
 */
module dds_top
	#(
		parameter NCH 	= 16
	)
	(
		// Reset and clock.
		input 	wire 		rstn		,
		input 	wire 		clk			,

		// Memory interface.
		output	wire [15:0]	mem_addr	,
		input	wire [63:0]	mem_do		,

		// Output data.
		output	wire [31:0]	dout		,
		output	wire		dout_last	,
		output	wire		dout_valid	,

		// Registers.
		input	wire		SYNC_REG
	);

/*************/
/* Internals */
/*************/
localparam NCH_LOG2 = $clog2(NCH);

// Counter for framing.
reg	 [NCH_LOG2-1:0]	cnt;

// Framing.
wire				last_i;

// DDS control.
wire [15:0]			dds_freq;
wire [15:0]			dds_phase;
wire [15:0]			dds_gain;
wire [15:0]			dds_cfg;
wire				dds_last_i;

// DDS outputs.
wire [31:0]			dds_dout;
wire				dds_last_o;
wire				dds_valid;

/****************/
/* Architecture */
/****************/

// DDS Framing.
// Latency = 1.
dds_framing
	#(
		.NCH(NCH)
	)
	dds_framing_i
	(
		// Reset and clock.
		.rstn		(rstn		),
		.clk		(clk		),

		// Memory interface.
		.mem_addr	(mem_addr	),
		.mem_do		(mem_do		),

		// Input tlast for framing.
		.last_i		(last_i		),

		// Output for dds control
		.dds_freq	(dds_freq	),
		.dds_phase	(dds_phase	),
		.dds_gain	(dds_gain	),
		.dds_cfg	(dds_cfg	),
		.dds_last	(dds_last_i	),

		// Registers.
		.SYNC_REG	(SYNC_REG	)
	);

// TDM-muxed DDS.
// Latency = 12.
dds_tdm
	dds_tdm_i
	(
		// Reset and clock.
		.rstn		(rstn		),
		.clk		(clk		),

		// Data input.
		.din_freq	(dds_freq	),
		.din_phase	(dds_phase	),
		.din_gain	(dds_gain	),
		.din_cfg	(dds_cfg	),
		.din_last	(dds_last_i	),

		// Data output.
		.dout		(dds_dout	),
		.dout_last	(dds_last_o	),
		.dout_valid	(dds_valid	)
	);

// Framing.
assign last_i = (cnt == NCH-1)? 1'b1 : 1'b0;

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Counter for framing.
		cnt	<= 0;
	end
	else begin
		// Counter for framing.
		if (cnt < NCH-1)
			cnt	<= cnt + 1;
		else
			cnt <= 0;
	end
end 

// Assign outputs.
assign dout			= dds_dout;
assign dout_last	= dds_last_o;
assign dout_valid	= dds_valid;

endmodule

