module tb;

reg			aclk				;
reg			aresetn				;
reg			s_axis_phase_tvalid	;
reg			s_axis_phase_tlast	;

wire[39:0]	s_axis_tdata0		;
wire[39:0]	s_axis_tdata1		;

wire[31:0]	m_axis_tdata0		;
wire[31:0]	m_axis_tdata1		;

// DDS control.
reg [15:0]	pinc0_r;
reg	[15:0]	phase0_r;
reg			sync0_r;
reg [15:0]	pinc1_r;
reg	[15:0]	phase1_r;
reg			sync1_r;

wire[15:0]	phi;

// Counter for phase control.
reg	[15:0]	cnt;

/*
 * DDS Control input format:
 *
 * |----------|------|----------|---------|
 * | 39 .. 33 |32    | 31 .. 16 | 15 .. 0 |
 * |----------|------|----------|---------|
 * | not used | sync | phase    | pinc    |
 * |----------|------|----------|---------|
 */
dds_0
	dds0_i
	(
		.aclk					,
		.s_axis_phase_tvalid	,
		.s_axis_phase_tdata		(s_axis_tdata0	),
		.s_axis_phase_tlast		,
		.m_axis_data_tvalid		(				),
		.m_axis_data_tdata		(m_axis_tdata0	),
		.m_axis_data_tlast		(				)
	);

dds_0
	dds1_i
	(
		.aclk					,
		.s_axis_phase_tvalid	,
		.s_axis_phase_tdata		(s_axis_tdata1	),
		.s_axis_phase_tlast		,
		.m_axis_data_tvalid		(				),
		.m_axis_data_tdata		(m_axis_tdata1	),
		.m_axis_data_tlast		(				)
	);


assign s_axis_tdata0	= {{7{1'b0}},sync0_r,phase0_r,pinc0_r};
assign s_axis_tdata1	= {{7{1'b0}},sync1_r,phase1_r,phi};
assign phi				= pinc1_r*cnt;

// Main TB.
initial begin
	aresetn				<= 0;
	s_axis_phase_tvalid	<= 0;
	s_axis_phase_tlast	<= 0;
	pinc0_r				<= 0;
	phase0_r			<= 0;
	sync0_r				<= 0;
	pinc1_r				<= 0;
	phase1_r			<= 0;
	sync1_r				<= 1;

	#200;

	aresetn				<= 1;

	@(posedge aclk);
	s_axis_phase_tvalid	<= 1;

	// Standard DDS control.
	pinc0_r				<= freq_calc(100,1);

	// Phase coherent.
	pinc1_r				<= freq_calc(100,1);

	#1000;

	@(posedge aclk);
	// Phase coherent.
	pinc1_r				<= freq_calc(100,7);

	#3000;

	@(posedge aclk);
	// Phase coherent.
	pinc1_r				<= freq_calc(100,1);
	phase1_r			<= freq_calc(100,25);
	
end

// Counter for phase control.
always @(posedge aclk) begin
	if (~aresetn)
		cnt <= 0;
	else if (s_axis_phase_tvalid)
		cnt <= cnt + 1;
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
    input real f;
    
	// All input frequencies are in MHz.
	real temp;
	temp = f/fclk*2**16;
	freq_calc = int'(temp);
endfunction

endmodule

