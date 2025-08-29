module firs 
	#(
		// Number of Lanes (Input).
		parameter L = 8
	)
	(
		// Reset and clock.
		input					aresetn			,
		input					aclk			,

		// S_AXIS for input data.
		output					s_axis_tready	,
		input					s_axis_tvalid	,
		input	[L*32-1:0]		s_axis_tdata	,

		// M_AXIS for output data.
		output					m_axis_tvalid	,
		output	[2*L*32-1:0]	m_axis_tdata
	);

/********************/
/* Internal signals */
/********************/
// Input delay.
wire[31:0]		data_v	[0:L-1];
reg	[31:0]		data_r1	[0:L-1];
reg	[31:0]		data_r2	[0:L-1];

// Valid input.
reg				valid_r;

// FIR outputs.
wire[2*L-1:0]	valid_v;
wire[31:0]		dout_v [0:2*L-1];

/**********************/
/* Begin Architecture */
/**********************/
genvar i;
generate
	for (i=0; i<L; i=i+1) begin
		// Registers.
		always @(posedge aclk) begin
			if (~aresetn) begin
				// Input delay.
				data_r1	[i] <= 0;
				data_r2	[i] <= 0;				
			end 
			else begin
				// Input delay.
				if (s_axis_tvalid == 1'b1)
					data_r1	[i] <= data_v[i];
				data_r2	[i] <= data_r1[i];
			end
		end

		// Assign input data to vector.
		assign data_v[i] = s_axis_tdata[i*32 +: 32];

		// Assign fir data to output.
		assign m_axis_tdata[i*32 +: 32]		= dout_v[i];
		assign m_axis_tdata[(L+i)*32 +: 32]	= dout_v[L+i];
	end
endgenerate

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		// Valid input.
		valid_r <= 0;
	end
	else begin
		// Valid input.
		valid_r <= s_axis_tvalid;
	end
end

// Delayed samples go to first half of firs. This is equivalent
// to a time advance z over the second half (non-causal).
// First half of FIRs.
fir_0 fir0_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r2[0]	),
		.m_axis_data_tvalid	(valid_v[0]	),
		.m_axis_data_tdata	(dout_v[0]	)
	);

fir_2 fir1_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r2[1]	),
		.m_axis_data_tvalid	(valid_v[1]	),
		.m_axis_data_tdata	(dout_v[1]	)
	);

fir_4 fir2_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r2[2]	),
		.m_axis_data_tvalid	(valid_v[2]	),
		.m_axis_data_tdata	(dout_v[2]	)
	);

fir_6 fir3_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r2[3]	),
		.m_axis_data_tvalid	(valid_v[3]	),
		.m_axis_data_tdata	(dout_v[3]	)
	);

fir_8 fir4_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r2[4]	),
		.m_axis_data_tvalid	(valid_v[4]	),
		.m_axis_data_tdata	(dout_v[4]	)
	);

fir_10 fir5_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r2[5]	),
		.m_axis_data_tvalid	(valid_v[5]	),
		.m_axis_data_tdata	(dout_v[5]	)
	);

fir_12 fir6_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r2[6]	),
		.m_axis_data_tvalid	(valid_v[6]	),
		.m_axis_data_tdata	(dout_v[6]	)
	);

fir_14 fir7_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r2[7]	),
		.m_axis_data_tvalid	(valid_v[7]	),
		.m_axis_data_tdata	(dout_v[7]	)
	);

// Second half of FIRs.
fir_1 fir8_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r1[0]	),
		.m_axis_data_tvalid	(valid_v[8]	),
		.m_axis_data_tdata	(dout_v[8]	)
	);

fir_3 fir9_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r1[1]	),
		.m_axis_data_tvalid	(valid_v[9]	),
		.m_axis_data_tdata	(dout_v[9]	)
	);

fir_5 fir10_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r1[2]	),
		.m_axis_data_tvalid	(valid_v[10]),
		.m_axis_data_tdata	(dout_v[10]	)
	);

fir_7 fir11_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r1[3]	),
		.m_axis_data_tvalid	(valid_v[11]),
		.m_axis_data_tdata	(dout_v[11]	)
	);

fir_9 fir12_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r1[4]	),
		.m_axis_data_tvalid	(valid_v[12]),
		.m_axis_data_tdata	(dout_v[12]	)
	);

fir_11 fir13_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r1[5]	),
		.m_axis_data_tvalid	(valid_v[13]),
		.m_axis_data_tdata	(dout_v[13]	)
	);

fir_13 fir14_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r1[6]	),
		.m_axis_data_tvalid	(valid_v[14]),
		.m_axis_data_tdata	(dout_v[14]	)
	);

fir_15 fir15_i 
	(
		.aclk				(aclk		),
		.s_axis_data_tvalid	(valid_r	),
		.s_axis_data_tready	(			),
		.s_axis_data_tdata	(data_r1[7]	),
		.m_axis_data_tvalid	(valid_v[15]),
		.m_axis_data_tdata	(dout_v[15]	)
	);

// Assign outputs.
assign s_axis_tready = 1'b1;
assign m_axis_tvalid = valid_v[0];

endmodule

