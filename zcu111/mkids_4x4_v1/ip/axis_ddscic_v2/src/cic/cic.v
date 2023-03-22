module cic
	(
		rstn		,
		clk			,
		din			,
		din_last	,
		dout		,
		dout_last	,
		dout_valid	,
		D_REG
	);

/**************/
/* Parameters */
/**************/
parameter NCH 	= 16;
parameter B		= 8;

/*********/
/* Ports */
/*********/
input			rstn;
input			clk;
input [B-1:0]	din;
input			din_last;
output[B-1:0]	dout;
output			dout_last;
output			dout_valid;
input [7:0]		D_REG;

/*************/
/* Internals */
/*************/
wire	[B-1:0]	hint_dout;
wire			hint_last;
wire	[B-1:0]	gdec_dout;
wire			gdec_last;
wire			gdec_valid;

/****************/
/* Architecture */
/****************/

// TDM Integrator.
hint
    #(
        .NCH(NCH),
        .B	(B	)
    )
    hint_i
	( 
		.rstn		(rstn		),
        .clk   		(clk		),
        .din    	(din		),
		.din_last	(din_last	),
        .dout		(hint_dout	),
		.dout_last	(hint_last	)
    );

// TDM Decimator.
gdec
    #(
        .NCH(NCH),
        .B	(B	)
    )
    gdec_i
	( 
		.rstn		(rstn		),
        .clk   		(clk		),
        .din    	(hint_dout	),
		.din_last	(hint_last	),
        .dout		(gdec_dout	),
		.dout_last	(gdec_last	),
		.dout_valid	(gdec_valid	),
		.D_REG		(D_REG		)
    );

// TDM Comb
hcomb
    #(
        .NCH(NCH),
        .B	(B	)
    )
    hcomb_i
	( 
		.rstn		(rstn		),
        .clk   		(clk		),
        .din    	(gdec_dout	),
		.din_last	(gdec_last	),
		.din_valid	(gdec_valid	),
        .dout		(dout		),
		.dout_last	(dout_last	),
		.dout_valid	(dout_valid	)
    );

endmodule

