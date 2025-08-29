module data_reader
	#(
		// Memory address width.
		parameter N 	= 8	,

		// Data width.
		parameter B		= 8	,

		// Output width.
		parameter BOUT	= 8	,

		// Latency.
		parameter L 	= 5
    )
    (
		// Reset and clock.
		rstn			,
		clk 			,
		
		// Memory I/F.
		mem_addr		,
		mem_dout		,
		
		// m_axis I/F.
		m_axis_aclk		,
		m_axis_aresetn	,
		m_axis_tdata	,
		m_axis_tlast	,
		m_axis_tvalid	,
		m_axis_tready	,
		
		// Start.
		start
    );

/*********/
/* Ports */
/*********/
input				rstn;
input				clk;

output	[N-1:0]		mem_addr;
input	[B-1:0]		mem_dout;

input				m_axis_aclk;
input				m_axis_aresetn;
output	[BOUT-1:0]	m_axis_tdata;
output				m_axis_tlast;
output				m_axis_tvalid;
input				m_axis_tready;

input				start;

/*************/
/* Internals */
/*************/
localparam NPOW		= 2**N;
localparam LOG2_L	= $clog2(L);

// States.
typedef enum	{	INIT_ST		,
					READ_ST		,
					WRITE_ST	,
					END_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

// FSM flags.
reg init_state;
reg read_state;
reg write_state;

// Fifo.
wire	[B:0]	fifo_din;
wire			fifo_rd_en;
wire	[B:0]	fifo_dout;
wire			fifo_full;
wire			fifo_empty;

// Counters.
reg		[N-1:0]			cnt_n;
reg		[LOG2_L-1:0]	cnt;

// Last.
wire	last_i;

/****************/
/* Architecture */
/****************/

// Fifo to drive AXI Stream Master I/F.
fifo_dc_axi
    #(
        // Data width.
        .B	(B+1	),
        
        // Fifo depth.
        .N	(4		)
    )
    fifo_i
    ( 
		.wr_rstn	(rstn			),
		.wr_clk		(clk			),

		.rd_rstn	(m_axis_aresetn	),
		.rd_clk		(m_axis_aclk	),
		        
		// Write I/F.
		.wr_en		(write_state	),
		.din		(fifo_din		),
		
		// Read I/F.
		.rd_en		(fifo_rd_en		),
		.dout		(fifo_dout		),
		
		// Flags.
		.full		(fifo_full		),
		.empty		(fifo_empty		)
    );
    
// Fifo connections.
assign fifo_din		= {last_i,mem_dout};
assign fifo_rd_en	= m_axis_tready;

// Last.
assign last_i		= (cnt_n == NPOW-1)? 1'b1 : 1'b0;
                
// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// State register.
		state 	<= INIT_ST;

		// Counters.
		cnt_n	<= 0;
		cnt		<= 0;

	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (start == 1'b1)
					state <= READ_ST;

			READ_ST:
				if (cnt == L-1)
					state <= WRITE_ST;

			WRITE_ST:
				if (fifo_full == 1'b0) begin
					if (cnt_n == NPOW-1)
						state <= END_ST;
					else
						state <= READ_ST;
			     end
			     
			END_ST:
				if (start == 1'b0)
					state <= INIT_ST;

		endcase

		// Counters.
		if (init_state == 1'b1)
			cnt_n <= 0;
		else if (write_state == 1'b1 && fifo_full == 1'b0)
			cnt_n <= cnt_n + 1;

		if (read_state == 1'b0)
			cnt <= 0;
		else
			cnt <= cnt + 1;

	end
end

// FSM outputs.
always_comb begin
	// Default.
	init_state	= 0;
	read_state 	= 0;
	write_state	= 0;

	case (state)
		INIT_ST:
			init_state = 1;

		READ_ST:
			read_state = 1;

		WRITE_ST:
			write_state = 1;

		//END_ST:
	endcase
end

// Assign outputs.
assign mem_addr			= cnt_n;

assign m_axis_tdata		= {{(BOUT-B){1'b0}},fifo_dout[B-1:0]};
assign m_axis_tlast		= fifo_dout[B];
assign m_axis_tvalid	= ~fifo_empty;

endmodule

