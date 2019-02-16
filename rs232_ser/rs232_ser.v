///////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed, Apr 01, 2015  4:43:49 PM
//
// rs232_ser.v
// "RS-232 Serializer"
// A custom Verilog HDL module
//
// Handshake in byte from upstream and RS-232 serialize it
//   No flow control
//   No parity
//   1 stop bit
//
// Clock rate needs to be >=2x baud rate for this to really work
// 
///////////////////////////////////////////////////////////////////////////////////////////

module rs232_ser
  (
   input       clk,                  // clock frequency
   input       rst_n,                // active low reset
   output reg  tx = 1'b1,            // serial RS-232 data
   input [7:0] tx_fifo_data,         // serial tx data
   output reg  tx_fifo_rd_en = 1'b0, // transmission request from upstream
   input       tx_fifo_empty         // acknowledge of acceptance to upstream
   );

`include "fncs.vh"
   
   parameter P_CLK_FREQ_HZ = 100000000;
   parameter P_BAUD_RATE = 9600;

   // Finite state machine
   reg [1:0]     fsm=2'd0;
   localparam
     S_IDLE  = 2'd0, // wait for TX req from upstream and handshake data in when you get it
     S_START = 2'd1, // transmit the start bit
     S_SHIFT = 2'd2, // shift out data byte (little endian)
     S_STOP  = 2'd3; // transmit the stop bit

   // Launch counter tells you where bit edges should be
   localparam LAUNCH_CNT_MAX = P_CLK_FREQ_HZ/P_BAUD_RATE;
   localparam NBITS_LAUNCH_CNT = clogb2(LAUNCH_CNT_MAX);
   reg [NBITS_LAUNCH_CNT-1:0] launch_cnt = {NBITS_LAUNCH_CNT{1'b0}};

   // Count the 8 bits to be shifted out
   reg [2:0] 	       shift_cnt = 3'd0;

   // Data shift register
   reg [7:0] 	       shift_reg = 8'd0;

   // FIFO read signal
   always @(posedge clk or negedge rst_n)
     if( !rst_n ) tx_fifo_rd_en <= 1'b0;
     else if( (fsm == S_IDLE) && !tx_fifo_empty) tx_fifo_rd_en <= 1'b1;
     else tx_fifo_rd_en <= 1'b0;
      
   // Finite State Machine
   always @(posedge clk or negedge rst_n)
     if( !rst_n )
       begin
	  fsm <= 2'd0;
	  tx  <= 1'b1;
	  shift_reg <= 8'd0;
       end
   
     else
       begin
	  case( fsm )
	    
	    S_IDLE:
	      begin
		 shift_cnt <= 3'd0;
		 launch_cnt <= {NBITS_LAUNCH_CNT-1{1'b0}};
		 if( !tx_fifo_empty ) 
		   fsm <= S_START;
	      end
	    	
	    S_START:
	      begin
		 tx <= 1'b0; // assert the start bit
		 if( launch_cnt == LAUNCH_CNT_MAX )
		   begin
		      shift_reg <= tx_fifo_data;
		      launch_cnt <= {NBITS_LAUNCH_CNT-1{1'b0}};
		      fsm <= S_SHIFT;
	           end
		 else
		   begin
		      launch_cnt <= launch_cnt + 1'b1;
		   end
	      end
		   		   
	    S_SHIFT:
	      begin
		 tx <= shift_reg[0];
		 if( (shift_cnt == 3'd7) && (launch_cnt == LAUNCH_CNT_MAX) )
		   begin
		      shift_reg <= {1'b0,shift_reg[7:1]};
		      shift_cnt <= 3'd0;
		      launch_cnt <= {NBITS_LAUNCH_CNT-1{1'b0}};
		      fsm <= S_STOP;
		   end
		 else if( launch_cnt == LAUNCH_CNT_MAX )
		   begin
		      shift_reg <= {1'b0,shift_reg[7:1]};
		      shift_cnt <= shift_cnt + 1'b1;
		      launch_cnt <= {NBITS_LAUNCH_CNT-1{1'b0}};
		   end
		 else
		   begin
		      launch_cnt <= launch_cnt + 1'b1;
		   end 
	      end

	    S_STOP:
	      begin
		 tx <= 1'b1; // assert the stop bit (active low)
		 if( launch_cnt == LAUNCH_CNT_MAX )
		   begin
		      launch_cnt <= {NBITS_LAUNCH_CNT-1{1'b0}};
		      fsm <= S_IDLE;
	           end
		 else
		   begin
		      launch_cnt <= launch_cnt + 1'b1;
		   end
	      end

	    default: fsm <= S_IDLE;

	  endcase // case ( fsm )
       end
   
endmodule
