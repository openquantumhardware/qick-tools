// Code your design here
module axis_cnt 
  #(
		parameter AXIS_DW = 32 ,
		parameter FFT_AW = 8
  ) (
   input wire [AXIS_DW-1:0]      range_i     ,
   input wire signed [AXIS_DW-1:0]      offset_i     ,
   input wire                    start_i     ,
   input wire                    en_i     ,

   // m_axis interfase.
   input wire                    m_axis_aclk     ,
   input wire                    m_axis_aresetn  ,
   output wire [AXIS_DW-1:0]	 m_axis_tdata    ,
   output wire [AXIS_DW-1:0]	 m_axis_tuser    ,
   output wire                   m_axis_tlast    ,
   input  wire                   m_axis_tready  ,
   output wire                   m_axis_tvalid   );


reg [AXIS_DW-1:0] cnt, cnt_reverse;
wire [AXIS_DW-1:0] cnt_p1 ;
reg m_axis_tvalid_r;

reg  working;
wire cnt_last;
wire cnt_rst_n;

initial begin
  $display("COUNTER CONFIGURATION");
  $display("AXIS_DW %d",  AXIS_DW);
  $display("FFT_AW %d",  FFT_AW);
end
///////////////////////////////////////////////////////////////////////////////
// WORKING STATE MACHINE
localparam
   ST_IDLE       = 2'b00,
   ST_WORKING    = 2'b01,
   ST_RST    = 2'b11;
reg [2:0] cnt_st, cnt_st_nxt;

//  Sequential Logic
always @ (posedge m_axis_aclk or negedge m_axis_aresetn) if (!m_axis_aresetn)  cnt_st <=  ST_IDLE; else cnt_st <=  cnt_st_nxt;
// Combinational Logic
always @ (cnt_st, start_i, cnt_last) begin : CNT_UPDATE_ST
   cnt_st_nxt      = cnt_st;  // default is to stay in current state
   working         = 1'b0; // Default is not working
   case (cnt_st)
      ST_IDLE : begin
         if (start_i) cnt_st_nxt = ST_RST;
      end
      ST_RST : begin
         cnt_st_nxt = ST_WORKING;
      end
      ST_WORKING : begin
         working   = 1'b1;
         if (!start_i) cnt_st_nxt = ST_IDLE;
      end
      endcase 
end

// Control Signals
assign cnt_last = (range_i == cnt_p1) ? 1 : 0;
assign cnt_rst_n = m_axis_aresetn & !cnt_last & working;

assign cnt_p1 = cnt + 1;
always @ (posedge m_axis_aclk or negedge m_axis_aresetn)
    if        (!m_axis_aresetn)              cnt <= 0; 
    else if  (en_i) begin
       if  (!cnt_rst_n)                   cnt <= 0;
       else if (working & m_axis_tready ) cnt <= cnt_p1;
    end
always @ (posedge m_axis_aclk or negedge m_axis_aresetn)
    if (!m_axis_aresetn) m_axis_tvalid_r <= 0; 
    else if (working & m_axis_tready & en_i) 
       m_axis_tvalid_r <= 1'b1;
    else
       m_axis_tvalid_r <= 1'b0;
      
integer i;
always@(cnt) begin
   cnt_reverse = 0;
   for (i=0;i<FFT_AW;i=i+1)
      cnt_reverse[i] = cnt[FFT_AW-1-i];
end
// OUT ASSIGNMENT
//assign m_axis_tdata   = cnt_reverse + offset_i;
//assign m_axis_tuser   = cnt_reverse;
assign m_axis_tdata   = cnt + offset_i;
assign m_axis_tuser   = cnt;// cnt_reverse;
//assign m_axis_tuser   = { !cnt[AXIS_DW-1], cnt[AXIS_DW-2:0] };
assign m_axis_tlast   = cnt_last;
assign m_axis_tvalid  = m_axis_tvalid_r;

endmodule
