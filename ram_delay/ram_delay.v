///////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Fri Feb 15 13:11:26 EST 2019
// ram_delay.v
//
// Implements a delay line using a RAM. 
// 
// Features:
// -- Adjustable delay in clock cycles, n
// -- Write enable
// -- Output valid (indicates that the delay line is primed)
// -- Input init (lowers valid for some number of clock,)
///////////////////////////////////////////////////////////////////////////////////////////////////
module ram_delay
  #(
    parameter P_NBITS_ADDR=8, 
    parameter P_NBITS_DATA=14
    ) (
       input 			 clk, // system clock
       input 			 rst, // system reset
       input 			 flush, // flush the RAM (valid for the length of the delay loop)
       input [P_NBITS_ADDR-1:0]  n, // Number of delay elements, minimum valid = 2 
       input 			 wr, // 
       input [P_NBITS_DATA-1:0]  d, // Input data
       input 			 addr_en, // enable external address bus control
       input [P_NBITS_ADDR-1:0]  addr, // external address. Should count up 0 to n-1 when wr is asserted. 
       output [P_NBITS_DATA-1:0] qo, // output
       output [P_NBITS_DATA-1:0] qn, // delayed output so that qn is qo from n samples earlier
       output reg 		 valid // Indicates the output is valid. This is the same as eariler
       );
      
   reg 				 i_wr_0 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_0 = 0 ;
   reg 				 i_wr_1 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_1 = 0 ;
   reg 				 i_wr_2 = 0;
   reg [P_NBITS_DATA-1:0] 	 i_d_2 = 0 ;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_in=0;
   reg [P_NBITS_ADDR-1:0] 	 i_addr_out=2;
   wire [P_NBITS_ADDR-1:0] 	 i_addr_in_0; 
   always @(posedge clk) 
     if(wr)
       begin
	  i_wr_0 <= wr;
	  i_d_0  <= d;
	  i_wr_1 <= i_wr_0;
	  i_d_1  <= i_d_0;
	  i_wr_2 <= i_wr_1;
	  i_d_2  <= i_d_1;
       end
   assign i_addr_in_0 = addr_en ? addr : i_addr_in; 
	
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
      .addr_a				(i_addr_in_0),
      .addr_b				(i_addr_out),
      .we_a				(i_wr_2),
      .we_b				(1'b0),
      .clk_a				(clk),
      .clk_b				(clk)); 
      
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Logic to handle reset and flush
   reg [P_NBITS_ADDR-1:0] 	 reset_cnt = 0;
   localparam S_RESET = 0, S_VALID = 1; 
   reg 				 state = S_RESET; 
   reg 				 i_state = 0;
   reg 				 i_flush = 0; 
   always @(posedge clk) begin i_state <= state; i_flush <= flush; end 
   always @(posedge clk or posedge rst)
     if(rst) 
       state <= S_RESET;
     else
       case(state)
	 S_RESET:
	   begin
	      if(wr)
		begin
		   reset_cnt <= reset_cnt + 1;
		   if(reset_cnt == n-1)
		     state <= S_VALID;
		end
	   end	 
	 S_VALID: 
	   if(n != reset_cnt)
	     begin 
		state <= S_RESET;
		reset_cnt <= 0;
	     end
       endcase
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Address management
   always @(posedge clk)
     if(wr)
       begin
	  i_addr_in <= i_addr_in + 1;
	  i_addr_out <= i_addr_out + 1;
	  if(i_addr_in_0 == n-1)
	    begin
	       i_addr_in <= 0;
	       i_addr_out <= 2;
	    end
	  if(i_addr_out == n-1)
	    i_addr_out <= 0;
       end // if (wr)

   ///////////////////////////////////////////////////////////////////////////////////////////////   
   // Output assignments
   assign qo = i_d_1; 
   always @(posedge clk) valid <= (wr && !i_flush) && (i_state == S_VALID);
    
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../true_dual_port_ram_dual_clock/")
// End:
