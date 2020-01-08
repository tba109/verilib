//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Mar 21 13:16:33 EDT 2019
//
// serial_tx.v
//
// Transmit a data word serially, MSB first.
// Transmission happens in 3 phases:
// S0: Hold y0 for n0 cycles
// S1: Output msb of data for n1 cycles
//////////////////////////////////////////////////////////////////////////////////

module serial_tx #(parameter P_Y_INIT=0, parameter P_DATA_WIDTH=256) 
  (
   input 		    clk, // clock
   input 		    rst, // active high resset
   input 		    y0, // idle output level 
   input [P_DATA_WIDTH-1:0] data, // data to be shifted out, msb first
   input [7:0] 		    nbits, // number of data bits, minimum valid value is 1
   input [31:0] 	    n0, // number of cnt cycles in getting started, minimum valid value is 1
   input [31:0] 	    n1, // number of cnt cycles in the first half cycle, minimum valid value is 1
   input [31:0] 	    cnt, // everything marches to this
   output reg 		    y=P_Y_INIT // this is output, most significant bit (msb) goes first       
   );

   ///////////////////////////////////////////////////////////////////////////////
  // Internals
   wire [31:0] 		    i_n0 = n0==0 ? 1 : n0; 
   wire [31:0] 		    i_n1 = n1==0 ? 1 : n1; 
   reg [31:0] 		    i_cnt_0 = 1; // cnt value for transition S0 to S1 
   reg [31:0] 		    i_cnt_1 = 1; // cnt value for transition S1 to S2
   reg [P_DATA_WIDTH-1:0]   sr = 0; 
   reg [7:0] 		    sr_cnt = 0; 
   
   ///////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   reg [0:0] fsm;
   localparam
     S0 = 0, 
     S1 = 1; 
        
`ifdef MODEL_TECH // This works well for modelsim
   reg [127:0] state_str;
   always @(*)
     case(fsm)
       S0: state_str = "S0";
       S1: state_str = "S1";
     endcase // case (fsm)
`endif
   
   ///////////////////////////////////////////////////////////////////////////////
   // FSM Flow
   always @(posedge clk)
     if(rst)
       begin
	  y <= y0;
	  fsm <= S0;
	  sr <= data;
	  sr_cnt <= 0; 
       end
     else
       case(fsm)

	 S0:
	   begin
	      sr <= data;
	      sr_cnt <= 0; 
	      y <= y0;
	      i_cnt_0 <= n0;
	      i_cnt_1 <= n0+n1;
	      if(cnt == i_cnt_0)
		begin
		   y <= (sr >> nbits-1) & 1;
		   sr <= {sr[P_DATA_WIDTH-2:0],1'b0};
		   fsm <= S1;
		end
	   end
	 
	 S1:
	   begin
	      if(cnt==i_cnt_1)
		begin
		   i_cnt_1 <= cnt + i_n1;
		   sr_cnt <= sr_cnt + 1; 
		   y <= (sr >> nbits-1) & 1;
		   sr <= {sr[P_DATA_WIDTH-2:0],1'b0};
		   if(sr_cnt == nbits-1)
		     begin
			fsm <= S0;
			y <= y0;
		     end
		end
	   end
	 	 
	 default:
	   begin
	      fsm <= S0;
	   end
    endcase // case (fsm)
   
   
endmodule
