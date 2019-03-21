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
// `define TEST_CASE_16_2_3_4_5
`define TEST_CASE_16_1_3_4_0

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
   wire			ack;			// From SERIAL_TX_0 of serial_tx.v
   wire			y;			// From SERIAL_TX_0 of serial_tx.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [255:0]		data;			// To SERIAL_TX_0 of serial_tx.v
   reg [31:0]		n0;			// To SERIAL_TX_0 of serial_tx.v
   reg [31:0]		n1;			// To SERIAL_TX_0 of serial_tx.v
   reg [31:0]		n2;			// To SERIAL_TX_0 of serial_tx.v
   reg [31:0]		n3;			// To SERIAL_TX_0 of serial_tx.v
   reg [7:0]		nbits;			// To SERIAL_TX_0 of serial_tx.v
   reg			y0;			// To SERIAL_TX_0 of serial_tx.v
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
   serial_tx SERIAL_TX_0(/*AUTOINST*/
			 // Outputs
			 .ack			(ack),
			 .y			(y),
			 // Inputs
			 .clk			(clk),
			 .rst			(rst),
			 .cnt                   (cnt),
			 .y0			(y0),
			 .data			(data[255:0]),
			 .nbits			(nbits[7:0]),
			 .n0			(n0[31:0]),
			 .n1			(n1[31:0]),
			 .n2			(n2[31:0]),
			 .n3			(n3[31:0])); 
   
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
   `ifdef TEST_CASE_16_2_3_4_5
   reg cnt_go;
   always @(posedge clk) if(cnt_go) cnt <= cnt + 1; else cnt <= 0; 
   initial
     begin
	cnt = 0; 
	rst = 1;
	clk = 0;
	cnt_go <= 0; 
	nbits <= 16;
	data <= 16'h5aaa; 
	n0 <= 2;
	n1 <= 3;
	n2 <= 4;
	n3 <= 5;
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

   `ifdef TEST_CASE_16_1_3_4_0
   reg cnt_go;
   always @(posedge clk) if(cnt_go) cnt <= cnt + 1; else cnt <= 0; 
   initial
     begin
	cnt = 0; 
	rst = 1;
	clk = 0;
	cnt_go <= 0; 
	nbits <= 16;
	data <= 16'h5aaa; 
	n0 <= 1;
	n1 <= 3;
	n2 <= 4;
	n3 <= 0;
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
   
