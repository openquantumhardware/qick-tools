import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb;

reg			s_axi_aclk			;
reg			s_axi_aresetn		;
wire [5:0]	s_axi_araddr		;
wire [2:0]	s_axi_arprot		;
wire		s_axi_arready		;
wire		s_axi_arvalid		;
wire [5:0]	s_axi_awaddr		;
wire [2:0]	s_axi_awprot		;
wire		s_axi_awready		;
wire		s_axi_awvalid		;
wire		s_axi_bready		;
wire [1:0]	s_axi_bresp			;
wire		s_axi_bvalid		;
wire [31:0]	s_axi_rdata			;
wire		s_axi_rready		;
wire [1:0]	s_axi_rresp			;
wire		s_axi_rvalid		;
wire [31:0]	s_axi_wdata			;
wire		s_axi_wready		;
wire [3:0]	s_axi_wstrb			;
wire		s_axi_wvalid		;

reg			aclk				;
reg			aresetn				;

reg			s_axis_coef_tvalid	;
reg [15:0]	s_axis_coef_tdata	;
wire		s_axis_coef_tready	;

wire [31:0]	s_axis_data_tdata	;
reg			s_axis_data_tvalid	;

// m_axis for output.
wire [63:0]	m_axis_data_tdata	;
wire [15:0]	m_axis_data_tuser	;
wire		m_axis_data_tlast	;
wire		m_axis_data_tvalid	;

// Debug.
reg signed [15:0]	din_real;
reg signed [15:0]	din_imag;
wire signed [31:0]	dout_real;
wire signed [31:0]	dout_imag;

// TB control.
reg tb_coef_start  = 0;
reg tb_coef_done   = 0;
reg	tb_input_start = 0;
reg	tb_input_done  = 0;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data_wr     = 32'h12345678;
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

axis_wxfft_65536
	DUT
	(
		// AXI Slave I/F for configuration.
		.s_axi_aclk			,
		.s_axi_aresetn		,
		.s_axi_araddr		,
		.s_axi_arprot		,
		.s_axi_arready		,
		.s_axi_arvalid		,
		.s_axi_awaddr		,
		.s_axi_awprot		,
		.s_axi_awready		,
		.s_axi_awvalid		,
		.s_axi_bready		,
		.s_axi_bresp		,
		.s_axi_bvalid		,
		.s_axi_rdata		,
		.s_axi_rready		,
		.s_axi_rresp		,
		.s_axi_rvalid		,
		.s_axi_wdata		,
		.s_axi_wready		,
		.s_axi_wstrb		,
		.s_axi_wvalid		,

		// s_axis_coef*, s_axis_data* and m_axis_data* reset and clock.
		.aclk				,
		.aresetn			,

		// s0_axis for uploading window coefficients.
		.s_axis_coef_tvalid	,
		.s_axis_coef_tdata	,
		.s_axis_coef_tready	,

		// s_axis for input.
		.s_axis_data_tdata	,
		.s_axis_data_tvalid	,

		// m_axis for output.
		.m_axis_data_tdata	,
		.m_axis_data_tuser	,
		.m_axis_data_tlast	,
		.m_axis_data_tvalid
	);

assign s_axis_data_tdata 	= {din_imag, din_real};
assign dout_real			= m_axis_data_tdata[0 +: 32];
assign dout_imag			= m_axis_data_tdata[32 +: 32];

// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;

initial begin
	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag	("axi_mst_0 VIP");

	// Start agents.
	axi_mst_0_agent.start_master();

	s_axi_aresetn	<= 0;
	aresetn			<= 0;
	#300;
	s_axi_aresetn	<= 1;
	aresetn			<= 1;

	#1000;
	
	// Load window coefficients.
	tb_coef_start <= 1;	
	wait (tb_coef_done);
	tb_coef_start <= 0;	

	#100;

	// Start data input.
	tb_input_start <= 1;	
	wait (tb_input_done);
	tb_input_start <= 0;	
end

// Load window coefficients.
initial begin
	int fd, value;

	s_axis_coef_tvalid	<= 0;
	s_axis_coef_tdata	<= 0;

	wait (tb_coef_start);

	////////////////////////////////////////
	// Load coefficients (using readmemh) //
	////////////////////////////////////////
	//$readmemh("../../../../../tb/window.hex", DUT.bram_i.RAM);

	////////////////////////////////////////////
	// Load coefficients (using s_axis_coef*) //
	////////////////////////////////////////////
	fd = $fopen("../../../../../tb/window.hex", "r");

	// DW_ADDR_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, 0, resp);
	#10;

	// DW_WE_REG
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*1, prot, 1, resp);
	#10;
	
	#200;

	while ($fscanf(fd,"%h", value) == 1) begin
		@(posedge aclk);
		s_axis_coef_tvalid	<= 1;
		s_axis_coef_tdata	<= value;
	end

	@(posedge aclk);
	s_axis_coef_tvalid	<= 0;

	// DW_WE_REG
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*1, prot, 0, resp);
	#10;

	tb_coef_done <= 1;

end

// Input data process.
initial begin
	real pi,w,a;
	int n;

	s_axis_data_tvalid	<= 0;
	din_real			<= 0;
	din_imag			<= 0;

	wait(tb_input_start);

	pi = 3.1415;
	w = 2*pi/65536*7.23;
	a = 0.34;
	n = 0;
	for (int j=0; j<15; j = j+1) begin
		for (int i=0; i<10000; i=i+1) begin
			@(posedge aclk);
			s_axis_data_tvalid <= 1'b1;
			din_real	<= a*(2**15-1)*$cos(w*n);
			din_imag	<= a*(2**15-1)*$sin(w*n);
			n = n + 1;
		end
		//for (int i=0; i<30; i=i+1) begin
		//	@(posedge aclk);
		//	s_axis_data_tvalid <= 1'b0;
		//end
		for (int i=0; i<10000; i=i+1) begin
			@(posedge aclk);
			s_axis_data_tvalid <= 1'b1;
			din_real	<= a*(2**15-1)*$cos(w*n);
			din_imag	<= a*(2**15-1)*$sin(w*n);
			n = n + 1;
		end
		//for (int i=0; i<3; i=i+1) begin
		//	@(posedge aclk);
		//	s_axis_data_tvalid <= 1'b0;
		//end
	end

	@(posedge aclk);
	s_axis_data_tvalid <= 1'b0;

	tb_input_done <= 1;
end

// Output data process.
initial begin
	int fd;

	wait(tb_input_start);

	$display("Opening file");
	fd = $fopen("../../../../../tb/dout.csv","w");

	while(tb_input_start) begin
		@(posedge aclk);
		$fdisplay(fd, "%d,%d,%d,%d,%d", m_axis_data_tvalid, m_axis_data_tlast, m_axis_data_tuser, dout_imag, dout_real);
	end
	
	$display("Closing file");
	$fclose(fd);
end

always begin
	s_axi_aclk	<= 0;
	#3;
	s_axi_aclk	<= 1;
	#3;
end

always begin
	aclk	<= 0;
	#5;
	aclk	<= 1;
	#5;
end

endmodule

