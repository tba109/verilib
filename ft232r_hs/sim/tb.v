///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue Mar 26 15:36:36 EDT 2019
//
// tb.v
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

///////////////////////////////////////////////////////////////////////////////////////////////////
// Test cases
///////////////////////////////////////////////////////////////////////////////////////////////////
`define TEST_CASE_1

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
   wire			cts_n;			// From FT232_R_HS_0 of ft232r_hs.v
   wire [7:0]		rd_data;		// From FT232_R_HS_0 of ft232r_hs.v
   wire			rd_req;			// From FT232_R_HS_0 of ft232r_hs.v
   wire			rxd;			// From FT232_R_HS_0 of ft232r_hs.v
   wire			txd;			
   wire			wr_ack;			
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			wr_req;			
   reg			rd_ack;			// To FT232_R_HS_0 of ft232r_hs.v
   reg			rts_n;			// To FT232_R_HS_0 of ft232r_hs.v   
   reg [7:0]		wr_data;		// To FT232_R_HS_0 of ft232r_hs.v
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
   ft232r_hs FT232_R_HS_0(/*AUTOINST*/
			  // Outputs
			  .rxd			(rxd),
			  .cts_n		(cts_n),
			  .wr_req		(wr_req),
			  .rd_req		(rd_req),
			  .rd_data		(rd_data[7:0]),
			  // Inputs
			  .clk			(clk),
			  .rst			(rst),
			  .txd			(txd),
			  .rts_n		(rts_n),
			  .wr_ack		(wr_ack),
			  .wr_data		(wr_data[7:0]),
			  .rd_ack		(rd_ack)); 
   
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
   assign txd = rxd; // simple loopback
   initial
     begin
	rd_ack = 0;
	rts_n = 1;
	wr_req = 0;
	wr_data = 0; 
	
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1, simple loopback");

	#(10*CLK_PERIOD);
	@(posedge clk) begin wr_data = 8'hae; wr_req = 1; end
	wait(wr_ack) @(posedge clk) wr_req = 0;
	wait(rd_req) @(posedge clk) rd_ack = 1; @(posedge clk) rd_ack = 0;  

	#(10*CLK_PERIOD);
	@(posedge clk) begin wr_data = 8'hb1; wr_req = 1; end
	wait(wr_ack) @(posedge clk) wr_req = 0;
	wait(rd_req) @(posedge clk) rd_ack = 1; @(posedge clk) rd_ack = 0;  

	// Now try with flow control
	#(10*CLK_PERIOD);
	@(posedge clk) begin rts_n = 0; end
	#(10*CLK_PERIOD); 
	@(posedge clk) begin wr_data = 8'h5c; wr_req = 1; rts_n = 1; end
	wait(wr_ack) @(posedge clk) wr_req = 0;
	wait(rd_req) @(posedge clk) rd_ack = 1; @(posedge clk) rd_ack = 0;  

	
     end
   `endif

   //////////////////////////////////////////////////////////////////////
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../")
// End:
   
