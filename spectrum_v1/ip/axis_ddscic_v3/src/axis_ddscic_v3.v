module axis_ddscic_v3
	(
		/*********************/
		/* s_axi_aclk domain */
		/*********************/
		input wire					s_axi_aclk		,
		input wire					s_axi_aresetn	,
		
		input wire	[5:0]			s_axi_awaddr	,
		input wire	[2:0]			s_axi_awprot	,
		input wire					s_axi_awvalid	,
		output wire					s_axi_awready	,
		
		input wire	[31:0]			s_axi_wdata		,
		input wire	[3:0]			s_axi_wstrb		,
		input wire					s_axi_wvalid	,
		output wire					s_axi_wready	,
		
		output wire	[1:0]			s_axi_bresp		,
		output wire					s_axi_bvalid	,
		input wire					s_axi_bready	,
		
		input wire	[5:0]			s_axi_araddr	,
		input wire	[2:0]			s_axi_arprot	,
		input wire					s_axi_arvalid	,
		output wire					s_axi_arready	,
		
		output wire	[31:0]			s_axi_rdata		,
		output wire	[1:0]			s_axi_rresp		,
		output wire					s_axi_rvalid	,
		input wire					s_axi_rready	,

		/***************/
		/* aclk domain */
		/***************/
		input wire					aclk			,
		input wire					aresetn			,

		// S_AXIS for input data.
		input wire	[31:0]			s_axis_tdata	,
		input wire					s_axis_tvalid	,
		output wire					s_axis_tready	,

		// M_AXIS for output data.
		output wire	[31:0]			m_axis_tdata	,
		input wire					m_axis_tready	,
		output wire					m_axis_tvalid
	);

/*************/
/* Internals */
/*************/

// Registers.
wire [31:0]	PINC_REG	;
wire		PINC_WE_REG	;
wire [1:0]	PRODSEL_REG	;
wire		CICSEL_REG	;
wire [31:0]	QPROD_REG	;
wire [31:0]	QCIC_REG	;
wire [31:0]	DEC_REG		;

/****************/
/* Architecture */
/****************/
// AXI Slave.
axi_slv axi_slv_i
	(
		// Reset and clock.
		.aclk			(s_axi_aclk	 	),
		.aresetn		(s_axi_aresetn	),

		// Write Address Channel.
		.awaddr			(s_axi_awaddr 	),
		.awprot			(s_axi_awprot 	),
		.awvalid		(s_axi_awvalid	),
		.awready		(s_axi_awready	),
		
		// Write Data Channel.
		.wdata			(s_axi_wdata	),
		.wstrb			(s_axi_wstrb	),
		.wvalid			(s_axi_wvalid	),
		.wready			(s_axi_wready	),
		
		// Write Response Channel.
		.bresp			(s_axi_bresp	),
		.bvalid			(s_axi_bvalid	),
		.bready			(s_axi_bready	),
		
		// Read Address Channel.
		.araddr			(s_axi_araddr 	),
		.arprot			(s_axi_arprot 	),
		.arvalid		(s_axi_arvalid	),
		.arready		(s_axi_arready	),
		
		// Read Data Channel.
		.rdata			(s_axi_rdata	),
		.rresp			(s_axi_rresp	),
		.rvalid			(s_axi_rvalid	),
		.rready			(s_axi_rready	),

		// Registers.
		.PINC_REG		(PINC_REG		),
		.PINC_WE_REG	(PINC_WE_REG	),
		.PRODSEL_REG	(PRODSEL_REG	),
		.CICSEL_REG		(CICSEL_REG		),
		.QPROD_REG		(QPROD_REG		),
		.QCIC_REG		(QCIC_REG		),
		.DEC_REG		(DEC_REG		)
);

// DDS + FIR block.
ddscic
	#(
		// Number of bits.
		.B(16)
	)
	ddscic_i
	(
		// Reset and clock.
		.rstn			(aresetn		),
		.clk			(aclk			),

		// Input data.
		.din			(s_axis_tdata	),

		// Output data.
		.dout			(m_axis_tdata	),
		.dout_valid		(m_axis_tvalid	),

		// Registers.
		.PINC_REG		(PINC_REG		),
		.PINC_WE_REG	(PINC_WE_REG	),
		.PRODSEL_REG	(PRODSEL_REG	),
		.CICSEL_REG		(CICSEL_REG		),
		.QPROD_REG		(QPROD_REG		),
		.QCIC_REG		(QCIC_REG		),
		.DEC_REG		(DEC_REG		)
	);

// Assign outputs.
assign s_axis_tready	= 1'b1;

endmodule

