/*
 * This block has a DDC + CIC filter. All options
 * can be by-passed.
 *
 * NOTE: DDS is supposed to give B-bits for I,Q
 * components.
 */
module ddscic
	#(
		// Number of bits.
		parameter	B = 16
	)
	(
		// Reset and clock.
		input 	wire 			rstn			,
		input 	wire 			clk				,

		// Input data.
		input	wire [2*B-1:0]	din				,

		// Output data.
		output	wire [2*B-1:0]	dout			,
		output	wire			dout_valid		,

		// Registers.
		input	wire [31:0]		PINC_REG		,
		input	wire			PINC_WE_REG		,
		input 	wire [1:0]		PRODSEL_REG		,
		input					CICSEL_REG		,
		input	wire [31:0]		QPROD_REG		,
		input	wire [31:0]		QCIC_REG		,
		input	wire [31:0]		DEC_REG
	);

/*************/
/* Internals */
/*************/
// Maximum number of bits for CIC internals: BIN + Q*Log2(D),
// where Q is the number of cascaded stages and D is the 
// maximum decimation factor (pp. 562 Lyons book).
localparam Q = 3;
localparam BCIC	= B + Q*$clog2(1024);

// Input registers.
reg		[2*B-1:0]		din_r1;
reg		[2*B-1:0]		din_r2;

// DDS output data.
wire	[2*B-1:0]		dds_dout;

// DDS registers.
reg		[2*B-1:0]		dds_dout_r1;
reg		[2*B-1:0]		dds_dout_r2;

// Product.
wire signed	[B-1:0]		din_real;
wire signed	[B-1:0]		din_imag;
wire signed	[B-1:0]		dds_real;
wire signed	[B-1:0]		dds_imag;
wire signed [2*B-1:0]	prod_real_a;
wire signed [2*B-1:0]	prod_real_b;
reg  signed [2*B-1:0]	prod_real_a_r1;
reg  signed [2*B-1:0]	prod_real_b_r1;
wire signed [2*B-1:0]	prod_real;
reg  signed [2*B-1:0]	prod_real_r1;
wire signed [2*B-1:0]	prod_imag_a;
wire signed [2*B-1:0]	prod_imag_b;
reg  signed [2*B-1:0]	prod_imag_a_r1;
reg  signed [2*B-1:0]	prod_imag_b_r1;
wire signed [2*B-1:0]	prod_imag;
reg  signed [2*B-1:0]	prod_imag_r1;
wire		[4*B-1:0]	prod;
wire		[2*B-1:0]	prod_round;
reg			[2*B-1:0]	prod_round_r1;

// Product mux.
wire		[2*B-1:0]	prod_mux;
reg			[2*B-1:0]	prod_mux_r1;
reg			[2*B-1:0]	prod_mux_r2;

// CIC Filter + Decimation.
wire		[BCIC-1:0]	cic_din_real;
wire		[BCIC-1:0]	cic_din_imag;
wire		[2*BCIC-1:0]cic_din;
wire		[2*BCIC-1:0]cic_dout;
wire					cic_valid;
wire		[2*B-1:0]	cic_dout_round;
wire					cic_valid_round;
reg			[2*B-1:0]	cic_dout_r1;
reg						cic_valid_r1;

// CIC mux.
wire		[2*B-1:0]	cic_mux;
wire					valid_mux;
reg			[2*B-1:0]	cic_mux_r1;
reg						valid_mux_r1;

// PINC_WE_REG_resync.
wire				PINC_WE_REG_resync;

/**********************/
/* Begin Architecture */
/**********************/
// PINC_WE_REG_resync.
synchronizer_n PINC_WE_REG_resync_i
	(
		.rstn	    (rstn				),
		.clk 		(clk				),
		.data_in	(PINC_WE_REG		),
		.data_out	(PINC_WE_REG_resync	)
);

// DDS IP.
dds_0 dds_i
	(
		.aclk					(clk				),
		.s_axis_config_tvalid	(PINC_WE_REG_resync	),
		.s_axis_config_tdata	(PINC_REG			),
		.m_axis_data_tvalid		(					),
		.m_axis_data_tdata		(dds_dout			)
	);

// Product.
assign din_real			= din_r1[0 +: B];
assign din_imag			= din_r1[B +: B];
assign dds_real			= dds_dout_r1[0 +: B];
assign dds_imag			= dds_dout_r1[B +: B];
assign prod_real_a		= din_real*dds_real;
assign prod_real_b		= din_imag*dds_imag;
assign prod_imag_a		= din_real*dds_imag;
assign prod_imag_b		= din_imag*dds_real;
assign prod_real		= prod_real_a_r1 - prod_real_b_r1;
assign prod_imag		= prod_imag_a_r1 + prod_imag_b_r1;
assign prod				= {prod_imag, prod_real};

// Product quantization.
qdata_iq
	#(
		// Number of bits of Input.
		.BIN	(2*B),

		// Number of bits of Output.
		.BOUT	(B	)
	)
	qdata_prod_i
	(
		// Reset and clock.
		.rstn		(rstn		),
		.clk		(clk		),

		// Input data.
		.din		(prod		),
		.din_valid	(1'b1		),

		// Output data.
		.dout		(prod_round	),
		.dout_valid	(			),

		// Registers.
		.QSEL_REG	(QPROD_REG	)
	);

// Product mux.
assign prod_mux	=	(PRODSEL_REG == 0)?	prod_round_r1	:
					(PRODSEL_REG == 1)?	dds_dout_r2		:
					(PRODSEL_REG == 2)?	din_r2			:
					{2*B{1'b0}};

// CIC + Decimation IP.
cic_3_iq
    #(
        .B	(BCIC	)
    )
    cic_i
	( 
		.rstn		(rstn		),
        .clk   		(clk   		),
        .din    	(cic_din	),
        .dout		(cic_dout	),
		.dout_valid	(cic_valid	),
		.D_REG		(DEC_REG	)
    );

// CIC input.
assign cic_din_real = {{(BCIC-B){prod_mux_r1[B-1]}	}	, prod_mux_r1[0 +: B]};
assign cic_din_imag = {{(BCIC-B){prod_mux_r1[2*B-1]}}	, prod_mux_r1[B +: B]};
assign cic_din		= {cic_din_imag, cic_din_real};

// CIC quantization.
qdata_iq
	#(
		// Number of bits of Input.
		.BIN	(BCIC),

		// Number of bits of Output.
		.BOUT	(B	)
	)
	qdata_cic_i
	(
		// Reset and clock.
		.rstn		(rstn				),
		.clk		(clk				),

		// Input data.
		.din		(cic_dout			),
		.din_valid	(cic_valid			),

		// Output data.
		.dout		(cic_dout_round		),
		.dout_valid	(cic_valid_round	),

		// Registers.
		.QSEL_REG	(QCIC_REG			)
	);

// CIC mux.
assign cic_mux		= (CICSEL_REG == 0)? cic_dout_r1 : prod_mux_r2;
assign valid_mux	= (CICSEL_REG == 0)? cic_valid_r1: 1'b1;

// Registers.
always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// Input registers.
		din_r1			<= 0;
		din_r2			<= 0;
		
		// DDS registers.
		dds_dout_r1		<= 0;
		dds_dout_r2		<= 0;
		
		// Product.
		prod_real_a_r1	<= 0;
		prod_real_b_r1	<= 0;
		prod_real_r1	<= 0;
		prod_imag_a_r1	<= 0;
		prod_imag_b_r1	<= 0;
		prod_imag_r1	<= 0;
		prod_round_r1	<= 0;
		
		// Product mux.
		prod_mux_r1		<= 0;
		prod_mux_r2		<= 0;

		// CIC Filter + Decimation.
		cic_dout_r1		<= 0;
		cic_valid_r1	<= 0;

		// CIC mux.
		cic_mux_r1		<= 0;
		valid_mux_r1	<= 0;
	end
	else begin
		// Input registers.
		din_r1			<= din;
		din_r2			<= din_r1;
		
		// DDS registers.
		dds_dout_r1		<= dds_dout;
		dds_dout_r2		<= dds_dout_r1;
		
		// Product.
		prod_real_a_r1	<= prod_real_a;
		prod_real_b_r1	<= prod_real_b;
		prod_real_r1	<= prod_real;
		prod_imag_a_r1	<= prod_imag_a;
		prod_imag_b_r1	<= prod_imag_b;
		prod_imag_r1	<= prod_imag;
		prod_round_r1	<= prod_round;
		
		// Product mux.
		prod_mux_r1		<= prod_mux;
		prod_mux_r2		<= prod_mux_r1;

		// CIC Filter + Decimation.
		cic_dout_r1		<= cic_dout_round;
		cic_valid_r1	<= cic_valid_round;

		// CIC mux.
		cic_mux_r1		<= cic_mux;
		valid_mux_r1	<= valid_mux;
	end
end

// Assign outputs.
assign dout 		= cic_mux_r1;
assign dout_valid	= valid_mux_r1;
	
endmodule
