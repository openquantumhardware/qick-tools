module dds_framing
	#(
		parameter NCH 	= 16
	)
	(
		// Reset and clock.
		input 	wire 		rstn		,
		input 	wire 		clk			,

		// Memory interface.
		output	wire [15:0]	mem_addr	,
		input	wire [63:0]	mem_do		,

		// Input tlast for framing.
		input	wire		last_i		,

		// Output for dds control
		output	wire [15:0]	dds_freq	,
		output	wire [15:0]	dds_phase	,
		output	wire [15:0]	dds_gain	,
		output	wire [15:0]	dds_cfg		,
		output	wire		dds_last	,

		// Registers.
		input	wire		SYNC_REG
	);

/*************/
/* Internals */
/*************/

// States.
typedef enum	{	RST0_ST	,
					RST1_ST	,
					SYNC_ST	,
					RUN_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg			rst_state;

// Address counter.
reg	[15:0]	cnt;
reg			cnt_rst;
reg			cnt_en;

// Latency for tlast (bram has 1 clock latency).
reg			last_r1;

// Re-sync registers.
wire		SYNC_REG_resync;

/****************/
/* Architecture */
/****************/
// SYNC_REG_resync.
synchronizer_n SYNC_REG_resync_i
	(
		.rstn	    (rstn				),
		.clk 		(clk				),
		.data_in	(SYNC_REG			),
		.data_out	(SYNC_REG_resync	)
	);

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// State register.
		state 		<= RST0_ST;

		// Address counter.
		cnt			<= 0;

		// Latency for tlast.
		last_r1	<= 0;
	end
	else begin
		// State register.
		case (state)
			RST0_ST:
				if (SYNC_REG_resync == 1'b0)
					state <= RST1_ST;

			RST1_ST:
				if (cnt == NCH-1)
					state <= SYNC_ST;

			SYNC_ST:
				if (last_i == 1'b1)
					state <= RUN_ST;

			RUN_ST:
				if (SYNC_REG_resync == 1'b1 || last_i == 1'b1 && cnt != NCH-1)
					state <= RST0_ST;
		endcase

		// Address counter.
		if (cnt_rst == 1'b1)
			cnt		<= 0;
		else if (cnt_en == 1'b1)
			if (cnt == NCH-1)
				cnt <= 0;
			else
				cnt <= cnt + 1;

		// Latency for tlast.
		last_r1	<= last_i;
	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	rst_state	= 0;
	cnt_rst		= 0;
	cnt_en		= 0;

	case (state)
		RST0_ST: begin
			rst_state 	= 1'b1;
			cnt_rst		= 1'b1;
		end

		RST1_ST: begin
			rst_state 	= 1'b1;
			cnt_en		= 1'b1;
		end

		SYNC_ST:
			cnt_rst		= 1'b1;

		RUN_ST:
			cnt_en		= 1'b1;
	endcase
end

// Assign outputs.
assign mem_addr		= cnt;
assign dds_freq		= mem_do[15:0];
assign dds_phase	= mem_do[31:16];
assign dds_gain		= mem_do[47:32];
assign dds_cfg		= mem_do[63:48];
assign dds_last		= last_r1;

endmodule

