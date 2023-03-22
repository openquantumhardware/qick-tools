// VIP: axi_mst_0
// VIP: axis_mst_0
// VIP: axis_slv_0
// DUT: axis_table_hopp_mr
// 	IF: m_axis -> axis_slv_0
// 	IF: s_axi -> axi_mst_0
// 	IF: s_axis -> axis_mst_0

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import axi_mst_0_pkg::*;
import axis_slv_0_pkg::*;

module tb();

// s_axi interfase.
reg			s_axi_aclk;
reg			s_axi_aresetn;
wire [5:0]	s_axi_araddr;
wire [2:0]	s_axi_arprot;
wire		s_axi_arready;
wire		s_axi_arvalid;
wire [5:0]	s_axi_awaddr;
wire [2:0]	s_axi_awprot;
wire		s_axi_awready;
wire		s_axi_awvalid;
wire		s_axi_bready;
wire [1:0]	s_axi_bresp;
wire		s_axi_bvalid;
wire [31:0]	s_axi_rdata;
wire		s_axi_rready;
wire [1:0]	s_axi_rresp;
wire		s_axi_rvalid;
wire [31:0]	s_axi_wdata;
wire		s_axi_wready;
wire [3:0]	s_axi_wstrb;
wire		s_axi_wvalid;

// m_axis interfase.
reg			m_axis_aclk;
reg			m_axis_aresetn;
wire 		m_axis_tready;
wire		m_axis_tvalid;
wire [87:0] m_axis_tdata;

// AXI VIP master address.
xil_axi_ulong   addr_freq		= 0;
xil_axi_ulong   addr_phase		= 1;
xil_axi_ulong   addr_addr		= 2;
xil_axi_ulong   addr_gain		= 3;
xil_axi_ulong   addr_nsamp		= 4;
xil_axi_ulong   addr_outsel		= 5;
xil_axi_ulong   addr_mode		= 6;
xil_axi_ulong   addr_we			= 7;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data_wr     = 32'h12345678;
reg[31:0]       data;
xil_axi_resp_t  resp;

// Ready generator for axis slave.
axi4stream_ready_gen ready_gen;

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

axis_slv_0 axis_slv_0_i
	(
		.aclk			(m_axis_aclk	),
		.aresetn		(m_axis_aresetn	),
		.s_axis_tdata	(m_axis_tdata	),
		.s_axis_tready	(m_axis_tready	),
		.s_axis_tvalid	(m_axis_tvalid	)
	);

axis_sg_int4_v1_ctrl
	DUT 
	( 
		// AXI Slave I/F for configuration.
		.s_axi_aclk		(s_axi_aclk		),
		.s_axi_aresetn	(s_axi_aresetn	),

		.s_axi_araddr	(s_axi_araddr	),
		.s_axi_arprot	(s_axi_arprot	),
		.s_axi_arready	(s_axi_arready	),
		.s_axi_arvalid	(s_axi_arvalid	),

		.s_axi_awaddr	(s_axi_awaddr	),
		.s_axi_awprot	(s_axi_awprot	),
		.s_axi_awready	(s_axi_awready	),
		.s_axi_awvalid	(s_axi_awvalid	),

		.s_axi_bready	(s_axi_bready	),
		.s_axi_bresp	(s_axi_bresp	),
		.s_axi_bvalid	(s_axi_bvalid	),

		.s_axi_rdata	(s_axi_rdata	),
		.s_axi_rready	(s_axi_rready	),
		.s_axi_rresp	(s_axi_rresp	),
		.s_axi_rvalid	(s_axi_rvalid	),

		.s_axi_wdata	(s_axi_wdata	),
		.s_axi_wready	(s_axi_wready	),
		.s_axi_wstrb	(s_axi_wstrb	),
		.s_axi_wvalid	(s_axi_wvalid	),

		// AXIS Master for output data.
		.m_axis_aresetn	(m_axis_aresetn	),
		.m_axis_aclk	(m_axis_aclk	),
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tready	(m_axis_tready	),
		.m_axis_tdata	(m_axis_tdata	)
	);

// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;
axis_slv_0_slv_t 	axis_slv_0_agent;

initial begin
	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);
	axis_slv_0_agent 	= new("axis_slv_0 VIP Agent",tb.axis_slv_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag	("axi_mst_0 VIP");
	axis_slv_0_agent.set_agent_tag	("axis_slv_0 VIP");

	// Drive everything to 0 to avoid assertion from axi_protocol_checker.
	axis_slv_0_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);

	// Ready generator.
	ready_gen = axis_slv_0_agent.driver.create_ready("ready gen 0");
	ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_EVENTS);
	ready_gen.set_low_time(3);
	ready_gen.set_event_count(5);

	// Start agents.
	axi_mst_0_agent.start_master();
	axis_slv_0_agent.start_slave();

	// Reset sequence.
	s_axi_aresetn 	<= 0;
	m_axis_aresetn 	<= 0;
	#500;
	s_axi_aresetn 	<= 1;
	m_axis_aresetn 	<= 1;

	#1000;
	
    // Change ready policy for AXIS Slave.
	axis_slv_0_agent.driver.send_tready(ready_gen);	

	$display("##############");
	$display("### Test 0 ###");
	$display("##############");

	/*
	Waveform 0
		-> FREQ_REG		= 100;
		-> PHASE_REG	= 23;
		-> ADDR_REG  	= 126;
		-> GAIN_REG		= 10000;
		-> NSAMP_REG	= 345;
		-> OUTSEL_REG	= 1;
		-> MODE_REG		= 0; 
	*/

	// freq.
	data_wr = 100;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_freq, prot, data_wr, resp);
	#10;

	// phase.
	data_wr = 23;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_phase, prot, data_wr, resp);
	#10;
	
	// addr.
	data_wr = 126;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_addr, prot, data_wr, resp);
	#10;	

	// gain.
	data_wr = 10000;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_gain, prot, data_wr, resp);
	#10;	

	// nsamp.
	data_wr = 345;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_nsamp, prot, data_wr, resp);
	#10;	

	// outsel.
	data_wr = 1;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_outsel, prot, data_wr, resp);
	#10;	

	// mode.
	data_wr = 0;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_mode, prot, data_wr, resp);
	#10;	

	for (int i=0; i<5; i = i + 1) begin
		// we.
		data_wr = 1;
		axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_we, prot, data_wr, resp);
		#10;	

		#100;

		// we.
		data_wr = 0;
		axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*addr_we, prot, data_wr, resp);
		#10;	

		#200;
	end


	#1000;

end

always begin
	s_axi_aclk <= 0;
	#10;
	s_axi_aclk <= 1;
	#10;
end

always begin
	m_axis_aclk <= 0;
	#3;
	m_axis_aclk <= 1;
	#3;
end

endmodule

