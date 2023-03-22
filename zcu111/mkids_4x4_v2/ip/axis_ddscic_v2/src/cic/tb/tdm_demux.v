module tdm_demux
	(
		rstn		,
		clk			,
		din			,
		din_last	,
		din_valid	,
		dout		,
		dout_last	,
		dout_valid

	);

/**************/
/* Parameters */
/**************/
parameter NCH 	= 16;
parameter B		= 8;

/*********/
/* Ports */
/*********/
input				rstn;
input				clk;
input [B-1:0]		din;
input				din_last;
input				din_valid;
output[NCH*B-1:0]	dout;
output				dout_last;
output				dout_valid;

/*************/
/* Internals */
/*************/
// Channel counter.
reg [9:0]	cnt_ch;

// Data input registers.
reg	[B-1:0]	din_r [0:NCH-1];
reg			valid_r;
reg			last_r;

/****************/
/* Architecture */
/****************/
genvar i;
generate
	for (i=0; i<NCH; i=i+1) begin
		always @(posedge clk) begin
			if (rstn == 1'b0) begin
				// Data input registers.
				din_r[i] <= 0;
			end
			else begin
				// Data input registers.
				if (cnt_ch == i)
					if (din_valid == 1'b1)
						din_r[i] <= din;
			end
		end

	// Assign outputs.
	assign dout[i*B +: B] = din_r[i];

	end
endgenerate

always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// Channel counter.
		cnt_ch	<= 0;

		// Data input registers.
		valid_r	<= 0;
		last_r	<= 0;
	end
	else begin
		// Channel counter.
		if (cnt_ch == NCH-1)
			cnt_ch	<= 0;
		else
			cnt_ch <= cnt_ch + 1;

		// Data input registers.
		valid_r	<= din_valid;
		if (din_valid == 1'b1)
			last_r	<= din_last;
	end
end

// Assign outputs.
assign dout_last 	= last_r;
assign dout_valid	= valid_r;

endmodule

