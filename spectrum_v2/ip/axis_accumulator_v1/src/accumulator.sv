///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
//  Date           : 6-2022
//  Version        : 5
///////////////////////////////////////////////////////////////////////////////
//Description:  Axi Stream Accumulator / Averager
//////////////////////////////////////////////////////////////////////////////

module accumulator #(
   parameter AXIS_IN_DW           = 32  , // AXIS IN Data Widht
   parameter AXIS_OUT_DW          = 128 , // AXIS OUT Data Widht
   parameter FFT_AW               = 15  , // Memory Address width
   parameter BANK_ARRAY_AW        = 4   , // Bits used to Address BANKS
   parameter MEM_DW               = 72  , // Memory Data Width
   parameter MEM_PIPE             = 6   , // Number of pipeline Registers
   parameter FFT_STORE            = 1   ,  // 0=FULL or 1=HALF FFT
   parameter IQ_FORMAT            = 1     // 0=IIII QQQQor 1=IQ IQ IQ IQ
  ) (
   // AXI Stream Slave I/F.
   input wire                                       s_axis_aclk         ,
   input wire                                       s_axis_aresetn      ,
   input wire [AXIS_IN_DW*(2**BANK_ARRAY_AW)-1:0]   s_axis_tdata        ,
   input wire [AXIS_IN_DW/2-1:0]                    s_axis_tuser        ,
   input wire                                       s_axis_tvalid       ,
   input wire                                       s_axis_tlast        ,
   output wire                                      s_axis_tready       ,
   // AXI Stream Master I/F.                          
   input wire                                       m_axis_aclk         ,
   input wire                                       m_axis_aresetn      ,
   output wire [AXIS_OUT_DW-1:0]                    m_axis_tdata        ,
   output wire                                      m_axis_tvalid       ,
   output wire                                      m_axis_tlast        ,
   input  wire                                      m_axis_tready       ,
   // Control                    
   input  wire                                      process_i           , // START Processing
   input  wire                                      tx_and_cnt_i        , // Transmite values from Memory and CONTINUE operation (KEEP Memory Values)
   input  wire                                      tx_and_rst_i        , // Transmit  values from Memory and RESTART  operation (RESET Memory Values)
   input  wire [31 : 0]                             usr_round_samples_i , // User Number of Samples per ROUND
   input  wire [31 : 0]                             usr_epoch_rounds_i  , // User Number of Rounds per EPOCH 
   // Output Debug.                    
   output wire [15 : 0]                             debug_o             , // Debug Output 
   // Output Data.                     
   output wire [31 : 0]                             round_cnt_o         , // Rounds in current epoch 
   output wire [31 : 0]                             epoch_cnt_o         ,  // Total of epochs processed since last start. 
   // Output Transmit.                    
   output wire                                      transmit_o            // Transmitting 
);

///////////////////////////////////////////////////////////////////////////////
// Parameters used in the design (derivated from input parameters)
localparam NUM_OF_BINS    = ( 2 ** FFT_AW )            ;
localparam NUM_OF_INPUTS  = ( 2 ** BANK_ARRAY_AW )     ;
localparam MEM_AW         = ( FFT_AW - FFT_STORE )     ;
localparam BANK_MEM_AW    = ( BANK_ARRAY_AW + MEM_AW ) ;
localparam MEM_SIZE       = ( 2 ** MEM_AW )            ;
localparam BANK_MEM_SIZE  = MEM_SIZE * NUM_OF_INPUTS   ;
localparam BANK_ARAY_QTY  = ( 2 ** BANK_ARRAY_AW )     ;
localparam BIN_DW         = AXIS_IN_DW/2               ;

