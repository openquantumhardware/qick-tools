module tb;

reg					aclk;
reg					aresetn;

wire [32*16-1:0]	s_axis_tdata;
reg					s_axis_tvalid;
wire				s_axis_tready;

wire [64*16-1:0]	m_axis_tdata;
wire [15:0]			m_axis_tuser;
wire				m_axis_tvalid;
wire				m_axis_tlast;

reg	[15:0]	din_vi	[16];
reg	[15:0]	din_vq	[16];
wire [31:0]	dout_vi [16];
wire [31:0]	dout_vq [16];

// Input data.
genvar i;
generate;
	for (i=0; i<16; i=i+1) begin
		assign s_axis_tdata[2*i*16 		+: 16] = din_vi[i];
		assign s_axis_tdata[2*i*16+16 	+: 16] = din_vq[i];

		assign dout_vi[i] = m_axis_tdata[2*i*32		+: 32];	
		assign dout_vq[i] = m_axis_tdata[2*i*32+32	+: 32];	
	end
endgenerate

axis_xfft_16x32768 DUT
	(
		// Reset and clock.
		.aclk			(aclk			),
		.aresetn		(aresetn		),

		// s_axis for input.
  		.s_axis_tdata	(s_axis_tdata 	),
  		.s_axis_tvalid	(s_axis_tvalid	),
  		.s_axis_tready	(s_axis_tready	),

		// m_axis for output.
  		.m_axis_tdata	(m_axis_tdata	),
		.m_axis_tuser	(m_axis_tuser	),
  		.m_axis_tvalid	(m_axis_tvalid	),
  		.m_axis_tlast	(m_axis_tlast	)
	);

initial begin
    int n;
    
	aresetn			<= 0;
	s_axis_tvalid	<= 0;
	#300;
	aresetn			<= 1;

	#1000;

	// Inject data.
	n = 0;
	for (int i=0; i<100; i=i+1) begin
		for (int j=0; j<32768; j=j+1) begin
			@(posedge aclk);
			din_vi[0] = 20000*$cos(2*3.1415/32768*3*n) + $urandom_range(0,2000) - 1000;
			din_vq[0] = 20000*$sin(2*3.1415/32768*3*n) + $urandom_range(0,2000) - 1000;
			for (int k=1; k<16; k=k+1) begin
				din_vi[k] <= $urandom_range(0,100) - 50;
				din_vq[k] <= $urandom_range(0,100) - 50;
				s_axis_tvalid	<= 1;
			end
			n = n + 1;
		end
		@(posedge aclk);
		s_axis_tvalid	<= 0;

		#500;
	end

end

always begin
	aclk	<= 0;
	#5;
	aclk	<= 1;
	#5;
end

endmodule

