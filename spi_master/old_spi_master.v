//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed Feb 27 14:38:00 EST 2019
//
// spi_master.v
//
// https://en.wikipedia.org/wiki/Serial_Peripheral_Interface
// CPOL determines the polarity of the clock. The polarities can be converted with a simple 
// inverter.
// -- CPOL=0 is a clock which idles at 0, and each cycle consists of a pulse of 1. That is, the 
//           leading edge is a rising edge, and the trailing edge is a falling edge.
// -- CPOL=1 is a clock which idles at 1, and each cycle consists of a pulse of 0. That is, the 
//           leading edge is a falling edge, and the trailing edge is a rising edge.
// 
// CPHA determines the timing of the data bits relative to the clock pulses. It is not trivial 
// to convert between the two forms. 
//
// For CPHA=0, the "out" side changes the data on the trailing edge of the preceding clock cycle, 
// while the "in" side captures the data on (or shortly after) the leading edge of the clock 
// cycle. The out side holds the data valid until the trailing edge of the current clock cycle. 
// For the first cycle, the first bit must be on the MOSI line before the leading clock edge. An 
// alternative way of considering it is to say that a CPHA=0 cycle consists of a half cycle with 
// the clock idle, followed by a half cycle with the clock asserted.
//
// For CPHA=1, the "out" side changes the data on the leading edge of the current clock cycle, 
// while the "in" side captures the data on (or shortly after) the trailing edge of the clock 
// cycle. The out side holds the data valid until the leading edge of the following clock cycle. 
// For the last cycle, the slave holds the MISO line valid until slave select is deasserted.
// An alternative way of considering it is to say that a CPHA=1 cycle consists of a half cycle 
// with the clock asserted, followed by a half cycle with the clock idle.
//
//////////////////////////////////////////////////////////////////////////////////////////////////

module spi_master
  (
   input 	     clk, // clock
   input 	     rst, // reset
   input 	     cpol, // clock polarity
   input 	     cpha, // clock phase
   input [31:0]      sclk_div, // division of the clock, cycles per clock tick
   input 	     wr_req, // write request
   output reg 	     wr_ack=0, // write acknowledge
   input [31:0]      wr_data, // write data
   input [31:0]      wr_n, // number of bits for read/write
   input 	     rd_req, // read request
   output reg 	     rd_ack=0, // read acknowledge
   output reg [31:0] rd_data=0, // read data
   input [31:0]      rd_n, // number of read bits
   output 	     mosi=0, // master out, slave in
   output 	     sclk=0, // master in, slave out
   input 	     miso // master in, slave out
   );

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Internals
   reg [31:0] 		       sclk_cnt=0;
   reg [31:0] 		       data_cnt=0; 
   reg 			       i_sclk=0;
   reg 			       i_mosi=0; 
   reg [31:0] 		       i_wr_data=0;
   reg [31:0] 		       i_rd_data=0;
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   reg [1:0] 		       fsm;
   localparam
     S_IDLE=0,
     S_WR_SHIFT=1,
     S_RD_SHIFT=2;

`ifdef MODEL_TECH // This works well for modelsim
   reg [127:0] state_str;
   always @(*)
     case(fsm)
       S_IDLE:     state_str <= "S_IDLE";
       S_WR_SHIFT: state_str <= "S_WR_SHIFT";
       S_RD_SHIFT: state_str <= "S_RD_SHIFT";
       default:    state_str <= "*** UNKNOWN ***"; 
     endcase // case (fsm)
`endif
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Output assignments
   assign sclk = cpol ? !i_sclk : i_sclk; 
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  i_sclk <= 0;
	  i_mosi <= 0; 
       end
     else
       begin
	  if(fsm == S_WR_SHIFT || fsm == S_RD_SHIFT)
	    begin
	       if(sclk_cnt == sclk_div)
		 i_sclk <= !i_sclk;
	    end
	  else
	    i_sclk <= 0; 
       end
   
   always @(posedge clk)
     if(cpha==0)
       begin
	  if(fsm == S_WR_SHIFT && sclk_cnt == 0)
	    begin
	       i_mosi <= ;
	    end
	  else
	    i_mosi <= i_wr_data[0];
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // FSM Flow
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  fsm <= S_IDLE;
	  wr_ack <= 0;
	  rd_ack <= 0;
	  sclk_cnt <= 0;
	  data_cnt <= 0;
	  i_sclk <= 0;
	  i_mosi <= 0;
	  i_sclk_run <= 0; 
       end
     else
       begin
	  wr_ack <= 0;
	  rd_ack <= 0; 
	  case(fsm)
	    
	    S_IDLE:
	      begin
		 sclk_cnt <= 0;
		 data_cnt <= 0; 
		 if(wr_req)
		   fsm <= S_WR_SHIFT;
		 else if(rd_req)
		   fsm <= S_RD_SHIFT; 
	      end
	    
	    S_WR_SHIFT:
	      begin
		 sclk_cnt <= sclk_cnt+1;
		 if(sclk_cnt == sclk_div)
		   begin
		      if(data_cnt == wr_n)
			begin
			   sclk_cnt <= 0;
			   data_cnt <= 0;
			   wr_ack <= 1;
			   if(rd_req)
			     fsm <= S_RD_SHIFT;
			   else
			     fsm <= S_IDLE; 
			end
		      else
			begin
			   sclk_cnt <= 0;
			   data_cnt <= data_cnt + 1;
			end
		   end
	      end
	    	    
	    S_RD_SHIFT:
	      begin
		 sclk_cnt <= sclk_cnt+1;
		 if(sclk_cnt == sclk_div)
		   begin
		      if(data_cnt == rd_n)
			begin
			   sclk_cnt <= 0;
			   data_cnt <= 0;
			   rd_ack <= 1; 
			   fsm <= S_IDLE; 
			end
		      else
			begin
			   sclk_cnt <= 0;
			   data_cnt <= data_cnt + 1;
			end
		   end
	      end
	    
	    default:  fsm <= S_IDLE;
	  endcase // case (fsm)
       end
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
