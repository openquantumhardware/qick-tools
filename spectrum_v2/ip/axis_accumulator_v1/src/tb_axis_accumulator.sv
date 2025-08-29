import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
//  Date           : 4-2022
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
//Description:  Constraints 
///////////////////////////////////////////////////////////////////////////////

`include "acc_defines.v"


module tb_axis_accumulator ;  

  reg clk_i, rst_ni;
  reg process_i        ;
  reg tx_and_cnt_i, tx_and_rst_i;
  reg [31 : 0]          usr_round_samples_i, usr_epoch_rounds_i ;

  reg [`AXIS_IN_DW-1:0]       max_value_i     ;
  reg start_i;
  reg en_i;
//AXI-LITE
wire                   s_axi_aclk       ;
wire                   s_axi_aresetn    ;
wire [5:0]             s_axi_awaddr     ;
wire [2:0]             s_axi_awprot     ;
wire                   s_axi_awvalid    ;
wire                   s_axi_awready    ;
wire [31:0]            s_axi_wdata      ;
wire [3:0]             s_axi_wstrb      ;
wire                   s_axi_wvalid     ;
wire                   s_axi_wready     ;
wire  [1:0]            s_axi_bresp      ;
wire                   s_axi_bvalid     ;
wire                   s_axi_bready     ;
wire [5:0]             s_axi_araddr     ;
wire [2:0]             s_axi_arprot     ;
wire                   s_axi_arvalid    ;
wire                   s_axi_arready    ;
wire  [31:0]           s_axi_rdata      ;
wire  [1:0]            s_axi_rresp      ;
wire                   s_axi_rvalid     ;
wire                   s_axi_rready     ;

//AXI-STREAM
  wire [`AXIS_OUT_DW-1:0]  m_axis_tdata    ;
  wire                     m_axis_tlast    ;
  reg                      m_axis_tready   ;
  wire                     m_axis_tvalid   ;
//
  wire [`AXIS_IN_DW/2-1:0]  r_axis_tdata   ;
  wire [`AXIS_IN_DW/2-1:0]  r_axis_tuser    ;
  wire                      r_axis_tlast    ;
  wire                      r_axis_tready   ;
  wire                      r_axis_tvalid   ;
//
  wire                      s_axis_tready   ;
  wire [`AXIS_IN_DW/2-1:0]  s0_axis_tdata   ;
  wire [`AXIS_IN_DW/2-1:0]  s_axis_tuser    ;

  wire [`AXIS_IN_DW*`NUM_OF_INPUTS-1:0]  s_axis_tdata  ;
  
  wire [31:0] state_do ;
  wire process_do, transmitting_do ;
  
// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data_wr     = 32'h12345678;
reg[31:0]       data;
xil_axi_resp_t  resp;


//////////////////////////////////////////////////////////////////////////
//  CLK Generation

`define T_CLK         2.6     // Clock Period
initial begin
  clk_i = 1'b0; // Clock without Jitter
  forever # (`T_CLK/2) clk_i = ~clk_i;
end

`define T_EN_VALID         26     // Clock Period
initial begin
  en_i = 1'b1;
  forever begin
      # (`T_EN_VALID/2)
      @ (posedge clk_i); #0.1;
      en_i = 1'b1;
      @ (posedge clk_i); #0.1;
      //en_i = 1'b0;
  end
end

always @ (posedge clk_i)
begin
   if (!rst_ni)
      m_axis_tready      <= 1'b1;
   else
       if (!m_axis_tready) @ (posedge clk_i); #0.1;
       m_axis_tready         <= m_axis_tready;
       m_axis_tready         <= 1'b1;
end  

  assign s_axi_aclk     = clk_i;
  assign s_axi_aresetn  = rst_ni;
  
 
axi_mst_0 axi_mst_0_i
	(
		.aclk			(s_axi_aclk		),
		.aresetn		(s_axi_aresetn	),
		.m_axi_araddr	(s_axi_araddr	),
		.m_axi_arprot	(s_axi_arprot	),
		.m_axi_arready	(s_axi_arready	),
		.m_axi_arvalid	(s_axi_arvalid	),
		.m_axi_awaddr	(s_axi_awaddr	),
		.m_axi_awprot	(s_axi_awprot	),
		.m_axi_awready	(s_axi_awready	),
		.m_axi_awvalid	(s_axi_awvalid	),
		.m_axi_bready	(s_axi_bready	),
		.m_axi_bresp	(s_axi_bresp	),
		.m_axi_bvalid	(s_axi_bvalid	),
		.m_axi_rdata	(s_axi_rdata	),
		.m_axi_rready	(s_axi_rready	),
		.m_axi_rresp	(s_axi_rresp	),
		.m_axi_rvalid	(s_axi_rvalid	),
		.m_axi_wdata	(s_axi_wdata	),
		.m_axi_wready	(s_axi_wready	),
		.m_axi_wstrb	(s_axi_wstrb	),
		.m_axi_wvalid	(s_axi_wvalid	)
	);
	
