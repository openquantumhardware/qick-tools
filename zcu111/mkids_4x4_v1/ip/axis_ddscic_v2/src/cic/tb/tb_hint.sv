module tb;

parameter NCH= 7;
parameter B  = 5;

reg				rstn;
reg 			clk;
reg  [B-1:0]	din;
reg				din_last;
wire [B-1:0]	dout;
wire			dout_last;

hint
    #(
        .NCH(NCH),
        .B	(B	)
    )
    DUT
	( 
		.rstn		,
        .clk   		,
        .din    	,
		.din_last	,
        .dout		,
		.dout_last
    );

initial begin
	rstn		<= 0;
	din			<= 0;
	din_last	<= 0;

	#300;

	@(posedge clk);
	rstn	<= 1;

	#200;

	for (int i=0; i<1000; i = i+1) begin
		@(posedge clk);
		din	<= $random;
	end
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end

endmodule

