/////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Sat Jul 21 10:08:12 EDT 2018
// fcr_ctrl.v
//
// FPGA Command-Response Module
//
// -- Idle, if new command request, handshake in
// -- Parse for correct format, return with error bit set if not
// -- Perform action
// -- Respond
//
////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module fcr_ctrl
  (
   // System I/O
   input 	     clk,
   input 	     rst_n,
   
   // To the byte-wise data controller
   input 	     cmd_byte_req,
   input [7:0] 	     cmd_byte_data,
   output reg 	     cmd_byte_ack = 1'b0, 
   output reg 	     rsp_byte_req = 1'b0,
   input 	     rsp_byte_ack, 
   output reg [7:0]  rsp_byte_data = 8'd0, 
   output 	     cmd_busy,

   // To the event BRAMs
   output reg [11:0] evt_y_loc = 0,
   output reg [11:0] evt_x_loc = 0,
   output reg [11:0] evt_data = 0, 
   output reg [3:0]  evt_res = 0, 
   output reg 	     evt_wr = 0,
   
   // To the Event Loader
   output reg 	     el_run = 0, 
   output reg 	     el_run_2 = 0, 
   output reg 	     el_test_pat = 0, 

   // To the Detector Loader
   output reg 	     de_nop = 0, 

   // More commands
   output reg [11:0] cmd_nsp = 12'd11,
   output reg [11:0] cmd_noc = 12'd10,
   output reg [11:0] cmd_x_loc_max = 12'd2047,
   output reg [11:0] cmd_y_loc_max = 12'd1023, 
   
   // Version number
   input [15:0]      vnum
   );

   wire 	     i_rst_n; 
   
