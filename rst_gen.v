/////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson
// Thu Feb 13 08:46:47 EST 2014
// Take an asynchronous (active low) reset in and generate a trailing edge that is
// synchronous with the system clock.
/////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps

module rst_gen(
	       input  clk, // system clk
	       input  arst_n, // async rst input
	       output rst_n // sync rst 
	       );
   
   reg [1:0] 	      ff;
   
   assign rst_n = ff[1];
   
   always @(posedge clk or negedge arst_n)
     if(!arst_n) ff <= 2'b0;
     else ff <= {ff[0],1'b1};
   
endmodule // rst_gen

      