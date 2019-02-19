//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Sat Feb 16 11:07:16 EST 2019
//
//////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

//////////////////////////////////////////////////////////////////////////////////////////////////
// Test cases
//////////////////////////////////////////////////////////////////////////////////////////////////
// `define TEST_CASE_N_16
// `define TEST_CASE_N_16_ADDR_EN
// `define TEST_CASE_FLUSH
`define TEST_CASE_RESET

module tb;
   
   //////////////////////////////////////////////////////////////////////
   // I/O
   //////////////////////////////////////////////////////////////////////   
   parameter CLK_PERIOD = 10;
   reg clk;
   reg rst;
   parameter P_NBITS_DATA = 42;
   parameter P_NBITS_ADDR = 9; 
   wire [P_NBITS_DATA-1:0] qo;			// From RAM_DELAY_0 of ram_delay.v
   wire [P_NBITS_DATA-1:0] qn;			// From RAM_DELAY_0 of ram_delay.v
   wire			valid;			// From RAM_DELAY_0 of ram_delay.v
   reg [P_NBITS_DATA-1:0] d;			// To RAM_DELAY_0 of ram_delay.v
   reg [P_NBITS_ADDR-1:0] n;		// To RAM_DELAY_0 of ram_delay.v
   reg 			  wr;			// To RAM_DELAY_0 of ram_delay.v
   reg 			  flush; 
   reg 			  addr_en;
   reg [P_NBITS_ADDR-1:0] addr; 
   
   //////////////////////////////////////////////////////////////////////
   // Clock Driver
   //////////////////////////////////////////////////////////////////////
   always @(clk)
     #(CLK_PERIOD / 2.0) clk <= !clk;
				   
   //////////////////////////////////////////////////////////////////////
   // Simulated interfaces
   //////////////////////////////////////////////////////////////////////   
   reg 			  ok = 1; 
   reg [P_NBITS_DATA-1:0] qn_prev=0;
   always @(posedge clk) 
     if(valid)
       qn_prev <= qn; 
   always @(posedge clk)
     if(valid && (qn+n!=qo) && (qn_prev+1!=qn))
       ok <= 0; 
      
   //////////////////////////////////////////////////////////////////////
   // UUT
   //////////////////////////////////////////////////////////////////////   
   ram_delay #(.P_NBITS_ADDR(P_NBITS_ADDR),.P_NBITS_DATA(P_NBITS_DATA)) RAM_DELAY_0
     (
      // Outputs
      .qn			(qn[P_NBITS_DATA-1:0]),
      .qo			(qo[P_NBITS_DATA-1:0]),
      .valid			(valid),
      // Inputs
      .clk			(clk),
      .rst                      (rst), 
      .flush                     (flush), 
      .addr_en                  (addr_en),
      .addr                     (addr), 
      .n		        (n[P_NBITS_ADDR-1:0]),
      .wr			(wr),
      .d			(d[P_NBITS_DATA-1:0])
      ); 
   
   //////////////////////////////////////////////////////////////////////
   // Test case
   //////////////////////////////////////////////////////////////////////   

   `ifdef TEST_CASE_N_16
   integer 		i = 0; 
   initial
     begin
	clk = 1'b0;
	rst = 1'b0; 
	wr <= 0; 
	d <= {P_NBITS_DATA{1'b1}};
	n <= 9'd16;
	flush <= 0; 
	addr_en <= 0;
	addr <= 0; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);
	
	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_N_16");
	
	// 
	$display("1.) 20 writes with 1 cycle delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end
	@(posedge clk) wr <= 0;

	
	// 
	$display("2.) 20 writes with 2 cycles of delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end 
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;

	// 
	$display("3.) 20 writes with 3 cycles of delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end 
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	
	// 
	$display("4.) 20 writes with 4 cycles of delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end 
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	
	// 
	$display("5.) write-delay, 10 cycles\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; @(posedge clk) wr <= 0; end 	
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;


	$display("6.) 20 final cycles of write\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end 
	@(posedge clk) wr <= 0;
	
	// Check
	if(ok) $display("OK\n"); else $display("ERR\n"); 
	
     end
   `endif

   
   `ifdef TEST_CASE_N_16_ADDR_EN
   always @(posedge clk)
     if(wr)
       begin
	  addr <= addr + 1;
	  if(addr==n-1)
	    addr <= 0;
       end
   
   integer 		i = 0; 
   initial
     begin
	clk = 1'b0;
	rst = 1'b0; 
	wr <= 0; 
	d <= {P_NBITS_DATA{1'b1}};
	n <= 9'd16;
	flush <= 0; 
	addr_en <= 1;
	addr <= 1; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);
	
	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_N_16_ADDR_EN");
	
	// 
	$display("1.) 20 writes with 1 cycle delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end
	@(posedge clk) wr <= 0;

	
	// 
	$display("2.) 20 writes with 2 cycles of delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end 
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;

	// 
	$display("3.) 20 writes with 3 cycles of delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end 
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	
	// 
	$display("4.) 20 writes with 4 cycles of delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end 
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	
	// 
	$display("5.) Read-write....10 cycles each, then 1 cycle of delay\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; @(posedge clk) wr <= 0; end 
	
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
	@(posedge clk) wr <= 0;
		
	$display("6.) 20 final cycles of write\n"); 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; end 
	@(posedge clk) wr <= 0;
	
	// Check
	if(ok) $display("OK\n"); else $display("ERR\n"); 
	
     end
   `endif

   `ifdef TEST_CASE_FLUSH
   integer 		i = 0; 
   initial
     begin
	clk = 1'b0;
	rst = 1'b1; 
	wr = 0; 
	d = {P_NBITS_DATA{1'b1}};
	n = 9'd16;
	flush = 0; 
	addr_en = 0;
	addr = 0; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);
	
	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_FLUSH");
	
	// 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=42'h3ffffffffff; end
	@(posedge clk); wr <= 0;
	for(i=0; i<16; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; flush <= 1; end
	@(posedge clk); flush <= 0; 
     end // initial begin
   `endif

   `ifdef TEST_CASE_RESET
   integer 		i = 0; 
   initial
     begin
	clk = 1'b0;
	rst = 1'b1; 
	wr = 0; 
	d = {P_NBITS_DATA{1'b1}};
	n = 9'd16;
	flush = 0; 
	addr_en = 0;
	addr = 0; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);
	
	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_FLUSH");
	
	// 
	for(i=0; i<20; i=i+1) begin @(posedge clk); wr <= 1; d<=42'h3ffffffffff; end
	@(posedge clk); wr <= 0;
	for(i=0; i<16; i=i+1) begin @(posedge clk); wr <= 1; d<=d+1; flush <= 1; end
	@(posedge clk); flush <= 0; 
     end // initial begin
   `endif

   
   //////////////////////////////////////////////////////////////////////
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../")
// End:
   
