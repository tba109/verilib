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
       input [P_NBITS_ADDR-1:0]  n, // Number of delay elements, minimum valid = 2 
       input 			 wr, // 
       input [P_NBITS_DATA-1:0]  d, // Input data
       output [P_NBITS_DATA-1:0] qo, // 
       output [P_NBITS_DATA-1:0] qn, // 
       output reg 		 valid // Indicates that the output reflects a delayed d
       );
      
   // Register the inputs so that we can "look ahead"
   reg 				 i_wr_0 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_0 = 0 ;
   reg 				 i_wr_1 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_1 = 0 ;
   reg 				 i_wr_2 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_2 = 0 ;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_in=0;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_out=2;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_in_0=0;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_out_0=2;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_in_1=0;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_out_1=2;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_in_2=0;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_out_2=2;
   always @(posedge clk) 
     if(wr)
       begin
	  i_wr_0 <= wr;
	  i_d_0  <= d;
	  i_wr_1 <= i_wr_0;
	  i_d_1  <= i_d_0;
	  i_wr_2 <= i_wr_1;
	  i_d_2  <= i_d_1;
	  i_addr_in_0 <= i_addr_in;
	  i_addr_out_0 <= i_addr_out;
	  i_addr_in_1 <= i_addr_in_0;
	  i_addr_out_1 <= i_addr_out_0;
	  i_addr_in_2 <= i_addr_in_1;
	  i_addr_out_2 <= i_addr_out_1;
       end
	
   // RAM
   true_dual_port_ram_dual_clock
     #(
       .DATA_WIDTH(P_NBITS_DATA),
       .ADDR_WIDTH(P_NBITS_ADDR)
       )  
   TRUE_DUAL_PORT_RAM_DUAL_CLOCK_0
     (
      .q_a				(),
      .q_b				(qn),
      .data_a				(i_d_2),
      .data_b				({P_NBITS_DATA{1'b0}}),
      .addr_a				(i_addr_in),
      .addr_b				(i_addr_out),
      .we_a				(i_wr_2),
      .we_b				(1'b0),
      .clk_a				(clk),
      .clk_b				(clk)); 
      
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Simple state machine for valid
   reg [P_NBITS_ADDR-1:0] 	 valid_cnt = 0;
   reg 				 state = 0; 
   reg 				 i_state = 0;
   always @(posedge clk) i_state <= state; 
   always @(posedge clk)
     case(state)
       0:
	 begin
	    if(wr)
	      begin
		 valid_cnt <= valid_cnt + 1;
		 if(valid_cnt == n-1)
		   state <= 1;
	      end
	 end	 
       1: 
	 if(n != valid_cnt)
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
	  if(i_addr_in == n-1)
	    begin
	       i_addr_in <= 0;
	       i_addr_out <= 2;
	    end
	  if(i_addr_out == n-1)
	    i_addr_out <= 0;
       end // if (wr)
   
   // Output assignments
   assign qo = i_d_1; 
   always @(posedge clk) valid <= wr && (i_state == 1); 
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../true_dual_port_ram_dual_clock/")
// End:
