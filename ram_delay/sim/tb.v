//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Sat Feb 16 11:07:16 EST 2019
//
//////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

//////////////////////////////////////////////////////////////////////////////////////////////////
// Test cases
//////////////////////////////////////////////////////////////////////////////////////////////////
`define TEST_CASE_DELAY_LEN_4

module tb;
   
   //////////////////////////////////////////////////////////////////////
   // I/O
   //////////////////////////////////////////////////////////////////////   
   parameter CLK_PERIOD = 10;
   reg clk;
   reg rst;
   parameter P_NBITS_DATA = 42;
   parameter P_NBITS_ADDR = 9; 
   
   // Connections
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [P_NBITS_DATA-1:0] q;			// From RAM_DELAY_0 of ram_delay.v
   wire			valid;			// From RAM_DELAY_0 of ram_delay.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [P_NBITS_DATA-1:0] d;			// To RAM_DELAY_0 of ram_delay.v
   reg [P_NBITS_ADDR-1:0] delay_len;		// To RAM_DELAY_0 of ram_delay.v
   reg 			  wr;			// To RAM_DELAY_0 of ram_delay.v
   // End of automatics
   
   //////////////////////////////////////////////////////////////////////
   // Clock Driver
   //////////////////////////////////////////////////////////////////////
   always @(clk)
     #(CLK_PERIOD / 2.0) clk <= !clk;
				   
   //////////////////////////////////////////////////////////////////////
   // Simulated interfaces
   //////////////////////////////////////////////////////////////////////   
      
   //////////////////////////////////////////////////////////////////////
   // UUT
   //////////////////////////////////////////////////////////////////////   
   ram_delay #(.P_NBITS_ADDR(P_NBITS_ADDR),.P_NBITS_DATA(P_NBITS_DATA)) RAM_DELAY_0
     (
      // Outputs
      .q			(q[P_NBITS_DATA-1:0]),
      .valid			(valid),
      // Inputs
      .clk			(clk),
      .delay_len		(delay_len[P_NBITS_ADDR-1:0]),
      .wr			(wr),
      .d			(d[P_NBITS_DATA-1:0])
      ); 
   
   //////////////////////////////////////////////////////////////////////
   // Test case
   //////////////////////////////////////////////////////////////////////   
`ifdef TEST_CASE_DELAY_LEN_4
   integer 		i = 0; 
   initial
     begin
	clk = 1'b0;
	rst = 1'b1; 
	wr <= 0; 
	d <= {P_NBITS_DATA{1'b1}};
	delay_len <= 9'd4;
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1");

	for(i=0; i<10; i=i+1)
	  begin
	     @(posedge clk);
	     wr <= 1; 
	     d<=d+1; 
	  end
	@(posedge clk) wr <= 0; 
	@(posedge clk) wr <= 0; 
	// Stimulate UUT
	
	for(i=0; i<delay_len; i=i+1)
	  begin
	     @(posedge clk);
	     wr <= 1; 
	     d<=d+1; 
	  end
	@(posedge clk) wr <= 0; 

     end
   `endif

   //////////////////////////////////////////////////////////////////////
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../")
// End:
   
