module wctrl 
	#(
		parameter N = 5	,
		parameter B = 8
	)
	(
		// Reset and clock.
		input wire 				clk				,
		input wire 				rstn			,

		// Memory if.
		output wire [N-1:0]		mem_addr		,
		input wire [B-1:0]		mem_dout		,

		// s_axis for input data.
		input wire 	[2*B-1:0]	s_axis_tdata	,
		input wire				s_axis_tvalid	,

		// m_axis for output data.
		output wire	[2*B-1:0]	m_axis_tdata	,
		output wire				m_axis_tlast	,
		output wire				m_axis_tvalid
	);

/********************/
/* Internal signals */
/********************/
// Register for input data.
reg	[2*B-1:0]			din_r1				;
reg	[2*B-1:0]			din_r2				;
reg	[2*B-1:0]			din_r3				;

// Registers for memory data.
reg	[B-1:0]				mem_dout_r1			;
reg	[B-1:0]				mem_dout_r2			;

// Address counter.
reg	[N-1:0]				cnt;

// Product.
wire signed	[B-1:0]		mem_real			;
wire signed	[B-1:0]		din_real			;
wire signed	[B-1:0]		din_imag			;
wire signed [2*B-1:0]	prod_real			;
wire		[B-1:0]		prod_real_round		;
reg			[B-1:0]		prod_real_round_r1	;
wire signed	[2*B-1:0]	prod_imag			;
wire		[B-1:0]		prod_imag_round		;
reg			[B-1:0]		prod_imag_round_r1	;
wire		[2*B-1:0]	prod				;
reg			[2*B-1:0]	prod_r1				;

// tlast.
wire					tlast				;

/**********************/
/* Begin Architecture */
/**********************/

// tlast latency.
latency_reg
	#(
		// Latency.
		.N(5),

		// Data width.
		.B(1)
	)
	tlast_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(tlast			),

		// Data output.
		.dout	(m_axis_tlast	)
	);

// valid latency.
latency_reg
	#(
		// Latency.
		.N(5),

		// Data width.
		.B(1)
	)
	valid_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(s_axis_tvalid	),

		// Data output.
		.dout	(m_axis_tvalid	)
	);

// Product.
assign mem_real			= mem_dout_r2;
assign din_real			= din_r3[0 +: B];
assign din_imag			= din_r3[B +: B];
assign prod_real		= mem_real*din_real;
assign prod_real_round	= prod_real[2*B-2 -: B];
assign prod_imag		= mem_real*din_imag;
assign prod_imag_round	= prod_imag[2*B-2 -: B];
assign prod				= {prod_imag_round_r1, prod_real_round_r1};

// tlast.
assign tlast = (cnt == '1)? 1'b1 : 1'b0;

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Register for input data.
		din_r1				<= 0;
		din_r2				<= 0;
		din_r3				<= 0;

		// Registers for memory data.
		mem_dout_r1			<= 0;
		mem_dout_r2			<= 0;

		// Address counter.
		cnt					<= 0;

		// Product.
		prod_real_round_r1	<= 0;
		prod_imag_round_r1	<= 0;
		prod_r1				<= 0;
	end
	else begin
		// Register for input data.
		din_r1				<= s_axis_tdata;
		din_r2				<= din_r1;
		din_r3				<= din_r2;

		// Registers for memory data.
		mem_dout_r1			<= mem_dout;
		mem_dout_r2			<= mem_dout_r1;

		// Address counter.
		if (s_axis_tvalid == 1'b1)
			cnt	<= cnt + 1;

		// Product.
		prod_real_round_r1	<= prod_real_round;
		prod_imag_round_r1	<= prod_imag_round;
		prod_r1				<= prod;
	end
end 

// Assign outputs.
assign mem_addr 	= cnt;
assign m_axis_tdata	= prod_r1;

endmodule

