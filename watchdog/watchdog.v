///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Mon Jul 30 13:02:56 EDT 2018
//
// watchdog.v
//
// A simple watchdog timer that compares a state to a known state and issues a reset if it doesn't appear in a 
// reasonable time frame. 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module watchdog #(parameter [63:0] P_CLK_FREQ_HZ=100000000, parameter [63:0] P_WATCH_NS=2000000000, parameter [63:0] P_KICK_NS=2000)
  (
   input 	clk,
   input 	rst_n, 
   input [31:0] watch_var,
   input [31:0] watch_val, 
   output reg 	kick = 0
   );

   reg 		state = 1;
   reg [31:0] 	cnt = 0;
   localparam [31:0] L_WATCH_CNT_MAX = P_WATCH_NS*P_CLK_FREQ_HZ/1000000000;
   localparam [31:0] L_KICK_CNT_MAX = P_KICK_NS*P_CLK_FREQ_HZ/1000000000; 
      
   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       begin
	  state <= 1;
	  kick <= 0; 
	  cnt <= 0;
       end
     else
       begin 
	  case(state)
	    
	    0: 
	      begin
		 kick <= 0;
		 cnt <= cnt + 1; 
		 if(watch_val == watch_var)
		   cnt <= 0; 
		 else if(cnt == L_WATCH_CNT_MAX)
		   begin 
		      state <= 1;
		      cnt <= 0;
		   end
	      end

	    1:
	      begin
		 kick <= 1;
		 cnt <= cnt + 1;
		 if(cnt == L_KICK_CNT_MAX)
		   begin
		      state <= 0;
		      cnt <= 0;
		   end
	      end
	  endcase // case (state)
       end
   
endmodule
