///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Fri Mar 22 14:28:04 EDT 2019
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
   wire			ack;			// From SPIM_0 of spi_master.v
   wire			mosi;			// From SPIM_0 of spi_master.v
   wire [31:0]		rd_data;		// From SPIM_0 of spi_master.v
   wire			sclk;			// From SPIM_0 of spi_master.v
   wire			miso;			// To SPIM_0 of spi_master.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)

   reg [31:0]		n0_miso;		// To SPIM_0 of spi_master.v
   reg [31:0]		n0_mosi;		// To SPIM_0 of spi_master.v
   reg [31:0]		n0_sclk;		// To SPIM_0 of spi_master.v
   reg [31:0]		n1_miso;		// To SPIM_0 of spi_master.v
   reg [31:0]		n1_mosi;		// To SPIM_0 of spi_master.v
   reg [31:0]		n1_sclk;		// To SPIM_0 of spi_master.v
   reg [31:0]		n2_sclk;		// To SPIM_0 of spi_master.v
   reg [7:0]		nb_miso;		// To SPIM_0 of spi_master.v
   reg [7:0]		nb_mosi;		// To SPIM_0 of spi_master.v
   reg [31:0]		nb_sclk;		// To SPIM_0 of spi_master.v
   reg			rd_req;			// To SPIM_0 of spi_master.v
   reg [31:0]		wr_data;		// To SPIM_0 of spi_master.v
   reg			wr_req;			// To SPIM_0 of spi_master.v
   reg			y0_mosi;		// To SPIM_0 of spi_master.v
   reg			y0_sclk;		// To SPIM_0 of spi_master.v
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
   spi_master SPIM_0(/*AUTOINST*/
		     // Outputs
		     .rd_data		(rd_data[31:0]),
		     .ack		(ack),
		     .mosi		(mosi),
		     .sclk		(sclk),
		     // Inputs
		     .clk		(clk),
		     .rst		(rst),
		     .nb_mosi		(nb_mosi[7:0]),
		     .y0_mosi		(y0_mosi),
		     .n0_mosi		(n0_mosi[31:0]),
		     .n1_mosi		(n1_mosi[31:0]),
		     .nb_miso		(nb_miso[7:0]),
		     .n0_miso		(n0_miso[31:0]),
		     .n1_miso		(n1_miso[31:0]),
		     .nb_sclk		(nb_sclk[31:0]),
		     .y0_sclk		(y0_sclk),
		     .n0_sclk		(n0_sclk[31:0]),
		     .n1_sclk		(n1_sclk[31:0]),
		     .n2_sclk		(n2_sclk[31:0]),
		     .wr_req		(wr_req),
		     .wr_data		(wr_data[31:0]),
		     .rd_req		(rd_req),
		     .miso		(miso)); 
   assign miso = mosi; // loopback
   
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
	// mosi
	n0_mosi = 10;
	n1_mosi = 10;
	nb_mosi = 16;
	y0_mosi = 1; 
	// sclk
	n0_sclk = 10;
	n1_sclk = 5;
	n2_sclk = 5;
	nb_sclk = 16; 
	y0_sclk = 1;
	// miso
	n0_miso = 5;
	n1_miso = 10;
	nb_miso = 16;
	wr_data = 16'h5aaa;
	wr_req  = 0;
	rd_req = 0; 

	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1");


	@(posedge clk) begin wr_req=1; rd_req=1; end
	wait(ack) @(posedge clk) begin wr_req=0; rd_req=0; end
	
	@(posedge clk) 
	  begin 
	     wr_req=1; 
	     rd_req=1; 
	     nb_miso=17; 
	     nb_sclk=17; 
	     nb_mosi=17; 
	     wr_data = 17'h15aaa; 
	  end
	wait(ack) @(posedge clk) begin wr_req=0; rd_req=0; end

	
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
   
