module tb;

parameter NCH= 13;
parameter B  = 5;

reg				rstn;
reg 			clk;
reg  [B-1:0]	din;
wire [B-1:0]	dout;
wire			dout_valid;
reg	 [7:0]		D_REG;

gdec
    #(
        .NCH(NCH),
        .B	(B	)
    )
    DUT
	( 
		.rstn		,
        .clk   		,
        .din    	,
        .dout		,
		.dout_valid	,
		.D_REG
    );

initial begin
	rstn		<= 0;
	din			<= 0;
	D_REG		<= 7;

	#300;

	@(posedge clk);
	rstn	<= 1;

	#200;

	for (int i=0; i<1000; i = i+1) begin
		@(posedge clk);
		din			<= $random;
	end
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end

endmodule

