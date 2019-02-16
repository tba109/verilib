///////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Fri Feb 15 13:11:26 EST 2019
// ram_delay.v
//
// Implements a delay line using a RAM. 
// 
// Features:
// -- Adjustable delay
// -- Write enable
// -- Output valid (indicates that the delay line is primed)
// -- Prime input (lowers valid for a number of write enabled clock cycles equal to delay length)
///////////////////////////////////////////////////////////////////////////////////////////////////
module ram_delay
  #(
    parameter P_NBITS_ADDR=8, 
    parameter P_NBITS_DATA=14
    ) (
       input 			 clk,
       input 			 prime,
       input [P_NBITS_ADDR-1:0]  delay_len, 
       input 			 wr, // 
       input [P_NBITS_DATA-1:0]  d, // Input data
       output [P_NBITS_DATA-1:0] q, // Delayed data
       output 			 valid // Indicates that the output reflects a delayed d
       );
      
   // RAM
   reg [P_NBITS_ADDR-1:0] 	 i_addr_in=0;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_out=2;
   ram_dual 
     #(
       .P_NBITS_ADDR(P_NBITS_ADDR),
       .P_NBITS_DATA(P_NBITS_DATA)
       )  
   RAM_DUAL_0
     (
      // Outputs
      .q		(valid),
      // Inputs
      .d		(d),
      .addr_in		(i_addr_in),
      .addr_out	        (i_addr_out),
      .we		(wr),
      .clk1		(clk),
      .clk2		(clk)
      ); 
      
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Simple state machine for valid
   reg [P_NBITS_ADDR-1:0] 	 valid_cnt = 0;
   reg 				 state = 0; 
   always @(posedge clk)
     case(state)
       0:
	 begin
	    if(wr)
	      begin
		 valid_cnt <= valid_cnt + 1;
		 if(valid_cnt == delay_len)
		   state <= 1;
	      end
	 end	 
       1: 
	 if((delay_len != valid_cnt) || prime)
	   begin 
	      state <= 0;
	      valid_cnt <= 0;
	   end
     endcase
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Address management 
   always @(posedge clk)
     if(wr)
       begin
	  i_addr_in <= i_addr_in + 1;
	  i_addr_out <= i_addr_out + 1;
	  if(i_addr_in == delay_len)
	    begin
	       i_addr_in <= 0;
	       i_addr_out <= 2;
	    end
	  if(i_addr_out == delay_len)
	    i_addr_out <= 0;
       end // if (wr)

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Address management 
   assign valid = (state == 1); 
   
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../ram_dual/")
// End:
