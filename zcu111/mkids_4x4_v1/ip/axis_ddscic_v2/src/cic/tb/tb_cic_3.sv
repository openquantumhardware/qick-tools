module tb;

// Number of channels.
parameter NCH 	= 8;

// Number of bits.
parameter B		= 8;

// Number of pipeline registers.
parameter NPIPE	= 2	;

// Maximum number of bits for CIC internals: BIN + Q*Log2(D),
// where Q is the number of cascaded stages and D is the 
// maximum decimation factor (pp. 562 Lyons book).
parameter DMAX	= 16;
parameter Q		= 3;
parameter BCIC	= B + Q*$clog2(DMAX);

// Reset and clock.
reg 			rstn		;
reg 			clk			;

// Data input.
wire [BCIC-1:0]	din			;
reg 			din_last	;

// Data output.
wire [BCIC-1:0]	dout		;
wire 			dout_last	;
wire			dout_valid	;

// Registers.
reg				RST_REG		;
reg	[7:0]		D_REG		;

// B-bits data input.
reg	[B-1:0]		din_b		;

// TDM-demux for debugging.
reg					sync			;
wire [NCH*BCIC-1:0]	demux_din_dout	;
wire				demux_din_valid	;
wire [NCH*BCIC-1:0]	demux_dout_dout	;
wire				demux_dout_valid;

wire [BCIC-1:0]		din_ii	[NCH];
wire [BCIC-1:0]		dout_ii [NCH];

// Sign-extended data input.
assign din = {{(BCIC-B){din_b[B-1]}},din_b};

genvar i;
generate
	for (i=0; i<NCH; i=i+1) begin
		assign din_ii	[i] = demux_din_dout	[i*BCIC	+: BCIC];
		assign dout_ii	[i]	= demux_dout_dout	[i*BCIC +: BCIC];
	end
endgenerate

cic_3
	#(
		// Number of channels.
		.NCH(NCH),

		// Number of bits.
		.B(BCIC),

		// Number of pipeline registers.
		.NPIPE(NPIPE)
	)
	cic_i
	(
		// Reset and clock.
		.rstn		,
		.clk		,

		// Data input.
		.din		,
		.din_last	,

		// Data output.
		.dout		,
		.dout_last	,
		.dout_valid	,

		// Registers.
		.RST_REG	,
		.D_REG
	);

// TDM-demux for input data.
tdm_demux
    #(
        .NCH(NCH	),
        .B	(BCIC	)
    )
	tdm_demux_din_i
	(
		// Reset and clock.
		.rstn		(rstn				),
		.clk		(clk				),

		// Resync.
		.sync		(sync				),

		// Data input.
		.din		(din				),
		.din_last	(din_last			),
		.din_valid	(1'b1				),

		// Data output.
		.dout		(demux_din_dout		),
		.dout_valid	(demux_din_valid	)

	);

// TDM-demux for output data.
tdm_demux
    #(
        .NCH(NCH	),
        .B	(BCIC	)
    )
	tdm_demux_i
	(
		// Reset and clock.
		.rstn		(rstn				),
		.clk		(clk				),

		// Resync.
		.sync		(sync				),

		// Data input.
		.din		(dout				),
		.din_last	(dout_last			),
		.din_valid	(dout_valid			),

		// Data output.
		.dout		(demux_dout_dout	),
		.dout_valid	(demux_dout_valid	)

	);

// Main TB.
initial begin
	rstn	<= 0;
	RST_REG	<= 1;
	D_REG	<= 2;
	sync	<= 1;

	#300;

	@(posedge clk);
	rstn	<= 1;

	#200;

	@(posedge clk);
	RST_REG	<= 0;
	sync	<= 0;
end

// TDM channels.
initial begin
	// Frequencies.
    real w[NCH];
	for (int i=0; i<NCH; i=i+1) begin
		w[i] = 0;
	end
	w[0] = 2*3.14*0.001;
	//w[1] = 2*3.14*0.02;
	//w[2] = 0;

	// Init.
	din_b		<= 0;
	din_last	<= 0;

	// Generate data.
	for (int i=0; i<10000; i = i+1) begin
		for (int j=0; j<NCH; j = j+1) begin
			@(posedge clk);
			din_b <= 0.2*(2**(B-1)-1)*$sin(w[j]*i);
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

