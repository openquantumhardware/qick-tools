// Polyphase Filter Bank, 8 lanes, 16 channels, 50 % overlap.
// s_axi_aclk	: clock for s_axi_*
// aclk			: clock for s_axis_* and m_axis_*
module axis_pfb_8x16_v1
	( 
		// AXI Slave I/F for configuration.
		input				s_axi_aclk		,
		input				s_axi_aresetn	,
		
		input	[7:0]		s_axi_awaddr	,
		input	[2:0]		s_axi_awprot	,
		input				s_axi_awvalid	,
		output				s_axi_awready	,
		
		input	[31:0]		s_axi_wdata		,
		input	[3:0]		s_axi_wstrb		,
		input				s_axi_wvalid	,
		output				s_axi_wready	,
		
		output	[1:0]		s_axi_bresp		,
		output				s_axi_bvalid	,
		input				s_axi_bready	,
		
		input	[7:0]		s_axi_araddr	,
		input	[2:0]		s_axi_arprot	,
		input				s_axi_arvalid	,
		output				s_axi_arready	,
		
		output	[31:0]		s_axi_rdata		,
		output	[1:0]		s_axi_rresp		,
		output				s_axi_rvalid	,
		input				s_axi_rready	,

		// s_* and m_* reset/clock.
		input				aresetn			,
		input				aclk			,

    	// S_AXIS for data input.
		output				s_axis_tready	,
		input				s_axis_tvalid	,
		input 	[8*32-1:0]	s_axis_tdata	,

		// M_AXIS for data output.
		output				m_axis_tvalid	,
		output	[16*32-1:0]	m_axis_tdata
	);

/********************/
/* Internal signals */
/********************/
// Registers.
wire	[31:0]	SCALE_REG;
wire	[31:0]	QOUT_REG;

/**********************/
/* Begin Architecture */
/**********************/
// AXI Slave.
axi_slv axi_slv_i
	(
		.s_axi_aclk		(s_axi_aclk	 	),
		.s_axi_aresetn	(s_axi_aresetn	),

		// Write Address Channel.
		.s_axi_awaddr	(s_axi_awaddr 	),
		.s_axi_awprot	(s_axi_awprot 	),
		.s_axi_awvalid	(s_axi_awvalid	),
		.s_axi_awready	(s_axi_awready	),

		// Write Data Channel.
		.s_axi_wdata	(s_axi_wdata	),
		.s_axi_wstrb	(s_axi_wstrb	),
		.s_axi_wvalid	(s_axi_wvalid   ),
		.s_axi_wready	(s_axi_wready	),

		// Write Response Channel.
		.s_axi_bresp	(s_axi_bresp	),
		.s_axi_bvalid	(s_axi_bvalid	),
		.s_axi_bready	(s_axi_bready	),

		// Read Address Channel.
		.s_axi_araddr	(s_axi_araddr 	),
		.s_axi_arprot	(s_axi_arprot 	),
		.s_axi_arvalid	(s_axi_arvalid	),
		.s_axi_arready	(s_axi_arready	),

		// Read Data Channel.
		.s_axi_rdata	(s_axi_rdata	),
		.s_axi_rresp	(s_axi_rresp	),
		.s_axi_rvalid	(s_axi_rvalid	),
		.s_axi_rready	(s_axi_rready	),

		// Registers.
		.SCALE_REG		(SCALE_REG		),
		.QOUT_REG		(QOUT_REG		)
	);

// PFB Block.
pfb
	#(
		.L	(8	)
	)
	pfb_i
	(
		// Reset and clock.
		.aresetn		(aresetn		),
		.aclk			(aclk			),

		// S_AXIS for input data.
		.s_axis_tready	(s_axis_tready	),
		.s_axis_tvalid	(s_axis_tvalid	),
		.s_axis_tdata	(s_axis_tdata	),

		// M_AXIS for output data.
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tdata	(m_axis_tdata	),

		// Registers.
		.SCALE_REG		(SCALE_REG		),
		.QOUT_REG		(QOUT_REG		)
	);

endmodule

