
`timescale 1ns/1ns

//////////////////////////////////////////////////////////////////////////////////
// Test cases
//////////////////////////////////////////////////////////////////////////////////
// `define TEST_CASE_1 // deadtime = 0, period = 400
// `define TEST_CASE_2 // deadtime = 1, period = 400
// `define TEST_CASE_3 // deadtime = 2, period = 400
// `define TEST_CASE_4 // deadtime = 3, period = 400
// `define TEST_CASE_5 // deadtime = 4, period = 400
`define TEST_CASE_6 // deadtime = 10, period = 400


module tb;
   
   //////////////////////////////////////////////////////////////////////
   // I/O
   //////////////////////////////////////////////////////////////////////   
   parameter CLK_PERIOD = 16.667;
   reg clk;
   reg rst;


   parameter P_N_WIDTH = 32; 
   // Connections
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [P_N_WIDTH-1:0]	cnt;			// From UUT_0 of rate_scaler_four_lane.v
   wire			dead;			// From UUT_0 of rate_scaler_four_lane.v
   wire			update;			// From UUT_0 of rate_scaler_four_lane.v
   wire			valid;			// From UUT_0 of rate_scaler_four_lane.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			a_0;			// To UUT_0 of rate_scaler_four_lane.v
   reg			a_1;			// To UUT_0 of rate_scaler_four_lane.v
   reg			a_2;			// To UUT_0 of rate_scaler_four_lane.v
   reg			a_3;			// To UUT_0 of rate_scaler_four_lane.v
   reg [P_N_WIDTH-1:0] 	deadtime;		// To UUT_0 of rate_scaler_four_lane.v
   reg [P_N_WIDTH-1:0]	period;			// To UUT_0 of rate_scaler_four_lane.v
   reg [15:0] 		subcase; 
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
   rate_scaler_four_lane #(.P_N_WIDTH(32)) UUT_0(/*AUTOINST*/
			       // Outputs
			       .valid		(valid),
			       .update		(update),
			       .dead		(dead),
			       .cnt		(cnt[P_N_WIDTH-1:0]),
			       // Inputs
			       .clk		(clk),
			       .rst		(rst),
			       .a_0		(a_0),
			       .a_1		(a_1),
			       .a_2		(a_2),
			       .a_3		(a_3),
			       .period		(period[P_N_WIDTH-1:0]),
			       .deadtime	(deadtime)); 
   
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
	a_0 = 1'b0;
	a_1 = 1'b0;
	a_2 = 1'b0;
	a_3 = 1'b0;
	deadtime = 0;
	period = 400; 
	subcase = 9; 
	
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1");
	
	// 0: 0,1
	if(subcase==0)
	  begin 
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end	     
	  end
	
	// 1: 1,2
	if(subcase==1)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 1; a_2 = 1; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	// 2: 2,3
	if(subcase==2)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end	     
	  end
	
	// 3: 3; 0
	if(subcase==3)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	// 4: 3; 1
	if(subcase==4)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 1; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	
	// 5: 3; 3
	if(subcase==5)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	// 6: 3; 0,1,2,3; 0,1,2,3
	if(subcase==6)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	// 7: 2,3; 0,1,2,3; 0,1,2,3
	if(subcase==7)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	
	// 8: 0,1,2,3; 0,3; 0
	if(subcase==8)
	  begin 
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end
	
	// 8: 0,1,2,3; 0,3; 1
	if(subcase==9) 
	  begin 
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 1; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end
     end   
   `endif

   `ifdef TEST_CASE_2
   initial
     begin
	a_0 = 1'b0;
	a_1 = 1'b0;
	a_2 = 1'b0;
	a_3 = 1'b0;
	deadtime = 0;
	period = 400; 
	subcase = 9; 
	
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_2");

	// Stimulate UUT
	#(101*CLK_PERIOD);


	// 0: 0,1
	if(subcase==0)
	  begin 
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end	     
	  end
	
	// 1: 1,2
	if(subcase==1)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 1; a_2 = 1; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	// 2: 2,3
	if(subcase==2)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end	     
	  end
	
	// 3: 3; 0
	if(subcase==3)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	// 4: 3; 1
	if(subcase==4)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 1; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	
	// 5: 3; 3
	if(subcase==5)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	// 6: 3; 0,1,2,3; 0,1,2,3
	if(subcase==6)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	// 7: 2,3; 0,1,2,3; 0,1,2,3
	if(subcase==7)
	  begin 
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end

	
	// 8: 0,1,2,3; 0,3; 0
	if(subcase==8)
	  begin 
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end
	
	// 8: 0,1,2,3; 0,3; 1
	if(subcase==9) 
	  begin 
	     @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 1; a_1 = 0; a_2 = 0; a_3 = 1; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 1; a_2 = 0; a_3 = 0; #1;   end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end
	  end
	
     end
   `endif

   `ifdef TEST_CASE_3
   integer i; 
   initial
     begin
	a_0 = 1'b0;
	a_1 = 1'b0;
	a_2 = 1'b0;
	a_3 = 1'b0;
	deadtime = 2;
	period = 400; 
	i = 0; 
	subcase = 0; 
	
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_3");

	// Stimulate UUT
	#(101*CLK_PERIOD);

	// 0: 
	if(subcase==0)
	  begin
	     for(i=0; i<50; i=i+1)
	       begin
		  @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	       end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end	     
	  end

     end
   `endif

   `ifdef TEST_CASE_4
   integer i; 
   initial
     begin
	a_0 = 1'b0;
	a_1 = 1'b0;
	a_2 = 1'b0;
	a_3 = 1'b0;
	deadtime = 3;
	period = 400; 
	i = 0; 
	subcase = 0; 
	
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_3");

	// Stimulate UUT
	#(101*CLK_PERIOD);

	// 0: 
	if(subcase==0)
	  begin
	     for(i=0; i<50; i=i+1)
	       begin
		  @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	       end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end	     
	  end

     end
   `endif

   
   `ifdef TEST_CASE_5
   integer i; 
   initial
     begin
	a_0 = 1'b0;
	a_1 = 1'b0;
	a_2 = 1'b0;
	a_3 = 1'b0;
	deadtime = 4;
	period = 400; 
	i = 0; 
	subcase = 0; 
	
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_3");

	// Stimulate UUT
	#(101*CLK_PERIOD);

	// 0: 
	if(subcase==0)
	  begin
	     for(i=0; i<50; i=i+1)
	       begin
		  @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	       end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end	     
	  end

     end
   `endif

   `ifdef TEST_CASE_6
   integer i; 
   initial
     begin
	a_0 = 1'b0;
	a_1 = 1'b0;
	a_2 = 1'b0;
	a_3 = 1'b0;
	deadtime = 10;
	period = 400; 
	i = 0; 
	subcase = 0; 
	
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_3");

	// Stimulate UUT
	#(101*CLK_PERIOD);

	// 0: 
	if(subcase==0)
	  begin
	     for(i=0; i<50; i=i+1)
	       begin
		  @(posedge clk) begin a_0 = 1; a_1 = 1; a_2 = 1; a_3 = 1; #1;   end
	       end
	     @(posedge clk) begin a_0 = 0; a_1 = 0; a_2 = 0; a_3 = 0; #1;   end	     
	  end

     end
   `endif
   
   //////////////////////////////////////////////////////////////////////
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../")
// End:
   
