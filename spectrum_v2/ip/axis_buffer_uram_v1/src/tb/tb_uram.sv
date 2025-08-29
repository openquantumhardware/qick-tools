module tb();

// DUT generics.
parameter AWIDTH	= 12;
parameter DWIDTH	= 8;
parameter NBPIPE	= 5;

reg 					clk		;
reg 					rst		;

// Port A.
reg 					wea		;
reg						cea		;
reg						ena		;
reg 	[DWIDTH-1:0] 	dina	;
reg 	[AWIDTH-1:0]	addra	;
wire 	[DWIDTH-1:0] 	douta	;

// Port B.
reg 					web		;
reg						ceb		;
reg						enb		;
reg 	[DWIDTH-1:0] 	dinb	;
reg 	[AWIDTH-1:0]	addrb	;
wire 	[DWIDTH-1:0] 	doutb	;

// URAM.
uram_dp
	#(
		.AWIDTH	(AWIDTH	),
		.DWIDTH	(DWIDTH	),
		.NBPIPE	(NBPIPE	)
 	)
	mem_i
	( 
		.clk	,
		.rst	,

		// Port A.
		.wea	,
		.cea	,
		.ena	,
    	.dina	,
    	.addra	,
    	.douta	,

		// Port B.
		.web	,
		.ceb	,
		.enb	,
    	.dinb	,
    	.addrb	,
    	.doutb
   );

// Reset sequence.
initial begin
	rst <= 1;
	#300;
	rst <= 0;
end

// Write some data into URAM.
initial begin
	wea		<= 0;
	cea		<= 0;
	ena		<= 0;
	dina	<= 0;
	addra	<= 0;

	#1000;

	for (int i=0; i<50; i = i+1) begin
		@(posedge clk);
		wea		<= 1;
		cea		<= 0;
		ena		<= 1;
		dina	<= i;
		addra	<= i;
	end

	@(posedge clk);
	wea		<= 0;
end

// Read some data from URAM.
initial begin
	web		<= 0;
	ceb		<= 0;
	enb		<= 0;
	dinb	<= 0;
	addrb	<= 0;

	#2000;

	for (int i=0; i<20; i = i+1) begin
		@(posedge clk);
		ceb		<= 1;
		enb		<= 1;
		addrb	<= i;
	end

	@(posedge clk);
	ceb		<= 1;
	enb		<= 0;

	#100;

	for (int i=20; i<30; i = i+1) begin
		@(posedge clk);
		ceb		<= 1;
		enb		<= 1;
		addrb	<= i;
	end

end

always begin
	clk <= 0;
	#10;
	clk <= 1;
	#10;
end

endmodule

