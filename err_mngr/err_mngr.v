/////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Fri May 25 16:41:29 EDT 2018
// err_mngr.v
//
// Error Manager
// Receives error data as a write strobe and handshakes downstream. 
//
////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module err_mngr
  (
   input 	     clk,       // System clock 
   input 	     rst_n,     // Reset (active low)
   input 	     err_wr,    // Write from downstream
   input [31:0]      err_in,    // Error data in 
   output reg [31:0] err_out=0, // Error data out
   output reg 	     err_req=0, // Handshake error data out
   input 	     err_ack    // Acknowledge error data out
   );

   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // Internals
   wire 	     err_ack_ne; 
   negedge_detector NEDGE_0(.clk(clk),.rst_n(rst_n),.a(err_ack),.y(err_ack_ne)); 

   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   reg 		     fsm;
   localparam
     S_IDLE      = 0,
     S_HANDSHAKE = 1;

`ifdef XILINX_ISIM
   reg [127:0] 	     state_str;
   always @(*)
     case(fsm)
       S_IDLE:      state_str <= "S_IDLE";
       S_HANDSHAKE: state_str <= "S_HANDSHAKE";
       default:     state_str <= "*** UNDEFINED ***"; 
     endcase
`endif
       
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // FSM flow
   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       begin
	  err_out <= 32'd0;
	  err_req <= 1'b0;
	  fsm <= S_IDLE; 
       end
     else
       begin
	  case(fsm)
	    
	    S_IDLE:
	      begin
		 err_req <= 1'b0; 
		 if(err_wr)
		   begin
		      err_out <= err_in; 
		      fsm <= S_HANDSHAKE;
		      err_req <= 1'b1; 
		   end
	      end
		 
	    S_HANDSHAKE:
	      begin
		 if(err_ack)
		   err_req <= 1'b0;
		 if(err_ack_ne)
		   begin
		      err_req <= 1'b0;
		      fsm <= S_IDLE;
		   end
	      end

	    default: fsm <= S_IDLE;

	  endcase
       end
	    
endmodule
