//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Mon 11/11/2019_15:14:00.69
//
// tb.v
//////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

//////////////////////////////////////////////////////////////////////////////////////////////////
// Test cases
//////////////////////////////////////////////////////////////////////////////////////////////////
`define TEST_CASE_1

module tb;
   
   //////////////////////////////////////////////////////////////////////
   // I/O
   //////////////////////////////////////////////////////////////////////   
   parameter CLK_PERIOD = 10;
   reg clk;
   reg rst;
   parameter P_IO_WIDTH = 1;
   parameter P_N_WIDTH = 32;
   
   // Connections
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			busy;			// From UUT_0 of pulse_gen.v
   wire			y;			// From UUT_0 of pulse_gen.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [P_IO_WIDTH-1:0]	a0;			// To UUT_0 of pulse_gen.v
   reg [P_IO_WIDTH-1:0]	a1;			// To UUT_0 of pulse_gen.v
   reg			en;			// To UUT_0 of pulse_gen.v
   reg [P_N_WIDTH-1:0]	n0;			// To UUT_0 of pulse_gen.v
   reg [P_N_WIDTH-1:0]	n1;			// To UUT_0 of pulse_gen.v
   reg [P_N_WIDTH-1:0]	period;			// To UUT_0 of pulse_gen.v
   reg			ss;			// To UUT_0 of pulse_gen.v
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
   pulse_gen UUT_0(/*AUTOINST*/
		   // Outputs
		   .busy		(busy),
		   .y			(y),
		   // Inputs
		   .clk			(clk),
		   .rst			(rst),
		   .en			(en),
		   .ss			(ss),
		   .a0			(a0[P_IO_WIDTH-1:0]),
		   .a1			(a1[P_IO_WIDTH-1:0]),
		   .n0			(n0[P_N_WIDTH-1:0]),
		   .n1			(n1[P_N_WIDTH-1:0]),
		   .period		(period[P_N_WIDTH-1:0])); 
   
   //////////////////////////////////////////////////////////////////////
   // Testbench
   //////////////////////////////////////////////////////////////////////   
   initial
     begin
	// Initializations
	clk = 1'b0;
	rst = 1'b1;
     end

   //////////////////////////////////////////////////////////////////////
   // Test case
   //////////////////////////////////////////////////////////////////////   
   `ifdef TEST_CASE_1
   initial
     begin
	a0 = 0;
	a1 = 1;
	en = 0;
	n0 = 5;
	n1 = 10;
	period = 100;
	ss = 0; 
	
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1");

	// Stimulate UUT
	@(posedge clk) ss = 1; #1;
	@(posedge clk) ss = 0; #1;

	#(250*CLK_PERIOD);

	@(posedge clk) en = 1; #1; 
     end
   `endif

   //////////////////////////////////////////////////////////////////////
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../")
// End:
   