///////////////////////////////////////////////////////////////////////////////
// Signals
// Transmission Command
wire                tx_and_cnt_t01, tx_and_rst_t01                          ; // Rising edge of signals
reg                 tx_and_cnt_req, tx_and_rst_req                          ; // Request for Transmitting
wire                goto_transmit                                           ; // State Change. End Accumulating, start Tranmitting
// Control State
reg                 resetting, accumulating, transmitting, meta_data        ; // State ID
reg                 working;
reg                 pipe_acc_in_waiting, pipe_acc_out_waiting               ; // State ID
reg                 pipe_tx_in_waiting, pipe_tx_out_waiting                 ; // State ID

// Counters
reg  [BANK_MEM_AW-1:0] addr_cnt                                             ; // Memory Address Counter
reg  [31:0]         smp_epoch_cnt, smp_cnt                                  ;
reg  [31:0]         epoch_cnt, round_cnt                                    ;
wire [31:0]         smp_epoch_cnt_p1, smp_cnt_p1              ; // Counters PLUS 1
//Counters Last Values
wire                mem_pipe_last, addr_last, smp_last, round_last          ;
//Counter Enables
wire                addr_cnt_bin_en, addr_cnt_tx_en, addr_cnt_rst_en        ;
wire                mem_pipe_cnt_en, addr_cnt_en                            ;
wire                smp_cnt_en,  round_cnt_en,  epoch_cnt_en                ;
// Counter RST
wire                mem_pipe_cnt_rst, addr_cnt_rst, smp_cnt_rst, round_cnt_rst;

// PIPE (DataPath Delay to Sync with Memory Pipeline)
reg  signed [AXIS_IN_DW-1:0] mem_dt_pipe    [NUM_OF_INPUTS-1:0][MEM_PIPE:0] ;   // Pipelines for DATA 
reg [BANK_MEM_AW:0]          mem_addr_pipe  [MEM_PIPE+1:0]                  ;   // Pipelines for ADDRESS 

// Memory Control Sequnce 
reg [BANK_MEM_AW:0] mem_addr                                                ; // Address INPUT to Memory PIPE
reg  [4:0]          mem_pipe_cnt                                            ; // Maximun number of PIPE STAGES 31
reg                 bin_mem_store                                           ; // bin must be stored (When HALF or FULL)
wire                mem_addr_usr                                            ; // Addres Selector (comes from T_USER or ADDR_CNT)
// The adjusted Addres moves the output of the FFT to the correct address 
// Memory Interface
wire [BANK_ARRAY_AW-1:0]     mem_bank_pt                                    ; // Pointer of the memory Bank to be READ
reg  [MEM_DW-1:0]   mem_r_data [BANK_ARAY_QTY-1:0]                          ; // Data Read From Memory
reg  [MEM_DW-1:0]   mem_w_data [BANK_ARAY_QTY-1:0]                          ; // Data Write To Memory
reg  [MEM_AW-1:0]   mem_addr_w_r                                            ; // Registered Adjusted  ADDRESS 
wire [MEM_AW-1:0]   addr_cnt_mem                                            ; // Single Memory address
wire                mem_clk, mem_rst_n, mem_en                              ; 
wire                mem_we                                                  ; 
// Registered Signals
reg  [BANK_ARRAY_AW-1:0] mem_bank_pt_r                                      ;
reg                 tx_and_cnt_r, tx_and_rst_r                              ;
reg                 mem_pipe_last_r                                         ;
reg                 resetting_r                                             ;
reg                 round_last_r, smp_cnt_en_r                              ;
reg  [31:0]         epoch_cnt_r, round_cnt_r, smp_epoch_cnt_r, smp_cnt_r    ;
// Control State
reg [3:0] averager_st, averager_st_nxt;
wire data_updt;

// For cycles index
integer ind_data, ind_pipe;

///////////////////////////////////////////////////////////////////////////////
// Samples and Rounds
/* 4 Ways to transmit:
1- tx_and_cnt_i         = 1            External signal to transmit and keep Memory values
2- tx_and_rst_i         = 1            External signal to transmit and reset Memory
3- usr_round_samples_i  = sample_cnt   Number of Samples in current Round, arrive to maximum set by user
4- usr_epoch_rounds_i   = round_cnt    Number of Rounds  in current Epoch, arrive to maximum set by user
*/

