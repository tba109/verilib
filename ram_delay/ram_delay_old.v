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
       input [P_NBITS_ADDR-1:0]  delay_len, // Number of delay elements, minimum valid = 2 
       input 			 wr, // 
       input [P_NBITS_DATA-1:0]  d, // Input data
       output [P_NBITS_DATA-1:0] q, // Delayed data
       output 			 valid // Indicates that the output reflects a delayed d
       );
      
   // Register the inputs so that we can "look ahead"
   reg 				 i_wr_0 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_0 = 0 ;
   reg 				 i_wr_1 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_1 = 0 ;
   reg 				 i_wr_2 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_2 = 0 ;
   always @(posedge clk) 
     begin
	i_wr_0 <= wr;
	i_d_0  <= d;
	i_wr_1 <= i_wr_0;
	i_d_1  <= i_d_0;
	i_wr_2 <= i_wr_1;
	i_d_2  <= i_d_1;
     end
	
   // RAM
   reg [P_NBITS_ADDR-1:0] 	 i_addr_in=0;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_out=3;
   true_dual_port_ram_dual_clock
     #(
       .DATA_WIDTH(P_NBITS_DATA),
       .ADDR_WIDTH(P_NBITS_ADDR)
       )  
   TRUE_DUAL_PORT_RAM_DUAL_CLOCK_0
     (
      .q_a				(),
      .q_b				(q),
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
   always @(posedge clk)
     case(state)
       0:
	 begin
	    if(wr)
	      begin
		 valid_cnt <= valid_cnt + 1;
		 if(valid_cnt == delay_len-1)
		   state <= 1;
	      end
	 end	 
       1: 
	 if(delay_len != valid_cnt)
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
	  if(i_addr_in == delay_len-1)
	    begin
	       i_addr_in <= 0;
	       i_addr_out <= 3;
	    end
	  if(i_addr_out == delay_len-1)
	    i_addr_out <= 0;
       end // if (wr)
     // else if(i_wr_0 && !wr)
     //   begin
     // 	  i_addr_in <= i_addr_in - 1;
     // 	  i_addr_out <= i_addr_out - 1;
     // 	  if(i_addr_in == 0)
     // 	    begin
     // 	       i_addr_in <= delay_len-1;
     // 	       i_addr_out <= 0;
     // 	    end
     // 	  if(i_addr_out == delay_len-1)
     // 	    i_addr_out <= 0;
     // end
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Output assignments
   
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../true_dual_port_ram_dual_clock/")
// End:
