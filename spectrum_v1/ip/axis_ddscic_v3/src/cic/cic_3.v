/*
 * Cascaded CIC filter implementation with 3 stages.
 * Differential delay: 1.
 * Decimatiion factor: 2-1023
 */
module cic_3
	#(
		// Number of bits.
		parameter B		= 8	,

		// Number of pipeline registers.
		parameter NPIPE	= 2
	)
	(
		// Reset and clock.
		input wire 			rstn		,
		input wire 			clk			,

		// Data input.
		input wire [B-1:0] 	din			,

		// Data output.
		output wire [B-1:0]	dout		,
		output wire			dout_valid	,

		// Registers.
		input wire [9:0]	D_REG
	);

/*************/
/* Internals */
/*************/
// Data input latency.
wire	[B-1:0]	din_la;

// Integrator outputs.
wire	[B-1:0]	hint0_dout;
wire	[B-1:0]	hint1_dout;
wire	[B-1:0]	hint2_dout;

// Integrator latenccy.
wire	[B-1:0]	hint0_dout_la;
wire	[B-1:0]	hint1_dout_la;
wire	[B-1:0]	hint2_dout_la;

// Decimator outputs.
wire	[B-1:0]	dec_dout;
wire			dec_valid;

// Decimator latency.
wire	[B-1:0]	dec_dout_la;
wire			dec_valid_la;

// Comb outputs.
wire	[B-1:0]	hcomb0_dout;
wire			hcomb0_valid;
wire	[B-1:0]	hcomb1_dout;
wire			hcomb1_valid;
wire	[B-1:0]	hcomb2_dout;
wire			hcomb2_valid;

// Comb latency.
wire	[B-1:0]	hcomb0_dout_la;
wire			hcomb0_valid_la;
wire	[B-1:0]	hcomb1_dout_la;
wire			hcomb1_valid_la;
wire	[B-1:0]	hcomb2_dout_la;
wire			hcomb2_valid_la;

// Output register.
reg		[B-1:0]	dout_r;
reg		[B-1:0]	valid_r;

/****************/
/* Architecture */
/****************/

// din_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(B	)
	)
	din_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Data input.
		.din	(din	),

		// Data output.
		.dout	(din_la	)
	);

// Integrator.
hint
    #(
        .B(B)
    )
    hint0_i
	( 
		.rstn		(rstn			),
        .clk   		(clk			),
        .din    	(din_la			),
        .dout		(hint0_dout		)
    );

// hint0_dout_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(B	)
	)
	hint0_dout_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(hint0_dout		),

		// Data output.
		.dout	(hint0_dout_la	)
	);

// Integrator.
hint
    #(
        .B	(B	)
    )
    hint1_i
	( 
		.rstn		(rstn			),
        .clk   		(clk			),
        .din    	(hint0_dout_la	),
        .dout		(hint1_dout		)
    );

// hint1_dout_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(B	)
	)
	hint1_dout_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(hint1_dout		),

		// Data output.
		.dout	(hint1_dout_la	)
	);

// Integrator.
hint
    #(
        .B	(B	)
    )
    hint2_i
	( 
		.rstn		(rstn			),
        .clk   		(clk			),
        .din    	(hint1_dout_la	),
        .dout		(hint2_dout		)
    );

// hint2_dout_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(B	)
	)
	hint2_dout_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(hint2_dout		),

		// Data output.
		.dout	(hint2_dout_la	)
	);

// Decimator.
dec
    #(
        .B	(B	)
    )
    gdec_i
	( 
		.rstn		(rstn			),
        .clk   		(clk			),
        .din    	(hint2_dout_la	),
        .dout		(dec_dout		),
		.dout_valid	(dec_valid		),
		.D_REG		(D_REG			)
    );

// gdec_dout_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(B	)
	)
	gdec_dout_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(dec_dout		),

		// Data output.
		.dout	(dec_dout_la	)
	);

// gdec_valid_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(1	)
	)
	gdec_valid_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(dec_valid		),

		// Data output.
		.dout	(dec_valid_la	)
	);

// Comb.
hcomb
    #(
        .B	(B	)
    )
    hcomb0_i
	( 
		.rstn		(rstn			),
        .clk   		(clk			),
        .din    	(dec_dout_la	),
		.din_valid	(dec_valid_la	),
        .dout		(hcomb0_dout	),
		.dout_valid	(hcomb0_valid	)
    );

// hcomb0_dout_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(B	)
	)
	hcomb0_dout_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(hcomb0_dout	),

		// Data output.
		.dout	(hcomb0_dout_la	)
	);

// hcomb0_valid_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(1	)
	)
	hcomb0_valid_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn				),
		.clk	(clk				),

		// Data input.
		.din	(hcomb0_valid		),

		// Data output.
		.dout	(hcomb0_valid_la	)
	);

// Comb.
hcomb
    #(
        .B	(B	)
    )
    hcomb1_i
	( 
		.rstn		(rstn				),
        .clk   		(clk				),
        .din		(hcomb0_dout_la		),
		.din_valid	(hcomb0_valid_la	),
        .dout		(hcomb1_dout		),
		.dout_valid	(hcomb1_valid		)
    );

// hcomb1_dout_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(B	)
	)
	hcomb1_dout_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(hcomb1_dout	),

		// Data output.
		.dout	(hcomb1_dout_la	)
	);

// hcomb1_valid_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(1	)
	)
	hcomb1_valid_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn				),
		.clk	(clk				),

		// Data input.
		.din	(hcomb1_valid		),

		// Data output.
		.dout	(hcomb1_valid_la	)
	);

// Comb.
hcomb
    #(
        .B	(B	)
    )
    hcomb2_i
	( 
		.rstn		(rstn				),
        .clk   		(clk				),
        .din		(hcomb1_dout_la		),
		.din_valid	(hcomb1_valid_la	),
        .dout		(hcomb2_dout		),
		.dout_valid	(hcomb2_valid		)
    );

// hcomb2_dout_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(B	)
	)
	hcomb2_dout_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(hcomb2_dout	),

		// Data output.
		.dout	(hcomb2_dout_la	)
	);

// hcomb2_valid_latency_reg
latency_reg
	#(
		// Latency.
		.N(NPIPE),

		// Data width.
		.B(1	)
	)
	hcomb2_valid_latency_reg_i
	(
		// Reset and clock.
		.rstn	(rstn				),
		.clk	(clk				),

		// Data input.
		.din	(hcomb2_valid		),

		// Data output.
		.dout	(hcomb2_valid_la	)
	);

// Registers.
always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// Output register.
		dout_r	<= 0;
		valid_r	<= 0;
	end
	else begin
		// Output register.
		if (hcomb2_valid_la == 1'b1)
			dout_r	<= hcomb2_dout_la;

		valid_r	<= hcomb2_valid_la;

	end
end

// Assign outputs.
assign dout			= dout_r;
assign dout_valid	= valid_r;

endmodule

