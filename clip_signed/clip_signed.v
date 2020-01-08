//////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu 10/24/2019_11:00:53.73
//
// clip_signed.v
//
// Clip signed input *a* between *a0* and *a1*
//
/////////////////////////////////////////////////////////////////////////////
module clip_signed #(parameter P_WIDTH=16)
   (
    input signed [P_WIDTH-1:0] 	    a,
    input signed [P_WIDTH-1:0] 	    a0,
    input signed [P_WIDTH-1:0] 	    a1,
    output reg signed [P_WIDTH-1:0] y
    );
   
   always @(*)
     begin
	if(a > a1)
	  y = a1;
	else if(a < a0)
	  y = a0;
	else
	  y = a; 
     end
   
endmodule
  
