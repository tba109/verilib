///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue Mar 26 12:05:56 EDT 2019
//
// ft232r_hs.v
//
// Adapts serializer and deserializer modules for 4 phase handshaking (FPGA side) to FT232R USB UART.
// 
// This module allows hardware handshaking on incoming transmission from the FT232. 
// There is no provision for handshaking outgoing data (to the FT232). 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module ft232r_hs
  (
   input 	clk,
   input 	rst,
   // FT232R interface
   input 	txd, // transmitted data FT232R to FPGA 
   output 	rxd, // received data FPGA to FT232R
   input 	rts_n, // request to send (active low) FPGA to FT232R
   output reg 	cts_n=1, // clear to send (active low) FT232R to FPGA 
   // Internal interface (FPGA logic) 
   input 	wr_req, // logic asserts to requests to write data to FT232R
   output 	wr_ack, // logic is signaled with acknowledge of write request to FT232R
   input [7:0] 	wr_data, // data to be written to FT232R
   output reg 	rd_req=0, // request logic read new data from FT232R
   input 	rd_ack, // logic acknowledges reading of data from FT232R
   output [7:0] rd_data // data read from FT232
   );

   /////////////////////////////////////////////////////////////////////////////////////////////////
   // Internals
   wire 	i_ser_en; 
   wire 	i_des_done; 
   parameter P_CLK_FREQ_HZ = 100000000;
   parameter P_BAUD_RATE = 3000000;

   /////////////////////////////////////////////////////////////////////////////////////////////////
   // Serializer. tx was written in the port names from an FPGA centric view (i.e.,
   // transmitting from the FPGA to the outside world). 
   rs232_ser #(.P_CLK_FREQ_HZ(P_CLK_FREQ_HZ),.P_BAUD_RATE(P_BAUD_RATE)) RS232_SER_0
     (
      // Outputs
      .tx			(rxd),
      .tx_fifo_rd_en		(),
      .done                     (wr_ack),
      // Inputs
      .clk			(clk),
      .rst_n			(!rst),
      .tx_fifo_data		(wr_data),
      .tx_fifo_empty		(!i_ser_en)
      );
   posedge_detector PEDGE_0(.clk(clk),.rst_n(!rst),.a(wr_req),.y(i_ser_en));

   /////////////////////////////////////////////////////////////////////////////////////////////////
   // Deserializer
   rs232_des #(.P_CLK_FREQ_HZ(P_CLK_FREQ_HZ),.P_BAUD_RATE(P_BAUD_RATE)) RS232_DES_0
     (
      // Outputs
      .rx_fifo_data		(rd_data),
      .rx_fifo_wr_en		(i_des_done),
      // Inputs
      .clk			(clk),
      .rst_n			(!rst),
      .rx			(txd),
      .rx_fifo_full		(1'b0)
      ); 
   // This requires slightly more translation:
   // 1.) cts_n idles low, rts_n asserts and go to S1. Otherwise, jump directly to S2 (no handshaking). 
   // 2.) data is received. cts_n is transitioned high by i_des_done. 
   // 3.) rd_req asserts. when rd_ack, return to S0. 
   localparam
     S0=0,
     S1=1,
     S2=2;
   reg [1:0] 	fsm=S0;
   wire 	rd_ack_ne; 
   negedge_detector NEDGE_0(.clk(clk),.rst_n(!rst),.a(rd_ack),.y(rd_ack_ne)); 
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  fsm <= 0;
	  rd_req <= 0;
	  cts_n <= 0; 
       end
     else
       case(fsm)
	 S0:
	   begin
	      rd_req <= 0; 
	      cts_n <= 0;
	      if(!rts_n) // rs232 flow control is being used
		fsm <= S1; // rs232 flow control is bypassed
	      else if(i_des_done)
		fsm <= S2; 
	   end
	 
	 S1:
	   begin
	      if(i_des_done)
		begin
		   cts_n <= 1; 
		   fsm <= S2;
		end
	   end
	 
	 S2:
	   begin
	      rd_req <= 1;
	      if(rd_ack)
		rd_req <= 0;
	      if(rd_ack_ne)
		begin
		   rd_req <= 0;
		   fsm <= S0;
		end
	   end
	     
	 default: fsm <= S0;
       
       endcase // case (fsm)

   
   
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../rs232_des/" "../rs232_ser/" "../posedge_detector")
// End:
