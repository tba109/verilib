///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Mar 21 15:00:54 EDT 2019
//
// tb.v
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

///////////////////////////////////////////////////////////////////////////////////////////////////
// Test cases
///////////////////////////////////////////////////////////////////////////////////////////////////
`define TEST_CASE_16_2_3_4
// `define TEST_CASE_16_1_3_4

module tb;
   
   //////////////////////////////////////////////////////////////////////
   // I/O
   //////////////////////////////////////////////////////////////////////   
   parameter CLK_PERIOD = 10;
   reg clk;
   reg rst;

   // Connections
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			ack;			// From SERIAL_CK_0 of serial_ck.v
   wire			y;			// From SERIAL_CK_0 of serial_ck.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [31:0] 		n0;			// To SERIAL_CK_0 of serial_ck.v
   reg [31:0]		n1;			// To SERIAL_CK_0 of serial_ck.v
   reg [31:0]		n2;			// To SERIAL_CK_0 of serial_ck.v
   reg [7:0]		ncyc;			// To SERIAL_CK_0 of serial_ck.v
   reg			y0;			// To SERIAL_CK_0 of serial_ck.v
   reg [31:0] 		cnt; 
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
   serial_ck SERIAL_CK_0(/*AUTOINST*/
			 // Outputs
			 .ack			(ack),
			 .y			(y),
			 // Inputs
			 .clk			(clk),
			 .rst			(rst),
			 .cnt                   (cnt),
			 .y0			(y0),
			 .ncyc			(ncyc[7:0]),
			 .n0			(n0[31:0]),
			 .n1			(n1[31:0]),
			 .n2			(n2[31:0]));
   
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
   `ifdef TEST_CASE_16_2_3_4
   reg cnt_go;
   always @(posedge clk) if(cnt_go) cnt <= cnt + 1; else cnt <= 0; 
   initial
     begin
	cnt = 0; 
	rst = 1;
	clk = 0;
	cnt_go <= 0; 
	ncyc <= 16;
	n0 <= 2;
	n1 <= 3;
	n2 <= 4;
	y0 <= 1; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_16_2_3_4_5");

	cnt_go = 1; 
	
	// Stimulate UUT
     end
   `endif

   `ifdef TEST_CASE_16_1_3_4
   reg cnt_go;
   always @(posedge clk) if(cnt_go) cnt <= cnt + 1; else cnt <= 0; 
   initial
     begin
	cnt = 0; 
	rst = 1;
	clk = 0;
	cnt_go <= 0; 
	ncyc <= 16;
	n0 <= 1;
	n1 <= 3;
	n2 <= 4;
	y0 <= 1; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_16_2_3_4_5");

	cnt_go = 1; 
	
	// Stimulate UUT
     end
   `endif

   
   //////////////////////////////////////////////////////////////////////
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../")
// End:
   
