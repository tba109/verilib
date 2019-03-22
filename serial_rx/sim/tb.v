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
`define TEST_CASE_16_2_3

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
   wire [255:0]		data;			// From SERIAL_RX_0 of serial_rx.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			a;			// To SERIAL_RX_0 of serial_rx.v
   reg [31:0]		cnt;			// To SERIAL_RX_0 of serial_rx.v
   reg [31:0]		n0;			// To SERIAL_RX_0 of serial_rx.v
   reg [31:0]		n1;			// To SERIAL_RX_0 of serial_rx.v
   reg [7:0]		nbits;			// To SERIAL_RX_0 of serial_rx.v
   reg [15:0] 		data_in; 
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
   serial_rx SERIAL_RX_0(/*AUTOINST*/
			 // Outputs
			 .data			(data[255:0]),
			 // Inputs
			 .clk			(clk),
			 .rst			(rst),
			 .a			(a),
			 .nbits			(nbits[7:0]),
			 .n0			(n0[31:0]),
			 .n1			(n1[31:0]),
			 .cnt			(cnt[31:0])); 
   
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
`ifdef TEST_CASE_16_2_3
   integer i; 
   reg cnt_go;
   always @(posedge clk) if(cnt_go) cnt <= cnt + 1; else cnt <= 0; 
   initial
     begin
	i = 0; 
	cnt = 0; 
	rst = 1;
	clk = 0;
	cnt_go <= 0; 
	nbits <= 16;
	n0 <= 2;
	n1 <= 3;
	data_in <= 16'h5aaa; 
	a <= 0; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_16_2_3");

	cnt_go = 1; 

	for(i=0; i < 4; i=i+1) @(posedge clk); a <= data_in[15];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[14];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[13];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[12];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[11];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[10];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[9];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[8];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[7];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[6];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[5];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[4];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[3];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[2];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[1];
	for(i=0; i < n1; i=i+1) @(posedge clk); a <= data_in[0];
	
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
   
