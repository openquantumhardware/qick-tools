// VIP: axi_mst_0
// DUT: axis_chsel_pfb
// 	IF: s_axi -> axi_mst_0

import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

// DUT generics.
parameter B = 8;
parameter N = 8;

// s_axi interfase.
reg					s_axi_aclk;
wire [5:0]			s_axi_araddr;
reg					s_axi_aresetn;
wire [2:0]			s_axi_arprot;
wire				s_axi_arready;
wire				s_axi_arvalid;
wire [5:0]			s_axi_awaddr;
wire [2:0]			s_axi_awprot;
wire				s_axi_awready;
wire				s_axi_awvalid;
wire				s_axi_bready;
wire [1:0]			s_axi_bresp;
wire				s_axi_bvalid;
wire [31:0]			s_axi_rdata;
wire				s_axi_rready;
wire [1:0]			s_axi_rresp;
wire				s_axi_rvalid;
wire [31:0]			s_axi_wdata;
wire				s_axi_wready;
wire [3:0]			s_axi_wstrb;
wire				s_axi_wvalid;

// Clock and reset for s_axis_* and m_axis_*.
reg					aclk;
reg					aresetn;

// s_axis interfase.
reg	[2*B*N-1:0]		s_axis_tdata;
reg					s_axis_tvalid;
wire				s_axis_tready;

// m_axis interfase.
wire [2*B-1:0]		m_axis_tdata;
wire				m_axis_tvalid;

// AXI VIP master address.
xil_axi_ulong   addr_chid	= 32'h40000000; // 0

xil_axi_prot_t  prot        = 0;
reg[31:0]       data_wr     = 32'h12345678;
reg[31:0]       data_rd;
reg[31:0]       data;
xil_axi_resp_t  resp;

// TB control.
reg	tb_start;

axi_mst_0 axi_mst_0_i
	(
		.aclk			(s_axi_aclk),
		.aresetn		(s_axi_aresetn),
		.m_axi_araddr	(s_axi_araddr),
		.m_axi_arprot	(s_axi_arprot),
		.m_axi_arready	(s_axi_arready),
		.m_axi_arvalid	(s_axi_arvalid),
		.m_axi_awaddr	(s_axi_awaddr),
		.m_axi_awprot	(s_axi_awprot),
		.m_axi_awready	(s_axi_awready),
		.m_axi_awvalid	(s_axi_awvalid),
		.m_axi_bready	(s_axi_bready),
		.m_axi_bresp	(s_axi_bresp),
		.m_axi_bvalid	(s_axi_bvalid),
		.m_axi_rdata	(s_axi_rdata),
		.m_axi_rready	(s_axi_rready),
		.m_axi_rresp	(s_axi_rresp),
		.m_axi_rvalid	(s_axi_rvalid),
		.m_axi_wdata	(s_axi_wdata),
		.m_axi_wready	(s_axi_wready),
		.m_axi_wstrb	(s_axi_wstrb),
		.m_axi_wvalid	(s_axi_wvalid)
	);

axis_chsel_pfb_x1
	#(
		.B(B),
		.N(N)
	)
	axis_chsel_pfb_i
	(
		// s_axi interfase.
		.s_axi_aclk		(s_axi_aclk),
		.s_axi_araddr	(s_axi_araddr),
		.s_axi_aresetn	(s_axi_aresetn),
		.s_axi_arprot	(s_axi_arprot),
		.s_axi_arready	(s_axi_arready),
		.s_axi_arvalid	(s_axi_arvalid),
		.s_axi_awaddr	(s_axi_awaddr),
		.s_axi_awprot	(s_axi_awprot),
		.s_axi_awready	(s_axi_awready),
		.s_axi_awvalid	(s_axi_awvalid),
		.s_axi_bready	(s_axi_bready),
		.s_axi_bresp	(s_axi_bresp),
		.s_axi_bvalid	(s_axi_bvalid),
		.s_axi_rdata	(s_axi_rdata),
		.s_axi_rready	(s_axi_rready),
		.s_axi_rresp	(s_axi_rresp),
		.s_axi_rvalid	(s_axi_rvalid),
		.s_axi_wdata	(s_axi_wdata),
		.s_axi_wready	(s_axi_wready),
		.s_axi_wstrb	(s_axi_wstrb),
		.s_axi_wvalid	(s_axi_wvalid),

		// Clock and reset for s_axis_* and m_axis_*.
		.aclk			(aclk			),
		.aresetn		(aresetn		),

		// s_axis interfase.
		.s_axis_tdata	(s_axis_tdata	),
		.s_axis_tvalid	(s_axis_tvalid	),
		.s_axis_tready	(s_axis_tready	),

		// m_axis interfase.
		.m_axis_tdata	(m_axis_tdata	),
		.m_axis_tvalid	(m_axis_tvalid	)
	);

// VIP Agents
axi_mst_0_mst_t axi_mst_0_agent;

initial begin
	// Create agents.
	axi_mst_0_agent = new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag("axi_mst_0 VIP");

	// Start agents.
	axi_mst_0_agent.start_master();

	/* ************* */
	/* Main TB Start */
	/* ************* */

	// Reset sequence.
	s_axi_aresetn 	<= 0;
	aresetn 		<= 0;
	tb_start		<= 0;
	#500;
	s_axi_aresetn 	<= 1;
	aresetn 		<= 1;

	#1000;

	// Start data.
	tb_start <= 1;

	$display("###############");
	$display("### Test 0  ###");
	$display("###############");

	/*
	CHID  = 0
	*/	
		
	// chid
	data_wr = 0;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_chid, prot, data_wr, resp);
	#10;
	
	#1000;

	$display("###############");
	$display("### Test 1  ###");
	$display("###############");

	/*
	CHID  = 7
	*/	
		
	// chid
	data_wr = 7;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_chid, prot, data_wr, resp);
	#10;
	
	#1000;

	$display("###############");
	$display("### Test 2  ###");
	$display("###############");

	/*
	CHID  = 3
	*/	
		
	// chid
	data_wr = 3;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_chid, prot, data_wr, resp);
	#10;

	#1000;

	$display("###############");
	$display("### Test 3  ###");
	$display("###############");

	/*
	CHID  = 30
	*/	
		
	// chid
	data_wr = 30;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_chid, prot, data_wr, resp);
	#10;

	#1000;

end

initial begin
	s_axis_tdata 	<= 0;
	s_axis_tvalid	<= 0;

	wait (tb_start);

	for (int i=0; i<1000; i = i+8) begin
		@(posedge aclk);
		s_axis_tvalid	<= 1;
		s_axis_tdata[0*B +: B]	<= i;
		s_axis_tdata[1*B +: B]	<= i+1;
		s_axis_tdata[2*B +: B]	<= i+2;
		s_axis_tdata[3*B +: B]	<= i+3;
		s_axis_tdata[4*B +: B]	<= i+4;
		s_axis_tdata[5*B +: B]	<= i+5;
		s_axis_tdata[6*B +: B]	<= i+6;
		s_axis_tdata[7*B +: B]	<= i+7;

		@(posedge aclk);
		s_axis_tvalid	<= 0;
	end
end

always begin
	s_axi_aclk <= 0;
	#10;
	s_axi_aclk <= 1;
	#10;
end

always begin
	aclk <= 0;
	#3;
	aclk <= 1;
	#3;
end

endmodule

