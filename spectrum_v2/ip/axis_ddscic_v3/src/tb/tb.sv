import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

reg				s_axi_aclk		;
reg				s_axi_aresetn	;
wire 	[5:0]	s_axi_araddr	;
wire 	[2:0]	s_axi_arprot	;
wire			s_axi_arready	;
wire			s_axi_arvalid	;
wire 	[5:0]	s_axi_awaddr	;
wire 	[2:0]	s_axi_awprot	;
wire			s_axi_awready	;
wire			s_axi_awvalid	;
wire			s_axi_bready	;
wire 	[1:0]	s_axi_bresp		;
wire			s_axi_bvalid	;
wire 	[31:0]	s_axi_rdata		;
wire			s_axi_rready	;
wire 	[1:0]	s_axi_rresp		;
wire			s_axi_rvalid	;
wire 	[31:0]	s_axi_wdata		;
wire			s_axi_wready	;
wire 	[3:0]	s_axi_wstrb		;
wire			s_axi_wvalid	;

reg				aclk			;
reg				aresetn			;

wire	 [31:0]	s_axis_tdata	;
reg				s_axis_tvalid	;
wire			s_axis_tready	;

wire [31:0]		m_axis_tdata	;
reg				m_axis_tready	;
wire			m_axis_tvalid	;

// Debug.
reg	 signed [15:0]		din_real;
reg	 signed [15:0]		din_imag;
wire signed [15:0]		dout_real;
wire signed [15:0]		dout_imag;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data;
xil_axi_resp_t  resp;

// TB Control.
reg tb_write_out = 0;
reg tb_read_in	 = 0;

// AXI Master.
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


// DDS + CIC block.
axis_ddscic_v1 DUT
	(
		/*********************/
		/* s_axi_aclk domain */
		/*********************/
		.s_axi_aclk		,
		.s_axi_aresetn	,

		.s_axi_awaddr	,
		.s_axi_awprot	,
		.s_axi_awvalid	,
		.s_axi_awready	,

		.s_axi_wdata	,
		.s_axi_wstrb	,
		.s_axi_wvalid	,
		.s_axi_wready	,

		.s_axi_bresp	,
		.s_axi_bvalid	,
		.s_axi_bready	,

		.s_axi_araddr	,
		.s_axi_arprot	,
		.s_axi_arvalid	,
		.s_axi_arready	,

		.s_axi_rdata	,
		.s_axi_rresp	,
		.s_axi_rvalid	,
		.s_axi_rready	,

		/***************/
		/* aclk domain */
		/***************/
		.aclk			,
		.aresetn		,

		// S_AXIS for input data.
		.s_axis_tdata	,
		.s_axis_tvalid	,
		.s_axis_tready	,

		// M_AXIS for output data.
		.m_axis_tdata	,
		.m_axis_tready	,
		.m_axis_tvalid
	);

// Input/output data.
assign s_axis_tdata	= {din_imag, din_real};
assign dout_real	= m_axis_tdata [0 	+: 16];
assign dout_imag	= m_axis_tdata [16 	+: 16];

// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;

// Main TB.
initial begin
	int decim;
	real qsel;

	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag("axi_mst_0 VIP");

	// Start agents.
	axi_mst_0_agent.start_master();

	// Reset sequence.
	s_axi_aresetn 		<= 0;
	aresetn 			<= 0;
	#500;
	s_axi_aresetn 		<= 1;
	aresetn 			<= 1;

	#1000;
	
	$display("###########################");
	$display("### Configure DDS + CIC ###");
	$display("###########################");
	$display("t = %0t", $time);


	// PINC_REG.
	data = freq_calc(100, 12.98);
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, data, resp);
	#10;

	// PINC_WE_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*1, prot, 1, resp);
	#10;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*1, prot, 0, resp);
	#10;

	// PRODSEL_REG.
	// 0 : product
	// 1 : dds
	// 2 : input
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*2, prot, 0, resp);
	#10;

	// CICSEL_REG.
	// 0 : CIC
	// 1 : by-pass
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*3, prot, 0, resp);
	#10;

	// QPROD_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*4, prot, 15, resp);
	#10;

	// DEC_REG.
	decim = 1000;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*6, prot, decim, resp);
	#10;

	// QCIC_REG.
	qsel = $ceil(3*$clog2(decim));
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*5, prot, int'(qsel), resp);
	#10;


	#500;

	@(posedge aclk);
	tb_write_out <= 1;
	tb_read_in	 <= 1;

end

// Input data generation.
initial begin
	// Frequency.
    real freq_v[5];
	real fs;
	real pi;
	
	// Amplitude.
	real a0_v[5];
	
	fs = 100;
	pi = 3.14159;

	din_real		<= 0;
	din_imag		<= 0;
	s_axis_tvalid 	<= 1;
	m_axis_tready	<= 1;

	// Set input signal parameters.
	freq_v[0] 	= 13;
	a0_v[0]		= 0.69;
	freq_v[1] 	= 0.7;
	a0_v[1]		= 0.25;
	
	for (int n=0; n<1000000; n=n+1) begin
		@(posedge aclk);
		din_real <=	a0_v[0]*(2**15-1)*$cos(2*pi*freq_v[0]/fs*n) + 
					a0_v[1]*(2**15-1)*$cos(2*pi*freq_v[1]/fs*n);
		din_imag <=	a0_v[0]*(2**15-1)*$sin(2*pi*freq_v[0]/fs*n) + 
					a0_v[1]*(2**15-1)*$sin(2*pi*freq_v[1]/fs*n);
	end
end

//// Input data file.
//initial begin
//	int fd;
//	int cnt, src, hdr, val;
//
//    s_axis_tdata    <= 0;
//	s_axis_tvalid 	<= 1;
//	m_axis_tready	<= 1;
//
//	// Output file.
//	fd = $fopen("../../../../../tb/comb.csv","r");
//
//	wait (tb_read_in);
//	$display("Reading data");
//
//	while ($fscanf(fd,"%d,%d,%d,%d", cnt, src, hdr, val) == 4) begin
//		@(posedge aclk);
//		s_axis_tdata <= val;
//	end
//
//	$display("Closing file, t = %0t", $time);
//	$fclose(fd);
//end

// Output data file.
initial begin
	int fd;

	// Output file.
	fd = $fopen("../../../../../tb/dout.csv","w");

	wait (tb_write_out);
	$display("Writing data");

	while (tb_write_out) begin
		@(posedge aclk);
		$fdisplay(fd, "%d,%d,%d", m_axis_tvalid, dout_real, dout_imag);
	end

	$display("Closing file, t = %0t", $time);
	$fclose(fd);
end

always begin
	s_axi_aclk <= 0;
	#10;
	s_axi_aclk <= 1;
	#10;
end

always begin
	aclk <= 0;
	#5;
	aclk <= 1;
	#5;
end  

// Function to compute frequency register.
function [31:0] freq_calc;
    input real fclk;
    input real f;
    
	// All input frequencies are in MHz.
	real temp;
	temp = f/fclk*2**30;
	freq_calc = {int'(temp),2'b00};
endfunction

endmodule

