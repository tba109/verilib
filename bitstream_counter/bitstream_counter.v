//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson 
//
// bitstream_counter.v
//
// Count positive and negative edges and levels on a incoming bitstream.
// Self inhibits for some number of cycles when n_self_inh != 0
//   
//////////////////////////////////////////////////////////////////////////////////

module bitstream_counter #(parameter P_N_WIDTH=16)
  (
   input 		      clk,
   input 		      rst,
   // Controls
   input 		      inh_pedge_in,
   input 		      inh_nedge_in,
   input 		      inh_high_in,
   input 		      inh_low_in,
   input [P_N_WIDTH-1:0]      n_self_inh, 
   input 		      a,
   input [P_N_WIDTH-1:0]      period, 
   // Status
   output 		      pedge,
   output 		      nedge,
   output 		      high,
   output 		      low,
   output 		      inh_pedge_out,
   output 		      inh_nedge_out,
   output 		      inh_high_out,
   output 		      inh_low_out,
   // Previous status
   output reg 		      valid=0, 
   output reg 		      update=0, 
   output reg [P_N_WIDTH-1:0] n_pedge=0,
   output reg [P_N_WIDTH-1:0] n_nedge=0,
   output reg [P_N_WIDTH-1:0] n_high=0,
   output reg [P_N_WIDTH-1:0] n_low=0
   );

   // Internals
   reg [P_N_WIDTH-1:0] 	      i_n_pedge=0;
   reg [P_N_WIDTH-1:0] 	      i_n_nedge=0;
   reg [P_N_WIDTH-1:0] 	      i_n_high=0;
   reg [P_N_WIDTH-1:0] 	      i_n_low=0;
      
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
	  n_pedge <= 0; 
	  n_nedge <= 0; 
	  n_high <= 0;
	  n_low <= 0;
	  valid <= valid_0;
	  valid_0 <= 0; 
       end
     else if(i_update)
       begin
	  n_pedge <= i_n_pedge;
	  n_nedge <= i_n_nedge;
	  n_high  <= i_n_high;
	  n_low   <= i_n_low;
	  valid   <= valid_0;
	  valid_0 <= 1; 
       end

   // Waveform conditions
   wire i_inh_self_pedge;
   wire i_inh_self_nedge;
   wire i_inh_self_high;
   wire i_inh_self_low;
   wire i_pedge_0;
   wire i_nedge_0;
   posedge_detector PEDGE_0(.clk(clk),.rst_n(!rst),.a(a),.y(i_pedge_0));
   negedge_detector NEDGE_0(.clk(clk),.rst_n(!rst),.a(a),.y(i_nedge_0));
   assign inh_pedge_out = inh_pedge_in || i_inh_self_pedge;
   assign inh_nedge_out = inh_nedge_in || i_inh_self_nedge;
   assign inh_high_out  = inh_high_in  || i_inh_self_high;
   assign inh_low_out   = inh_low_in   || i_inh_self_low; 
   assign pedge = i_pedge_0 && !inh_pedge_out;
   assign nedge = i_nedge_0 && !inh_nedge_out; 
   assign high  = (a==1'b1) && !inh_high_out;
   assign low   = (a==1'b0) && !inh_low_out;
   
   // Internal inhibits
   one_shot #(.P_N_WIDTH(P_N_WIDTH),.P_IO_WIDTH(1)) OS_INH_PEDGE_0
     (
      .clk(clk),
      .rst_n(!rst),
      .trig(pedge && !inh_pedge_out),
      .a0(1'b0),
      .a1(1'b1),
      .n0(0),
      .n1(n_self_inh),
      .busy(),
      .y(i_inh_self_pedge)
      ); 
   one_shot #(.P_N_WIDTH(P_N_WIDTH),.P_IO_WIDTH(1)) OS_INH_NEDGE_0
     (
      .clk(clk),
      .rst_n(!rst),
      .trig(nedge && !inh_nedge_out),
      .a0(1'b0),
      .a1(1'b1),
      .n0(0),
      .n1(n_self_inh),
      .busy(),
      .y(i_inh_self_nedge)
      ); 
   one_shot #(.P_N_WIDTH(P_N_WIDTH),.P_IO_WIDTH(1)) OS_INH_HIGH_0
     (
      .clk(clk),
      .rst_n(!rst),
      .trig(high && !inh_high_out),
      .a0(1'b0),
      .a1(1'b1),
      .n0(0),
      .n1(n_self_inh),
      .busy(),
      .y(i_inh_self_high)
      );
   one_shot #(.P_N_WIDTH(P_N_WIDTH),.P_IO_WIDTH(1)) OS_INH_LOW_0
     (
      .clk(clk),
      .rst_n(!rst),
      .trig(low && !inh_low_out),
      .a0(1'b0),
      .a1(1'b1),
      .n0(0),
      .n1(n_self_inh),
      .busy(),
      .y(i_inh_self_low)
      );
   
   // Update the Internal Counters, don't let them overflow
   always @(posedge clk)
     if(rst)
       begin
	  i_n_pedge <= 0; 
	  i_n_nedge <= 0; 
	  i_n_high <= 0;
	  i_n_low <= 0;
       end
     else if(i_update)
       begin
	  i_n_pedge <= pedge; 
	  i_n_nedge <= nedge; 
	  i_n_high <= high;
	  i_n_low <= low;
       end   
     else
       begin
	  if(i_n_pedge != {P_N_WIDTH{1'b1}})
	    i_n_pedge <= i_n_pedge + {{P_N_WIDTH-1{1'b0}},pedge};
	  if(i_n_nedge != {P_N_WIDTH{1'b1}})
	    i_n_nedge <= i_n_nedge + {{P_N_WIDTH-1{1'b0}},nedge};
	  if(i_n_high != {P_N_WIDTH{1'b1}})
	    i_n_high <= i_n_high + {{P_N_WIDTH-1{1'b0}},high};
	  if(i_n_low != {P_N_WIDTH{1'b1}})
	    i_n_low <= i_n_low + {{P_N_WIDTH-1{1'b0}},low};
       end
   
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
