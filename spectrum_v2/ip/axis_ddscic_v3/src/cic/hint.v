module hint
	#(
		parameter B		= 8
	)
	(
		// Reset and clock.
		input wire 			rstn	,
		input wire 			clk		,

		// Data input.
		input wire [B-1:0]	din		,

		// Data output.
		output wire [B-1:0]	dout
	);

/*************/
/* Internals */
/*************/
// Input/output.
wire signed [B-1:0] xn,yn;

// Delayed output.
reg  signed [B-1:0] yn_d;

/****************/
/* Architecture */
/****************/
// Input data.
assign xn = din;

// Adder.
assign yn = xn + yn_d;

always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// Delayed output.
		yn_d		<= 0;
	end
	else begin
		// Delayed output.
		yn_d		<= yn;
	end
end

// Assign outputs.
assign dout 		= yn;

endmodule

