///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
//  Date           : 6-2022
//  Versi?n        : 5
///////////////////////////////////////////////////////////////////////////////
//Description:  Axi Stream Accumulator Verilog Wrapper for IP 
//////////////////////////////////////////////////////////////////////////////

module axis_accumulator #(
  parameter AXIS_IN_DW           = 32  , // AXIS IN Data Widht
  parameter AXIS_OUT_DW          = 128 , // AXIS OUT Data Widht
  parameter FFT_AW               = 15  , // Bins Addresses
  parameter BANK_ARRAY_AW        = 4   , // Bits used to Address BANKS
  parameter MEM_DW               = 72  , // Memory Data Width
  parameter MEM_PIPE             = 6   , // Number of pipeline Registers
  parameter FFT_STORE            = 1   ,  // 0=FULL or 1=HALF FFT
  parameter IQ_FORMAT            = 1     // 0=IIII QQQQor 1=IQ IQ IQ IQ
)  (
  // AXI-Lite DATA Slave I/F.
  input  wire                   s_axi_aclk        ,
  input  wire                   s_axi_aresetn     ,
  input  wire [5:0]             s_axi_awaddr      ,
  input  wire [2:0]             s_axi_awprot      ,
  input  wire                   s_axi_awvalid     ,
  output wire                   s_axi_awready     ,
  input  wire [31:0]            s_axi_wdata       ,
  input  wire [3:0]             s_axi_wstrb       ,
  input  wire                   s_axi_wvalid      ,
  output wire                   s_axi_wready      ,
  output wire  [1:0]            s_axi_bresp       ,
  output wire                   s_axi_bvalid      ,
  input  wire                   s_axi_bready      ,
  input  wire [5:0]             s_axi_araddr      ,
  input  wire [2:0]             s_axi_arprot      ,
  input  wire                   s_axi_arvalid     ,
  output wire                   s_axi_arready     ,
  output wire  [31:0]           s_axi_rdata       ,
  output wire  [1:0]            s_axi_rresp       ,
  output wire                   s_axi_rvalid      ,
  input  wire                   s_axi_rready      ,
  // AXI Stream CLK & RST.
  input wire                    axis_aclk       ,
  input wire                    axis_aresetn    ,
  // AXI Stream Slave I/F.
  input wire [AXIS_IN_DW*(2**BANK_ARRAY_AW)-1:0] s_axis_tdata   ,
  input wire [AXIS_IN_DW/2-1:0] s_axis_tuser      ,
  input wire                    s_axis_tvalid     ,
  input wire                    s_axis_tlast      ,
  output wire                   s_axis_tready     ,
  // AXI Stream Master I/F.                       
  output wire [AXIS_OUT_DW-1:0] m_axis_tdata      ,
  output wire                   m_axis_tvalid     ,
  output wire                   m_axis_tlast      ,
  input  wire                   m_axis_tready     ,
  // DEBUG INTERFACE                       
  output wire  [15:0]          state_do             ,
  output wire                  process_do           ,
  //output wire  [31:0]        round_cnt_do         ,
  //output wire  [31:0]        epoch_cnt_do         ,
  //output wire  [31:0]        usr_round_samples_do ,
  //output wire  [31:0]        usr_epoch_rounds_do  
  output wire                  transmitting_do       );

  wire        PROCESS_R           ;
  wire        TX_AND_CNT_R        ;
  wire        TX_AND_RST_R        ;
  wire [31:0] USR_ROUND_SAMPLES_R ;
  wire [31:0] USR_EPOCH_ROUNDS_R  ;
  wire [15:0] DEBUG_R             ;
  wire [31:0] ROUND_CNT_R         ;
  wire [31:0] EPOCH_CNT_R         ;
  wire        TRANSMITTING_R      ;

  wire        PROCESS_R_SYNC           ;
  wire        TX_AND_CNT_R_SYNC        ;
  wire        TX_AND_RST_R_SYNC        ;
  wire [31:0] USR_ROUND_SAMPLES_R_SYNC ;
  wire [31:0] USR_EPOCH_ROUNDS_R_SYNC  ;
  wire [15:0] DEBUG_R_SYNC             ;
  wire [31:0] ROUND_CNT_R_SYNC         ;
  wire [31:0] EPOCH_CNT_R_SYNC         ;
  wire        TRANSMITTING_R_SYNC      ;

  assign state_do             = DEBUG_R               ;
  assign process_do           = PROCESS_R             ;
  assign transmitting_do      = TRANSMITTING_R        ;
  //assign round_cnt_do         = ROUND_CNT_R           ;
  //assign epoch_cnt_do         = EPOCH_CNT_R           ;
  //assign usr_round_samples_do = USR_ROUND_SAMPLES_R   ;
  //assign usr_epoch_rounds_do  = USR_EPOCH_ROUNDS_R    ;



  ///////////////////////////////////////////////////////////////////////////////
  // Instance System Verilog Module

  // AXI Slave.
  axi_slv_accumulator axi_slv_inst
  (
    .aclk			(s_axi_aclk	 	),
    .aresetn		(s_axi_aresetn	),
    // Write Address Channel.
    .awaddr			(s_axi_awaddr [5:0] 	),
    .awprot			(s_axi_awprot 	),
    .awvalid		(s_axi_awvalid	),
    .awready		(s_axi_awready	),
    // Write Data Channel.
    .wdata			(s_axi_wdata	),
    .wstrb			(s_axi_wstrb	),
    .wvalid			(s_axi_wvalid   ),
    .wready			(s_axi_wready	),
    // Write Response Channel.
    .bresp			(s_axi_bresp	),
    .bvalid			(s_axi_bvalid	),
    .bready			(s_axi_bready	),
    // Read Address Channel.
    .araddr			(s_axi_araddr 	),
    .arprot			(s_axi_arprot 	),
    .arvalid		(s_axi_arvalid	),
    .arready		(s_axi_arready	),
    // Read Data Channel.
    .rdata			(s_axi_rdata	),
    .rresp			(s_axi_rresp	),
    .rvalid			(s_axi_rvalid	),
    .rready			(s_axi_rready	),

    // Registers.
    .PROCESS_O           ( PROCESS_R           ) ,
    .TX_AND_CNT_O        ( TX_AND_CNT_R        ) ,
    .TX_AND_RST_O        ( TX_AND_RST_R        ) ,
    .USR_ROUND_SAMPLES_O ( USR_ROUND_SAMPLES_R ) ,
    .USR_EPOCH_ROUNDS_O  ( USR_EPOCH_ROUNDS_R  ) ,
    .DEBUG_I             ( DEBUG_R_SYNC             ) ,
    .ROUND_CNT_I         ( ROUND_CNT_R_SYNC         ) ,
    .EPOCH_CNT_I         ( EPOCH_CNT_R_SYNC         ) ,
    .TRANSMITTING_I      ( TRANSMITTING_R_SYNC      ) 
  );

  //resync
  synchronizer #(
    .NB(1)
  )(
    .i_clk(axis_aclk) ,
    .i_rstn(axis_aresetn),
    .i_async(PROCESS_R),
    .o_sync(PROCESS_R_SYNC)
  );

  synchronizer #(
    .NB(1)
  )(
    .i_clk(axis_aclk) ,
    .i_rstn(axis_aresetn),
    .i_async(TX_AND_CNT_R),
    .o_sync(TX_AND_CNT_R_SYNC)
  );

  synchronizer #(
    .NB(1)
  )(
    .i_clk(axis_aclk) ,
    .i_rstn(axis_aresetn),
    .i_async(TX_AND_RST_R),
    .o_sync(TX_AND_RST_R_SYNC)
  );

  synchronizer #(
    .NB(32)
  )(
    .i_clk(axis_aclk) ,
    .i_rstn(axis_aresetn),
    .i_async(USR_ROUND_SAMPLES_R),
    .o_sync(USR_ROUND_SAMPLES_R_SYNC)
  );

  synchronizer #(
    .NB(32)
  )(
    .i_clk(axis_aclk) ,
    .i_rstn(axis_aresetn),
    .i_async(USR_EPOCH_ROUNDS_R),
    .o_sync(USR_EPOCH_ROUNDS_R_SYNC)

  );

  synchronizer #(
    .NB(15)
  )(
    .i_clk(s_axi_aclk) ,
    .i_rstn(s_axi_aresetn),
    .i_async(DEBUG_R),
    .o_sync(DEBUG_R_SYNC)
  );

  synchronizer #(
    .NB(32)
  )(
    .i_clk(s_axi_aclk) ,
    .i_rstn(s_axi_aresetn),
    .i_async(ROUND_CNT_R),
    .o_sync(ROUND_CNT_R_SYNC)
  );

  synchronizer #(
    .NB(32)
  )(
    .i_clk(s_axi_aclk) ,
    .i_rstn(s_axi_aresetn),
    .i_async(EPOCH_CNT_R),
    .o_sync(EPOCH_CNT_R_SYNC)
  );

  synchronizer #(
    .NB(1)
  )(
    .i_clk(s_axi_aclk) ,
    .i_rstn(s_axi_aresetn),
    .i_async(TRANSMITTING_R),
    .o_sync(TRANSMITTING_R_SYNC)
  );

  accumulator #(
    .AXIS_IN_DW     ( AXIS_IN_DW    ) , // AXIS IN Data Widht
    .AXIS_OUT_DW    ( AXIS_OUT_DW   ) , // AXIS OUT Data Widht
    .FFT_AW         ( FFT_AW        ) , // ADDRESS IN FFT TUSER
    .BANK_ARRAY_AW  ( BANK_ARRAY_AW ) , // Bits used to Address BANKS
    .MEM_DW         ( MEM_DW        ) , // Memory Data Width
    .MEM_PIPE       ( MEM_PIPE      ) ,  // Number of pipeline Registers
    .FFT_STORE      ( FFT_STORE     ) ,  // 0=FULL or 1=HALF FFT
    .IQ_FORMAT      ( IQ_FORMAT     )   // 0=IIIIQQQQL or 1=IQIQIQIQ
  ) accumulator_inst (
    // FFT - AXI Stream Slave
    .s_axis_aclk        ( axis_aclk           ) ,
    .s_axis_aresetn     ( axis_aresetn        ) ,
    .s_axis_tdata       ( s_axis_tdata          ) ,
    .s_axis_tuser       ( s_axis_tuser          ) ,
    .s_axis_tvalid      ( s_axis_tvalid         ) ,
    .s_axis_tlast       ( s_axis_tlast          ) ,
    .s_axis_tready      ( s_axis_tready         ) ,
    // DMA - AXI Stream Master
    .m_axis_aclk         ( axis_aclk          ) ,
    .m_axis_aresetn      ( axis_aresetn       ) ,
    .m_axis_tdata        ( m_axis_tdata         ) ,
    .m_axis_tvalid       ( m_axis_tvalid        ) ,
    .m_axis_tlast        ( m_axis_tlast         ) ,
    .m_axis_tready       ( m_axis_tready        ) ,
    // REGISTERS - 
    .process_i           ( PROCESS_R_SYNC            ) ,
    .tx_and_cnt_i        ( TX_AND_CNT_R_SYNC         ) ,
    .tx_and_rst_i        ( TX_AND_RST_R_SYNC         ) ,
    .usr_round_samples_i ( USR_ROUND_SAMPLES_R_SYNC  ) ,
    .usr_epoch_rounds_i  ( USR_EPOCH_ROUNDS_R_SYNC   ) ,
    .debug_o             ( DEBUG_R              ) ,
    .round_cnt_o         ( ROUND_CNT_R          ) ,
    .epoch_cnt_o         ( EPOCH_CNT_R          ) ,
    .transmit_o          ( TRANSMITTING_R       ) );


endmodule
