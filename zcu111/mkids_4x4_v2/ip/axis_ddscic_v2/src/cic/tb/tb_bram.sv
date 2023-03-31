module tb;

parameter N = 3;
parameter B = 8;

reg 			clk;
reg 			en;
reg 			we;
reg  [N-1:0]	addr;
reg  [B-1:0]	din;
wire [B-1:0]	dout;

initial begin
	en 		<= 1;
	we 		<= 0;
	addr	<= 0;
	din		<= 0;

	@(posedge clk);
	we 		<= 1;

	for (int i=0; i<1000; i = i+1) begin
		@(posedge clk);
		we 		<= 1;
		if (addr == 2**N-2)
			addr <= 0;
		else
			addr 	<= addr + 1;
		din		<= din + 1;
	end

	@(posedge clk);
	we 		<= 0;
end

bram_sp_rf
    #(
        // Memory address size.
        .N(N),
        // Data width.
        .B(B)
    )
    DUT
	( 
        .clk   	,
        .en     ,
        .we    	,
        .addr 	,
        .din    ,
        .dout
    );

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end

endmodule

