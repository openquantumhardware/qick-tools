module tb;

parameter BIN  	= 16;
parameter Q		= 3;

// Maximum number of bits for CIC internals: BIN + Q*Log2(D),
// where Q is the number of cascaded stages and D is the 
// maximum decimation factor (pp. 562 Lyons book).
parameter BCIC	= BIN + Q*$clog2(1024);

reg					rstn;
reg 				clk;
wire [2*BCIC-1:0]	din;
wire [2*BCIC-1:0]	dout;
wire				dout_valid;
reg	 [9:0]			D_REG;

// I,Q input/output.
reg	 [BCIC-1:0]		din_i;
reg	 [BCIC-1:0]		din_q;
wire [BCIC-1:0]		dout_i;
wire [BCIC-1:0]		dout_q;

assign din 		= {din_q, din_i};
assign dout_i	= dout[0 	+: BCIC];
assign dout_q	= dout[BCIC +: BCIC];

cic_3_iq
    #(
        .B	(BCIC	)
    )
    cic_i
	( 
		.rstn		(rstn		),
        .clk   		(clk   		),
        .din    	(din    	),
        .dout		(dout		),
		.dout_valid	(dout_valid	),
		.D_REG		(D_REG		)
    );

// Main TB.
initial begin
	rstn	<= 0;
	D_REG	<= 200;

	#300;

	@(posedge clk);
	rstn	<= 1;
end

// Input signal.
initial begin
	// Frequency.
    real w0,w1,a0,a1;
	w0 = 2*3.14*0.00001;
	a0 = 0.66;
	w1 = 2*3.14*0.01;
	a1 = 0.23;

	// Init.
	din_i	<= 0;
	din_q	<= 0;

	// Generate data.
	for (int i=0; i<1000000; i = i+1) begin
		@(posedge clk);
		din_i <= a0*(2**(BIN-1))*$cos(w0*i+3.14/32) + a1*(2**(BIN-1))*$cos(w1*i+3.14/56);
		din_q <= a0*(2**(BIN-1))*$sin(w0*i+3.14/32) + a1*(2**(BIN-1))*$sin(w1*i+3.14/56);
	end
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end

endmodule

