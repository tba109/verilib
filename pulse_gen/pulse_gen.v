///////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Mon 11/11/2019_11:59:00.80
//
// pulse_gen.v
//
//
// Fire a pulse in either single shot or repetative mode
///////////////////////////////////////////////////////////////////////////////////
module pulse_gen #(parameter P_N_WIDTH=32, parameter P_IO_WIDTH=1)
  (
   input 		  clk,
   input 		  rst,
   input 		  en,
   input 		  ss, 
   input [P_IO_WIDTH-1:0] a0, // start value
   input [P_IO_WIDTH-1:0] a1, // stop value
   input [P_N_WIDTH-1:0]  n0, // time to assert n0
   input [P_N_WIDTH-1:0]  n1, // time to assert n1
   input [P_N_WIDTH-1:0]  period, // time between triggers
   output 		  busy, 
   output 		  y   
   ); 


   // Periodic firing control
   reg [P_N_WIDTH-1:0] 	 cnt = {P_N_WIDTH{1'b1}};
   always @(posedge clk) 
     if(rst)
       begin
	  cnt <= {P_N_WIDTH{1'b1}}; 
       end
     else if(en)
       begin
	  cnt <= cnt + 1;
	  /////////////////////////////////////////
	  // Thu 11/21/2019_22:06:20.08
	  // Make sure counter doesn't get
	  // stuck if period changes while
	  // running. 
	  //
	  // if(cnt==period-1)
	  if(cnt>=period-1)
	  ////////////////////////////////////////
	    begin
	       cnt <= 0; 
	    end
       end
   wire trig_os; 
   assign trig_os = (cnt==0); 
   
   // One shot
   wire busy_os; 
   one_shot 
     #(.P_N_WIDTH(P_N_WIDTH),.P_IO_WIDTH(P_IO_WIDTH))
   OS_0
     (
      .clk(clk),
      .rst_n(!rst),
      .trig(trig_os || ss),
      .n0(n0),
      .n1(n1),
      .a0(a0),
      .a1(a1),
      .busy(busy_os), 
      .y(y)
      ); 
   
   // Busy assignment
   assign busy = busy_os || en; 
   
   
endmodule
