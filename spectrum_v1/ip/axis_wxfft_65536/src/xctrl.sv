module xctrl 
	(
		// Reset and clock.
		clk				,
		rstn			,

		// m_axis for config.
		m_axis_tdata	,
		m_axis_tvalid	,
		m_axis_tready
	);

/*********/
/* Ports */
/*********/
input			clk;
input			rstn;

output	[7:0]	m_axis_tdata;
output			m_axis_tvalid;
input			m_axis_tready;

/********************/
/* Internal signals */
/********************/
// States.
typedef enum	{	INIT_ST	,
					CFG_ST	,
					END_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg				valid_i;

/**********************/
/* Begin Architecture */
/**********************/

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// State register.
		state 			<= INIT_ST;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				state <= CFG_ST;

			CFG_ST:
				if ( m_axis_tready )
					state <= END_ST;

			END_ST:
				state <= END_ST;
		endcase

	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	valid_i 	= 0;

	case (state)
		//INIT_ST:

		CFG_ST:
			valid_i 	= 1;

		//END_ST:
	endcase
end

// Assign outputs.
assign	m_axis_tdata	= {{7{1'b0}},1'b1};	// Forward FFT.
assign	m_axis_tvalid	= valid_i;

endmodule

