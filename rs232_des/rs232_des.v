///////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed, Apr 01, 2015 10:59:20 AM
//
// rs232_des.v
// "RS-232 Deserializer"
// A custom Verilog HDL module
//
// Deserialize RS-232 communication and handshake each character downstream
//   No flow control
//   No parity
//   1 stop bit
//
// Tue 07/30/2019_16:11:48.24
// Had to shorten STOP_LATCH_CNT for a 3Mbaud with 60MHz clock
// Had to shorten START_LATCH_CNT for a 3Mbaud with 60MHz clock
//
// Mon 08/05/2019_22:37:30.40
// Change from paramaterization in terms of clock rate and baud rate to  
///////////////////////////////////////////////////////////////////////////////////////////


module rs232_des
  (
   input 	    clk,                  // clock frequency
   input 	    rst_n,                // active low reset
   input 	    rx,                   // serial RS-232 data
   output reg [7:0] rx_fifo_data = 8'b0,  // ascii data byte
   output reg 	    rx_fifo_wr_en = 1'b0, // request for downstream module to accept character
   input 	    rx_fifo_full          // acknowledgement of acceptance from downstream
   );

   // ceiling(log2()), used to figure out counter size.   
   function integer clogb2;
      input integer value;
      for(clogb2=0;value>0;clogb2=clogb2+1)
	value = value >> 1;
   endfunction // for
        
   // Finite state machine
   reg [1:0] 	    fsm=2'd0;
   localparam
     S_IDLE  = 2'd0, // sit around waiting for a start bit
     S_START = 2'd1, // wait for the start bit to finish
     S_SHIFT = 2'd2, // shift in the serial data byte (little endian) and notify downstream when finished
     S_STOP  = 2'd3; // wait for the stop bit to finish
         
   // Synchronize rx into the clk domain and detect it's positive edgeOA
   wire 	    rx_s;
   wire 	    rx_s_nedge;
   sync SYNC0(.clk(clk), .rst_n(rst_n), .a(rx), .y(rx_s));
   negedge_detector NEDGE0(.clk(clk), .rst_n(rst_n), .a(rx_s), .y(rx_s_nedge));
   
   // Count to the center of each bit and latch on it
   parameter P_START_LATCH_CNT_MAX = 7;
   parameter P_SHIFT_LATCH_CNT_MAX = 20;
   parameter P_STOP_LATCH_CNT_MAX = 20;
   localparam NBITS_LATCH_CNT = clogb2(P_SHIFT_LATCH_CNT_MAX-1);
   reg [NBITS_LATCH_CNT-1:0]  latch_cnt={NBITS_LATCH_CNT{1'b0}};

   // Count the 8 bits to be shifted in
   reg [2:0] 	    shift_cnt=3'd0;

   // FIFO write signal (watch out for break condition)
   always @(posedge clk or negedge rst_n )
     if( !rst_n ) rx_fifo_wr_en <= 1'b0;
     else if( (fsm == S_STOP) && (latch_cnt == P_STOP_LATCH_CNT_MAX-1) && (rx_s == 1'b1) && !rx_fifo_full ) rx_fifo_wr_en <= 1'b1;
     else rx_fifo_wr_en <= 1'b0;
     
   // Finite State Machine
   always @(posedge clk or negedge rst_n)
     if( !rst_n ) 
       begin
	  latch_cnt <= {NBITS_LATCH_CNT{1'b0}}; 
          shift_cnt <= 3'd0; 
	  rx_fifo_data <= 8'd0;
	  fsm <= S_IDLE;
       end
     
     else
       begin
	  case( fsm )
	    
	    S_IDLE:
	      begin
		 latch_cnt <= {NBITS_LATCH_CNT-1{1'b0}};
		 shift_cnt <= 3'd0;
		 if( rx_s_nedge )
		   fsm <= S_START;
	      end
		 
	    S_START: 
	      if( latch_cnt == P_START_LATCH_CNT_MAX-1 )
		begin
		   latch_cnt <= {NBITS_LATCH_CNT-1{1'b0}}; 
	           fsm <= S_SHIFT; 
	        end
	      else 
                begin
		   latch_cnt <= latch_cnt + 1'b1;
		end
	    
	    S_SHIFT: 
	      if( (shift_cnt == 3'd7) && (latch_cnt == P_SHIFT_LATCH_CNT_MAX-1) )   
		begin
		   rx_fifo_data <= {rx_s,rx_fifo_data[7:1]}; // RS-232 is little endian
		   shift_cnt <= 3'b0;
		   latch_cnt <= {NBITS_LATCH_CNT-1{1'b0}}; 
		   fsm <= S_STOP;  
		end
	      else if( latch_cnt == P_SHIFT_LATCH_CNT_MAX-1 )
		begin
		   rx_fifo_data <= {rx_s,rx_fifo_data[7:1]}; // RS-232 is little endian
		   shift_cnt <= shift_cnt + 1'b1;
		   latch_cnt <= {NBITS_LATCH_CNT-1{1'b0}};
		end
	      else
		begin
		   latch_cnt <= latch_cnt + 1'b1;
		end
	 
	    S_STOP:  
	      if( latch_cnt == P_STOP_LATCH_CNT_MAX-1 )   
		begin 
		   latch_cnt <= {NBITS_LATCH_CNT-1{1'b0}}; 
	           fsm <= S_IDLE;
	        end
	      else
		begin
		   latch_cnt <= latch_cnt + 1'b1;
		end

	    default: fsm <= S_IDLE;
	    
	  endcase // case ( fsm )
       end
   
endmodule // rs232_des

