// Triggers on a positive edge
module one_shot #(parameter P_N_WIDTH=32, parameter P_IO_WIDTH=1)
  (
   input 		   clk,
   input 		   rst_n,
   input 		   trig, 
   input [P_N_WIDTH-1:0]   n0,
   input [P_N_WIDTH-1:0]   n1, 
   input [P_IO_WIDTH-1:0]  a0,
   input [P_IO_WIDTH-1:0]  a1, 
   output 		   busy, 
   output [P_IO_WIDTH-1:0] y
   );

   // Positive edge detector on a
   reg 	      trig_0 = 0;
   always @(posedge clk or negedge rst_n) begin if(!rst_n) trig_0 <= 0; else trig_0 <= trig; end 
   wire       trig_pe;
   assign trig_pe = trig && !trig_0; 
   
   // FSM for oneshot
   reg [P_N_WIDTH-1:0] cnt=0;
   reg [1:0] 	       fsm = 0; 
   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       begin
	  fsm <= 0; 
	  cnt <= 0; 
       end
     else
       begin
	  case(fsm)
	    
	    0:
	      begin
		 cnt <= 0;
		 if(trig_pe)
		   begin
		      if(n0==0 && n1!=0)
			fsm <= 2;
		      else if(n1!=0)
			fsm <= 1;
		   end
	      end

	    1:
	      begin
		 cnt <= cnt + 1;
		 if(cnt == n0-1)
		   begin
		      cnt <= 0; 
		      if(n1==0)
			fsm <= 0;
		      else
			fsm <= 2;
		   end
	      end
	    
	    2:
	      begin 
		 cnt <= cnt + 1; 
		 if(cnt== n1-1)
		   begin 
		      cnt <= 0;
		      fsm <= 0; 
		   end 
	      end 

	    default: fsm <= 0; 
	    
	  endcase
       end

   // Output assignments
   assign y    = fsm==2 ? a1 : a0; 
   assign busy = fsm!=0; 
      
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
