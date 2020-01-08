//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue 12/10/2019_10:46:38.80
//
// bitstream_counter_simple.v
//
// Count condition incoming bitstream, allowing an external inhibit
//   
//////////////////////////////////////////////////////////////////////////////////

module bitstream_counter_simple #(parameter P_N_WIDTH=16)
  (
   input 		      clk,
   input 		      rst,
   // Controls
   input 		      inh,
   input 		      a,
   input [P_N_WIDTH-1:0]      period, 
   // Previous status
   output 		      y, 
   output reg 		      valid=0, 
   output reg 		      update=0, 
   output reg [P_N_WIDTH-1:0] n=0
   );

   // Internals
   reg [P_N_WIDTH-1:0] 	      i_n=0;
         
   // Window update flag
   reg [P_N_WIDTH-1:0] 	      i_cnt = 0;
   wire 		      i_update;
   assign i_update = (i_cnt>=period-1);
   always @(posedge clk)
     if(rst)
       i_cnt <= 0;
     else if(i_update)
       i_cnt <= 0;
     else
       i_cnt <= i_cnt + 1;
   always @(posedge clk)
     if(rst)
       update <= 0;
     else
       update <= i_update; 
   
   // Update the outputs
   reg 			      valid_0 = 0; 
   always @(posedge clk)
     if(rst)
       begin 
	  n <= 0; 
	  valid <= valid_0;
	  valid_0 <= 0; 
       end
     else if(i_update)
       begin
	  n <= i_n;
	  valid   <= valid_0;
	  valid_0 <= 1; 
       end

   // Waveform conditions
   assign y = a && !inh;
      
   // Update the Internal Counters, don't let them overflow
   always @(posedge clk)
     if(rst)
       i_n <= 0; 
     else if(i_update)
       i_n <= y; 
     else if(i_n != {P_N_WIDTH{1'b1}})
       i_n <= i_n + {{P_N_WIDTH-1{1'b0}},y};
          
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
