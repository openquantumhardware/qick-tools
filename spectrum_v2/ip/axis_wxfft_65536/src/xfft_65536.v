module xfft_65536
	(
		// s_axis_* and m_axis_* reset and clock.
		input wire			aclk			,
		input wire			aresetn			,

		// s_axis for input.
		input wire	[31:0]	s_axis_tdata	,
		input wire			s_axis_tlast	,
		input wire			s_axis_tvalid	,

		// m_axis for output.
		output wire	[63:0]	m_axis_tdata	,
		output wire	[15:0]	m_axis_tuser	,
		output wire			m_axis_tlast	,
		output wire			m_axis_tvalid
	);

/********************/
/* Internal signals */
/********************/
// xfft configuration interface.
wire	[7:0]	axis_cfg_tdata	;
wire			axis_cfg_tvalid	;
wire			axis_cfg_tready	;

// xfft output data.
wire	[79:0]	tdata_i			;

/**********************/
/* Begin Architecture */
/**********************/
// XFFT control block.
xctrl ctrl_i
	(
		// Reset and clock.
		.clk			(aclk				),
		.rstn			(aresetn			),

		// m_axis for config.
		.m_axis_tdata	(axis_cfg_tdata		),
		.m_axis_tvalid	(axis_cfg_tvalid	),
		.m_axis_tready	(axis_cfg_tready	)
	);


// Instantiate XFFT block.
// Output data: 80 bits.
// [32:0]	: I
// [72:40]	: Q
//
// I will preserve 32 bits instead of 33.
xfft_0 fft_i 
	(
		.aclk							(aclk				),
  		.s_axis_config_tdata			(axis_cfg_tdata		),
  		.s_axis_config_tvalid			(axis_cfg_tvalid	),
  		.s_axis_config_tready			(axis_cfg_tready	),
  		.s_axis_data_tdata				(s_axis_tdata		),
  		.s_axis_data_tvalid				(s_axis_tvalid		),
  		.s_axis_data_tready				(					),
  		.s_axis_data_tlast				(s_axis_tlast		),
  		.m_axis_data_tdata				(tdata_i			),
  		.m_axis_data_tuser				(m_axis_tuser		),
  		.m_axis_data_tvalid				(m_axis_tvalid		),
  		.m_axis_data_tready				(1'b1				),
  		.m_axis_data_tlast				(m_axis_tlast		),
  		.event_frame_started			(					),
  		.event_tlast_unexpected			(					),
  		.event_tlast_missing			(					),
  		.event_status_channel_halt		(					),
  		.event_data_in_channel_halt		(					),
  		.event_data_out_channel_halt	(					)
	);

// Assign outputs.
assign m_axis_tdata [0	+: 32]	= tdata_i	[1	+: 32];
assign m_axis_tdata [32 +: 32]	= tdata_i	[41	+: 32];

endmodule