///////////////////////////////////////////////////////////////////////////////
// CONTROL PRE-PROCESSING
always @ (posedge s_axis_aclk or negedge s_axis_aresetn) begin : CTRL_PRE_PROC
   if (!s_axis_aresetn) begin
      round_last_r              <= 0;
      smp_cnt_en_r              <= 0;
      tx_and_cnt_r              <= 0;
      tx_and_rst_r              <= 0;
      tx_and_cnt_req            <= 1'b0;
      tx_and_rst_req            <= 1'b0;
      mem_pipe_last_r           <= 1'b0;
      resetting_r               <= 1'b0;
      end
   else begin 
      if (working) begin
          round_last_r              <= round_last;
          smp_cnt_en_r              <= smp_cnt_en;
          tx_and_cnt_r              <= tx_and_cnt_i          ;
          tx_and_rst_r              <= tx_and_rst_i          ;
          resetting_r               <= resetting;
          mem_pipe_last_r           <= mem_pipe_last      ;
          if ( tx_and_rst_t01 | (round_last & (tx_and_cnt_t01 | smp_last) ) )  
             tx_and_rst_req         <= 1'b1 ;
          else if ( tx_and_cnt_t01 | smp_last )                  
             tx_and_cnt_req         <= 1'b1 ;
          if (data_updt) begin 
             tx_and_cnt_req         <= 1'b0;
             tx_and_rst_req         <= 1'b0;
          end
       end
   end
end

// External Rising Edge detection
assign tx_and_cnt_t01   =  ~tx_and_cnt_r  & tx_and_cnt_i        ; // Rising of tx_and_cnt_i          
assign tx_and_rst_t01   =  ~tx_and_rst_r & tx_and_rst_i         ; // Rising of tx_and_rstrt_i          

assign goto_transmit    = ( tx_and_cnt_req | tx_and_rst_req ) & smp_cnt_en & accumulating  ;

// Address Counter
assign data_updt        = pipe_acc_in_waiting & mem_pipe_last ;
assign addr_cnt_bin_en  = (pipe_acc_in_waiting | accumulating) & s_axis_tvalid ;
assign addr_cnt_tx_en   = pipe_tx_in_waiting  | (transmitting & m_axis_tready & !pipe_tx_out_waiting & !meta_data);
assign addr_cnt_rst_en  = resetting            ;
assign addr_cnt_en      = addr_cnt_bin_en | addr_cnt_tx_en | addr_cnt_rst_en;
assign addr_rst_last    =  &addr_cnt_mem & resetting      ;  // End of Memory (Last single Memory reached)
assign addr_bin_last    = ( NUM_OF_BINS-1   == addr_cnt ) & accumulating      ;  // End of BIN    (Last Bin Received) 
assign addr_tx_last     = ( BANK_MEM_SIZE-1 == addr_cnt ) & transmitting & m_axis_tready     ;  // Transmit last data in memory
assign addr_last        = ( addr_rst_last | addr_bin_last | addr_tx_last ) & mem_en ;
assign addr_cnt_mem     = addr_cnt[MEM_AW-1:0]       ;
assign addr_cnt_rst     = addr_last | pipe_acc_out_waiting                               ; 
// Sample Counter
assign smp_cnt_en       = addr_bin_last & addr_cnt_bin_en ; //!transmitting  & !resetting      ; //  
assign smp_last         = ( usr_round_samples_i <= smp_cnt_p1 ) ;  // End of ROUND  (Last Number of Sample) 
assign smp_cnt_rst      = goto_transmit                         ;
// Round Counter
assign round_cnt_en     = data_updt  ;   
assign round_last       = (usr_epoch_rounds_i <= round_cnt) ; 
assign round_cnt_rst    = round_cnt_en & tx_and_rst_req ;
// Epoch Counter
assign epoch_cnt_en     = round_cnt_rst;
// Memory Pipeline Counter
assign mem_pipe_cnt_en  = ( (pipe_acc_in_waiting | pipe_acc_out_waiting) & s_axis_tvalid) | pipe_tx_in_waiting | pipe_tx_out_waiting & m_axis_tready ;
assign mem_pipe_last    = ( MEM_PIPE+1 == mem_pipe_cnt )        ;  // Mem PIPE FULL
assign mem_pipe_cnt_rst = (mem_pipe_last | mem_pipe_last_r) & ( !pipe_tx_out_waiting | (pipe_tx_out_waiting & m_axis_tready) )    ;
// Memory Signals 
assign mem_clk          = s_axis_aclk;
assign mem_rst_n        = s_axis_aresetn;
assign mem_en           = (resetting | resetting_r) | addr_cnt_bin_en | pipe_tx_in_waiting | (transmitting & m_axis_tready );
assign mem_addr_usr     = pipe_acc_in_waiting | (accumulating & ! pipe_acc_out_waiting) ;
assign mem_bank_pt      = (BANK_ARRAY_AW > 0) ? mem_addr_pipe[MEM_PIPE+1][MEM_AW +: BANK_ARRAY_AW] : 0 ;


