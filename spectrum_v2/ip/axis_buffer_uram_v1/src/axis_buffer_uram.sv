// AXIS Buffer that uses URAM memory. The block captures both
// s_axis_tdata and s_axis_tuser. It allows to sync capture with
// s_axis_tlast. m_axis_tlast is generated in the last transaction
// to allow using a DMA block for fast transfer.
//
// Output m_axis is BOUT bits, lower BDATA bits are s_axis_tdata and 
// upper bits are s_axis_tuser.
module axis_buffer_uram
    #(
		parameter N 	= 12	,
		parameter BDATA = 32	,
		parameter BUSER	= 16	,
		parameter BOUT	= 64
    )
	(
		// AXI-Lite Slave I/F.
		s_axi_aclk	 	,
		s_axi_aresetn	,

		s_axi_awaddr	,
		s_axi_awprot	,
		s_axi_awvalid	,
		s_axi_awready	,
		s_axi_wdata	 	,
		s_axi_wstrb	 	,
		s_axi_wvalid	,
		s_axi_wready	,

		s_axi_bresp	 	,
		s_axi_bvalid	,
		s_axi_bready	,

		s_axi_araddr	,
		s_axi_arprot	,
		s_axi_arvalid	,
		s_axi_arready	,

		s_axi_rdata	 	,
		s_axi_rresp	 	,
		s_axi_rvalid	,
		s_axi_rready	,

        // AXI Stream Slave I/F.
        s_axis_aclk	   	,
		s_axis_aresetn 	,
		s_axis_tdata	,
		s_axis_tuser	,
		s_axis_tlast	,
		s_axis_tvalid	,
		s_axis_tready	,
        
        // AXI Stream Master I/F.
        m_axis_aclk	   	,
		m_axis_aresetn 	,
		m_axis_tdata	,
		m_axis_tlast	,
        m_axis_tvalid  	,
		m_axis_tready
	);

/*********/
/* Ports */
/*********/
input 				s_axi_aclk	 	;
input 				s_axi_aresetn	;

input [7:0]			s_axi_awaddr	;
input [2:0]			s_axi_awprot	;
input 				s_axi_awvalid	;
output 				s_axi_awready	;
input [31:0]		s_axi_wdata	 	;
input [3:0]			s_axi_wstrb	 	;
input 				s_axi_wvalid	;
output				s_axi_wready	;

output [1:0]		s_axi_bresp	 	;
output 				s_axi_bvalid	;
input				s_axi_bready	;

input [7:0]			s_axi_araddr	;
input [2:0]			s_axi_arprot	;
input 				s_axi_arvalid	;
output				s_axi_arready	;

output [31:0]		s_axi_rdata	 	;
output [1:0]		s_axi_rresp	 	;
output 				s_axi_rvalid	;
input				s_axi_rready	;

// AXI Stream Slave I/F.
input				s_axis_aclk	   	;
input				s_axis_aresetn 	;
input [BDATA-1:0]	s_axis_tdata	;
input [BUSER-1:0]	s_axis_tuser	;
input 				s_axis_tlast	;
input 				s_axis_tvalid	;
output				s_axis_tready	;

// AXI Stream Master I/F.
input				m_axis_aclk	   	;
input				m_axis_aresetn 	;
output [BOUT-1:0]	m_axis_tdata	;
output 				m_axis_tlast	;
output 				m_axis_tvalid  	;
input				m_axis_tready	;

/*************/
/* Internals */
/*************/

// Registers.
wire RW_REG;
wire START_REG;
wire SYNC_REG;

/****************/
/* Architecture */
/****************/

// AXI-Lite Slave.
axi_slv axi_slv_i
	(
		.aclk		(s_axi_aclk	 	),
		.aresetn	(s_axi_aresetn	),

		// Write Address Channel.
		.awaddr		(s_axi_awaddr	),
		.awprot		(s_axi_awprot	),
		.awvalid	(s_axi_awvalid	),
		.awready	(s_axi_awready	),

		// Write Data Channel.
		.wdata		(s_axi_wdata	),
		.wstrb		(s_axi_wstrb	),
		.wvalid		(s_axi_wvalid	),
		.wready		(s_axi_wready	),

		// Write Response Channel.
		.bresp		(s_axi_bresp	),
		.bvalid		(s_axi_bvalid	),
		.bready		(s_axi_bready	),

		// Read Address Channel.
		.araddr		(s_axi_araddr	),
		.arprot		(s_axi_arprot	),
		.arvalid	(s_axi_arvalid	),
		.arready	(s_axi_arready	),

		// Read Data Channel.
		.rdata		(s_axi_rdata	),
		.rresp		(s_axi_rresp	),
		.rvalid		(s_axi_rvalid	),
		.rready		(s_axi_rready	),

		// Output registers.
		.RW_REG		(RW_REG			),
		.START_REG	(START_REG		),
		.SYNC_REG	(SYNC_REG		)
	);

// buffer_rw.
buffer_rw
    #(
		.N		(N		),
		.BDATA	(BDATA	),
		.BUSER	(BUSER	),
		.BOUT	(BOUT	)
    )
    buffer_rw_i
    (
        // AXI Stream Slave I/F.
		.s_axis_aclk	(s_axis_aclk	),
		.s_axis_aresetn	(s_axis_aresetn	),
		.s_axis_tdata	(s_axis_tdata	),
		.s_axis_tuser	(s_axis_tuser	),
		.s_axis_tlast	(s_axis_tlast	),
		.s_axis_tvalid	(s_axis_tvalid	),
		.s_axis_tready	(s_axis_tready	),
        
        // AXI Stream Master I/F.
		.m_axis_aclk	(m_axis_aclk	),
		.m_axis_aresetn	(m_axis_aresetn	),
		.m_axis_tdata	(m_axis_tdata	),
		.m_axis_tlast	(m_axis_tlast	),
        .m_axis_tvalid  (m_axis_tvalid  ),
		.m_axis_tready	(m_axis_tready	),

		// Registers.
		.RW_REG			(RW_REG	  		),
		.START_REG		(START_REG		),
		.SYNC_REG		(SYNC_REG		)
    );

endmodule

