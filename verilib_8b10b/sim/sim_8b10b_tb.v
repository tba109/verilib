//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed Apr 27 14:18:47 EDT 2022
//
// sim_8b10b_tb.v
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

//////////////////////////////////////////////////////////////////////////////////
// Test cases
//////////////////////////////////////////////////////////////////////////////////
// `define TEST_CASE_1 // counter through normal symbols and all commas
`define TEST_CASE_2 // force running disparity and generate whole table

module sim_8b10b_tb;
   
   //////////////////////////////////////////////////////////////////////
   // I/O
   //////////////////////////////////////////////////////////////////////   
   integer f; 
   parameter CLK_PERIOD = 20;
   reg clk;
   reg rst;

   // Wires
   wire [9:0]		data_out_enc;
   wire [7:0] 		data_out_dec; 
   wire			is_k_dec;    
   wire			rd_dec;	     
   wire			valid_enc;   
   wire 		valid_dec; 
   
   // Regs
   reg [7:0] 		data_in_enc; 
   reg			k_en_enc;			
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
   encode_8b10b ENCODE_8B10B_0(/*AUTOINST*/
			       // Outputs
			       .data_out	(data_out_enc[9:0]),
			       .rd		(rd_enc),
			       .valid		(valid_enc),
			       // Inputs
			       .clk		(clk),
			       .rst		(rst),
			       .k_en		(k_en_enc),
			       .data_in		(data_in_enc[7:0]));
   decode_8b10b DECODE_8B10B_0(/*AUTOINST*/
			       // Outputs
			       .data_out	(data_out_dec[7:0]),
			       .valid		(valid_dec),
			       .is_k		(is_k_dec),
			       // Inputs
			       .clk		(clk),
			       .rst		(rst),
			       .data_in		(data_out_enc[9:0])); 
   
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
   // Tasks (e.g., writing data, etc.)
   //////////////////////////////////////////////////////////////////////   
   
   //////////////////////////////////////////////////////////////////////
   // Test case
   //////////////////////////////////////////////////////////////////////   
   `ifdef TEST_CASE_1
   integer i; 
   initial
     begin
	data_in_enc = 8'd0;
	k_en_enc = 1'b0; 
	i = 0; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1");

	for(i=0; i<256; i=i+1)
	  begin
	     @(posedge clk) data_in_enc = i; #1;  
	  end
	@(posedge clk) #1; 
	
	for(i=0; i<256; i=i+1)
	  begin
	     @(posedge clk) data_in_enc = i; k_en_enc = 1'b1; #1; 
	  end

	$display("Done!\n"); 
	// Stimulate UUT
     end
   `endif


   `ifdef TEST_CASE_2
   integer i;
   reg 	   fwrite_en; 
   reg [7:0] k_in;
   always @(*)
     case(i[3:0])
        0: k_in = 8'h1c;
        1: k_in = 8'h3c;
        2: k_in = 8'h5c;
        3: k_in = 8'h7c;
        4: k_in = 8'h9c;
        5: k_in = 8'hbc;
        6: k_in = 8'hdc;
        7: k_in = 8'hf7;
        8: k_in = 8'hfb;
        9: k_in = 8'hfc;
       10: k_in = 8'hfd;
       11: k_in = 8'hfe;
       default: k_in = 0;
     endcase // case (i[3:0])
   
   initial
     begin
	fwrite_en = 1'b0; 
	data_in_enc = 8'd0;
	k_en_enc = 1'b0; 
	i = 0; 
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_2");

	force ENCODE_8B10B_0.rd = 1'b0; 
	for(i=0; i<256; i=i+1)
	  begin
	     @(posedge clk) data_in_enc = i; #1;
	     if(i==1) fwrite_en = 1'b1; 
	  end
	@(posedge clk) #1;
	@(posedge clk) #1; 
	@(posedge clk) fwrite_en = 1'b0; #1; 

	force ENCODE_8B10B_0.rd = 1'b1; 
	for(i=0; i<256; i=i+1)
	  begin
	     @(posedge clk) data_in_enc = i; #1;
	     if(i==1) fwrite_en = 1'b1; 
	  end
	@(posedge clk) #1;
	@(posedge clk) #1; 
	@(posedge clk) fwrite_en = 1'b0; #1; 

	force ENCODE_8B10B_0.rd = 1'b0; 
	for(i=0; i<12; i=i+1)
	  begin
	     @(posedge clk) data_in_enc = k_in; k_en_enc = 1'b1; #1;
	     if(i==1) fwrite_en = 1'b1; 
	  end
	@(posedge clk) #1;
	@(posedge clk) #1; 
	@(posedge clk) fwrite_en = 1'b0; #1; 

	force ENCODE_8B10B_0.rd = 1'b1; 
	for(i=0; i<12; i=i+1)
	  begin
	     @(posedge clk) data_in_enc = k_in; k_en_enc = 1'b1; #1;
	     if(i==1) fwrite_en = 1'b1; 
	  end
	@(posedge clk) #1;
	@(posedge clk) #1; 
	@(posedge clk) fwrite_en = 1'b0; #1; 

	release ENCODE_8B10B_0.rd; 
	
	$display("Done!\n"); 
	$fclose(f);
	// Stimulate UUT
     end
  
    initial
     begin 
	f = $fopen("../../../../hdl/verilib_8b10b/sim/sim_8b10b_tb_out.txt","w");
	$fwrite(f,"i,rd,is_k,data_out,rd_out\n");
     end

   reg enc_rd_prev;
   reg [7:0] data_in_0;
   reg [7:0] data_in_1;
   reg [7:0] data_in_2; 
   always @(posedge clk)
     begin
	data_in_0 <= ENCODE_8B10B_0.data_in;
	data_in_1 <= data_in_0;
	data_in_2 <= data_in_1; 
	enc_rd_prev <= ENCODE_8B10B_0.rd; 
     end
   
   always @(posedge clk)
     begin
	if(!rst && fwrite_en)
	  begin 	     
	     $fwrite(f,"%d %d %d 0x%x %d\n",data_in_1,enc_rd_prev,ENCODE_8B10B_0.k_en,ENCODE_8B10B_0.data_out,ENCODE_8B10B_0.rd);
	  end 
     end
   

   `endif

   
  endmodule

// Local Variables:
// verilog-library-flags:("-y ../hdl/")
// End:
   
