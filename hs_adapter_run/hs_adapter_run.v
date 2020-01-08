//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed 10/09/2019_15:21:11.25
//
// hs_adapter_run.v
//
// Launches from handshake controls and adapts to a run/done control.
// Also includes a provision for when the run signal is actually data_in != 0.  
//////////////////////////////////////////////////////////////////////////////////////////////////

module hs_adapter_run
  (
   input 	 clk,
   input 	 rst,
   input 	 req,
   output reg 	 ack = 0,
   input [31:0]  data_in,
   output [31:0] data_out,
   output 	 run, 
   input 	 done
   );
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   localparam
     S_IDLE=0,
     S_RUN=1,
     S_ACK=2;
   reg [1:0]    fsm=S_IDLE;
   
`ifdef MODEL_TECH // This works well for modelsim
   reg [127:0] state_str;
   always @(*)
     case(fsm)
       S_IDLE: state_str = "S_IDLE";
       S_RUN:  state_str = "S_RUN";
       S_ACK:  state_str = "S_ACK";
       default: state_str = "*** UNKNOWN ***";
     endcase // case (fsm)
`endif


   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Output assignments
   assign run = fsm==S_RUN && !done; 
   assign data_out = run ? data_in : 0; 
   
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // FSM Flow
   always @(posedge clk)
     if(rst)
       begin
	  fsm <= S_IDLE; 
	  ack <= 0;
       end
     else
       begin
	  ack <= 0; 
	  case(fsm)
	    
	    S_IDLE:
	      begin  
		 if(req)  
		   fsm <= S_RUN; 
	      end
	    
	    S_RUN:  
	      begin 
		 if(done) 
		   fsm <= S_ACK;  
	      end
	    
	    S_ACK:
	      begin
		 ack <= 1;
		 if(req==0)
		   fsm <= S_IDLE; 
	      end
	    
	    default: fsm <= S_IDLE; 
	  endcase // case (fsm)
       end
      
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
