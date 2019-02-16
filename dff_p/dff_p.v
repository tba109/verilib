//////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Feb 13 16:11:03 EST 2014
// D-ff's of arbitrary width operating on the positive edge
//////////////////////////////////////////////////////////////////////////////////////
module dff_p #(parameter P_NFF = 1, parameter P_DEFVAL = 1'b0)
  (
   ////////// inputs //////////
   input 	      clk, // clock
   input 	      rst_n, // active low reset
   input [P_NFF-1:0]  a, // input
   
   ////////// outputs //////////
   output [P_NFF-1:0] y
   ); 
 
   reg [P_NFF-1:0]  ff;
   
   always @(posedge clk or negedge rst_n)
     begin
	if( !rst_n ) ff <= {P_NFF{P_DEFVAL}};
	else ff <= a;
     end

   assign y = ff;

endmodule // dff_p