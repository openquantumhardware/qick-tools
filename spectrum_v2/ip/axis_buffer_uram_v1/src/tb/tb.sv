import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb;

parameter N 	= 12	;
parameter BDATA = 64	;
parameter BUSER	= 16	;
parameter BOUT	= 128	;

reg				s_axi_aclk;
reg				s_axi_aresetn;
wire [7:0]		s_axi_araddr;
wire [2:0]		s_axi_arprot;
wire			s_axi_arready;
wire			s_axi_arvalid;
wire [7:0]		s_axi_awaddr;
wire [2:0]		s_axi_awprot;
wire			s_axi_awready;
wire			s_axi_awvalid;
wire			s_axi_bready;
wire [1:0]		s_axi_bresp;
wire			s_axi_bvalid;
wire [31:0]		s_axi_rdata;
wire			s_axi_rready;
wire [1:0]		s_axi_rresp;
wire			s_axi_rvalid;
wire [31:0]		s_axi_wdata;
wire			s_axi_wready;
wire [3:0]		s_axi_wstrb;
wire			s_axi_wvalid;


reg				s_axis_aclk;
reg				s_axis_aresetn;
reg [BDATA-1:0]	 s_axis_tdata;
reg [BUSER-1:0]	s_axis_tuser;
reg				s_axis_tlast;
reg				s_axis_tvalid;
wire			s_axis_tready;

reg				m_axis_aclk;
reg				m_axis_aresetn;
wire [BOUT-1:0]	m_axis_tdata;
wire			m_axis_tlast;
wire			m_axis_tvalid;
reg				m_axis_tready;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data_wr     = 32'h12345678;
reg[31:0]       data;
xil_axi_resp_t  resp;

axi_mst_0 axi_mst_0_i
	(
		.aclk			(s_axi_aclk		),
		.aresetn		(s_axi_aresetn	),
		.m_axi_araddr	(s_axi_araddr	),
		.m_axi_arprot	(s_axi_arprot	),
		.m_axi_arready	(s_axi_arready	),
		.m_axi_arvalid	(s_axi_arvalid	),
		.m_axi_awaddr	(s_axi_awaddr	),
		.m_axi_awprot	(s_axi_awprot	),
		.m_axi_awready	(s_axi_awready	),
		.m_axi_awvalid	(s_axi_awvalid	),
		.m_axi_bready	(s_axi_bready	),
		.m_axi_bresp	(s_axi_bresp	),
		.m_axi_bvalid	(s_axi_bvalid	),
		.m_axi_rdata	(s_axi_rdata	),
		.m_axi_rready	(s_axi_rready	),
		.m_axi_rresp	(s_axi_rresp	),
		.m_axi_rvalid	(s_axi_rvalid	),
		.m_axi_wdata	(s_axi_wdata	),
		.m_axi_wready	(s_axi_wready	),
		.m_axi_wstrb	(s_axi_wstrb	),
		.m_axi_wvalid	(s_axi_wvalid	)
	);

