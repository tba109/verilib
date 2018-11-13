///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Mon Jul 23 21:47:02 EDT 2018
//
// one_shot.v
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module one_shot
  (
   input clk,
   input rst,
   input a,
   output reg y = 0
   );

   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // Internals
   reg [26:0] cnt = 0; 
   localparam [26:0] MAX_CNT = 27'd100_000_000; 
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   localparam
     S_IDLE = 0,
     S_FIRE = 1;
   reg fsm = 0;
      
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // FSM Flow
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  fsm <= S_IDLE;
	  cnt <= 0;
	  y <= 0; 
       end
     else
       begin
	  case(fsm)
	    
	    S_IDLE:
	      begin
		 cnt <= 0;
		 y <= 0;
		 if(a)
		   fsm <= S_FIRE;
	      end
	    
	    S_FIRE:
	      begin
		 y <= 1; 
		 cnt <= cnt + 1;
		 if(cnt == MAX_CNT)
		   begin
		      fsm <= S_IDLE; 
		      cnt <= 0; 
		   end
	      end

	    default: fsm <= S_IDLE;
	    
	  endcase // case (fsm)
       end

   
endmodule