///////////////////////////////////////////////////////////////////////////////
// ACCUMULATOR STATE MACHINE
localparam
   ST_IDLE          = 4'b0000, //0
   ST_RST_MEM       = 4'b0001, //1
   ST_SYNC          = 4'b0010, //2
   ST_ACC_PIPE_IN   = 4'b1010, //10
   ST_ACCUMULATING  = 4'b0100, //4
   ST_ACC_PIPE_OUT  = 4'b1011, //11
   ST_TX_PIPE_IN    = 4'b1100, //12
   ST_TXING         = 4'b0110, //6
   ST_TX_PIPE_OUT   = 4'b1101, //13
   ST_TX_META_OUT   = 4'b1111; //15
   
//  Sequential Logic
always @ (posedge s_axis_aclk or negedge s_axis_aresetn) if (!s_axis_aresetn)  averager_st <=  ST_IDLE; else averager_st <=  averager_st_nxt;

// Combinational Logic (OUTPUT and STATE CHANGE)
always @ (averager_st, process_i, goto_transmit, s_axis_tlast,addr_tx_last,  addr_rst_last, mem_pipe_last, mem_pipe_last_r, tx_and_rst_req, m_axis_tready) begin : CNT_UPDATE_ST
   averager_st_nxt      = averager_st;  // default is to stay in current state
   accumulating         = 1'b0;
   transmitting         = 1'b0;
   resetting            = 1'b0;
   meta_data            = 1'b0;
   pipe_acc_in_waiting  = 1'b0;
   pipe_tx_in_waiting   = 1'b0;
   pipe_acc_out_waiting = 1'b0;
   pipe_tx_out_waiting  = 1'b0;
   working              = 1'b1;
   case (averager_st)
      ST_IDLE : begin
      working = 1'b0;;
         if      (process_i)     averager_st_nxt = ST_RST_MEM;
      end
      ST_RST_MEM : begin
        resetting = 1'b1;
         if (addr_rst_last) averager_st_nxt = ST_SYNC;
      end
      ST_SYNC : begin
         if      (s_axis_tlast)  averager_st_nxt = ST_ACC_PIPE_IN;
         else if (!process_i)    averager_st_nxt = ST_IDLE;
      end
      ST_ACC_PIPE_IN : begin
         pipe_acc_in_waiting        = 1'b1;
         if (mem_pipe_last_r)   averager_st_nxt = ST_ACCUMULATING;
      end
      
      ST_ACCUMULATING : begin
         accumulating = 1'b1;
         if (goto_transmit)   averager_st_nxt = ST_ACC_PIPE_OUT;
      end
      ST_ACC_PIPE_OUT : begin
         pipe_acc_out_waiting        = 1'b1;
         accumulating = 1'b1;
         if (mem_pipe_last_r) averager_st_nxt = ST_TX_PIPE_IN;
      end
      ST_TX_PIPE_IN : begin
         pipe_tx_in_waiting        = 1'b1;
         if (mem_pipe_last) averager_st_nxt = ST_TXING;
      end
      
      ST_TXING : begin
         transmitting = 1'b1;
         if (addr_tx_last)      averager_st_nxt = ST_TX_PIPE_OUT;
      end
      ST_TX_PIPE_OUT : begin
         transmitting = 1'b1;
         pipe_tx_out_waiting    = 1'b1;
         if (m_axis_tready & mem_pipe_last)   averager_st_nxt = ST_TX_META_OUT;
      end
      ST_TX_META_OUT : begin
         transmitting = 1'b1;
         meta_data = 1'b1;
         if (m_axis_tready) begin
            if (!process_i)      averager_st_nxt = ST_IDLE;
            else if (tx_and_rst_req)  averager_st_nxt = ST_RST_MEM;
            else averager_st_nxt = ST_SYNC;
         end
      end
      endcase 
