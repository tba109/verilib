//////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue May 20 14:19:35 EDT 2014
// fcr_ctrl.v
// 
// "FPGA Command and Reponse Control"
//  A custom Verilog HDL module. 
//  Reads commands from QSYS command FIFO, takes the appropriate action, and writes 
//  response words to the QSYS response FIFO.
//
// Steps to adding a command:
//  1.) Add req, busy, and parameter I/Os to the module declaration
//  2.) Add a local register for the parameter
//  3.) Add a synchronizer for busy
//  4.) Add E_<TARGET>_<ACTION>_REQ and _BUSY localparams for exe_state.
//  5.) Initialize the local parameter inside the exe_state always block reset
//  6.) Add the command content for exe_state == C_<TARGET>_<ACTION>
//  7.) Add E_<TARGET>_<ACTION>_REQ and _BUSY implementation
//  8.) Add combinational outputs for req and the local parameter
//////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps

module fcr_ctrl
  (
   input 	 clk, // module clock
   input 	 rst_n, // active low reset
   input [31:0]  cmd_data, // incoming 32-bit command data
   output [31:0] rsp_data, // outgoing 32-bit response data
   output 	 cmd_rdreq, // read flag for cmd fifo
   output 	 rsp_wrreq, // write flag for cmd fifo
   input 	 cmd_waitreq, // wait request for cmd fifo. Note that this goes low when data appears
   input 	 rsp_waitreq, // wait request for rsp fifo. Note that this goes high when data appears 
   input [15:0]  version_number
   // Step 1.): Add req, busy, and parameter I/Os to the module declaration
   );
   
   `include "cmd_defs.v"
   
   // finite state machine (fsm) states
   reg [1:0] 	 fsm;
   localparam 
     S_IDLE   = 3'd0, 
     S_RD_CMD = 3'd1, 
     S_EXE    = 3'd2, 
     S_WR_RSP = 3'd3;
   
   // local registers for the state of FPGA parameters

   // Step 2.) Add a local register for the parameter
   
   
   reg [4:0] 	 exe_state;
   localparam 
     E_IDLE            = 5'd0, 
     E_PARSE           = 5'd1, 
     E_DONE            = 5'd17;
   // Step 4.) Add E_<ACTION>_<TARGET>_REQ and _BUSY localparams for exe_state.
   
   wire		 exe_done;
   wire 	 exe_run;
   wire [15:0] 	 exe_instr;
   wire 	 exe_busy;
   assign exe_run = (fsm == S_EXE);
   assign exe_instr = cmd_data[31:16];
   assign exe_done = (exe_state == E_DONE);
   assign exe_busy = tap_busy_s || af_busy_s;
   always @(posedge clk or negedge rst_n)
     begin
	if(!rst_n)
	  begin
	     exe_state <= E_IDLE;
	     l_tap_gt <= 1'b0;
	     l_tap_et <= 1'b0;
	     l_tap_lt <= 1'b0;
	     l_tap_thr <= 14'b0;
	     l_tap_trig_en <= 1'b0;
	     l_tap_run <= 1'b0;
	     l_ltc <= 48'b0;
	     l_rsp_data <= 32'd0;
	     l_af_pre_config <= 3'd0;
	     l_af_post_config <= 3'd0;
	     l_af_test_config <= 11'd0;
	     l_af_cnst_config <= 11'd0;
	     l_af_cnst_run <= 1'b0;
	     l_af_status <= 16'd0;
	     l_pef_status <= 16'd0;
	     l_phf_status <= 16'd0;
	     l_dt_trig_mode <= 1'd0;
	     // Step 5.) Initialize the local parameter inside the exe_state always block reset
	  end
	else
	  case(exe_state)
	    E_IDLE: if( exe_run ) exe_state <= E_PARSE;
	    E_PARSE:
	      begin
		 case(exe_instr)
		   C_TAP_SET_GT        : begin   l_tap_gt      <= cmd_data[0];       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_TAP_REQ;        end 
		   C_TAP_SET_ET        : begin   l_tap_et      <= cmd_data[0];       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_TAP_REQ;        end
		   C_TAP_SET_LT        : begin   l_tap_lt      <= cmd_data[0];       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_TAP_REQ;        end
		   C_TAP_SET_THR       : begin   l_tap_thr     <= cmd_data[13:0];    l_rsp_data <= cmd_data[31:0];                   exe_state <= E_TAP_REQ;        end
		   C_TAP_SET_TRIG_EN   : begin   l_tap_trig_en <= cmd_data[0];       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_TAP_REQ;        end
		   C_TAP_SET_RUN       : begin   l_tap_run     <= cmd_data[0];       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_TAP_REQ;        end
		   C_LTC_UPDATE        : begin                                       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_LTC_REQ;        end
		   C_LTC_GET_HIGH      : begin                                       l_rsp_data <= {cmd_data[31:16],l_ltc[47:32]};   exe_state <= E_DONE;           end
		   C_LTC_GET_MID       : begin                                       l_rsp_data <= {cmd_data[31:16],l_ltc[31:16]};   exe_state <= E_DONE;           end
		   C_LTC_GET_LOW       : begin                                       l_rsp_data <= {cmd_data[31:16],l_ltc[15:0]};    exe_state <= E_DONE;           end
                   C_AF_SET_PRE_CONFIG : begin   l_af_pre_config  <= cmd_data[2:0];  l_rsp_data <= cmd_data[31:0];                   exe_state <= E_AF_REQ;         end
		   C_AF_SET_POST_CONFIG: begin   l_af_post_config <= cmd_data[2:0];  l_rsp_data <= cmd_data[31:0];                   exe_state <= E_AF_REQ;         end
		   C_AF_SET_TEST_CONFIG: begin   l_af_test_config <= cmd_data[10:0]; l_rsp_data <= cmd_data[31:0];                   exe_state <= E_AF_REQ;         end
		   C_AF_SET_CNST_CONFIG: begin   l_af_cnst_config <= cmd_data[10:0]; l_rsp_data <= cmd_data[31:0];                   exe_state <= E_AF_REQ;         end
		   C_AF_SET_CNST_RUN   : begin   l_af_cnst_run    <= cmd_data[0];    l_rsp_data <= cmd_data[31:0];                   exe_state <= E_AF_REQ;         end
                   C_AF_UPDATE_STATUS  : begin                                       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_AF_REQ;         end
		   C_AF_GET_STATUS     : begin                                       l_rsp_data <= {cmd_data[31:16],l_af_status};    exe_state <= E_DONE;           end
		   C_PEF_CLEAR         : begin                                       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_PEF_CLEAR_REQ;  end
		   C_PEF_UPDATE_STATUS : begin                                       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_PEF_STATUS_REQ; end
		   C_PEF_GET_STATUS    : begin                                       l_rsp_data <= {cmd_data[31:16],l_pef_status};   exe_state <= E_DONE;           end
		   C_PHF_CLEAR         : begin                                       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_PHF_CLEAR_REQ;  end
		   C_PHF_UPDATE_STATUS : begin                                       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_PHF_STATUS_REQ; end
		   C_PHF_GET_STATUS    : begin                                       l_rsp_data <= {cmd_data[31:16],l_phf_status};   exe_state <= E_DONE;           end
		   C_DT_TRIG_MODE      : begin  l_dt_trig_mode <= cmd_data[0];       l_rsp_data <= cmd_data[31:0];                   exe_state <= E_DONE;           end
		   C_VERSION_NUMBER    : begin                                       l_rsp_data <= {cmd_data[31:16],version_number}; exe_state <= E_DONE;           end
	           // Step 6.) Add the command content for exe_state == C_<TARGET>_<ACTION>		   
		   default             : begin                                       l_rsp_data <= {1'b1,cmd_data[30:0]};            exe_state <= E_DONE;           end
		 endcase // case (exe_instr)
	      end
	    E_TAP_REQ:         if(  tap_busy_s )        begin                             exe_state <= E_BUSY;            end
	    E_LTC_REQ:         if(  ltc_busy_s )        begin                             exe_state <= E_LTC_BUSY;        end
	    E_LTC_BUSY:        if( !ltc_busy_s )        begin l_ltc <= ltc;               exe_state <= E_DONE;            end
	    E_PEF_CLEAR_REQ:   if( pef_clear_busy_s )   begin                             exe_state <= E_PEF_CLEAR_BUSY;  end 
	    E_PEF_CLEAR_BUSY:  if( !pef_clear_busy_s )  begin                             exe_state <= E_DONE;            end
	    E_PEF_STATUS_REQ:  if( pef_status_busy_s )  begin                             exe_state <= E_PEF_STATUS_BUSY; end 
	    E_PEF_STATUS_BUSY: if( !pef_status_busy_s ) begin l_pef_status <= pef_status; exe_state <= E_DONE;            end
	    E_PHF_CLEAR_REQ:   if( phf_clear_busy_s )   begin                             exe_state <= E_PHF_CLEAR_BUSY;  end 
	    E_PHF_CLEAR_BUSY:  if( !phf_clear_busy_s )  begin                             exe_state <= E_DONE;            end
	    E_PHF_STATUS_REQ:  if( phf_status_busy_s )  begin                             exe_state <= E_PHF_STATUS_BUSY; end 
	    E_PHF_STATUS_BUSY: if( !phf_status_busy_s ) begin l_phf_status <= phf_status; exe_state <= E_DONE;            end
	    E_AF_REQ:          if( af_busy_s )          begin                             exe_state <= E_AF_BUSY;         end 
	    E_AF_BUSY:         if( !af_busy_s )         begin l_af_status <= af_status;   exe_state <= E_DONE;            end
	    E_BUSY:            if( !exe_busy )          begin                             exe_state <= E_DONE;            end
	    E_DONE:                                     begin                             exe_state <= E_IDLE;            end
	    // Step 7.) Add E_<TARGET>_<ACTION>_REQ and _BUSY implementation 
	    default exe_state <= E_IDLE;
	  endcase // case (exe_state)
     end					
	  
   // combinational outputs
   assign cmd_rdreq = (fsm == S_RD_CMD);
   assign rsp_wrreq = (fsm == S_WR_RSP);
   assign ltc_req = (exe_state == E_LTC_REQ);
   assign tap_req = (exe_state == E_TAP_REQ);
   assign pef_clear_req = (exe_state == E_PEF_CLEAR_REQ);
   assign pef_status_req = (exe_state == E_PEF_STATUS_REQ);
   assign phf_clear_req = (exe_state == E_PHF_CLEAR_REQ);
   assign phf_status_req = (exe_state == E_PHF_STATUS_REQ);
   assign af_req = (exe_state == E_AF_REQ);
   assign tap_run = l_tap_run;
   assign tap_gt = l_tap_gt;
   assign tap_et = l_tap_et;
   assign tap_lt = l_tap_lt;
   assign tap_thr = l_tap_thr;
   assign tap_trig_en = l_tap_trig_en;
   assign rsp_data = l_rsp_data;
   assign af_pre_config = l_af_pre_config;
   assign af_post_config = l_af_post_config;
   assign af_test_config = l_af_test_config;
   assign af_cnst_config = l_af_cnst_config;
   assign af_cnst_run = l_af_cnst_run;
   assign dt_trig_mode = l_dt_trig_mode;
   //  Step 8.) Add combinational outputs for req and the local parameter
   
   // sequental logic
   always @(posedge clk or negedge rst_n)
     begin
	if(!rst_n)
	  fsm <= S_IDLE;
	else
	  case(fsm)
	    S_IDLE:         if( !cmd_waitreq )             fsm <= S_RD_CMD;
	    S_RD_CMD:                                      fsm <= S_EXE;
	    S_EXE:          if( exe_done && !rsp_waitreq ) fsm <= S_WR_RSP;
	               else if( exe_done && rsp_waitreq)   fsm <= S_IDLE;
	    S_WR_RSP:                                      fsm <= S_IDLE;
	    default:                                       fsm <= S_IDLE;
	  endcase // case (fsm)
     end // always @ (posedge clk or negedge rst_n)
endmodule
		     