`include "inc_params.v"
   
   ///////////////////////////////////////////////////////////////////////
   // Internal registers
   reg [7:0] 	act = 8'd0; // action
   reg [7:0] 	param = 8'd0; // parameter
   reg [47:0] 	adr = 48'd0; // address
   reg [71:0] 	data = 72'd0; // command data	
   reg [71:0] 	rsp_data = 72'd0; // response data
   reg [7:0] 	byte_in = 8'd0; 
   reg 		cmd_err = 1'b0; 
   reg [2:0] 	cmd_state = 3'd0;
   reg [15:0] 	nevt = 16'd0; 
   reg 		is_evt2 = 0; 
   localparam
     S_CMD_IDLE  = 3'd0,
     S_CMD_PARSE = 3'd1,
     S_CMD_EXE   = 3'd2,
     S_CMD_RSP   = 3'd3;   
   
   reg [4:0] 	parse_state = 5'd0;
   localparam
     S_PARSE_ACT         = 5'd0,
     S_PARSE_PARAM       = 5'd1,
     S_PARSE_ADR_5       = 5'd2,
     S_PARSE_ADR_4       = 5'd3,
     S_PARSE_ADR_3       = 5'd4,
     S_PARSE_ADR_2       = 5'd5,
     S_PARSE_ADR_1       = 5'd6,
     S_PARSE_ADR_0       = 5'd7,
     S_PARSE_DATA_8      = 5'd8,
     S_PARSE_DATA_7      = 5'd9, 
     S_PARSE_DATA_6      = 5'd10, 
     S_PARSE_DATA_5      = 5'd11, 
     S_PARSE_DATA_4      = 5'd12, 
     S_PARSE_DATA_3      = 5'd13,
     S_PARSE_DATA_2      = 5'd14,
     S_PARSE_DATA_1      = 5'd15,
     S_PARSE_DATA_0      = 5'd16,
     S_PARSE_EVT_Y_LOC_1 = 5'd17,
     S_PARSE_EVT_Y_LOC_0 = 5'd18,
     S_PARSE_EVT_N_1     = 5'd19,
     S_PARSE_EVT_N_0     = 5'd20,
     S_PARSE_EVT_E_1     = 5'd21,
     S_PARSE_EVT_E_0     = 5'd22,
     S_PARSE_EVT_PIX_1   = 5'd23,
     S_PARSE_EVT_PIX_0   = 5'd24; 
     
   reg [5:0] 	exe_state = 6'd0;
   localparam
     S_EXE_IDLE               = 6'd0,
     S_EXE_NOP                = 6'd1,
     S_EXE_GET_VNUM           = 6'd2,
     S_EXE_SET_EL_RUN         = 6'd3,      
     S_EXE_SET_EL_TP          = 6'd4,
     S_EXE_SET_DE_NOP         = 6'd5,
     S_EXE_SET_NSP            = 6'd6,
     S_EXE_SET_NOC            = 6'd7,
     S_EXE_SET_X_LOC_MAX      = 6'd8,
     S_EXE_SET_Y_LOC_MAX      = 6'd9, 
     S_EXE_SET_EL_RUN_2       = 6'd10,
     // TBA_NOTE: Add execution state for new commands here
     S_EXE_DONE = 6'd63;
   
   reg [4:0] 	rsp_state = 5'd0;
   localparam
     S_RSP_IDLE        = 5'd0,
     S_RSP_ACT         = 5'd1,
     S_RSP_PARAM       = 5'd2,
     S_RSP_ADR_5       = 5'd3,
     S_RSP_ADR_4       = 5'd4,
     S_RSP_ADR_3       = 5'd5,
     S_RSP_ADR_2       = 5'd6,
     S_RSP_ADR_1       = 5'd7,
     S_RSP_ADR_0       = 5'd8,
     S_RSP_DATA_8      = 5'd9,
     S_RSP_DATA_7      = 5'd10,
     S_RSP_DATA_6      = 5'd11,
     S_RSP_DATA_5      = 5'd12,
     S_RSP_DATA_4      = 5'd13,
     S_RSP_DATA_3      = 5'd14,
     S_RSP_DATA_2      = 5'd15,
     S_RSP_DATA_1      = 5'd16,
     S_RSP_DATA_0      = 5'd17;

   assign cmd_busy = (cmd_state != S_CMD_IDLE) || (rsp_state != S_RSP_IDLE); 
 	     
   //////////////////////////////////////////////////////////////////////
   // Response
   wire 	cmd_byte_req_s;
   sync SYNC0(.clk(clk),.rst_n(i_rst_n),.a(cmd_byte_req),.y(cmd_byte_req_s)); 
   wire 	rsp_byte_ack_s;
   sync SYNC1(.clk(clk),.rst_n(i_rst_n),.a(rsp_byte_ack),.y(rsp_byte_ack_s)); 
   wire 	rsp_byte_ack_s_ne;
   negedge_detector NEDGE1(.clk(clk),.rst_n(i_rst_n),.a(rsp_byte_ack_s),.y(rsp_byte_ack_s_ne));
   always @(posedge clk or negedge i_rst_n)
     if(!i_rst_n)
       begin
	  rsp_state <= S_RSP_IDLE;
	  rsp_byte_req <= 1'b0;
	  rsp_byte_data <= 8'hXX; 
       end
     else
       case(rsp_state)
   	 S_RSP_IDLE:
	   begin
   	      rsp_byte_req <= 1'b0;
	      if(cmd_state == S_CMD_RSP)
   		rsp_state <= S_RSP_ACT;
	   end
   	 S_RSP_ACT:         begin rsp_byte_data <= {cmd_err,act[6:0]};        rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_PARAM;       rsp_byte_req <= 1'b0; end end
   	 S_RSP_PARAM:       begin rsp_byte_data <= param;                     rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_ADR_5;       rsp_byte_req <= 1'b0; end end
	 S_RSP_ADR_5:       begin rsp_byte_data <= adr[47:40];                rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_ADR_4;       rsp_byte_req <= 1'b0; end end
	 S_RSP_ADR_4:       begin rsp_byte_data <= adr[39:32];                rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_ADR_3;       rsp_byte_req <= 1'b0; end end
   	 S_RSP_ADR_3:       begin rsp_byte_data <= adr[31:24];                rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_ADR_2;       rsp_byte_req <= 1'b0; end end
   	 S_RSP_ADR_2:       begin rsp_byte_data <= adr[23:16];                rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_ADR_1;       rsp_byte_req <= 1'b0; end end
   	 S_RSP_ADR_1:       begin rsp_byte_data <= adr[15:8];                 rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_ADR_0;       rsp_byte_req <= 1'b0; end end
   	 S_RSP_ADR_0:       begin rsp_byte_data <= adr[7:0];                  rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_8;      rsp_byte_req <= 1'b0; end end
	 S_RSP_DATA_8:      begin rsp_byte_data <= rsp_data[71:64];           rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_7;      rsp_byte_req <= 1'b0; end end
   	 S_RSP_DATA_7:      begin rsp_byte_data <= rsp_data[63:56];           rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_6;      rsp_byte_req <= 1'b0; end end
   	 S_RSP_DATA_6:      begin rsp_byte_data <= rsp_data[55:48];           rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_5;      rsp_byte_req <= 1'b0; end end
   	 S_RSP_DATA_5:      begin rsp_byte_data <= rsp_data[47:40];           rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_4;      rsp_byte_req <= 1'b0; end end
   	 S_RSP_DATA_4:      begin rsp_byte_data <= rsp_data[39:32];           rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_3;      rsp_byte_req <= 1'b0; end end
	 S_RSP_DATA_3:      begin rsp_byte_data <= rsp_data[31:24];           rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_2;      rsp_byte_req <= 1'b0; end end
   	 S_RSP_DATA_2:      begin rsp_byte_data <= rsp_data[23:16];           rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_1;      rsp_byte_req <= 1'b0; end end
   	 S_RSP_DATA_1:      begin rsp_byte_data <= rsp_data[15:8];            rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_DATA_0;      rsp_byte_req <= 1'b0; end end
   	 S_RSP_DATA_0:      begin rsp_byte_data <= rsp_data[7:0];             rsp_byte_req <= 1'b1; if(rsp_byte_ack_s) rsp_byte_req <= 1'b0; if(rsp_byte_ack_s_ne) begin rsp_state <= S_RSP_IDLE;        rsp_byte_req <= 1'b0; end end
   	 default:
	   begin
	      rsp_byte_req <= 1'b0;
	      rsp_state <= S_RSP_IDLE;
	   end
       endcase // case (rsp_state)
   
   //////////////////////////////////////////////////////////////////////
   // Execution
   wire exe_done;
   assign exe_done         = (exe_state == S_EXE_DONE);
      
   always @(posedge clk or negedge i_rst_n)
     if(!i_rst_n)
       begin
	  exe_state <= S_EXE_IDLE;
	  cmd_err <= 1'b0;
	  rsp_data <= 32'hXXXXXXXX;
	  el_run <= 0;
	  el_test_pat <= 0; 
	  de_nop <= 0;
	  cmd_nsp <= 12'd11;
	  cmd_noc <= 12'd10;
	  cmd_x_loc_max <= 12'd2047;
	  cmd_y_loc_max <= 12'd1023;
	  el_run_2 <= 0; 
	  // TBA_NOTE: Initialize new command outputs 
       end  
     else 
       begin
	  el_run <= 0;
	  de_nop <= 0; 
	  el_run_2 <= 0; 
	  case(exe_state)
	    
	    S_EXE_IDLE:  
	      begin
		 // req initialization
		 // TBA_NOTE: If new command requires handshake, req <= 1'b0 here;
		 if(cmd_state == S_CMD_EXE)
		   case(act)
		     C_NOP:                                 exe_state <= S_EXE_NOP;
		     C_GET:      
		       if(param == C_VNUM)                  exe_state <= S_EXE_GET_VNUM;
		       // TBA_NOTE: Add new GET param here
		       else                                 exe_state <= S_EXE_DONE; // This makes sure the main state machine doesn't get stuck if things go weird 
		     C_SET:
		       if(param == C_EL_RUN)                exe_state <= S_EXE_SET_EL_RUN; 		     
		       else if(param == C_EL_TP)            exe_state <= S_EXE_SET_EL_TP;
		       else if(param == C_DE_NOP)           exe_state <= S_EXE_SET_DE_NOP; 
		       else if(param == C_NSP)              exe_state <= S_EXE_SET_NSP; 
		       else if(param == C_NOC)              exe_state <= S_EXE_SET_NOC; 
		       else if(param == C_X_LOC_MAX)        exe_state <= S_EXE_SET_X_LOC_MAX;
		       else if(param == C_Y_LOC_MAX)        exe_state <= S_EXE_SET_Y_LOC_MAX; 
		       else if(param == C_EL_RUN_2)         exe_state <= S_EXE_SET_EL_RUN_2; 
		       else                                 exe_state <= S_EXE_DONE;
		     // TBA_NOTE: Add new SET param here
		     default:                               exe_state <= S_EXE_DONE; // This makes sure the main state machine doesn't get stuck if things go weird 
		   endcase // case (act)
	      end // case: S_EXE_IDLE
	    
	    // GET
	    S_EXE_GET_VNUM:   begin exe_state <= S_EXE_DONE; rsp_data <= {56'd0,vnum}; cmd_err <= 1'b0; end // Return version number
	    
	    // SET	 
	    S_EXE_SET_EL_RUN:    begin exe_state <= S_EXE_DONE; rsp_data <= 1; el_run <= 1; cmd_err <= 0;          end
	    S_EXE_SET_EL_TP:     begin exe_state <= S_EXE_DONE; rsp_data <= data[0]; el_test_pat <= data[0];       end
	    S_EXE_SET_DE_NOP:    begin exe_state <= S_EXE_DONE; rsp_data <= 1; de_nop <= 1;                        end 
	    S_EXE_SET_NSP:       begin exe_state <= S_EXE_DONE; rsp_data <= data; cmd_nsp <= data; cmd_err <= 0;   end
	    S_EXE_SET_NOC:       begin exe_state <= S_EXE_DONE; rsp_data <= data; cmd_noc <= data; cmd_err <= 0;   end 
	    S_EXE_SET_X_LOC_MAX: begin exe_state <= S_EXE_DONE; rsp_data <= data; cmd_x_loc_max <= data; cmd_err <= 0; end 
	    S_EXE_SET_Y_LOC_MAX: begin exe_state <= S_EXE_DONE; rsp_data <= data; cmd_y_loc_max <= data; cmd_err <= 0; end 
	    S_EXE_SET_EL_RUN_2:  begin exe_state <= S_EXE_DONE; rsp_data <= 1; el_run_2 <= 1; cmd_err <= 0;          end
	    // TBA_NOTE: Add new execution state here
	    S_EXE_DONE:       begin exe_state <= S_EXE_IDLE;                            end 
	    default:          begin exe_state <= S_EXE_DONE;                            end // This makes sure things get cleared out if something goes weird 
	  endcase
       end
	  
   //////////////////////////////////////////////////////////////////////
   // Handshake incoming bytes
   always @(posedge clk or negedge i_rst_n)
     if(!i_rst_n) begin cmd_byte_ack <= 1'b0; byte_in <= 8'hXX; end 
     else if(cmd_byte_req_s && (cmd_state == S_CMD_PARSE)) begin cmd_byte_ack <= 1'b1; byte_in <= cmd_byte_data; end
     else cmd_byte_ack <= 1'b0;
   wire cmd_new_byte; 
   negedge_detector NEDGE0(.clk(clk),.rst_n(i_rst_n),.a(cmd_byte_ack),.y(cmd_new_byte));
   
   //////////////////////////////////////////////////////////////////////
   // Parsing commands
   // Add new actions here, note that we look for a valid action in 
   //   order to allow processing of the command. 
   reg 	act_valid;
   always @(*)
     case(byte_in)
       C_NOP: act_valid <= 1'b1;
       C_GET: act_valid <= 1'b1;
       C_SET: act_valid <= 1'b1;
       default: act_valid <= 1'b0;
     endcase

   reg parse_done = 1'b0;
   reg parse_err = 1'b0; 
   reg evt_done = 1'b0; 
   always @(posedge clk or negedge i_rst_n)
     if(!i_rst_n)
       begin
	  parse_state <= S_PARSE_ACT;
	  parse_done <= 1'b0;
	  parse_err <= 1'b0; 
	  act <= 8'd0;
	  param <= 8'd0;
	  adr <= 48'd0;
	  data <= 72'd0;
	  evt_wr <= 0;
	  evt_done <= 1'b0; 
       end
     else 
       begin
	  parse_done <= 1'b0;
	  parse_err <= 1'b0;
	  evt_wr <= 1'b0;
	  evt_done <= 1'b0; 
	  if(cmd_new_byte)
	    begin
	       case(parse_state)
		 S_PARSE_ACT:
		   begin
		      is_evt2 <= 0; 
		      if(act_valid)
			begin
			   act <= byte_in;
			   parse_state <= S_PARSE_PARAM;                                                
			end
		      else if(byte_in==C_EVT)
			begin
			   parse_state <= S_PARSE_EVT_Y_LOC_1;
			end
		      else if(byte_in==C_EVT2)
			begin
			   parse_state <= S_PARSE_EVT_Y_LOC_1;
			   is_evt2 <= 1;
			end 
		      else
			begin
			   parse_done <= 1'b1;
			   parse_err <= 1'b1; 
			end
		   end
		 S_PARSE_PARAM:       begin param       <= byte_in; parse_state <= S_PARSE_ADR_5;  end
		 S_PARSE_ADR_5:       begin adr[47:40]  <= byte_in; parse_state <= S_PARSE_ADR_4;  end
		 S_PARSE_ADR_4:       begin adr[39:32]  <= byte_in; parse_state <= S_PARSE_ADR_3;  end
		 S_PARSE_ADR_3:       begin adr[31:24]  <= byte_in; parse_state <= S_PARSE_ADR_2;  end
		 S_PARSE_ADR_2:       begin adr[23:16]  <= byte_in; parse_state <= S_PARSE_ADR_1;  end
		 S_PARSE_ADR_1:       begin adr[15:8]   <= byte_in; parse_state <= S_PARSE_ADR_0;  end
		 S_PARSE_ADR_0:       begin adr[7:0]    <= byte_in; parse_state <= S_PARSE_DATA_8; end
		 S_PARSE_DATA_8:      begin data[71:64] <= byte_in; parse_state <= S_PARSE_DATA_7; end
		 S_PARSE_DATA_7:      begin data[63:56] <= byte_in; parse_state <= S_PARSE_DATA_6; end
		 S_PARSE_DATA_6:      begin data[55:48] <= byte_in; parse_state <= S_PARSE_DATA_5; end
		 S_PARSE_DATA_5:      begin data[47:40] <= byte_in; parse_state <= S_PARSE_DATA_4; end
		 S_PARSE_DATA_4:      begin data[39:32] <= byte_in; parse_state <= S_PARSE_DATA_3; end
		 S_PARSE_DATA_3:      begin data[31:24] <= byte_in; parse_state <= S_PARSE_DATA_2; end
		 S_PARSE_DATA_2:      begin data[23:16] <= byte_in; parse_state <= S_PARSE_DATA_1; end
		 S_PARSE_DATA_1:      begin data[15:8]  <= byte_in; parse_state <= S_PARSE_DATA_0; end
		 S_PARSE_DATA_0:
		   begin
		      data[7:0] <= byte_in;
		      parse_state <= S_PARSE_ACT;
		      parse_done <= 1'b1;
		      parse_err <= 1'b0; 
		   end
		 S_PARSE_EVT_Y_LOC_1: begin evt_y_loc[11:8] <= byte_in[3:0];                               parse_state <= S_PARSE_EVT_Y_LOC_0; end
		 S_PARSE_EVT_Y_LOC_0: begin evt_y_loc[7:0]  <= byte_in;                                    parse_state <= S_PARSE_EVT_N_1;     end
		 S_PARSE_EVT_N_1:     begin nevt[15:8]      <= byte_in;                                    parse_state <= S_PARSE_EVT_N_0;     end
		 S_PARSE_EVT_N_0:     begin nevt[7:0]       <= byte_in;                                    parse_state <= S_PARSE_EVT_E_1;     end
		 S_PARSE_EVT_E_1:     begin evt_x_loc[11:8] <= byte_in[3:0]; evt_res <= byte_in[7:4];      parse_state <= S_PARSE_EVT_E_0;     end
		 S_PARSE_EVT_E_0:     
		   begin 
		      evt_x_loc[7:0] <= byte_in; 
		      if(is_evt2)
			parse_state <= S_PARSE_EVT_PIX_1; 
		      else
			begin
			   evt_wr <= 1'b1; 
			   nevt <= nevt - 1;
			   if(nevt==1)
			     begin
				parse_state <= S_PARSE_ACT;
				evt_done <= 1'b1;
			     end
			   else
			     parse_state <= S_PARSE_EVT_E_1;
			end 
		   end // case: S_PARSE_EVT_E_0
		 S_PARSE_EVT_PIX_1: begin evt_data[11:8] <= byte_in[3:0]; parse_state <= S_PARSE_EVT_PIX_0; end
		 S_PARSE_EVT_PIX_0: 
		   begin 
		      evt_data[7:0] <= byte_in;
		      evt_wr <= 1'b1;
		      nevt <= nevt - 1;
		      if(nevt==1)
			begin
			   parse_state <= S_PARSE_ACT;
			   evt_done <= 1'b1;
			end
		      else
			parse_state <= S_PARSE_EVT_E_1;
		   end 
		 
		 default:
		   begin
		      parse_state <= S_PARSE_ACT;
		      parse_done <= 1'b0;
		   end
	       endcase
	    end
       end

   /////////////////////////////////////////////////////////////////////
   // Helper Logic
   wire cmd_byte_req_s_pe; 
   posedge_detector PEDGE0(.clk(clk),.rst_n(i_rst_n),.a((cmd_state == S_CMD_IDLE) && cmd_byte_req_s),.y(cmd_byte_req_s_pe)); 
   
   //////////////////////////////////////////////////////////////////////
   // Command FSM
   always @(posedge clk or negedge i_rst_n)
     if(!i_rst_n)
       cmd_state <= S_CMD_IDLE;
     else
       case(cmd_state)
	 
	 S_CMD_IDLE:  
	   if(cmd_byte_req_s_pe) 
	     cmd_state <= S_CMD_PARSE; 
	 
	 S_CMD_PARSE:
	   begin 
	      if(parse_done)
		begin
		   if(!parse_err)
		     cmd_state <= S_CMD_EXE;
		   else
		     cmd_state <= S_CMD_IDLE;
		end
	      else if(evt_done)
		cmd_state <= S_CMD_IDLE;
	   end 

	 S_CMD_EXE:   
	   if(exe_done)          
	     cmd_state <= S_CMD_RSP;

	 S_CMD_RSP:                         
	   cmd_state <= S_CMD_IDLE;

	 default:                           
	   cmd_state <= S_CMD_IDLE;
       endcase 

   assign wd_test = {cmd_state,parse_state,exe_state,rsp_state};

   wire i_rst; 
   watchdog #(
	      .P_CLK_FREQ_HZ(P_CLK_FREQ_HZ),
	      .P_WATCH_NS(P_WD_TIMEOUT_NS),
	      .P_KICK_NS(P_WD_KICK_NS)) 
   FCR_WD_0
     (
      .clk(clk),
      .rst_n(rst_n),
      .watch_var({29'b0,cmd_state}),
      .watch_val({29'b0,S_CMD_IDLE}),
      .kick(i_rst)
      ); 
   assign i_rst_n = !i_rst; 
   // assign i_rst_n = 1'b1; 
   
endmodule
