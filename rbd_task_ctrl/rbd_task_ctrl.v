//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed 10/09/2019_15:21:11.25
//
// rbd_task_ctrl.v
//
// Run, busy, done task. Also include a a data out that reflects data_in. 
//////////////////////////////////////////////////////////////////////////////////
module rbd_task_ctrl #(parameter P_DATA_WIDTH=32)

  (
   input 			 clk,
   input 			 rst,
   input 			 run,
   output reg 			 busy=0,
   input [P_DATA_WIDTH-1:0] 	 data_in,
   output reg [P_DATA_WIDTH-1:0] data_out=0,
   input 			 done
   );
   
   always @(posedge clk) 
     if(rst) 
       data_out <= 0; 
     else if(run)
       data_out <= data_in;
     else if(done)
       data_out <= 0; 
   
   always @(posedge clk)
     if(rst)
       begin
	  busy <= 0; 
       end
     else
       begin
	  if(run)
	    busy <= 1;
	  else if(done)
	    busy <= 0; 
       end
      
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
