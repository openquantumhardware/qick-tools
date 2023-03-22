import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

// DUT generics.
parameter L 	= 4;
parameter NCH 	= 8;

reg						s_axi_aclk		;
reg						s_axi_aresetn	;
wire 	[5:0]			s_axi_araddr	;
wire 	[2:0]			s_axi_arprot	;
wire					s_axi_arready	;
wire					s_axi_arvalid	;
wire 	[5:0]			s_axi_awaddr	;
wire 	[2:0]			s_axi_awprot	;
wire					s_axi_awready	;
wire					s_axi_awvalid	;
wire					s_axi_bready	;
wire 	[1:0]			s_axi_bresp		;
wire					s_axi_bvalid	;
wire 	[31:0]			s_axi_rdata		;
wire					s_axi_rready	;
wire 	[1:0]			s_axi_rresp		;
wire					s_axi_rvalid	;
wire 	[31:0]			s_axi_wdata		;
wire					s_axi_wready	;
wire 	[3:0]			s_axi_wstrb		;
wire					s_axi_wvalid	;

reg						aresetn			;
reg						aclk			;

wire [32*L-1:0]			m_axis_tdata	;
wire					m_axis_tlast	;
wire					m_axis_tvalid	;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data;
xil_axi_resp_t  resp;

// TDM demux for debugging.
reg						sync_demux		;
wire [31:0]				din_demux_v [L]	;
wire [NCH*32-1:0]		dout_demux_v [L];
wire [L-1:0]			valid_demux		;

wire signed [15:0]		dout_real_ii [L][NCH];
wire signed [15:0]		dout_imag_ii [L][NCH];

// TB Control.
reg tb_write_out = 0;

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

axis_dds_v3
    #(
		// Number of Lanes.
		.L	(L		),

		// Number of Channels.
		.NCH(NCH	)

    )
	DUT
	( 
		// AXI Slave I/F.
		.s_axi_aclk		,
		.s_axi_aresetn	,

		// Write Address Channel.
		.s_axi_awaddr	,
		.s_axi_awprot	,
		.s_axi_awvalid	,
		.s_axi_awready	,

		// Write Data Channel.
		.s_axi_wdata	,
		.s_axi_wstrb	,
		.s_axi_wvalid	,
		.s_axi_wready	,

		// Write Response Channel.
		.s_axi_bresp	,
		.s_axi_bvalid	,
		.s_axi_bready	,

		// Read Address Channel.
		.s_axi_araddr	,
		.s_axi_arprot	,
		.s_axi_arvalid	,
		.s_axi_arready	,

		// Read Data Channel.
		.s_axi_rdata	,
		.s_axi_rresp	,
		.s_axi_rvalid	,
		.s_axi_rready	,

		// Reset and clock of AXIS I/Fs.
		.aresetn		,
		.aclk			,

		// Master AXIS I/F for output data.
		.m_axis_tdata	,
		.m_axis_tlast	,
		.m_axis_tvalid
	);

genvar i,j;
generate
	for (i=0; i<L; i = i+1) begin
		for (j=0; j<NCH; j=j+1) begin
			assign dout_real_ii[i][j] = dout_demux_v[i][2*j*16 +: 16];
			assign dout_imag_ii[i][j] = dout_demux_v[i][(2*j+1)*16 +: 16];
		end
		// TDM demux.
		tdm_demux
		    #(
		        .NCH(NCH),
		        .B	(32	)
		    )
			tdm_demux_i
			(
				// Reset and clock.
				.rstn		(aresetn			),
				.clk		(aclk				),
		
				// Resync.
				.sync		(sync_demux			),
		
				// Data input.
				.din		(din_demux_v[i]		),
				.din_last	(m_axis_tlast		),
				.din_valid	(m_axis_tvalid		),
		
				// Data output.
				.dout		(dout_demux_v[i]	),
				.dout_valid	(valid_demux[i]		)
			);

		// TDM demux input data.
		assign din_demux_v[i] = m_axis_tdata[32*i +: 32];
	end
endgenerate

// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;

// Main TB.
initial begin
	// Frequency/gain vector for DDSs.
    real freq_v[L*NCH];
    real phase_v[L*NCH];
    real gain_v[L*NCH];
    int  cfg_v[L*NCH];
    int i_single, j_single;

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
	
	$display("###############################");
	$display("### Program DDS Frequencies ###");
	$display("###############################");
	$display("t = %0t", $time);

	// Frequencies.
	for (int i=0; i<L*NCH; i=i+1) begin
		freq_v[i] 	= 0;
		phase_v[i] 	= 0;
		gain_v[i] 	= 0;
		cfg_v[i]	= 0;
	end

	// Set some DDS frequencies (MHz).
	freq_v[0] 	= 0.1;
	phase_v[0] 	= 0;
	gain_v[0] 	= 0.99;

	freq_v[1] 	= 0.1;
	phase_v[1] 	= 0;
	gain_v[1] 	= 0.99;

	freq_v[4] 	= 0.1;
	phase_v[4] 	= 0;
	gain_v[4] 	= 0.9;
//	cfg_v[4]	= 1;	// Select noise for output.

//	freq_v[8] = 0.1;
//	phase_v[8] = 0;
//	gain_v[8] = 0.9;

//	freq_v[12] = 0.1;
//	phase_v[12] = 0;
//	gain_v[12] = 0.9;

	sync_demux <= 1;

	// DDS_SYNC_REG: force SYNC while programming frequencies.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*6, prot, 1, resp);
	#10;

	for (int i=0; i<NCH; i = i+1) begin
		for (int j=0; j<L; j = j+1) begin
			// ADDR_NCHAN_REG
			axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, L*i+j, resp);
			#10;

			// ADDR_PINC_REG
			data = freq_calc(100, NCH, freq_v[L*i+j]);
			axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*1, prot, data, resp);
			#10;

			// ADDR_PHASE_REG
			data = phase_calc(phase_v[L*i+j]);
			axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*2, prot, data, resp);
			#10;

			// ADDR_GAIN_REG
			data = gain_v[L*i+j]*(2**15-1);
			axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*3, prot, data, resp);
			#10;

			// ADDR_CFG_REG
			data = cfg_v[L*i+j];
			axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*4, prot, data, resp);
			#10;
			
			// ADDR_WE_REG
			axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*5, prot, 1, resp);
			#10;	

			// ADDR_WE_REG
			axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*5, prot, 0, resp);
			#10;	
		end
	end

	// DDS_SYNC_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*6, prot, 0, resp);
	#10;

	sync_demux <= 0;
	
	#1000;
	
	tb_write_out <= 1;
	
	#3000;
	
	// Program single DDS.
	freq_v[4] 	= 0.15;
	i_single = 1;
	j_single = 0;	
	
    // ADDR_NCHAN_REG
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, L*i_single+j_single, resp);
    #10;

    // ADDR_PINC_REG
    data = freq_calc(100, NCH, freq_v[L*i_single+j_single]);
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*1, prot, data, resp);
    #10;

    // ADDR_PHASE_REG
    data = phase_calc(phase_v[L*i_single+j_single]);
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*2, prot, data, resp);
    #10;

    // ADDR_GAIN_REG
    data = gain_v[L*i_single+j_single]*(2**15-1);
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*3, prot, data, resp);
    #10;

    // ADDR_CFG_REG
    data = cfg_v[L*i_single+j_single];
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*4, prot, data, resp);
    #10;
			
    // ADDR_WE_REG
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*5, prot, 1, resp);
    #10;	

    // ADDR_WE_REG
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*5, prot, 0, resp);
    #10;
    
    #60000;
    
	// Program single DDS.
	freq_v[4] 	= 0.1;
	i_single = 1;
	j_single = 0;	
	
    // ADDR_NCHAN_REG
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, L*i_single+j_single, resp);
    #10;

    // ADDR_PINC_REG
    data = freq_calc(100, NCH, freq_v[L*i_single+j_single]);
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*1, prot, data, resp);
    #10;

    // ADDR_PHASE_REG
    data = phase_calc(phase_v[L*i_single+j_single]);
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*2, prot, data, resp);
    #10;

    // ADDR_GAIN_REG
    data = gain_v[L*i_single+j_single]*(2**15-1);
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*3, prot, data, resp);
    #10;

    // ADDR_CFG_REG
    data = cfg_v[L*i_single+j_single];
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*4, prot, data, resp);
    #10;
			
    // ADDR_WE_REG
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*5, prot, 1, resp);
    #10;	

    // ADDR_WE_REG
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*5, prot, 0, resp);
    #10;        		

	#50000;

	tb_write_out <= 0;
end

// Output data file.
initial begin
	int real_d, imag_d;
	int lane_idx, ch_idx, channel;
	int fd;

	// Output file.
	fd = $fopen("../../../../../tb/dout.csv","w");

	// Data format.
	$fdisplay(fd, "valid, real, imag");

	// Channel.
	lane_idx 	= 1;
	ch_idx 		= 0;
	channel		= L*ch_idx + lane_idx;

	wait (tb_write_out);
	$display("Writing data for CH = %d", channel);

	while (tb_write_out) begin
		@(posedge aclk);
		real_d = dout_real_ii[lane_idx][ch_idx];
		imag_d = dout_imag_ii[lane_idx][ch_idx];
		$fdisplay(fd, "%d, %d, %d", m_axis_tvalid, real_d, imag_d);
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
function [15:0] freq_calc;
    input real fclk;
	input real nch;
    input real f;
    
	// All input frequencies are in kHz.
	real fclk_temp, temp;
	fclk_temp = fclk/nch;
	temp = f/fclk_temp*2**16;
	freq_calc = int'(temp);
endfunction

// Function to compute phase register.
function [15:0] phase_calc;
    input real fi;
    
	// All input frequencies are in kHz.
	real temp;
	temp = fi/360*2**16;
	phase_calc = int'(temp);
endfunction

endmodule