axis_cnt #(
   .AXIS_DW	(`AXIS_IN_DW/2		) ,
   .FFT_AW	(`FFT_AW		)
) axis_cnt_inst0 (
   .range_i          (  max_value_i     ) ,
   .offset_i         (  -7        ) ,
   .start_i          (  start_i         ) ,
   .en_i             (  en_i         ) ,
   .m_axis_aclk      (  clk_i     ) ,
   .m_axis_aresetn   (  rst_ni    ) ,
   .m_axis_tdata     (  s0_axis_tdata   ) ,
   .m_axis_tuser     (  s_axis_tuser    ) ,
   .m_axis_tlast     (  s_axis_tlast    ) ,
   .m_axis_tready    (  s_axis_tready   ) ,
   .m_axis_tvalid    (  s_axis_tvalid   ) );


genvar ind_data;
generate
   for (ind_data = 0; ind_data <= `NUM_OF_INPUTS-1; ind_data = ind_data+1) begin
      //assign s_axis_tdata[ind_data * (`AXIS_IN_DW) +: (`AXIS_IN_DW) ] = { { 2 { ind_data + s0_axis_tdata } } };
      // I ASSIGN
      assign s_axis_tdata[(2*ind_data) * (`AXIS_IN_DW/2) +: (`AXIS_IN_DW/2) ] =  s0_axis_tdata;
      // Q ASSIGN
      assign s_axis_tdata[(2*ind_data+1) * (`AXIS_IN_DW/2) +: (`AXIS_IN_DW/2) ] = s0_axis_tdata+ind_data[`AXIS_IN_DW/2-1:0];
   end
endgenerate