end

///////////////////////////////////////////////////////////////////////////////
// COUNTERS

// MEMORY ADDRES COUNTER
always @ (posedge s_axis_aclk or negedge s_axis_aresetn) begin
   if (!s_axis_aresetn)
      addr_cnt <= 0;
   else begin
      if      ( addr_cnt_rst )   addr_cnt  <= 0; 
      else if ( addr_cnt_en  )   addr_cnt  <= addr_cnt + 1'b1;;
   end
end

// SAMPLE, ROUND & EPOCH COUNTER
assign smp_cnt_p1        = smp_cnt + 1'b1;
assign smp_epoch_cnt_p1  = smp_epoch_cnt + 1'b1;

always @ (posedge s_axis_aclk) begin
   if (!s_axis_aresetn) begin
      mem_pipe_cnt  <= 0;
      smp_cnt       <= 0;
      round_cnt     <= 0;
      smp_epoch_cnt <= 0;
      epoch_cnt     <= 0;
   end else
      if (mem_pipe_cnt_rst) mem_pipe_cnt   <= 0; else if  (mem_pipe_cnt_en) mem_pipe_cnt  <= mem_pipe_cnt + 1'b1;;
      if (smp_cnt_rst)      smp_cnt        <= 0; else if  (smp_cnt_en)      smp_cnt       <= smp_cnt_p1;
      if (round_cnt_rst)    smp_epoch_cnt  <= 0; else if  (smp_cnt_en)      smp_epoch_cnt <= smp_epoch_cnt_p1;
      if (round_cnt_rst)    round_cnt      <= 1; else if  (round_cnt_en)    round_cnt     <= round_cnt + 1'b1;;
      if (epoch_cnt_en)     epoch_cnt <= epoch_cnt + 1'b1;
  end

///////////////////////////////////////////////////////////////////////////////
// MEMORY PIPELINE DELAY
wire [FFT_AW-1:0] tuser_adj_addr;
wire [NUM_OF_INPUTS*BIN_DW-1:0] data_i_array_in, data_q_array_in ;
reg [BIN_DW-1:0] i_in, q_in;
wire mem_addr_bin_store;

assign tuser_adj_addr     = { !s_axis_tuser[FFT_AW-1] , s_axis_tuser[FFT_AW-2:0] }; // Negate the Most Significative BIT
assign mem_addr_bin_store = tuser_adj_addr[FFT_AW-1] ^ tuser_adj_addr[FFT_AW-2] ;
assign data_i_array_in    = s_axis_tdata [ (NUM_OF_INPUTS*BIN_DW)-1 : 0] ;
assign data_q_array_in    = s_axis_tdata [ (2*NUM_OF_INPUTS*BIN_DW)-1 : (NUM_OF_INPUTS*BIN_DW)] ;
assign mem_we         = accumulating & bin_mem_store | resetting_r;
 
