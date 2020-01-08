//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue 11/12/2019_12:49:50.72
//
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

   parameter P_N_WIDTH=32; 
   // Connections
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			high;			// From WC_0 of bitstream_counter.v
   wire			inh_high_out;		// From WC_0 of bitstream_counter.v
   wire			inh_low_out;		// From WC_0 of bitstream_counter.v
   wire			inh_nedge_out;		// From WC_0 of bitstream_counter.v
   wire			inh_pedge_out;		// From WC_0 of bitstream_counter.v
   wire			low;			// From WC_0 of bitstream_counter.v
   wire [P_N_WIDTH-1:0]	n_high;			// From WC_0 of bitstream_counter.v
   wire [P_N_WIDTH-1:0]	n_low;			// From WC_0 of bitstream_counter.v
   wire [P_N_WIDTH-1:0]	n_nedge;		// From WC_0 of bitstream_counter.v
   wire [P_N_WIDTH-1:0]	n_pedge;		// From WC_0 of bitstream_counter.v
   wire			nedge;			// From WC_0 of bitstream_counter.v
   wire			pedge;			// From WC_0 of bitstream_counter.v
   wire			update;			// From WC_0 of bitstream_counter.v
   wire			valid;			// From WC_0 of bitstream_counter.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			a;			// To WC_0 of bitstream_counter.v
   reg			inh_high_in;		// To WC_0 of bitstream_counter.v
   reg			inh_low_in;		// To WC_0 of bitstream_counter.v
   reg			inh_nedge_in;		// To WC_0 of bitstream_counter.v
   reg			inh_pedge_in;		// To WC_0 of bitstream_counter.v
   reg [P_N_WIDTH-1:0]	n_self_inh;		// To WC_0 of bitstream_counter.v
   reg [P_N_WIDTH-1:0]	period;			// To WC_0 of bitstream_counter.v
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
   bitstream_counter
     #(.P_N_WIDTH(P_N_WIDTH))
   WC_0(/*AUTOINST*/
	// Outputs
	.pedge				(pedge),
	.nedge				(nedge),
	.high				(high),
	.low				(low),
	.inh_pedge_out			(inh_pedge_out),
	.inh_nedge_out			(inh_nedge_out),
	.inh_high_out			(inh_high_out),
	.inh_low_out			(inh_low_out),
	.valid				(valid),
	.update				(update),
	.n_pedge			(n_pedge[P_N_WIDTH-1:0]),
	.n_nedge			(n_nedge[P_N_WIDTH-1:0]),
	.n_high				(n_high[P_N_WIDTH-1:0]),
	.n_low				(n_low[P_N_WIDTH-1:0]),
	// Inputs
	.clk				(clk),
	.rst				(rst),
	.inh_pedge_in			(inh_pedge_in),
	.inh_nedge_in			(inh_nedge_in),
	.inh_high_in			(inh_high_in),
	.inh_low_in			(inh_low_in),
	.n_self_inh			(n_self_inh[P_N_WIDTH-1:0]),
	.a				(a),
	.period				(period[P_N_WIDTH-1:0])); 
   
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
   integer i; 
   initial
     begin
	n_self_inh = 0; 
	i =0; 
	a = 0;		
   	inh_high_in = 0;	
   	inh_low_in = 0;	
   	inh_nedge_in = 0;	
   	inh_pedge_in = 0;	
	period = 100;	

	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1");

	//
	wait(update) #1; @(posedge clk) #1; 
	wait(update) #1; @(posedge clk) #1; 

	//
	wait(update) #1;
	for(i=0; i<100; i=i+1)
	  begin
	     @(posedge clk) a = 1; #1; 
	  end
	@(posedge clk) a = 0; #1;

	//
	wait(update) #1; 
	
	
	for(i=0; i<100; i=i+1)
	  @(posedge clk) a = !a; #1; 
	
	//
	wait(update) #1; @(posedge clk) #1; 
	wait(update) #1; @(posedge clk) #1; 
	
	for(i=0; i<1; i=i+1)
	  @(posedge clk) a = 0; #1; 

	//
	wait(update) #1; @(posedge clk) #1; 
	wait(update) #1; @(posedge clk) #1; 
	
	for(i=0; i<1; i=i+1)
	  @(posedge clk) a = 1; #1; 

	//
	wait(update) #1; @(posedge clk) #1; 
	wait(update) #1; @(posedge clk) #1; 
	
	for(i=0; i<1; i=i+1)
	  @(posedge clk) a = 0; #1; 

	
     end
   `endif

   //////////////////////////////////////////////////////////////////////
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../")
// End:
   
