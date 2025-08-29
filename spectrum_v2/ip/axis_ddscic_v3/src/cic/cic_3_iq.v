/*
 * Cascaded CIC filter implementation with 3 stages.
 * Differential delay: 1.
 * Decimatiion factor: 2-1023
 * IQ input/output.
 */
module cic_3_iq
	#(
		// Number of bits.
		parameter B		= 8
	)
	(
		// Reset and clock.
		input wire 				rstn		,
		input wire 				clk			,

		// Data input.
		input wire [2*B-1:0]	din			,

		// Data output.
		output wire [2*B-1:0]	dout		,
		output wire				dout_valid	,

		// Registers.
		input wire [9:0]	D_REG
	);

/*************/
/* Internals */
/*************/
wire	[B-1:0]	din_i;
wire	[B-1:0]	din_q;
wire	[B-1:0]	dout_i;
wire	[B-1:0]	dout_q;

/****************/
/* Architecture */
/****************/

// CIC for real part.
cic_3
	#(
		// Number of bits.
		.B(B)
	)
	cic_3_i
	(
		// Reset and clock.
		.rstn		(rstn		),
		.clk		(clk		),

		// Data input.
		.din		(din_i		),

		// Data output.
		.dout		(dout_i		),
		.dout_valid	(dout_valid	),

		// Registers.
		.D_REG		(D_REG		)
	);

// CIC for imaginary part.
cic_3
	#(
		// Number of bits.
		.B(B)
	)
	cic_3_q
	(
		// Reset and clock.
		.rstn		(rstn		),
		.clk		(clk		),

		// Data input.
		.din		(din_q		),

		// Data output.
		.dout		(dout_q		),
		.dout_valid	(			),

		// Registers.
		.D_REG		(D_REG		)
	);

// Slice input.
assign din_i	= din[0 +: B];
assign din_q	= din[B +: B];

// Assign output.
assign dout		= {dout_q,dout_i};

endmodule

