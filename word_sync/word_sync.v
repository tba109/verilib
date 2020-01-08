// Synchronize a word from clock 0 to clock 1
module word_sync #(parameter P_DATA_WIDTH=32, parameter P_N_SYNC=4)
  (
   input clk_0,
   input clk_1,
   input rst,
   input wr,
   input [P_DATA_WIDTH-1:0] data_0,
   output [P_DATA_WIDTH-1:0] data_1
   );

   // Positive edge for wr strobe
   wire 		    wr_pe; 
   posedge_detector PEDGE_0(.clk(clk_0),.rst_n(!rst),.a(wr),.y(wr_pe)); 
   
   // One shot to handle synchronization between modules
   wire 		      req; 
   one_shot #(.P_N_WIDTH(32),.P_IO_WIDTH(1)) ONE_SHOT_0
     (
      .clk(clk_0),
      .rst_n(!rst),
      .trig(wr_pe),
      .n0(0),
      .n1(P_N_SYNC),
      .a0(1'b0),
      .a1(1'b1),
      .busy(),
      .y(req)
      ); 
	
   wire 		      req_s;
   sync SYNC_0(.clk(clk_0),.rst_n(!rst),.a(req),.y(req_s)); 
   hstm #(.P_DATA_WIDTH(32),.P_BUSY_CNT(8)) HSTM_0
     (
      .clk(clk_1),
      .rst_n(!rst),
      .req(req_s),
      .busy(),
      .hstm_data_in(data_0),
      .hstm_data_out(data_1)
      ); 

endmodule