axis_accumulator #(
        .AXIS_IN_DW       ( `AXIS_IN_DW      ) , 
        .AXIS_OUT_DW      ( `AXIS_OUT_DW     ) , 
        .FFT_AW           ( `FFT_AW         ) , 
        .BANK_ARRAY_AW    ( `BANK_ARRAY_AW   ) , 
        .MEM_DW           ( `MEM_DW           ) , 
        .MEM_PIPE         ( `MEM_PIPE	         ) , 
        .FFT_STORE        ( `FFT_STORE          ) 
  ) axis_accumulator_inst (
   .s_axi_aclk          ( s_axi_aclk           ) ,
   .s_axi_aresetn       ( s_axi_aresetn        ) ,
   .s_axi_awaddr        ( s_axi_awaddr         ) ,
   .s_axi_awprot        ( s_axi_awprot         ) ,
   .s_axi_awvalid       ( s_axi_awvalid        ) ,
   .s_axi_awready       ( s_axi_awready        ) ,
   .s_axi_wdata         ( s_axi_wdata          ) ,
   .s_axi_wstrb         ( s_axi_wstrb          ) ,
   .s_axi_wvalid        ( s_axi_wvalid         ) ,
   .s_axi_wready        ( s_axi_wready         ) ,
   .s_axi_bresp         ( s_axi_bresp          ) ,
   .s_axi_bvalid        ( s_axi_bvalid         ) ,
   .s_axi_bready        ( s_axi_bready         ) ,
   .s_axi_araddr        ( s_axi_araddr         ) ,
   .s_axi_arprot        ( s_axi_arprot         ) ,
   .s_axi_arvalid       ( s_axi_arvalid        ) ,
   .s_axi_arready       ( s_axi_arready        ) ,
   .s_axi_rdata         ( s_axi_rdata          ) ,
   .s_axi_rresp         ( s_axi_rresp          ) ,
   .s_axi_rvalid        ( s_axi_rvalid         ) ,
   .s_axi_rready        ( s_axi_rready         ) ,
   .axis_aclk           ( clk_i          ) ,
   .axis_aresetn        ( rst_ni         ) ,
   .s_axis_tready       ( s_axis_tready        ) ,
   .s_axis_tdata        ( s_axis_tdata         ) ,
   .s_axis_tuser        ( s_axis_tuser         ) ,
   .s_axis_tvalid       ( s_axis_tvalid        ) ,
   .s_axis_tlast        ( s_axis_tlast         ) ,
   .m_axis_tdata        ( m_axis_tdata         ) ,
   .m_axis_tvalid       ( m_axis_tvalid        ) ,
   .m_axis_tlast        ( m_axis_tlast         ) ,
   .m_axis_tready       ( m_axis_tready        ) ,
   .state_do            ( state_do             ) ,
   .process_do          ( process_do           ) ,
   .transmitting_do     ( transmitting_do      ) );

 integer ind;
 initial begin
    $display("NUM_OF_BINS %d",  `NUM_OF_BINS);
    $display("NUM_OF_INPUTS %d",  `NUM_OF_INPUTS);
    $display("MEM_AW %d",  `MEM_AW);
    $display("MEM_SIZE %d",  `MEM_SIZE);
    $display("BANK_ARAY_QTY %d",  `BANK_ARAY_QTY);
    $display("BANK_MEM_AW %d",  `BANK_MEM_AW);
    $display("BANK_MEM_SIZE %d",  `BANK_MEM_SIZE);
    //$dumpfile("dumpvar.vcd");
    //$dumpvars();
 
  	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb_axis_accumulator.axi_mst_0_i.inst.IF);
	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag	("axi_mst_0 VIP");
	// Start agents.
	axi_mst_0_agent.start_master();
  
	rst_ni        = 1'b0;
    process_i     = 1'b0;
    tx_and_cnt_i  = 1'b0;
    tx_and_rst_i  = 1'b0;
    max_value_i   = `NUM_OF_BINS;
    start_i       = 1'b0;
    @ (posedge clk_i); #1;
	rst_ni = 1'b1;


  	// usr_round_samples_i.
   usr_round_samples_i = 2;
	data_wr = usr_round_samples_i;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(12, prot, data_wr, resp);
	#10;

    // usr_epoch_rounds_i
    usr_epoch_rounds_i  = 5;
	data_wr = usr_epoch_rounds_i;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(16, prot, data_wr, resp);
	#10;


    @ (posedge clk_i); #1;
    start_i       = 1'b1;

    // PROCESS_I
    process_i     = 1'b1;
	data_wr = 1;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(0, prot, data_wr, resp);

	#10000;

    @ (negedge m_axis_tlast); #1;  
    @ (posedge clk_i); #1;
  	// usr_round_samples_i.
    usr_round_samples_i = 30;
	data_wr = 30;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(12, prot, data_wr, resp);

	#3000;

    @ (negedge m_axis_tlast); #1;  
    @ (posedge clk_i); #1;
    // usr_epoch_rounds_i
    usr_epoch_rounds_i  = 20;
	data_wr = 10;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(16, prot, data_wr, resp);
	#10;

	#3000;
    @ (negedge m_axis_tlast); #1;  
	#1000;
    @ (posedge clk_i); #1;
    // TX AND CONTINUE
	data_wr = 1;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4, prot, data_wr, resp);

	#3500;
    @ (negedge m_axis_tlast); #1;  
	#1000;
    @ (posedge clk_i); #1;
    // TX AND RST
	data_wr = 1;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(8, prot, data_wr, resp);
	#10;

	#35000;

    @ (negedge m_axis_tlast); #1;  
    @ (posedge clk_i); #1;
    // usr_epoch_rounds_i
    usr_epoch_rounds_i  = 2;
	data_wr = 2;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(16, prot, data_wr, resp);


//   for (ind=500; ind<10000; ind=ind + 1000) begin
//      #ind;
//      //TASK_cmd_TC;
//      @ (posedge clk_i); #1;
//      @ (m_axis_tvalid==1'b1);
//      #300;
//      @ (posedge clk_i); #1;
//      //m_axis_tready = 1'b0;
//      #500;
//      @ (posedge clk_i); #1;
//      //m_axis_tready = 1'b1;
//    end

//   for (ind=700; ind<20000; ind=ind + 7000) begin
//      #ind;
//      TASK_cmd_TR;
//      @ (m_axis_tvalid==1'b1);
//      #3000;
//      m_axis_tready = 1'b0;
//      #500;
//      @ (posedge clk_i);
//      m_axis_tready = 1'b1;
//    end

	#100000000;

    $finish;
  end

task TASK_cmd_TC; begin
   $display("Transmit and Continue Command sent");
	#250;
    @ (posedge clk_i); #1;
    tx_and_cnt_i = 1'b1;
	#250;
    @ (posedge clk_i); #1;
    tx_and_cnt_i = 1'b0;
    end
endtask
task TASK_cmd_TR; begin
   $display("Transmit and Reset Command sent");
	#250;
    @ (posedge clk_i); #1;
    tx_and_rst_i = 1'b1;
	#250;
    @ (posedge clk_i); #1;
    tx_and_rst_i = 1'b0;
    end
endtask

endmodule