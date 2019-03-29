//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed Mar 27 21:02:38 EDT 2019
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
   parameter CLK_PERIOD = 10;
   reg clk;
   reg rst;
   // Connections
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [11:0]		adr;			// From UART_PROC_0 of uart_proc.v
   wire			cmd_ack;		// From UART_PROC_0 of uart_proc.v
   wire [7:0]		rsp_data;		// From UART_PROC_0 of uart_proc.v
   wire			rsp_req;		// From UART_PROC_0 of uart_proc.v
   wire			wr;			// From UART_PROC_0 of uart_proc.v
   wire [15:0]		wr_data;		// From UART_PROC_0 of uart_proc.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [7:0]		cmd_data;		// To UART_PROC_0 of uart_proc.v
   reg			cmd_req;		// To UART_PROC_0 of uart_proc.v
   reg [15:0]		rd_data;		// To UART_PROC_0 of uart_proc.v
   reg			rsp_ack;		// To UART_PROC_0 of uart_proc.v
   reg 			err_ack;
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
   uart_proc UART_PROC_0(/*AUTOINST*/
			 // Outputs
			 .cmd_ack		(cmd_ack),
			 .rsp_req		(rsp_req),
			 .rsp_data		(rsp_data[7:0]),
			 .adr			(adr[11:0]),
			 .wr_data		(wr_data[15:0]),
			 .wr			(wr),
			 // Inputs
			 .clk			(clk),
			 .rst			(rst),
			 .cmd_req		(cmd_req),
			 .cmd_data		(cmd_data[7:0]),
			 .rsp_ack		(rsp_ack),
			 .rd_data		(rd_data[15:0]),
			 .err_ack               (err_ack)); 
   
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

   integer i = 0;
   always @(posedge clk) if(rsp_req) rsp_ack <= 1; else rsp_ack <= 0; 
   
   initial
     begin
	err_ack = 0; 
	cmd_data = 0;
	cmd_req = 0;
	rd_data = 16'hdeed;
	rsp_ack = 0;
	// Reset	
	#(10 * CLK_PERIOD);
	rst = 1'b0;
	#(20* CLK_PERIOD);

	// Logging
	$display("");
	$display("------------------------------------------------------");
	$display("Test Case: TEST_CASE_1");

	// Single Write 
	@(posedge clk) begin cmd_data = 8'h8f; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // HDR1
	@(posedge clk) begin cmd_data = 8'hc7; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // HDR0
	@(posedge clk) begin cmd_data = 8'h00; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // PID1
	@(posedge clk) begin cmd_data = 8'h01; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // PID0
	@(posedge clk) begin cmd_data = 8'h0a; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // ADR1
	@(posedge clk) begin cmd_data = 8'hbc; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // ADR0
	@(posedge clk) begin cmd_data = 8'hde; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_DATA1
	@(posedge clk) begin cmd_data = 8'hf1; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_DATA0
	@(posedge clk) begin cmd_data = 8'hc7; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_CRC1
	@(posedge clk) begin cmd_data = 8'h3d; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_CRC0
	// CRC should be 16'hc73d
	
	#(100*CLK_PERIOD); 
	// Single Read
	@(posedge clk) begin cmd_data = 8'h8f; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // HDR1
	@(posedge clk) begin cmd_data = 8'hc7; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // HDR0
	@(posedge clk) begin cmd_data = 8'h00; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // PID1
	@(posedge clk) begin cmd_data = 8'h02; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // PID0
	@(posedge clk) begin cmd_data = 8'h0a; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // ADR1
	@(posedge clk) begin cmd_data = 8'hbc; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // ADR0
	wait(rsp_req); wait(!rsp_req); // RD_DATA1
	wait(rsp_req); wait(!rsp_req); // RD_DATA0
	wait(rsp_req); wait(!rsp_req); // RD_CRC1
	wait(rsp_req); wait(!rsp_req); // RD_CRC0
	// CRC should be 16'h4776
	
	#(100*CLK_PERIOD); 
	// Burst Write 
	@(posedge clk) begin cmd_data = 8'h8f; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // HDR1
	@(posedge clk) begin cmd_data = 8'hc7; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // HDR0
	@(posedge clk) begin cmd_data = 8'h80; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // PID1
	@(posedge clk) begin cmd_data = 8'h01; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // PID0
	@(posedge clk) begin cmd_data = 8'h00; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // LEN1
	@(posedge clk) begin cmd_data = 8'h10; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // LEN0
	@(posedge clk) begin cmd_data = 8'h0a; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // ADR1
	@(posedge clk) begin cmd_data = 8'hbc; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // ADR0
	for(i=0; i < 16; i=i+1)
	  begin
	     @(posedge clk) begin cmd_data = 15-i; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // WR_DATA1
	     @(posedge clk) begin cmd_data = i; cmd_req = 1;    end wait(cmd_ack) @(posedge clk) cmd_req = 0;  wait(!cmd_ack); // WR_DATA0
	  end
	@(posedge clk) begin cmd_data = 8'h94; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_CRC1
	@(posedge clk) begin cmd_data = 8'hD8; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_CRC0
	// CRC should be 16'h94d8
	
	// Burst Read 
	#(100*CLK_PERIOD); rd_data <= 16'd0; 
	@(posedge clk) begin cmd_data = 8'h8f; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // HDR1
	@(posedge clk) begin cmd_data = 8'hc7; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // HDR0
	@(posedge clk) begin cmd_data = 8'h80; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // PID1
	@(posedge clk) begin cmd_data = 8'h02; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // PID0
	@(posedge clk) begin cmd_data = 8'h00; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // LEN1
	@(posedge clk) begin cmd_data = 8'h10; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // LEN0
	@(posedge clk) begin cmd_data = 8'h0a; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // ADR1
	@(posedge clk) begin cmd_data = 8'hbc; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // ADR0
	for(i=0; i < 16; i=i+1)
	  begin
	     wait(rsp_req); wait(!rsp_req);                                                  // RD_DATA1 
	     wait(rsp_req); wait(!rsp_req); @(posedge clk)  begin rd_data = rd_data + 1; end // RD_DATA0
	  end
	// CRC should be 16'hF42B
	
	// Partial command. This should reset eventually.
	#(100*CLK_PERIOD); rd_data <= 16'd0; 
	@(posedge clk) begin cmd_data = 8'h8f; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // HDR1
	@(posedge clk) begin cmd_data = 8'hc7; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // HDR0
	@(posedge clk) begin cmd_data = 8'h80; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // PID1
	@(posedge clk) begin cmd_data = 8'h02; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // PID0
	@(posedge clk) begin cmd_data = 8'h00; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; // LEN1

	#(1100*CLK_PERIOD); rd_data <= 16'd0; 
	
	// This checks that the interface still works
	// Single Write 
	@(posedge clk) begin cmd_data = 8'h8f; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // HDR1
	@(posedge clk) begin cmd_data = 8'hc7; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // HDR0
	@(posedge clk) begin cmd_data = 8'h00; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // PID1
	@(posedge clk) begin cmd_data = 8'h01; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // PID0
	@(posedge clk) begin cmd_data = 8'h0a; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // ADR1
	@(posedge clk) begin cmd_data = 8'hbc; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // ADR0
	@(posedge clk) begin cmd_data = 8'hde; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_DATA1
	@(posedge clk) begin cmd_data = 8'hf1; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_DATA0
	@(posedge clk) begin cmd_data = 8'hc7; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_CRC1
	@(posedge clk) begin cmd_data = 8'h3d; cmd_req = 1; end wait(cmd_ack) @(posedge clk) cmd_req = 0; wait(!cmd_ack); // WR_CRC0
	// CRC should be 16'hc73d
	
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
   
