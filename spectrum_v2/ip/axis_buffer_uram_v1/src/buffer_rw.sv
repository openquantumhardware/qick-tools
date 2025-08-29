module buffer_rw
	#(
		parameter N		= 12	,
		parameter BDATA = 32	,
		parameter BUSER	= 16	,
		parameter BOUT	= 64
	)
	(
        // AXI Stream Slave I/F.
		s_axis_aclk		,
		s_axis_aresetn	,
		s_axis_tdata	,
		s_axis_tuser	,
		s_axis_tlast	,
		s_axis_tvalid	,
		s_axis_tready	,
        
        // AXI Stream Master I/F.
		m_axis_aclk		,
		m_axis_aresetn	,
		m_axis_tdata	,
		m_axis_tlast	,
        m_axis_tvalid   ,
		m_axis_tready	,

		// Registers.
		RW_REG			,
		START_REG		,
		SYNC_REG
    );

/*********/
/* Ports */
/*********/
input				s_axis_aclk;
input				s_axis_aresetn;
input [BDATA-1:0]	s_axis_tdata;
input [BUSER-1:0]	s_axis_tuser;
input				s_axis_tlast;
input 				s_axis_tvalid;
output 				s_axis_tready;
        
input				m_axis_aclk;
input				m_axis_aresetn;
output [BOUT-1:0]	m_axis_tdata;
output 				m_axis_tlast;
output 				m_axis_tvalid;
input				m_axis_tready;

input				RW_REG;
input				START_REG;
input				SYNC_REG;

/*************/
/* Internals */
/*************/
localparam		NBPIPE	= 5				; // Ultra ram pipeline stages.
localparam		BT 		= BDATA + BUSER	; // Number of bits.

wire			rst;

wire			mem_we;
wire [BT-1:0]	mem_din;
wire [N-1:0]	mem_addra;
wire [N-1:0]	mem_addrb;
wire [BT-1:0]	mem_dout;

wire			start_dw;
wire			start_dr;

// Re-sync.
wire			RW_REG_resync;
wire			START_REG_resync;
wire			SYNC_REG_resync;

/****************/
/* Architecture */
/****************/
assign	rst = ~s_axis_aresetn;

// Mux for start.
// RW_REG
// * 0 : Read.
// * 1 : Write.
assign	start_dw	= (RW_REG_resync == 1'b1)? START_REG_resync : 1'b0;
assign	start_dr	= (RW_REG_resync == 1'b0)? START_REG_resync : 1'b0;

// RW_REG_resync.
synchronizer_n
	RW_REG_resync_i
	(
		.rstn	    (s_axis_aresetn	),
		.clk 		(s_axis_aclk	),
		.data_in	(RW_REG			),
		.data_out	(RW_REG_resync	)
	);

// START_REG_resync.
synchronizer_n
	START_REG_resync_i
	(
		.rstn	    (s_axis_aresetn		),
		.clk 		(s_axis_aclk		),
		.data_in	(START_REG			),
		.data_out	(START_REG_resync	)
	);

// SYNC_REG_resync.
synchronizer_n
	SYNC_REG_resync_i
	(
		.rstn	    (s_axis_aresetn		),
		.clk 		(s_axis_aclk		),
		.data_in	(SYNC_REG			),
		.data_out	(SYNC_REG_resync	)
	);

// URAM.
uram_dp
	#(
		.AWIDTH	(N		),
		.DWIDTH	(BT		),
		.NBPIPE	(NBPIPE	)
 	)
	mem_i
	( 
		.clk	(s_axis_aclk	),
		.rst	(rst			),

		// Port A.
		.wea	(mem_we			),
		.cea	(1'b1			),
		.ena	(1'b1			),
    	.dina	(mem_din		),
    	.addra	(mem_addra		),
    	.douta	(				),

		// Port A.
		.web	(1'b0			),
		.ceb	(1'b1			),
		.enb	(1'b1			),
    	.dinb	({BT{1'b0}}		),
    	.addrb	(mem_addrb		),
    	.doutb	(mem_dout		)
   );

// Data writer.
data_writer
    #(
		// Address map of memory.
		.N		(N		),

		// Data width.
		.BDATA	(BDATA	),

		// Tuser width.
		.BUSER	(BUSER	)
    )
    data_writer_i
    (
        .rstn		(s_axis_aresetn	),
        .clk		(s_axis_aclk	),
        
        // AXI Stream I/F.
		.tdata		(s_axis_tdata	),
		.tuser		(s_axis_tuser	),
		.tlast		(s_axis_tlast	),
		.tvalid		(s_axis_tvalid	),
        .tready		(s_axis_tready	),
		
		// Memory I/F.
		.mem_we		(mem_we			),
		.mem_addr	(mem_addra		),
		.mem_di		(mem_din		),
		
		// Start.
		.start		(start_dw		),
		.sync		(SYNC_REG_resync)
    );

// Data reader.
data_reader
    #(
		// Memory address width.
		.N		(N			),

		// Data width.
		.B		(BT			),

		// Output width.
		.BOUT	(BOUT		),
		
		// Latency.
		.L		(NBPIPE+2	)
    )
    data_reader_i
    (
		// Reset and clock.
		.rstn			(s_axis_aresetn	),
		.clk 			(s_axis_aclk	),
		
		// Memory I/F.
		.mem_addr		(mem_addrb		),
		.mem_dout		(mem_dout		),
		
		// m_axis I/F.
		.m_axis_aclk	(m_axis_aclk  	),
		.m_axis_aresetn	(m_axis_aresetn	),
		.m_axis_tdata	(m_axis_tdata 	),
		.m_axis_tlast	(m_axis_tlast 	),
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tready	(m_axis_tready	),
		
		// Start.
		.start			(start_dr		)
    );

endmodule

