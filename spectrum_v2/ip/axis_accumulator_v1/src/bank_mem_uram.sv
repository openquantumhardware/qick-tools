///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
//  Date           : 5-2022
//  Versión        : 3
///////////////////////////////////////////////////////////////////////////////
//Description:  URAM Memory Bank 
//////////////////////////////////////////////////////////////////////////////

module bank_mem_uram #(
   parameter       BANK_ARAY_QTY  = 4       , // Amount of Memories
   parameter       BANK_MEM_AW    = 12      , // Bits used to Address Complete MEMORY
   parameter       MEM_AW         = 10      , // Bits used to Address Individual MEMORY
   parameter       MEM_DW         = 32      , // Individual Memory Data Width
   parameter       MEM_PIPE       = 3      // Number of pipeline Registers
)(
   input  wire                    clk_i     ,
   input  wire                    rst_ni     ,
   input  wire                    mem_en_i  ,
   input  wire                    we_i      ,
   input  wire [MEM_AW-1:0]       w_addr_i  ,
   input  wire [MEM_DW-1:0]       w_data_i  [BANK_ARAY_QTY-1:0],
   input  wire [MEM_AW-1:0]       r_addr_i  ,
   output wire [MEM_DW-1:0]       r_data_o  [BANK_ARAY_QTY-1:0]  );

wire [MEM_DW-1:0]	  r_data         [BANK_ARAY_QTY-1:0] ;

generate
   genvar ind_mem;
   for (ind_mem=0; ind_mem<BANK_ARAY_QTY; ind_mem=ind_mem+1) begin: MEM_ARRAY
      uram_memory 
      #(
         .MEM_AW (MEM_AW) ,
         .MEM_DW (MEM_DW) ,
         .NBPIPE (MEM_PIPE)
      ) uram_inst (
         .clk_i    ( clk_i    ) ,
         .rst_ni   ( rst_ni    ) ,
         .mem_en_i ( mem_en_i ) ,
         .we_i     ( we_i     ) ,
         .w_addr_i ( w_addr_i) ,
         .w_data_i ( w_data_i[ind_mem] ) ,
         .r_addr_i ( r_addr_i[MEM_AW-1 : 0] ) ,
         .r_data_o ( r_data [ind_mem])  );
       
       assign r_data_o[ind_mem] = r_data [ind_mem];
    end
    
endgenerate

/*
integer i;
reg                mem_rd_pipe_r [MEM_PIPE:0];    // Pipelines for RD   
reg                mem_en_pipe_r [MEM_PIPE:0];    // Pipelines for Enable  

//reg  [BANK_ARRAY_AW-1 : 0] mem_bank_pt_r ;
reg mem_bank_rd_r;

// assign mem_bank_pt = r_addr_i[BANK_MEM_AW-1 : MEM_AW];

// The ENABLE and BANK DATA goes through pipeline

// RAM output data goes through a pipeline.
always @ (posedge clk_i)
begin
   mem_en_pipe_r[0] <= mem_en_i;
   for (i = 1; i <= MEM_PIPE; i = i+1) begin
      mem_en_pipe_r[i] <= mem_en_pipe_r[i-1];
      if (mem_en_pipe_r[i]) mem_rd_pipe_r[i] <= mem_rd_pipe_r[i-1];
   end
if (mem_en_pipe_r[MEM_PIPE] )   mem_bank_rd_r <= mem_rd_pipe_r[MEM_PIPE];

end    
*/
assign r_data_o      = r_data;


endmodule