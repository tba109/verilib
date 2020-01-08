///////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson 
//
// rate_scaler_four_lane.v
//
// Count positive edges on incoming 4 lane bitstream. 
// For edge detection, the order of incoming bits is a[0], a[1], a[2]...
///////////////////////////////////////////////////////////////////////////////////

module rate_scaler_four_lane #(parameter P_N_WIDTH=16)
  (
   input 		  clk,
   input 		  rst,
   // Controls
   input 		  a_0,
   input 		  a_1,
   input 		  a_2,
   input 		  a_3, 
   input [P_N_WIDTH-1:0]  period, 
   input [P_N_WIDTH-1:0]  deadtime, 
   // Status
   output 		  valid, 
   output 		  update, 
   output 		  dead, 
   // Counters
   output [P_N_WIDTH-1:0] cnt
   );

   localparam [P_N_WIDTH-1:0] L_CNST_P_N_WIDTH_4 = {{(P_N_WIDTH-3){1'b0}},3'd4};
   localparam [P_N_WIDTH-1:0] L_CNST_P_N_WIDTH_3 = {{(P_N_WIDTH-2){1'b0}},2'd3};
   localparam [P_N_WIDTH-1:0] L_CNST_P_N_WIDTH_2 = {{(P_N_WIDTH-2){1'b0}},2'd2};
   localparam [P_N_WIDTH-1:0] L_CNST_P_N_WIDTH_1 = {{(P_N_WIDTH-2){1'b0}},2'd1};
   localparam [P_N_WIDTH-1:0] L_CNST_P_N_WIDTH_0 = {{(P_N_WIDTH-2){1'b0}},2'd0};  
   
   /////////////////////////////////////////////////////////////////
   // Bitsream counters. Do not self inhibit. 

   wire 		  i_pe_0;
   wire 		  i_update_0; 
   wire 		  i_valid_0;
   wire 		  i_inh_0; 
   wire [P_N_WIDTH-1:0]   i_n_pe_0;
   bitstream_counter_simple #(.P_N_WIDTH(P_N_WIDTH)) BC_0
     (
      // Outputs
      .y		(i_pe_0),
      .valid		(i_valid_0),
      .update		(i_update_0),
      .n		(i_n_pe_0),
      // Inputs
      .clk		(clk),
      .rst		(rst),
      .inh	        (i_inh_0),
      .a		(a_0),
      .period		(period>>2)); 

   wire 		  i_pe_1;
   wire 		  i_update_1; 
   wire 		  i_valid_1;
   wire 		  i_inh_1; 
   wire [P_N_WIDTH-1:0]   i_n_pe_1;
   bitstream_counter_simple #(.P_N_WIDTH(P_N_WIDTH)) BC_1
     (
      // Outputs
      .y		(i_pe_1),
      .valid		(i_valid_1),
      .update		(i_update_1),
      .n		(i_n_pe_1),
      // Inputs
      .clk		(clk),
      .rst		(rst),
      .inh	        (i_inh_1),
      .a		(a_1),
      .period		(period>>2)); 
   
   wire 		  i_pe_2;
   wire 		  i_update_2; 
   wire 		  i_valid_2;
   wire  		  i_inh_2; 
   wire [P_N_WIDTH-1:0]   i_n_pe_2;
   bitstream_counter_simple #(.P_N_WIDTH(P_N_WIDTH)) BC_2
     (
      // Outputs
      .y		(i_pe_2),
      .valid		(i_valid_2),
      .update		(i_update_2),
      .n		(i_n_pe_2),
      // Inputs
      .clk		(clk),
      .rst		(rst),
      .inh	        (i_inh_2),
      .a		(a_2),
      .period		(period>>2)); 
   
   wire 		  i_pe_3;
   wire 		  i_update_3; 
   wire 		  i_valid_3;
   wire 		  i_inh_3; 
   wire [P_N_WIDTH-1:0]   i_n_pe_3;
   bitstream_counter_simple #(.P_N_WIDTH(P_N_WIDTH)) BC_3
     (
      // Outputs
      .y		(i_pe_3),
      .valid		(i_valid_3),
      .update		(i_update_3),
      .n		(i_n_pe_3),
      // Inputs
      .clk		(clk),
      .rst		(rst),
      .inh	        (i_inh_3),
      .a		(a_3),
      .period		(period>>2)); 

   // Deadtime counter
   wire 		  i_trig_0;
   wire 		  i_trig_1;
   wire 		  i_trig_2;
   wire 		  i_trig_3;
   reg [P_N_WIDTH-1:0] i_deadtime_cnd = 0; // countdown
   reg 		       i_dead = 0;
   always @(posedge clk)
     if(rst)
       begin
	  i_deadtime_cnd <= 0;
	  i_dead <= 0; 
       end
     else 
       begin
	  case(i_dead)
	    
	    0:
	      begin
		 i_deadtime_cnd <= 0;
		 if(i_trig_0)
		   begin
		      i_deadtime_cnd <= deadtime - L_CNST_P_N_WIDTH_3;
		      i_dead <= 1; 
		   end
		 else if(i_trig_1) 
		   begin
		      i_deadtime_cnd <= deadtime - L_CNST_P_N_WIDTH_2;
		      i_dead <= 1;
		   end
		 else if(i_trig_2)
		   begin
		      i_deadtime_cnd <= deadtime - L_CNST_P_N_WIDTH_1; 
		      i_dead <= 1;
		   end
		 else if(i_trig_3)
		   begin
		      i_deadtime_cnd <= deadtime - L_CNST_P_N_WIDTH_0; 
		      i_dead <= 1;
		   end
	      end

	    1:
	      begin
		 i_deadtime_cnd <= i_deadtime_cnd - L_CNST_P_N_WIDTH_4;
		 if(i_deadtime_cnd < L_CNST_P_N_WIDTH_4)
		   begin 
		      i_dead <= 1;
		      if(i_trig_0 && (i_deadtime_cnd <= L_CNST_P_N_WIDTH_0))
			i_deadtime_cnd <= deadtime - L_CNST_P_N_WIDTH_3;
		      else if(i_trig_1 && (i_deadtime_cnd <= L_CNST_P_N_WIDTH_1))
			i_deadtime_cnd <= deadtime - L_CNST_P_N_WIDTH_2;
		      else if(i_trig_2 && (i_deadtime_cnd <= L_CNST_P_N_WIDTH_2))
			i_deadtime_cnd <= deadtime - L_CNST_P_N_WIDTH_1;
		      else if(i_trig_3 && (i_deadtime_cnd <= L_CNST_P_N_WIDTH_3))
			i_deadtime_cnd <= deadtime - L_CNST_P_N_WIDTH_0;
		      else
			begin 
			   i_deadtime_cnd <= 0; 
			   i_dead <= 0; 
			end
		   end 
	      end
	    
	    default:
	      begin
		 i_deadtime_cnd <= 0; 
		 i_dead <= 0; 
	      end
	    
	  endcase // case (i_dead)
       end
   
   // Trigger assignments
   assign i_trig_0 = i_pe_0 && (deadtime >= L_CNST_P_N_WIDTH_4) && !i_inh_0; 
   assign i_trig_1 = i_pe_1 && (deadtime >= L_CNST_P_N_WIDTH_3) && !i_inh_1;
   assign i_trig_2 = i_pe_2 && (deadtime >= L_CNST_P_N_WIDTH_2) && !i_inh_2;
   assign i_trig_3 = i_pe_3 && (deadtime >= L_CNST_P_N_WIDTH_1) && !i_inh_3; 
   
   // Inhibits   
   assign i_inh_0 =                                                                                                         (i_deadtime_cnd >= L_CNST_P_N_WIDTH_1);
   assign i_inh_1 = (i_pe_0 && deadtime >= L_CNST_P_N_WIDTH_1) ||                                                           (i_deadtime_cnd >= L_CNST_P_N_WIDTH_2);
   assign i_inh_2 = (i_pe_0 && deadtime >= L_CNST_P_N_WIDTH_2) || (i_pe_1 && deadtime >= 1) ||                              (i_deadtime_cnd >= L_CNST_P_N_WIDTH_3);
   assign i_inh_3 = (i_pe_0 && deadtime >= L_CNST_P_N_WIDTH_3) || (i_pe_1 && deadtime >= 2) || (i_pe_2 && deadtime >= 1) || (i_deadtime_cnd >= L_CNST_P_N_WIDTH_4);

   /////////////////////////////////////////////////////////////////////////////
   // TBA_NOTE: Handle overflow and cycle align these. 
   // Outputs 
   assign cnt = i_n_pe_0 + i_n_pe_1 + i_n_pe_2 + i_n_pe_3; 
   assign valid = i_valid_0 || i_valid_1 || i_valid_2 || i_valid_3;
   assign update = i_update_0 || i_update_1 || i_update_2 || i_update_3; 
   assign dead = i_dead; 

endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../bitstream_counter_simple/")
// End:
