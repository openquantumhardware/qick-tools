module dec
	#(
		// Number of bits.
		parameter B = 8
	)
	(
		// Reset and clock.
		input wire			rstn		,
		input wire			clk			,

		// Data input.
		input wire 	[B-1:0]	din			,

		// Data output.
		output wire [B-1:0]	dout		,
		output wire			dout_valid	,

		// Registers.
		input wire	[9:0]	D_REG
	);
/*************/
/* Internals */
/*************/
// Decimation register.
wire [9:0]	dreg_int;
reg  [9:0]	dreg_r;

// Decimation counter.
reg	 [9:0]	cnt_d;

/****************/
/* Architecture */
/****************/
// Decimation register.
assign dreg_int = (D_REG < 2)? 2 : D_REG;

always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// Decimation register.
		dreg_r	<= 0;

		// Decimation counter.
		cnt_d	<= 0;
	end
	else begin
		// Decimation register.
		dreg_r	<= dreg_int;

		// Decimation counter.
		if (cnt_d == dreg_r-1)
			cnt_d	<= 0;
		else
			cnt_d	<= cnt_d + 1;
	end
end

// Assign outputs.
assign dout 		= din;
assign dout_valid	= (cnt_d == 0)? 1'b1 : 0;

endmodule

