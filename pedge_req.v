////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Sep 14 10:58:10 EDT 2017
//
// pedge_req.v
//
// Initiate a req/ack handshake on the positive edge of incoming signal
/////////////////////////////////////////////////////////////////////////

module pedge_req
  (
   input clk,             // clock
   input rst_n,           // reset
   input a,               // signal on which to initiaite req/ack
   output reg req = 1'b0, // handshake request
   input ack              // handshake acknowledge
   );

   reg 	 fsm = 1'b0; 
   localparam
     S_HANDSHAKE = 1'b1,
     S_IDLE      = 1'b0; 
   
   wire  a_pe;
   posedge_detector PEDGE_0(.clk(clk),.rst_n(rst_n),.a(a),.y(a_pe));
   wire  ack_ne; 
   negedge_detector NEDGE_0(.clk(clk),.rst_n(rst_n),.a(ack),.y(ack_ne));

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       begin
	  fsm <= S_IDLE; 
	  req <= 1'b0;
       end
     else
       case(fsm)
	 S_IDLE:
	   begin
	      req <= 1'b0;
	      if(a_pe)
		begin 
		   req <= 1'b1;
		   fsm <= S_HANDSHAKE;
		end
	   end
	 
	 S_HANDSHAKE:
	   begin
	      if(ack)
		begin
		   req <= 1'b0;
		end
	      if(ack_ne)
		begin
		   req <= 1'b0;
		   fsm <= S_IDLE;
		end
	   end // case: S_HANDSHAKE
	 default: fsm <= S_IDLE; 
       endcase   
endmodule
