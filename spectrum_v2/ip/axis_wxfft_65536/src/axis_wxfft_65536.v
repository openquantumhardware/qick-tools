module axis_wxfft_65536
	(
		// AXI Slave I/F for configuration.
		input wire 			s_axi_aclk			,
		input wire 			s_axi_aresetn		,
		
		input wire 	[5:0]	s_axi_awaddr		,
		input wire 	[2:0]	s_axi_awprot		,
		input wire 			s_axi_awvalid		,
		output wire			s_axi_awready		,
		
		input wire	[31:0]	s_axi_wdata			,
		input wire	[3:0]	s_axi_wstrb			,
		input wire			s_axi_wvalid		,
		output wire			s_axi_wready		,
		
		output wire	[1:0]	s_axi_bresp			,
		output wire			s_axi_bvalid		,
		input wire			s_axi_bready		,
		
		input wire	[5:0]	s_axi_araddr		,
		input wire	[2:0]	s_axi_arprot		,
		input wire			s_axi_arvalid		,
		output wire			s_axi_arready		,
		
		output wire	[31:0]	s_axi_rdata			,
		output wire	[1:0]	s_axi_rresp			,
		output wire			s_axi_rvalid		,
		input wire			s_axi_rready		,

		// s_axis_coef*, s_axis_data* and m_axis_data* reset and clock.
		input wire			aclk				,
		input wire			aresetn				,

		// s0_axis for uploading window coefficients.
		input wire			s_axis_coef_tvalid	,
		input wire	[15:0]	s_axis_coef_tdata	,
		output wire			s_axis_coef_tready	,

		// s_axis for input.
		input wire	[31:0]	s_axis_data_tdata	,
		input wire			s_axis_data_tvalid	,

		// m_axis for output.
		output wire	[63:0]	m_axis_data_tdata	,
		output wire	[15:0]	m_axis_data_tuser	,
		output wire			m_axis_data_tlast	,
		output wire			m_axis_data_tvalid
	);

/********************/
/* Internal signals */
/********************/
// LOG2(FFT SIZE).
localparam N = 16;

// Number of bits.
localparam B = 16;

// Memory IF for writing coefficients.
wire 			mem_ena			;
wire 			mem_wea			;
wire [N-1:0]	mem_addra		;
wire [B-1:0]	mem_dia			;

// Memory IF for reading coefficients.
wire [N-1:0]	mem_addrb		;
wire [B-1:0]	mem_dob			;

// axis_data for window-fft connection.
wire	[31:0]	axis_tdata		;
wire			axis_tlast		;
wire			axis_tvalid		;

// Registers.
wire [31:0] 	DW_ADDR_REG		;
wire 			DW_WE_REG		;

/**********************/
/* Begin Architecture */
/**********************/
// AXI Slave.
axi_slv axi_slv_i
	(
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
		.wvalid			(s_axi_wvalid   ),
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
		.DW_ADDR_REG	(DW_ADDR_REG	),
		.DW_WE_REG		(DW_WE_REG		)
	);


// Data writer.
data_writer
    #(
        // Memory size.
        .N(N),
        // Data width.
        .B(B)
    )
    data_writer_i
    (
        .rstn           (aresetn			),
        .clk            (aclk				),
        
        // AXI Stream I/F.
        .s_axis_tready	(s_axis_coef_tready	),
		.s_axis_tdata	(s_axis_coef_tdata	),
		.s_axis_tvalid	(s_axis_coef_tvalid	),
		
		// Memory I/F.
		.mem_en         (mem_ena			),
		.mem_we         (mem_wea			),
		.mem_addr       (mem_addra			),
		.mem_di         (mem_dia			),
		
		// Registers.
		.ADDR_REG  		(DW_ADDR_REG		),
		.WE_REG			(DW_WE_REG			)
    );

// Memory for window coefficients.
bram_dp
	#(
		.N(N),
		.B(B)
	)
	bram_i
	(
		.clka	(aclk		),
		.ena	(mem_ena	),
		.wea	(mem_wea	),
		.addra	(mem_addra	),
		.dia	(mem_dia	),
		.doa	(			),

		.clkb	(aclk		),
		.enb	(1'b1		),
		.web	(1'b0		),
		.addrb	(mem_addrb	),
		.dib	({B{1'b0}}	),
		.dob    (mem_dob	)
	);

// Window control.
wctrl 
	#(
		.N(N),
		.B(B)
	)
	wctrl_i
	(
		// Reset and clock.
		.clk			(aclk				),
		.rstn			(aresetn			),

		// Memory if.
		.mem_addr		(mem_addrb			),
		.mem_dout		(mem_dob			),

		// s_axis for input data.
		.s_axis_tdata	(s_axis_data_tdata	),
		.s_axis_tvalid	(s_axis_data_tvalid	),

		// m_axis for output data.
		.m_axis_tdata	(axis_tdata 		),
		.m_axis_tlast	(axis_tlast 		),
		.m_axis_tvalid	(axis_tvalid		)
	);

// XFFT, 65536-point with scaling controller.
xfft_65536
	fft_i
	(
		// s_axis_* and m_axis_* reset and clock.
		.aclk			(aclk				),
		.aresetn		(aresetn			),

		// s_axis for input.
		.s_axis_tdata	(axis_tdata 		),
		.s_axis_tlast	(axis_tlast 		),
		.s_axis_tvalid	(axis_tvalid		),

		// m_axis for output.
		.m_axis_tdata	(m_axis_data_tdata 	),
		.m_axis_tuser	(m_axis_data_tuser 	),
		.m_axis_tlast	(m_axis_data_tlast 	),
		.m_axis_tvalid	(m_axis_data_tvalid	)
	);

endmodule

