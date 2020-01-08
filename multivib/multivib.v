///////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue 08/27/2019_21:47:43.01
//
// multivib.v
//
// Multivibrator.
// n0 determines the startup delay
// n1 determines the number of cycles in the 1st phase of cycle,
// n2 determines the number of cycles in the 2nd phase of cycle,
// y0 is the starting value
// input en   
module multivib
  (
   input 	clk,
   input 	rst,
   input 	en,
   input [31:0] n0, 
   input [31:0] n1,
   input [31:0] n2,
   input 	y0,
   output 	y
   );
   
   reg 		i_y = 0; 
   reg [31:0] 	cnt;
   localparam
     S0=0,
     S1=1,
     S2=2; 
   reg [1:0] 	fsm=0; 
   
   assign y = en ? i_y : y0; 
   always @(posedge clk)
     if(rst)
       begin
	  fsm <= S0;
	  i_y <= y0;
	  cnt <= 0; 
       end
     else if(!en)
       begin
	  fsm <= S0;
	  i_y <= y0;
	  cnt <= 0;
       end
     else
       begin
	  case(fsm)
	  
	    S0:
	      begin
		 i_y <= y0; 
		 cnt <= cnt + 1;
		 if(cnt == n0-1)
		   fsm <= S1; 
	      end
	    
	    S1:
	      begin
		 if(!en)
		   fsm <= S0;
		 else
		   begin
		      cnt <= cnt + 1; 
		      if(cnt == n0+n1-1)
			fsm <= S2; 
		   end
	      end
	    
	    S2:
	      begin
		 if(!en)
		   fsm <= S0;
		 else
		   begin
		      i_y <= !y0; 
		      cnt <= cnt + 1;
		      if(cnt == n0+n1+n2-1)
			begin 
			   i_y <= y0; 
			   fsm <= S1;
			   cnt <= n0;
			end
		   end
	      end
	    
	    default: fsm <= S0;
	  endcase
       end  
          
endmodule