axis_buffer_uram
    #(
		.N		(N		),
		.BDATA	(BDATA	),
		.BUSER	(BUSER	),
		.BOUT	(BOUT	)
    )
	DUT
	(
		// AXI-Lite Slave I/F.
		.s_axi_aclk	 	(s_axi_aclk	 	),
		.s_axi_aresetn	(s_axi_aresetn	),

		.s_axi_awaddr	(s_axi_awaddr	),
		.s_axi_awprot	(s_axi_awprot	),
		.s_axi_awvalid	(s_axi_awvalid	),
		.s_axi_awready	(s_axi_awready	),
		.s_axi_wdata 	(s_axi_wdata 	),
		.s_axi_wstrb 	(s_axi_wstrb 	),
		.s_axi_wvalid	(s_axi_wvalid	),
		.s_axi_wready	(s_axi_wready	),

		.s_axi_bresp 	(s_axi_bresp 	),
		.s_axi_bvalid	(s_axi_bvalid	),
		.s_axi_bready	(s_axi_bready	),

		.s_axi_araddr	(s_axi_araddr 	),
		.s_axi_arprot	(s_axi_arprot 	),
		.s_axi_arvalid	(s_axi_arvalid	),
		.s_axi_arready	(s_axi_arready	),

		.s_axi_rdata 	(s_axi_rdata 	),
		.s_axi_rresp 	(s_axi_rresp 	),
		.s_axi_rvalid	(s_axi_rvalid	),
		.s_axi_rready	(s_axi_rready	),

        // AXI Stream Slave I/F.
        .s_axis_aclk  	(s_axis_aclk  	),
		.s_axis_aresetn	(s_axis_aresetn	),
		.s_axis_tdata	(s_axis_tdata	),
		.s_axis_tuser	(s_axis_tuser	),
		.s_axis_tlast	(s_axis_tlast	),
		.s_axis_tvalid	(s_axis_tvalid	),
		.s_axis_tready	(s_axis_tready	),
        
        // AXI Stream Master I/F.
        .m_axis_aclk	(m_axis_aclk	),
		.m_axis_aresetn (m_axis_aresetn ),
		.m_axis_tdata	(m_axis_tdata	),
		.m_axis_tlast	(m_axis_tlast	),
        .m_axis_tvalid  (m_axis_tvalid  ),
		.m_axis_tready	(m_axis_tready	)
	);

// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;

initial begin
    integer i;
    
	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag	("axi_mst_0 VIP");

	// Start agents.
	axi_mst_0_agent.start_master();

	// Reset sequence.
	s_axi_aresetn	<= 0;
	s_axis_aresetn	<= 0;
	m_axis_aresetn	<= 0;
	s_axis_tdata	<= 0;
	s_axis_tuser	<= 0;
	s_axis_tlast	<= 0;
	s_axis_tvalid	<= 0;
	m_axis_tready	<= 1;
	#300;
	s_axi_aresetn	<= 1;
	s_axis_aresetn	<= 1;
	m_axis_aresetn	<= 1;

	#1000;

	// RW_REG : write operation.
	data_wr = 1;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(0*4, prot, data_wr, resp);
	#10;

	// SYNC_REG : synced start (with tlast).
	data_wr = 1;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(2*4, prot, data_wr, resp);
	#10;

	// START_REG.
	data_wr = 1;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(1*4, prot, data_wr, resp);
	#10;

	#100;

	for (i=0; i<123; i=i+1) begin
		@(posedge s_axis_aclk);
		s_axis_tdata	<= i;
		s_axis_tuser	<= 3*i;
		s_axis_tlast	<= 0;
		s_axis_tvalid	<= 1;
	end

	// Sync with tlast.
	@(posedge s_axis_aclk);
	s_axis_tlast	<= 1;
	s_axis_tvalid	<= 1;

	@(posedge s_axis_aclk);
	s_axis_tlast	<= 0;
	s_axis_tvalid	<= 0;

	#200;

	// Inject data.
	for (i=0; i<2**N; i=i+1) begin
		@(posedge s_axis_aclk);
		s_axis_tdata	<= i;
		s_axis_tvalid	<= 1;
	end

	@(posedge s_axis_aclk);
	s_axis_tvalid	<= 0;

	// START_REG.
	data_wr = 0;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(1*4, prot, data_wr, resp);
	#10;

	#1000;

	// RW_REG : read operation.
	data_wr = 0;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(0*4, prot, data_wr, resp);
	#10;

	// START_REG.
	data_wr = 1;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(1*4, prot, data_wr, resp);
	#10;
	
	#1000;
	@(posedge m_axis_aclk);
	m_axis_tready	<= 0;

	#1000;
	@(posedge m_axis_aclk);
	m_axis_tready	<= 1;

	wait (m_axis_tlast);

	// START_REG.
	data_wr = 0;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(1*4, prot, data_wr, resp);
	#10;

end

always begin
	s_axi_aclk	<= 0;
	#3;
	s_axi_aclk	<= 1;
	#3;
end

always begin
	s_axis_aclk	<= 0;
	#5;
	s_axis_aclk	<= 1;
	#5;
end

always begin
	m_axis_aclk	<= 0;
	#8;
	m_axis_aclk	<= 1;
	#8;
end

endmodule

