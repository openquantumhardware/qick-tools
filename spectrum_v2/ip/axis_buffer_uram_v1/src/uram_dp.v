module uram_dp
	#(
		parameter AWIDTH = 12,  // Address Width
		parameter DWIDTH = 72,  // Data Width
		parameter NBPIPE = 3    // Number of pipeline Registers
	)
	( 
    	input 					clk		,
    	input 					rst		,

		// Port A.
    	input 					wea		,
		input					cea		,
		input					ena		,
    	input [DWIDTH-1:0] 		dina	,
    	input [AWIDTH-1:0] 		addra	,
    	output reg [DWIDTH-1:0] douta	,

		// Port B.
    	input 					web		,
		input					ceb		,
		input					enb		,
    	input [DWIDTH-1:0] 		dinb	,
    	input [AWIDTH-1:0] 		addrb	,
    	output reg [DWIDTH-1:0] doutb
   );

/********************/
/* Internal signals */
/********************/
(* ram_style = "ultra" *)
reg [DWIDTH-1:0]	mem[(1<<AWIDTH)-1:0];

reg [DWIDTH-1:0]	memrega;
reg [DWIDTH-1:0]	mem_pipe_rega[NBPIPE-1:0];
reg 				mem_en_pipe_rega[NBPIPE:0];

reg [DWIDTH-1:0] 	memregb;
reg [DWIDTH-1:0] 	mem_pipe_regb[NBPIPE-1:0];
reg 				mem_en_pipe_regb[NBPIPE:0];

integer          i;

/****************/
/* Architecture */
/****************/

// RAM : Both READ and WRITE have a latency of one
always @ (posedge clk) begin
	if(ena) begin
		if(wea)
			mem[addra] <= dina;
		else
			memrega <= mem[addra];
	end
end

// The enable of the RAM goes through a pipeline to produce a
// series of pipelined enable signals required to control the data
// pipeline.
always @ (posedge clk) begin
	mem_en_pipe_rega[0] <= ena;

	for (i=0; i<NBPIPE; i=i+1)
		mem_en_pipe_rega[i+1] <= mem_en_pipe_rega[i];
end

// RAM output data goes through a pipeline.
always @ (posedge clk) begin
	if (mem_en_pipe_rega[0])
		mem_pipe_rega[0] <= memrega;
end    

always @ (posedge clk) begin
	for (i = 0; i < NBPIPE-1; i = i+1)
		if (mem_en_pipe_rega[i+1])
			mem_pipe_rega[i+1] <= mem_pipe_rega[i];
end      

// Final output register gives user the option to add a reset and
// an additional enable signal just for the data ouptut
always @ (posedge clk) begin
	if (rst)
		douta <= 0;
	else if (mem_en_pipe_rega[NBPIPE] && cea)
		douta <= mem_pipe_rega[NBPIPE-1];
end

always @ (posedge clk) begin
	if(enb) begin
		if(web)
			mem[addrb] <= dinb;
		else
			memregb <= mem[addrb];
	end
end

// The enable of the RAM goes through a pipeline to produce a
// series of pipelined enable signals required to control the data
// pipeline.
always @(posedge clk) begin
	mem_en_pipe_regb[0] <= enb;
	for (i=0;i<NBPIPE;i=i+1)
		mem_en_pipe_regb[i+1] <= mem_en_pipe_regb[i];
end

// RAM output data goes through a pipeline.
always @(posedge clk) begin
	if (mem_en_pipe_regb[0])
		mem_pipe_regb[0] <= memregb;
end    

always @(posedge clk) begin
	for (i = 0; i < NBPIPE-1; i = i+1)
  		if (mem_en_pipe_regb[i+1])
     		mem_pipe_regb[i+1] <= mem_pipe_regb[i];
end      

// Final output register gives user the option to add a reset and
// an additional enable signal just for the data ouptut.
always @(posedge clk) begin
	if (rst)
		doutb <= 0;
	else
		if (mem_en_pipe_regb[NBPIPE] && ceb)
			doutb <= mem_pipe_regb[NBPIPE-1];
end

endmodule

