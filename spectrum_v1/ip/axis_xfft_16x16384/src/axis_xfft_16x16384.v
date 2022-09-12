// This block integrates 16 XFFT blocks, 16384 points each.
module axis_xfft_16x16384
	(
		// s_axis_* and m_axis_* reset and clock.
		input					aclk			,
		input					aresetn			,

		// s_axis for input.
		input	[32*16-1:0]		s_axis_tdata	,
		input					s_axis_tvalid	,
		output					s_axis_tready	,

		// m_axis for output.
		output	[64*16-1:0]		m_axis_tdata	,
		output	[15:0]			m_axis_tuser	,
		output					m_axis_tvalid	,
		output					m_axis_tlast
	);

/**************/
/* Parameters */
/**************/
// Number of parallel inputs.
localparam N = 16;

// Number of bits of I/Q parts.
localparam BIN 	= 16;
localparam BOUT = 32;

/********************/
/* Internal signals */
/********************/
// xfft configuration interface.
wire	[7:0]			axis_cfg_tdata;
wire					axis_cfg_tvalid;
wire	[N-1:0]			axis_cfg_tready;

// Vectors for input/output.
wire	[2*BIN-1:0]		din_v 	[N-1:0];
wire	[2*BOUT-1:0]	dout_v	[N-1:0];
wire	[15:0]			tuser_v	[N-1:0];

// Valid/last.
wire	[N-1:0]	valid_i;
wire	[N-1:0]	last_i;

/**********************/
/* Begin Architecture */
/**********************/
ctrl ctrl_i
	(
		// Reset and clock.
		.clk			(aclk				),
		.rstn			(aresetn			),

		// m_axis for config.
		.m_axis_tdata	(axis_cfg_tdata		),
		.m_axis_tvalid	(axis_cfg_tvalid	),
		.m_axis_tready	(axis_cfg_tready[0]	)
	);

genvar i;
generate
	for (i=0; i<N; i=i+1) begin: GEN_xfft
		// Slice input.
		assign din_v[i][15:0]	= s_axis_tdata	[i*2*BIN		+: BIN];
		assign din_v[i][31:16] 	= s_axis_tdata	[i*2*BIN+BIN	+: BIN];

		// Instantiate XFFT blocks.
		xfft_0 fft_i
			(
				.aclk							(aclk					),
				.s_axis_config_tdata			(axis_cfg_tdata			),
				.s_axis_config_tvalid			(axis_cfg_tvalid		),
				.s_axis_config_tready			(axis_cfg_tready[i]		),
				.s_axis_data_tdata				(din_v[i]				),
				.s_axis_data_tvalid				(s_axis_tvalid			),
				.s_axis_data_tready				(						),
				.s_axis_data_tlast				(1'b0					),
				.m_axis_data_tdata				(dout_v[i]				),
				.m_axis_data_tuser				(tuser_v[i]				),
				.m_axis_data_tvalid				(valid_i[i]				),
				.m_axis_data_tready				(1'b1					),
				.m_axis_data_tlast				(last_i[i]				),
				.event_frame_started			(						),
				.event_tlast_unexpected			(						),
				.event_tlast_missing			(						),
				.event_status_channel_halt		(						),
				.event_data_in_channel_halt		(						),
				.event_data_out_channel_halt	(						)
			);

		// Build output.
		assign m_axis_tdata	[i*2*BOUT 		+: BOUT]	= dout_v[i][0 		+: BOUT];
		assign m_axis_tdata	[i*2*BOUT+BOUT 	+: BOUT] 	= dout_v[i][BOUT 	+: BOUT];
	
	end
endgenerate

// Assign outputs.
assign s_axis_tready 	= 1'b1;
assign m_axis_tuser		= tuser_v[0];
assign m_axis_tvalid 	= valid_i[0];
assign m_axis_tlast		= last_i[0];

endmodule

