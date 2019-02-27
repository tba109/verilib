//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed Feb 27 07:57:14 EST 2019
//
// tb.v
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
   parameter P_NBITS_DATA_IN = 14;
   parameter P_NBITS_DATA_OUT = 20;
   parameter P_NBITS_ADDR = 6; 
   parameter CLK_PERIOD = 10;
   reg clk;
   reg rst;

   // Connections
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [P_NBITS_DATA_OUT-1:0] sum;		// From GI_0 of gated_integrator.v
   wire			valid;			// From GI_0 of gated_integrator.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [P_NBITS_ADDR-1:0] addr;			// To GI_0 of gated_integrator.v
   reg			addr_en;		// To GI_0 of gated_integrator.v
   reg [P_NBITS_DATA_IN-1:0] d;			// To GI_0 of gated_integrator.v
   reg [P_NBITS_ADDR-1:0] n;			// To GI_0 of gated_integrator.v
   reg			wr;			// To GI_0 of gated_integrator.v
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
   gated_integrator GI_0(/*AUTOINST*/
			 // Outputs
			 .sum			(sum[P_NBITS_DATA_OUT-1:0]),
			 .valid			(valid),
			 // Inputs
			 .clk			(clk),
			 .rst			(rst),
			 .n			(n[P_NBITS_ADDR-1:0]),
			 .wr			(wr),
			 .d			(d[P_NBITS_DATA_IN-1:0]),
			 .addr_en		(addr_en),
			 .addr			(addr[P_NBITS_ADDR-1:0])); 
   
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
   
   // Data loader   
   integer i; 
   integer fin;
   reg [P_NBITS_DATA_OUT-1:0] fsum_0;
   reg [P_NBITS_DATA_OUT-1:0] fsum_1;
   reg [P_NBITS_DATA_OUT-1:0] fsum_2;
   reg [P_NBITS_DATA_OUT-1:0] fsum_3;
   reg 			      started; 
   reg 			      ok; 
   always @(posedge clk) if(valid) started <= 1; 
   always @(posedge clk) begin fsum_3 <= fsum_2; fsum_2 <= fsum_1; fsum_1 <= fsum_0; end	
   initial
     begin
	started = 0; 
	ok = 1; 
	clk = 0;
	rst = 1;
	addr = 0;
	addr_en = 0;
	d = 0;
	wr = 0; 
	n = 6'd16;
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 0;
	#(20* CLK_PERIOD);
	
	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1");

	fin = $fopen("../util/test.txt","r");
	
	$display("1.) read in 100 cycles, wait 1 cycle\n"); 
	for(i=0;i<100;i=i+1)
	  begin
	     @(posedge clk); 
	     wr <= 1; 
	     $fscanf(fin,"%d %d\n",d,fsum_0);
	  end
	@(posedge clk) wr <= 0;

	$display("2.) read in 100 cycles, wait 2 cycles\n"); 
	for(i=0;i<100;i=i+1)
	  begin
	     @(posedge clk); 
	     wr <= 1; 
	     $fscanf(fin,"%d %d\n",d,fsum_0);
	  end
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;

	$display("3.) read in 100 cycles, wait 3 cycles\n"); 
	for(i=0;i<100;i=i+1)
	  begin
	     @(posedge clk); 
	     wr <= 1; 
	     $fscanf(fin,"%d %d\n",d,fsum_0);
	  end
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;

	$display("4.) read in 100 cycles, wait 4 cycles\n"); 
	for(i=0;i<100;i=i+1)
	  begin
	     @(posedge clk); 
	     wr <= 1; 
	     $fscanf(fin,"%d %d\n",d,fsum_0);
	  end
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;

	$display("5.) read in 100 cycles of alterating read/wait, read/wait...\n"); 
	for(i=0;i<100;i=i+1)
	  begin
	     @(posedge clk); 
	     wr <= 1; 
	     $fscanf(fin,"%d %d\n",d,fsum_0);
	     @(posedge clk);
	     wr <= 0; 
	  end
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	
	
	while(!$feof(fin))
	  begin
	     @(posedge clk);
	     wr <= 1; 
	     $fscanf(fin,"%d %d\n",d,fsum_0);
	  end

	$fclose(fin);
	
	if(started && ok) $display("OK!\n"); else $display("ERR\n"); 
	
	// Stimulate UUT
     end
   
   // Data checker
   always @(posedge clk) if(valid && fsum_3 != sum) ok <= 0; 

   `endif

   //////////////////////////////////////////////////////////////////////
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../")
// End:
   
