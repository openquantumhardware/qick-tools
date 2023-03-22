module tb;

parameter NCH	= 5;
parameter BIN  	= 16;

// Maximum number of bits for CIC internals: BIN + Q*Log2(D),
// where Q is the number of cascaded stages and D is the 
// maximum decimation factor (pp. 562 Lyons book).
parameter BCIC	= BIN + $clog2(256);

reg					rstn;
reg 				clk;
reg  [BCIC-1:0]		din;
reg					din_last;
wire [BCIC-1:0]		dout;
wire				dout_last;
wire				dout_valid;
reg	 [7:0]			D_REG;

// TDM-demux for debugging.
wire [NCH*BCIC-1:0]	dout_demux;
wire				last_demux;
wire				valid_demux;

wire [BCIC-1:0]		dout_ii [NCH];

genvar i;
generate
	for (i=0; i<NCH; i=i+1) begin
		assign dout_ii[i] = dout_demux[i*BCIC +: BCIC];
	end
endgenerate

cic
    #(
        .NCH(NCH	),
        .B	(BCIC	)
    )
    cic_i
	( 
		.rstn		(rstn		),
        .clk   		(clk   		),
        .din    	(din    	),
		.din_last	(din_last	),
        .dout		(dout		),
		.dout_last	(dout_last	),
		.dout_valid	(dout_valid	),
		.D_REG		(D_REG		)
    );

tdm_demux
    #(
        .NCH(NCH	),
        .B	(BCIC	)
    )
	tdm_demux_i
	(
		.rstn		(rstn		),
		.clk		(clk		),
		.din		(dout		),
		.din_last	(dout_last	),
		.din_valid	(dout_valid	),
		.dout		(dout_demux	),
		.dout_last	(last_demux	),
		.dout_valid	(valid_demux)

	);

// Main TB.
initial begin
	rstn	<= 0;
	D_REG	<= 160;

	#300;

	@(posedge clk);
	rstn	<= 1;
end

// TDM channels.
initial begin
	// Frequencies.
    real w[NCH];
	for (int i=0; i<NCH; i=i+1) begin
		w[i] = 0;
	end
	w[0] = 2*3.14*0.001;
	w[1] = 2*3.14*0.07;
	w[2] = 0;

	// Init.
	din			<= 0;
	din_last	<= 0;

	// Generate data.
	for (int i=0; i<10000; i = i+1) begin
		for (int j=0; j<NCH; j = j+1) begin
			@(posedge clk);
			din <= (2**(BIN-1))*$cos(w[j]*i);
			if (j == NCH-1)
				din_last <= 1;
			else
				din_last <= 0;
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

