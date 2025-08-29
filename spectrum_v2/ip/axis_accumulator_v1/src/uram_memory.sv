///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
//  Date           : 4-2022
//  Versión        : 1
///////////////////////////////////////////////////////////////////////////////
//Description:  URAM Memory 
//////////////////////////////////////////////////////////////////////////////
module uram_memory #(
   parameter       MEM_AW         = 16      ,    // Address Width
   parameter       MEM_DW         = 8       ,    // Data Width
   parameter       NBPIPE         = 3            // Number of pipeline Registers
) (
   input  wire                    clk_i     ,
   input  wire                    rst_ni     ,
   input  wire                    mem_en_i  ,
   input  wire                    we_i      ,
   input  wire  [MEM_AW-1:0]      w_addr_i  ,
   input  wire  [MEM_DW-1:0]      w_data_i  ,
   input  wire  [MEM_AW-1:0]      r_addr_i  ,
   output wire  [MEM_DW-1:0]      r_data_o   );
    
(* ram_style = "ultra" *)
reg [MEM_DW-1:0]  mem           [(1<<MEM_AW)-1 : 0 ]; // Memory Declaration
reg [MEM_DW-1:0]  mem_dt_r;              
reg [MEM_DW-1:0]  mem_dt_pipe_r [ NBPIPE-1 : 0];      // Pipelines for memory
reg               mem_en_pipe_r [ NBPIPE : 0];        // Pipelines for memory enable  
reg [MEM_DW-1:0]  r_data;

reg [MEM_DW-1:0]  mem_dt_out_pipe [ NBPIPE+1 : 0];      // Pipelines for OUT

integer           i;

// RAM : Both READ and WRITE have a latency of one
always @ (posedge clk_i) begin
 if(mem_en_i) begin
   if(we_i)  mem[w_addr_i] <= w_data_i;
   mem_dt_r <= mem[r_addr_i];
  end
end

// The enable of the RAM goes through a pipeline to produce a
// series of pipelined enable signals required to control the data
// pipeline.
always @ (posedge clk_i) begin
   mem_en_pipe_r[0] <= mem_en_i;
   for (i=0; i<NBPIPE; i=i+1)
      mem_en_pipe_r [i+1] <= mem_en_pipe_r[i];
end

// The DATA of the RAM goes through a pipeline

// RAM output data goes through a pipeline.
always @ (posedge clk_i ) begin
   if ( mem_en_pipe_r [0]) mem_dt_pipe_r [0] <= mem_dt_r;
   for (i = 0; i < NBPIPE-1; i = i+1)
      if (mem_en_pipe_r[i+1])
         mem_dt_pipe_r [i+1] <= mem_dt_pipe_r[i];
//   if (mem_en_pipe_r [NBPIPE])
//      r_data <= mem_dt_pipe_r [NBPIPE-1]; //REGISTERED IN PIPE
end      


///////////////////////////////////////////////////////////////////////////////
// FIFO TO MANAGE OUTPUT ENABLE 
wire [4:0] addr_cnt_p1, addr_cnt_m1 ; // Max 16 
reg [4:0] addr_out_cnt;
wire addr_up, addr_dn ;
wire zero_n;

// Pipeline
always @ (posedge clk_i ) begin
   if ( mem_en_pipe_r[NBPIPE] ) begin
      mem_dt_out_pipe [0] <= mem_dt_pipe_r [NBPIPE-1];
      for (i = 0; i < NBPIPE+1; i = i+1)
         mem_dt_out_pipe [i+1] <= mem_dt_out_pipe[i];
   end

end      


assign addr_up = !mem_en_i  & mem_en_pipe_r[NBPIPE];
assign addr_dn = mem_en_i &  !mem_en_pipe_r[NBPIPE] & zero_n;

assign addr_cnt_p1 = addr_out_cnt + 1'b1;
assign addr_cnt_m1 = addr_out_cnt - 1'b1;
assign zero_n      = |addr_out_cnt;

always @ (posedge clk_i or negedge rst_ni) begin
   if (!rst_ni)
      addr_out_cnt <= 0;
   else begin
      if      ( addr_up )   addr_out_cnt  <= addr_cnt_p1; 
      else if ( addr_dn )   addr_out_cnt  <= addr_cnt_m1;
   end
end

always @ (posedge clk_i) begin
   if (mem_en_i) begin
      r_data <= mem_dt_out_pipe[addr_out_cnt];
      end
end 


/*always @ (posedge clk_i) begin
   if (mem_en_i) begin
      mem_dt_pipe_r[0] <= mem_dt_r;
      for (i = 0; i < NBPIPE-1; i = i+1)
         mem_dt_pipe_r[i+1] <= mem_dt_pipe_r[i];
      r_data <= mem_dt_pipe_r[NBPIPE-1];
   end   
end 
*/

assign r_data_o = r_data;
//assign r_data_o = mem_dt_out_pipe[addr_out_cnt];

endmodule
