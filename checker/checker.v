///////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Fri 10/18/2019_15:12:51.65
//
// checker.v
//
// A simple data checker. 
module checker #(parameter P_DATA_WIDTH = 32) 
  (
   input 		    clk,
   input 		    rst,
   input [P_DATA_WIDTH-1:0] data_run,
   input [P_DATA_WIDTH-1:0] data_done,
   input 		    run,
   output reg 		    busy=0,
   input 		    done,
   output reg 		    ran=0, 
   output reg 		    ok=1 
   );

   reg [P_DATA_WIDTH-1:0]   i_data_run=0; 

   always @(posedge clk)
     if(rst)
       ran <= 0;
     else if(run)
       ran <= 1; 
   
   always @(posedge clk)
    if(rst)
      begin 
	 ok <= 1;
	 busy <= 0;
	 i_data_run <= 0;
      end
    else
      begin 
	 case(busy)
	   
	   0:
	     begin
		if(run)
		  begin
		     i_data_run <= data_run;
		     busy <= 1; 
		  end
	     end

	   1:
	     begin
		if(done)
		  begin
		     busy <= 0; 
		  if(i_data_run!=data_done)
		    begin
		       ok <= 0; 
		    end
		  end
	     end // case: 1

	   default: busy <= 0;
	   
	 endcase // case (busy)
      end

      
endmodule
