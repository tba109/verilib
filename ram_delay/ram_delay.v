///////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Fri Feb 15 13:11:26 EST 2019
// ram_delay.v
//
// Implements a delay line using a RAM. 
// 
// Features:
// -- Adjustable delay in clock cycles, n
// -- Write enable
// -- Valid indicates that th
// -- Reset causes valid to be low until the result of n writes appears on qn
//
// Notes:
// -- Minimum n = 2 for valid operation. Use PLINE for shorter delays
//
// Testing:
// -- sim/tb.v contains a self-checking testbench which shows various writes and resets
//
// Implementation:
// -- fpga/5cefa5f23i7: 42 ALMs, 72 registers, 1 M10K, FMAX = 307MHz, 240MHz (restricted) 
///////////////////////////////////////////////////////////////////////////////////////////////////
module ram_delay
  #(
    parameter P_NBITS_ADDR=8, 
    parameter P_NBITS_DATA=14
    ) (
       input 			 clk, // system clock
       input 			 rst, // delay ram begins filling and is asserted after n writes
       input [P_NBITS_ADDR-1:0]  n, // Number of delay elements, minimum valid = 2 
       input 			 wr, // write enable for input data
       input [P_NBITS_DATA-1:0]  d, // input data
       input 			 addr_en, // enable external address bus control
       input [P_NBITS_ADDR-1:0]  addr, // external address. Must count 0 to n-1 when wr is asserted. 
       output [P_NBITS_DATA-1:0] qo, // output aligned with qn
       output [P_NBITS_DATA-1:0] qn, // qo from n samples earlier
       output reg 		 valid=0 // Indicates qn accurately represents n cycle delay from qo
       );
      
   // Internal
   localparam 
     S_PRIME = 0, 
     S_VALID = 1; 
   reg  			 state = S_PRIME; 
   reg  			 i_state = 0;
   reg [P_NBITS_ADDR-1:0] 	 prime_cnt = 0;   
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
	  i_wr_1 <= i_wr_0;
	  i_wr_2 <= i_wr_1;
	  i_d_0  <= d;
	  i_d_1  <= i_d_0;
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
      
   // Logic to handle reset
   always @(posedge clk) i_state <= state;
   always @(posedge clk)
     case(state)
       S_PRIME:
	 begin
	    if(rst)
	      prime_cnt <= 0; 
	    else if(wr)
	      prime_cnt <= prime_cnt + 1;
	    if(prime_cnt == n-1)
	      state <= S_VALID; 
	 end
       S_VALID: 
	 if(n != prime_cnt || rst)
	   begin 
	      state <= S_PRIME;
	      prime_cnt <= 0;
	   end
       default state <= S_PRIME; 
     endcase
   
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
       end

   // Output assignments
   assign qo = i_d_1;
   always @(posedge clk) valid <= wr && (i_state == S_VALID);
    
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../true_dual_port_ram_dual_clock/")
// End:
