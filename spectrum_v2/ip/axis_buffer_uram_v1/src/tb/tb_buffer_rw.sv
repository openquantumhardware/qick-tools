module tb();

// DUT generics.
parameter N = 12;
parameter B = 32;

reg				s_axis_aclk;
reg				s_axis_aresetn;
reg [B-1:0]		s_axis_tdata;
reg 			s_axis_tvalid;
wire 			s_axis_tready;
        
reg				m_axis_aclk;
reg				m_axis_aresetn;
wire [B-1:0]	m_axis_tdata;
wire 			m_axis_tlast;
wire 			m_axis_tvalid;
reg				m_axis_tready;

reg				RW_REG;
reg				START_REG;

// DUT.
buffer_rw
	#(
		.N(N),
		.B(B)
	)
	DUT
	(
        // AXI Stream Slave I/F.
		.s_axis_aclk	(s_axis_aclk   	),
		.s_axis_aresetn	(s_axis_aresetn	),
		.s_axis_tdata	(s_axis_tdata 	),
		.s_axis_tvalid	(s_axis_tvalid	),
		.s_axis_tready	(s_axis_tready	),
        
        // AXI Stream Master I/F.
		.m_axis_aclk	(m_axis_aclk   	),
		.m_axis_aresetn	(m_axis_aresetn	),
		.m_axis_tdata	(m_axis_tdata 	),
		.m_axis_tlast	(m_axis_tlast 	),
        .m_axis_tvalid  (m_axis_tvalid	),
		.m_axis_tready	(m_axis_tready	),

		// Registers.
		.RW_REG			(RW_REG			),
		.START_REG		(START_REG		)
    );

initial begin
    	m_axis_tready	= 0;
    	
    	forever 
    	# 600 m_axis_tready	<= ~m_axis_tready	;
end

initial begin
	// Reset sequence.
	s_axis_aresetn	<= 0;
	m_axis_aresetn	<= 0;
	s_axis_tdata	<= 0;
	s_axis_tvalid	<= 0;

	RW_REG			<= 0;
	START_REG		<= 0;
	#500;
	s_axis_aresetn	<= 1;
	m_axis_aresetn	<= 1;

	#1000;

	@(posedge s_axis_aclk);
	RW_REG			<= 1;	// Write mode.
	START_REG		<= 1;

	@(posedge s_axis_aclk);
	@(posedge s_axis_aclk);
	@(posedge s_axis_aclk);
	START_REG		<= 0;

	for (int i=0; i<2**N; i=i+1) begin
		@(posedge s_axis_aclk);
		s_axis_tdata	<= i;
		s_axis_tvalid	<= 1;
	end

	@(posedge s_axis_aclk);
	s_axis_tvalid	<= 0;

	wait (s_axis_tready == 1'b0);

	@(posedge s_axis_aclk);
	RW_REG			<= 0;	// Read mode.
	START_REG		<= 1;

end

always begin
	s_axis_aclk <= 0;
	#10;
	s_axis_aclk <= 1;
	#10;
end

always begin
	m_axis_aclk <= 0;
	#33;
	m_axis_aclk <= 1;
	#33;
end

endmodule

