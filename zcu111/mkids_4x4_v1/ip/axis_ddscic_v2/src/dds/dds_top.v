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
		input	wire [15:0]	mem_do		,

		// Input data.
		input	wire [31:0]	din			,
		input	wire		din_last	,

		// Output data.
		output	wire [31:0]	dout		,
		output	wire		dout_last	,

		// Registers.
		input	wire		SYNC_REG	,
		input	wire [1:0]	OUTSEL_REG
	);

/*************/
/* Internals */
/*************/
// DDS control.
wire [15:0]	dds_freq;
wire		dds_last_i;

// DDS outputs.
wire [31:0]	dds_dout;
wire		dds_last_o;
wire		dds_valid;

// Latency registers for din.
wire [31:0]	din_la;
reg  [31:0]	din_la_r1;
reg  [31:0]	din_la_r2;

// Latency register for dds_last_o;
wire		dds_last_o_la;

// DDS output registers.
reg  [31:0]	dds_dout_r1;
reg  [31:0]	dds_dout_r2_a;
reg  [31:0]	dds_dout_r2_b;
reg  [31:0]	dds_dout_r3;
reg  [31:0]	dds_dout_r4;

// Partial products.
wire signed [15:0]	dds_real;
wire signed [15:0]	dds_imag;
wire signed [15:0]	din_real;
wire signed [15:0]	din_imag;
wire signed [32:0]	prod_real_a;
wire signed [32:0]	prod_real_b;
wire signed [32:0]	prod_imag_a;
wire signed [32:0]	prod_imag_b;
reg  signed [32:0]	prod_real_a_r;
reg  signed [32:0]	prod_real_b_r;
reg  signed [32:0]	prod_imag_a_r;
reg  signed [32:0]	prod_imag_b_r;

// Full product.
wire signed [32:0]	prod_real;
wire signed [32:0]	prod_imag;
reg signed [32:0]	prod_real_r;
reg signed [32:0]	prod_imag_r;

// Rounding.
wire signed [15:0]	prod_real_round;
wire signed [15:0]	prod_imag_round;
wire [31:0]			prod;

// Output mux.
wire [31:0]			dout_mux;
reg  [31:0]			dout_mux_r;

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
		.last_i		(din_last	),

		// Output for dds control
		.dds_freq	(dds_freq	),
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
		.din		(dds_freq	),
		.din_last	(dds_last_i	),

		// Data output.
		.dout		(dds_dout	),
		.dout_last	(dds_last_o	),
		.dout_valid	(dds_valid	)
	);

// din_latency_reg
latency_reg
	#(
		// Latency.
		.N(15	),

		// Data width.
		.B(32	)
	)
	din_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Data input.
		.din	(din	),

		// Data output.
		.dout	(din_la	)
	);

// dds_last_o_latency_reg
latency_reg
	#(
		// Latency.
		.N(5	),

		// Data width.
		.B(1	)
	)
	dds_last_o_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(dds_last_o		),

		// Data output.
		.dout	(dds_last_o_la	)
	);

// Partial products.
assign dds_real			= dds_dout_r2_a[15:0];
assign dds_imag			= dds_dout_r2_a[31:16];
assign din_real			= din_la[15:0];
assign din_imag			= din_la[31:16];
assign prod_real_a		= dds_real*din_real;
assign prod_real_b		= dds_imag*din_imag;
assign prod_imag_a		= dds_imag*din_real;
assign prod_imag_b		= dds_real*din_imag;

// Full product.
assign prod_real		= prod_real_a_r - prod_real_b_r;
assign prod_imag		= prod_imag_a_r + prod_imag_b_r;

// Rounding.
assign prod_real_round	= prod_real_r[30 -: 16];
assign prod_imag_round	= prod_imag_r[30 -: 16];
assign prod				= {prod_imag_round,prod_real_round};

// Output mux.
assign dout_mux			= 	(OUTSEL_REG == 0)? prod			:
							(OUTSEL_REG == 1)? dds_dout_r4	:
							(OUTSEL_REG == 2)? din_la_r2	:
							32'h0000_0000;

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Latency registers for din.
		din_la_r1		<= 0;
		din_la_r2		<= 0;
		
		// DDS output registers.
		dds_dout_r1		<= 0;
		dds_dout_r2_a	<= 0;
		dds_dout_r2_b	<= 0;
		dds_dout_r3		<= 0;
		dds_dout_r4		<= 0;
		
		// Partial products.
		prod_real_a_r	<= 0;
		prod_real_b_r	<= 0;
		prod_imag_a_r	<= 0;
		prod_imag_b_r	<= 0;
		
		// Full product.
		prod_real_r		<= 0;
		prod_imag_r		<= 0;
		
		// Output mux.
		dout_mux_r		<= 0;
	end
	else begin
		// Latency registers for din.
		din_la_r1		<= din_la;
		din_la_r2		<= din_la_r1;
		
		// DDS output registers.
		dds_dout_r1		<= dds_dout;
		dds_dout_r2_a	<= dds_dout_r1;
		dds_dout_r2_b	<= dds_dout_r1;
		dds_dout_r3		<= dds_dout_r2_b;
		dds_dout_r4		<= dds_dout_r3;
		
		// Partial products.
		prod_real_a_r	<= prod_real_a;
		prod_real_b_r	<= prod_real_b;
		prod_imag_a_r	<= prod_imag_a;
		prod_imag_b_r	<= prod_imag_b;
		
		// Full product.
		prod_real_r		<= prod_real;
		prod_imag_r		<= prod_imag;
		
		// Output mux.
		dout_mux_r		<= dout_mux;
	end
end 

// Assign outputs.
assign dout			= dout_mux_r;
assign dout_last	= dds_last_o_la;

endmodule