always @ (mem_addr_usr,  tuser_adj_addr, addr_cnt) begin
  if (mem_addr_usr) //
     if (FFT_STORE == 0) 
        mem_addr    = {1'b1, { {BANK_MEM_AW-MEM_AW{1'b0}} ,  tuser_adj_addr  }} ;
     else
        mem_addr    = {mem_addr_bin_store, { {BANK_MEM_AW-MEM_AW{1'b0}} ,  tuser_adj_addr[FFT_AW-1]  , tuser_adj_addr[FFT_AW-3:0]}} ;
  else 
        mem_addr    = {1'b0, addr_cnt} ;
end

///////////////////////////////////////////////////////////////////////////////
// ADDRESS and DATA PILELINE
always @ (posedge mem_clk) begin
   if (mem_en) begin
      mem_addr_pipe[0] <= mem_addr;
      for (ind_data = 0; ind_data <= NUM_OF_INPUTS-1; ind_data = ind_data+1) begin
         if (IQ_FORMAT == 0) begin 
            // IIII QQQQ
            i_in = data_i_array_in[ind_data * BIN_DW +: BIN_DW];
            q_in = data_q_array_in[ind_data * BIN_DW +: BIN_DW];
            mem_dt_pipe[ind_data][0] <= {i_in, q_in} ;
         end else
            // IQ IQ IQ IQ
            mem_dt_pipe[ind_data][0] <= s_axis_tdata[ind_data * AXIS_IN_DW +: AXIS_IN_DW];
      end
      for (ind_pipe = 1; ind_pipe <= MEM_PIPE; ind_pipe = ind_pipe+1) begin
         mem_addr_pipe[ind_pipe]  <= mem_addr_pipe[ind_pipe-1];
         for (ind_data = 0; ind_data <= NUM_OF_INPUTS-1; ind_data = ind_data+1)
            mem_dt_pipe[ind_data][ind_pipe] <= mem_dt_pipe[ind_data][ind_pipe-1];
      end
      mem_addr_pipe[MEM_PIPE+1] <= mem_addr_pipe[MEM_PIPE];
    end
end
    
// PIPELINE LAST STAGE
always @ (posedge mem_clk) begin
   if (!s_axis_aresetn) begin
      mem_addr_w_r     <= 0;
      mem_bank_pt_r      <= 0;
   end else if (mem_en) begin
      if (resetting)
         mem_addr_w_r  <=  addr_cnt;
      else begin
         bin_mem_store   <= mem_addr_pipe[MEM_PIPE+1][BANK_MEM_AW];
         mem_addr_w_r  <= mem_addr_pipe[MEM_PIPE+1][MEM_AW-1:0] ;
      end
      mem_bank_pt_r         <= mem_bank_pt; 
   end
end    

///////////////////////////////////////////////////////////////////////////////
// DATA PROCESSING - ACCUMULATE
reg signed [BIN_DW-1 : 0] data_i_fft  [NUM_OF_INPUTS-1:0] ;
reg signed [BIN_DW-1 : 0] data_q_fft  [NUM_OF_INPUTS-1:0] ;
//reg signed [AXIS_IN_DW-1 : 0] data_i2_fft [NUM_OF_INPUTS-1:0] ;
//reg signed [AXIS_IN_DW-1 : 0] data_q2_fft [NUM_OF_INPUTS-1:0] ;
reg  [AXIS_IN_DW : 0] data_i2_fft [NUM_OF_INPUTS-1:0] ;
reg  [AXIS_IN_DW : 0] data_q2_fft [NUM_OF_INPUTS-1:0] ;

reg [MEM_DW-1 : 0] smp_dt      [NUM_OF_INPUTS-1:0] ;

//One Cycle to SQUARE + ONE Cycel TO ADD (i+q) + One cycle to Accumulate  
always @ (posedge mem_clk) begin
   if (mem_en) begin
       for (ind_data = 0; ind_data <= NUM_OF_INPUTS-1; ind_data = ind_data+1) begin
          data_i_fft[ind_data]   <= mem_dt_pipe[ind_data][MEM_PIPE-2][BIN_DW-1 : 0]        ;
          data_i2_fft[ind_data]  <= data_i_fft[ind_data] * data_i_fft[ind_data]  ;
          data_q_fft[ind_data]   <= mem_dt_pipe[ind_data][MEM_PIPE-2][AXIS_IN_DW-1:BIN_DW]        ;
          data_q2_fft[ind_data]  <= data_q_fft[ind_data] * data_q_fft[ind_data]  ;
          //smp_dt    [ind_data]   <= data_i2_fft[ind_data][AXIS_IN_DW-2:0] + data_q2_fft[ind_data][AXIS_IN_DW-2:0] ;
          smp_dt    [ind_data]   <= data_i2_fft[ind_data] + data_q2_fft[ind_data];
          if (resetting) 
             mem_w_data[ind_data]    <= 0;
          else
             mem_w_data[ind_data]    <= smp_dt[ind_data] + mem_r_data[ind_data];
       end
    end
end

///////////////////////////////////////////////////////////////////////////////
// MEMORY BANK INSTANCE 
  
bank_mem_uram #(
   .BANK_ARAY_QTY ( BANK_ARAY_QTY ) ,
   .BANK_MEM_AW   ( BANK_MEM_AW   ) ,
   .MEM_AW        ( MEM_AW        ) ,
   .MEM_DW        ( MEM_DW        ) ,
   .MEM_PIPE      ( MEM_PIPE-1    )
  ) uram_inst (
   .clk_i         ( mem_clk        ) ,
   .rst_ni        ( mem_rst_n      ) ,
   .mem_en_i      ( mem_en         ) ,
   .we_i          ( mem_we         ) ,
   .w_addr_i      ( mem_addr_w_r   ) ,
   .w_data_i      ( mem_w_data     ) ,
   .r_addr_i      ( mem_addr[MEM_AW-1:0]      ) ,
   .r_data_o      ( mem_r_data      ) );
   
///////////////////////////////////////////////////////////////////////////////
// OUTPUT ASSIGNMENT
 
// OUT REGISTERS
always @ (posedge s_axis_aclk or negedge s_axis_aresetn) begin
   if (!s_axis_aresetn) begin
      round_cnt_r       <= 0;
      epoch_cnt_r       <= 0;
      smp_cnt_r         <= 0;
      smp_epoch_cnt_r   <= 0;
      
   end else if (goto_transmit) begin 
      round_cnt_r       <= round_cnt;
      epoch_cnt_r       <= epoch_cnt;
      smp_cnt_r         <= smp_cnt_p1;
      smp_epoch_cnt_r   <= smp_epoch_cnt_p1;
   end
end


// OUT ASSIGNMENT
assign round_cnt_o    = round_cnt_r                   ;
assign epoch_cnt_o    = epoch_cnt_r                   ;
assign m_axis_tdata   = meta_data ? {epoch_cnt_r, round_cnt_r, smp_epoch_cnt_r, smp_cnt_r } : mem_r_data [mem_bank_pt]  ;
assign m_axis_tlast   = meta_data                     ;
assign m_axis_tvalid  = transmitting                  ;
//assign s_axis_tready  = !(transmitting | resetting)   ;
assign s_axis_tready  = 1'b1 ;
assign transmit_o     = transmitting ;

// Debug Size 16
// averager_st 4
// mem_addr_w_r 4
// smp_cnt_r 4

assign debug_o        = {averager_st, smp_cnt_r[3:0], addr_cnt[3:0], mem_addr_w_r[3:0]}  ;
endmodule
