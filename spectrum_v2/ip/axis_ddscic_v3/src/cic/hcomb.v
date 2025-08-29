module hcomb
	#(
		parameter B		= 8
	)
	(
		// Reset and clock.
		input wire 			rstn		,
		input wire 			clk			,
	
		// Data input.
		input wire [B-1:0] 	din			,
		input wire			din_valid	,

		// Data output.
		output wire [B-1:0]	dout		,
		output wire			dout_valid
	);

/*************/
/* Internals */
/*************/
// Input/output.
wire signed [B-1:0] xn,yn;

// Delayed input.
reg  signed [B-1:0] xn_d;
reg  signed [B-1:0] xn_dd;

// Valid pipe.
reg					valid_r1;

/****************/
/* Architecture */
/****************/
// Input data.
assign xn = din;

// Adder.
assign yn = xn_d - xn_dd;

always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// Delayed input.
		xn_d		<= 0;
		xn_dd		<= 0;

		// Valid pipe.
		valid_r1	<= 0;
	end
	else begin
		// Delayed input.
		if (din_valid) begin
			xn_d	<= xn;
			xn_dd	<= xn_d;
		end

		// Valid pipe.
		valid_r1	<= din_valid;
	end
end

// Assign outputs.
assign dout 		= yn;
assign dout_valid	= valid_r1;

endmodule

