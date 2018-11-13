//////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Feb 13 16:11:03 EST 2014
// Pipeline of arbitrary width and depth
//////////////////////////////////////////////////////////////////////////////////////
module pline #(parameter P_WIDTH = 1,
	       parameter P_DEPTH = 1,
	       parameter P_DEFVAL = {P_WIDTH{1'b0}})
  (
   ////////// inputs //////////
   input 	      clk, // clock
   input 	      rst_n, // active low reset
   input [P_WIDTH-1:0]  a, // input
   
   ////////// outputs //////////
   output [P_WIDTH-1:0] y
   ); 
         
   reg [P_WIDTH-1:0] ff[P_DEPTH-1:0];

   integer 	     i;
   always @(posedge clk or negedge rst_n)
     if( !rst_n ) 
       for( i = 0; i < P_DEPTH; i=i+1 )
	 ff[i] <= P_DEFVAL;
     else 
       begin
	  ff[0] <= a;
	  for( i = 1; i < P_DEPTH; i=i+1 )
	    ff[i] <= ff[i-1];
       end
   assign y = ff[P_DEPTH-1];
endmodule // pline


   