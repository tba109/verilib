//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Mar 21 13:16:33 EDT 2019
//
// serial_ck.v
//
// Transmit a clock in 3 phases
// S0: Hold y0 for n0 cycles
// S1: Output msb of data after n1 cycles. 
// S2: Hold for n2 cycles. If we've output ncyc, go back to S0. Otherwise, return to S1.
//////////////////////////////////////////////////////////////////////////////////
module serial_ck #(parameter P_Y_INIT=0) 
  (
   input 	 clk, // clock
   input 	 rst, // active high resset
   input 	 y0, // idle output level 
   input [7:0] 	 ncyc, // number of data bits, minimum valid value is 1
   input [31:0]  n0, // number of cnt cycles in getting started, minimum valid value is 1
   input [31:0]  n1, // number of cnt cycles in the first half cycle, minimum valid value is 1
   input [31:0]  n2, // number of cnt cycles in the second half cycle, minimum valid value is 1
   input [31:0]  cnt, // everything marches to this
   output reg 	 y=P_Y_INIT // this is output, most significant bit (msb) goes first       
   );

   ///////////////////////////////////////////////////////////////////////////////
   // Internals
   wire [31:0] 	 i_n0 = n0==0 ? 1 : n0; 
   wire [31:0] 	 i_n1 = n1==0 ? 1 : n1; 
   wire [31:0] 	 i_n2 = n2==0 ? 1 : n2; 
   reg [31:0] 	 i_cnt_0_1=1; // cnt value for transition S0 to S1 
   reg [31:0] 	 i_cnt_1_2=1; // cnt value for transition S1 to S2
   reg [31:0] 	 i_cnt_2_1=1; // cnt value for transition S2 to S1
   reg [31:0] 	 cyc_cnt = 0; 
   
   ///////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   reg [1:0] fsm;
   localparam
     S0 = 0, 
     S1 = 1, 
     S2 = 2; 

`ifdef MODEL_TECH // This works well for modelsim
   reg [127:0] state_str;
   always @(*)
     case(fsm)
       S0: state_str = "S0";
       S1: state_str = "S1";
       S2: state_str = "S2";
     endcase // case (fsm)
`endif
   
   ///////////////////////////////////////////////////////////////////////////////
   // FSM Flow
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  y <= y0;
	  fsm <= S0;
	  cyc_cnt <= 0; 
       end
     else
       case(fsm)

	 S0:
	   begin
	      y <= y0;
	      i_cnt_0_1 <= n0;
	      i_cnt_1_2 <= n0+n1;
	      i_cnt_2_1 <= n0+n1+n2;
	      cyc_cnt <= 0; 
	      if(cnt == i_cnt_0_1)
		begin
		   y <= !y0;
		   fsm <= S1;
		end
	   end
	 
	 S1:
	   begin
	      if(cnt==i_cnt_1_2)
		begin
		   i_cnt_1_2 <= cnt + i_n1 + i_n2;
		   fsm <= S2;
		   y <= !y;
		end
	   end
	 
	 S2:
	   begin
	      if(cnt == i_cnt_2_1)
		begin
		   i_cnt_2_1 <= cnt + i_n1 + i_n2;
		   if(cyc_cnt == ncyc-1)
		     begin
			fsm <= S0;
			y <= y0;
		     end
		   else
		     begin
			fsm <= S1;
			y <= !y;
			cyc_cnt <= cyc_cnt + 1; 
		     end
		end
	   end
	 
	 default:
	   begin
	      y <= y0;
	      fsm <= S0;
	   end
    endcase // case (fsm)
      
endmodule
