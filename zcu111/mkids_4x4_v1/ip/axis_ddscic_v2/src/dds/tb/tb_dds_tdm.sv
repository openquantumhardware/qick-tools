module tb;

parameter NCH	= 7;

reg 		rstn;
reg 		clk;
reg			rst_acc;
reg [15:0]	din;
reg		    din_last;
wire [31:0]	dout;
wire		dout_last;
wire		dout_valid;

// TDM-demux for debugging.
reg					sync_demux;
wire [NCH*32-1:0]	dout_demux;
wire			    valid_demux;

wire [15:0]			dout_real_ii [NCH];
wire [15:0]			dout_imag_ii [NCH];

genvar i;
generate
	for (i=0; i<NCH; i=i+1) begin
		assign dout_real_ii[i] = dout_demux[2*i*16 +: 16];
		assign dout_imag_ii[i] = dout_demux[(2*i+1)*16 +: 16];
	end
endgenerate

dds_tdm
	#(
		.NCH(NCH)
	)
	dds_tdm_i
	(
		.rstn		,
		.clk		,
		.rst_acc	,
		.din		,
		.din_last	,
		.dout		,
		.dout_last	,
		.dout_valid
	);

tdm_demux
    #(
        .NCH(NCH),
        .B	(32	)
    )
	tdm_demux_i
	(
		.rstn		(rstn		),
		.clk		(clk		),
		.sync		(sync_demux	),
		.din		(dout		),
		.din_last	(dout_last	),
		.din_valid	(dout_valid	),
		.dout		(dout_demux	),
		.dout_valid	(valid_demux)

	);

// Main TB.
initial begin
	rstn		<= 0;
	rst_acc		<= 1;
	sync_demux	<= 1;

	#300;

	@(posedge clk);
	rstn	<= 1;

	#300;

	@(posedge clk);
	rst_acc		<= 0;

	#200;

	@(posedge clk);
	sync_demux	<= 0;
	
end

// TDM channels.
initial begin
	// Frequencies.
    real w[NCH];
	for (int i=0; i<NCH; i=i+1) begin
		w[i] = 0;
	end
	w[0] = 1;
	w[1] = 3.3;

	// Init.
	din	<= 0;

	// Generate data.
	for (int i=0; i<10000; i = i+1) begin
		for (int j=0; j<NCH; j = j+1) begin
			@(posedge clk);
			din <= freq_calc(100, w[j]);
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

// Function to compute frequency register.
function [15:0] freq_calc;
    input real fclk;
    input real f;
    
	// All input frequencies are in MHz.
	real temp;
	temp = f/fclk*2**16;
	freq_calc = int'(temp);
endfunction

endmodule

