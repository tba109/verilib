//////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Feb 13 16:11:03 EST 2014
// Pulse one clock cycle when a positive edge is detected
//////////////////////////////////////////////////////////////////////////////////////
module posedge_detector
  (
   input clk, // clock
   input rst_n, // active low reset
   input a, // input on which positive edges should be detected
   output y
   );

   reg 	  ff;
   
   always @(posedge clk or negedge rst_n)
     begin
	if( !rst_n ) ff <= 1'b0;
	else ff <= a;
     end
   
   assign y = !ff & a;
	
endmodule
