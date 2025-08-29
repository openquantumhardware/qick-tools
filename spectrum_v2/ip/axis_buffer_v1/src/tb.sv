// VIP: axi_mst_0
// DUT: axis_buffer
// 	IF: m_axis -> axis_slv_0
// 	IF: s_axi -> axi_mst_0
// 	IF: s_axis -> axis_mst_0
// VIP: axis_mst_0
// VIP: axis_slv_0

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import axi_mst_0_pkg::*;
import axis_mst_0_pkg::*;
import axis_slv_0_pkg::*;

module tb();

// DUT generics.
parameter AXIS_DATA_WIDTH = 24;
parameter B = 16;
parameter N = 8;

// m_axis interfase.
reg								m_axis_aclk;
reg								m_axis_aresetn;
wire [AXIS_DATA_WIDTH-1:0]		m_axis_tdata;
wire							m_axis_tlast;
wire [AXIS_DATA_WIDTH/8-1:0]	m_axis_tstrb;
wire							m_axis_tvalid;

// s_axi interfase.
reg								s_axi_aclk;
wire [7:0]						s_axi_araddr;
reg								s_axi_aresetn;
wire [2:0]						s_axi_arprot;
wire							s_axi_arready;
wire							s_axi_arvalid;
wire [7:0]						s_axi_awaddr;
wire [2:0]						s_axi_awprot;
wire							s_axi_awready;
wire							s_axi_awvalid;
wire							s_axi_bready;
wire [1:0]						s_axi_bresp;
wire							s_axi_bvalid;
wire [31:0]						s_axi_rdata;
wire							s_axi_rready;
wire [1:0]						s_axi_rresp;
wire							s_axi_rvalid;
wire [31:0]						s_axi_wdata;
wire							s_axi_wready;
wire [3:0]						s_axi_wstrb;
wire							s_axi_wvalid;

// s_axis interfase.
reg								s_axis_aclk;
reg								s_axis_aresetn;
wire [AXIS_DATA_WIDTH-1:0]		s_axis_tdata;
wire							s_axis_tlast;
wire							s_axis_tready;
wire [AXIS_DATA_WIDTH/8-1:0]	s_axis_tstrb;
wire							s_axis_tvalid;

axi4stream_transaction wr_transaction;
axi4stream_ready_gen ready_gen;

xil_axi_ulong addr_DW_CAPTURE_REG   = 32'h44A00000; // 0
xil_axi_ulong addr_DR_START_REG     = 32'h44A00004; // 1

xil_axi_prot_t  prot = 0;
reg[31:0]       data_wr=32'h01234567;
reg[31:0]       data_rd=32'h01234567;
xil_axi_resp_t  resp;

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

axis_buffer
	#(
		.AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
		.B(B),
		.N(N)
	)
	axis_buffer_i
	(
		// m_axis interfase.
		.m_axis_aclk	(m_axis_aclk),
		.m_axis_aresetn	(m_axis_aresetn),
		.m_axis_tdata	(m_axis_tdata),
		.m_axis_tlast	(m_axis_tlast),
		.m_axis_tready	(m_axis_tready),
		.m_axis_tstrb	(m_axis_tstrb),
		.m_axis_tvalid	(m_axis_tvalid),

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

		// s_axis interfase.
		.s_axis_aclk	(s_axis_aclk),
		.s_axis_aresetn	(s_axis_aresetn),
		.s_axis_tdata	(s_axis_tdata),
		.s_axis_tlast	(s_axis_tlast),
		.s_axis_tready	(s_axis_tready),
		.s_axis_tstrb	(s_axis_tstrb),
		.s_axis_tvalid	(s_axis_tvalid)
	);

axis_mst_0 axis_mst_0_i
	(
		.aclk			(s_axis_aclk),
		.aresetn		(s_axis_aresetn),
		.m_axis_tdata	(s_axis_tdata),
		.m_axis_tlast	(s_axis_tlast),
		.m_axis_tready	(s_axis_tready),
		.m_axis_tstrb	(s_axis_tstrb),
		.m_axis_tvalid	(s_axis_tvalid)
	);

axis_slv_0 axis_slv_0_i
	(
		.aclk			(m_axis_aclk),
		.aresetn		(m_axis_aresetn),
		.s_axis_tdata	(m_axis_tdata),
		.s_axis_tlast	(m_axis_tlast),
		.s_axis_tready	(m_axis_tready),
		.s_axis_tstrb	(m_axis_tstrb),
		.s_axis_tvalid	(m_axis_tvalid)
	);

// VIP Agents
axi_mst_0_mst_t axi_mst_0_agent;
axis_mst_0_mst_t axis_mst_0_agent;
axis_slv_0_slv_t axis_slv_0_agent;

initial begin
	// Create agents.
	axi_mst_0_agent = new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);
	axis_mst_0_agent = new("axis_mst_0 VIP Agent",tb.axis_mst_0_i.inst.IF);
	axis_slv_0_agent = new("axis_slv_0 VIP Agent",tb.axis_slv_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag("axi_mst_0 VIP");
	axis_mst_0_agent.set_agent_tag("axis_mst_0 VIP");
	axis_slv_0_agent.set_agent_tag("axis_slv_0 VIP");

	// Drive everything to 0 to avoid assertion from axi_protocol_checker.
	axis_mst_0_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
	axis_slv_0_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);

	// Start agents.
	axi_mst_0_agent.start_master();
	axis_mst_0_agent.start_master();
	axis_slv_0_agent.start_slave();

    /* 
    DW_CAPTURE_REG : 1 bit.
    -> 0 : disable capture.
    -> 1 : enable capture.
 
    DR_START_REG	: 1 bit.
    -> 0 : stop.
    -> 1 : start.
    */

	// Reset sequence.
	m_axis_aresetn <= 0;
	s_axi_aresetn <= 0;
	s_axis_aresetn <= 0;
	#500;
	m_axis_aresetn <= 1;
	s_axi_aresetn <= 1;
	s_axis_aresetn <= 1;

	#1000;

    // Write DW_CAPTURE_REG.
    data_wr = 1;
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_DW_CAPTURE_REG,prot,data_wr,resp);
    #200;

	// Send data.
	fork
	   gen_0(256,0);
	join

    // Write DW_CAPTURE_REG.
    data_wr = 0;
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_DW_CAPTURE_REG,prot,data_wr,resp);
    #200;

    // Write DR_START_REG.
    data_wr = 1;
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_DR_START_REG,prot,data_wr,resp);
    #200;
    
    // Write DR_START_REG.
    data_wr = 0;
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_DR_START_REG,prot,data_wr,resp);
    #200;

	#1000;
end

always begin
	m_axis_aclk <= 0;
	#10;
	m_axis_aclk <= 1;
	#10;
end

always begin
	s_axi_aclk <= 0;
	#10;
	s_axi_aclk <= 1;
	#10;
end

always begin
	s_axis_aclk <= 0;
	#10;
	s_axis_aclk <= 1;
	#10;
end

task gen_0(input bit [31:0] cnt, input bit [31:0] delay);        
    // Create transaction.
    axi4stream_transaction wr_transaction;
    wr_transaction = axis_mst_0_agent.driver.create_transaction("Master 0 VIP write transaction");
    
    // Set transaction parameters.
    wr_transaction.set_xfer_alignment(XIL_AXI4STREAM_XFER_RANDOM);    
    
    // Send transactions.
    for (int i=0; i < cnt; i++)
    begin
        WR_TRANSACTION_FAIL: assert(wr_transaction.randomize());
        wr_transaction.set_delay(delay);
        axis_mst_0_agent.driver.send(wr_transaction);
    end
endtask    

endmodule

