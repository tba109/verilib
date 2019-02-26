///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue Feb 26 14:36:52 EST 2019
//
// gated_integrator.v
//
// Gated integrator using ram_delay. Sum all samples in a window 
//  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module gated_integrator
  #(
    parameter P_NBITS_ADDR=6, // max number of bits for the addressing power 2 is gate width
    parameter P_NBITS_DATA_IN=14, // input data size
    parameter P_NBITS_DATA_OUT=20 // output data size   
    ) (
       input 			     clk, // system clock
       input 			     rst, // delay ram begins filling and is asserted after n writes
       input [P_NBITS_ADDR-1:0]      n, // Number of delay elements, minimum valid = 2 
       input 			     wr, // write enable for input data
       input [P_NBITS_DATA_IN-1:0]   d, // input data
       input 			     addr_en, // enable external address bus control
       input [P_NBITS_ADDR-1:0]      addr, // external address. Must count 0 to n-1 when wr is asserted. 
       output reg [P_NBITS_DATA-1:0] sum=0, // output aligned with qn
       output reg 		     valid=0 // Indicates qn accurately represents n cycle delay from qo
       );

   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // Internals
   wire [P_NBITS_DATA-1:0] 	     i_a; // output aligned with b
   wire 			     i_v_a; // a valid 
   wire [P_NBITS_DATA-1:0] 	     i_b; // a from n samples earlier
   wire 			     i_v_b; // b valid
   ram_delay RAM_DELAY_0(/*AUTOINST*/
			 // Outputs
			 .qo			(i_a[P_NBITS_DATA-1:0]),
			 .qn			(i_b[P_NBITS_DATA-1:0]),
			 .valid			(i_v),
			 // Inputs
			 .clk			(clk),
			 .rst			(rst),
			 .n			(n[P_NBITS_ADDR-1:0]),
			 .wr			(wr),
			 .d			(d[P_NBITS_DATA-1:0]),
			 .addr_en		(addr_en),
			 .addr			(addr[P_NBITS_ADDR-1:0])); 
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // Internals
   always @(posedge clk) 
     begin
	valid <= i_v_a; 
	if(!i_v_a)
	  sum <= 0;
	else if(!i_v_b)
	  sum <= sum + i_a;
	else
	  sum <= sum + i_a - i_b;
     end
	
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../ram_delay/")
// End:
