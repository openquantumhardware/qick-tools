module tb;

parameter NCH= 7;
parameter B  = 8;

// Reset and clock.
reg				rstn		;
reg 			clk			;

// Data input.
reg  [B-1:0]	din			;
reg				din_last	;
reg				din_valid	;

// Data output.
wire [B-1:0]	dout		;
wire			dout_last	;
wire			dout_valid	;

hcomb
    #(
        .NCH(NCH),
        .B	(B	)
    )
    DUT
	( 
		// Reset and clock.
		.rstn		,
		.clk		,
	
		// Data input.
		.din		,
		.din_last	,
		.din_valid	,

		// Data output.
		.dout		,
		.dout_last	,
		.dout_valid
    );

initial begin
	rstn		<= 0;
	din			<= 0;
	din_last	<= 0;
	din_valid	<= 0;

	#300;

	@(posedge clk);
	rstn	<= 1;

	#200;

	for (int i=0; i<1000; i = i+1) begin
		for (int j=0; j<NCH; j=j+1) begin
			@(posedge clk);
			din			<= $random;
			din_valid 	<= 1;
		end
		for (int j=0; j<NCH; j=j+1) begin
			@(posedge clk);
			din_valid 	<= 0;
		end
	end
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end

endmodule

