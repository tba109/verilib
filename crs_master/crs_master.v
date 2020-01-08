///////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Mon Apr  1 09:55:34 EDT 2019
//
// crs_master.v
//
// Command, response and status.
// Allows 4 peripherals (a0,a1,a2,a3) to access the system commandand response bus (y). 
// Includes provisions for reading in buffered data. 
//
// Thu 08/01/2019_ 9:33:46.68
// -- Add a priority override
// -- When UART was at 60MHz with this module at 20MHz phase locked to 0deg, the indexing logic
//    was getting stuck because the UART req flag was clearing. Add a term to also clear 
//    the y_req when y_ack is asserted. 
////////////////////////////////////////////////////////////////////////////////////////////////
module crs_master
  (
   // System inputs
   input 	     clk,
   input 	     rst, 
   // System bus
   output [11:0]     y_adr,
   output [15:0]     y_wr_data,
   input [15:0]      y_rd_data,
   output 	     y_wr, 
   // Priority override bus
   input 	     po_en, // priority override enable
   input 	     po_wr, // priority override write strobe
   input [11:0]      po_adr, // priority override address
   output [15:0]     po_rd_data, // priority override read data
   input [15:0]      po_wr_data, // priority override write data
   // Peripheral 0
   input 	     a0_wr_req, 
   input 	     a0_bwr_req,
   input 	     a0_rd_req,
   output reg 	     a0_ack, 
   input [15:0]      a0_wr_data,
   output reg [15:0] a0_rd_data,
   input [11:0]      a0_adr,
   output reg 	     a0_buf_rd,
   input 	     a0_buf_empty,
   input [31:0]      a0_buf_wr_data, 
   // Peripheral 1
   input 	     a1_wr_req, 
   input 	     a1_bwr_req,
   input 	     a1_rd_req,
   output reg 	     a1_ack, 
   input [15:0]      a1_wr_data,
   output reg [15:0] a1_rd_data,
   input [11:0]      a1_adr,
   output reg 	     a1_buf_rd,
   input 	     a1_buf_empty,
   input [31:0]      a1_buf_wr_data, 
   // Peripheral 2
   input 	     a2_wr_req, 
   input 	     a2_bwr_req,
   input 	     a2_rd_req,
   output reg 	     a2_ack, 
   input [15:0]      a2_wr_data,
   output reg [15:0] a2_rd_data,
   input [11:0]      a2_adr,
   output reg 	     a2_buf_rd,
   input 	     a2_buf_empty,
   input [31:0]      a2_buf_wr_data, 
   // Peripheral 3
   input 	     a3_wr_req, 
   input 	     a3_bwr_req,
   input 	     a3_rd_req,
   output reg 	     a3_ack, 
   input [15:0]      a3_wr_data,
   output reg [15:0] a3_rd_data,
   input [11:0]      a3_adr,
   output reg 	     a3_buf_rd,
   input 	     a3_buf_empty,
   input [31:0]      a3_buf_wr_data
   );

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Internals
   reg [1:0] 	     i_index=0; 
   reg 		     i_ack=0;
   reg 		     i_wr_req;
   reg 		     i_rd_req;
   reg 		     i_bwr_req;
   reg [11:0] 	     i_adr;
   reg [15:0] 	     i_wr_data;
   reg [15:0] 	     i_rd_data;
   reg 		     i_buf_rd; 
   reg 		     i_buf_empty;
   reg [31:0] 	     i_buf_wr_data;
   reg 		     y_req = 0;
   reg 		     y_ack = 0; 
   wire 	     y_ack_ne; 
   reg [11:0] 	     i_y_adr=0;
   reg [15:0] 	     i_y_wr_data=0;
   wire [15:0] 	     i_y_rd_data;
   reg 		     i_y_wr=0;
   negedge_detector NEDGE_0(.clk(clk),.rst_n(!rst),.a(y_ack),.y(y_ack_ne)); 

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   localparam
     S_IDLE          = 0,
     S_BWR_BUF_EMPTY = 1,
     S_BWR_WAIT_0    = 2, 
     S_BWR_WRITE     = 3,
     S_ACK           = 4,
     S_RD_WAIT       = 5;
   reg [2:0] 	     fsm = S_IDLE; 
   reg [3:0] 	     rd_wait_cnt = 0;
   localparam        L_RD_WAIT_CNT_MAX = 0; 
   
`ifdef MODEL_TECH
   reg [127:0] 	     state_str;
   always @(*)
     case(fsm)
       S_IDLE:          state_str = "S_IDLE";
       S_BWR_BUF_EMPTY: state_str = "S_BWR_BUF_EMPTY";
       S_BWR_WRITE:     state_str = "S_BWR_WRITE";
       S_ACK:           state_str = "S_ACK";
       S_RD_WAIT:       state_str = "S_RD_WAIT"; 
     endcase // case (fsm)
`endif

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Output assignments
   assign y_adr      = po_en       ? po_adr     : i_y_adr;
   assign y_wr_data  = po_en       ? po_wr_data : i_y_wr_data;
   assign y_wr       = po_en       ? po_wr      : i_y_wr;
   assign po_rd_data = i_y_rd_data;
   assign i_y_rd_data = y_rd_data; 
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Helper logic
   always @(*)
     begin
	i_wr_req = 0; 
	i_rd_req = 0;
	i_bwr_req = 0; 
	a0_ack = 0;	
	a1_ack = 0;
	a2_ack = 0;
	a3_ack = 0; 
	i_adr = 0;
	i_wr_data = 0; 
	a0_rd_data = i_rd_data;
	a1_rd_data = i_rd_data;
	a2_rd_data = i_rd_data;
	a3_rd_data = i_rd_data;
	a0_buf_rd = 0;
	a1_buf_rd = 0;
	a2_buf_rd = 0;
	a3_buf_rd = 0;
	i_buf_empty = 0;
	i_buf_wr_data = 0;
	case(i_index)
	  0:
	    begin
	       i_wr_req = a0_wr_req;
	       i_rd_req = a0_rd_req;
	       i_bwr_req = a0_bwr_req;
	       a0_ack = i_ack; 
	       i_adr = a0_adr;
	       i_wr_data = a0_wr_data;
	       a0_rd_data = i_rd_data;
	       a0_buf_rd = i_buf_rd;
	       i_buf_empty = a0_buf_empty;
	       i_buf_wr_data = a0_buf_wr_data; 
	    end
	  
	  1:
	    begin
	       i_wr_req = a1_wr_req;
	       i_rd_req = a1_rd_req;
	       i_bwr_req = a1_bwr_req;
	       a1_ack = i_ack; 
	       i_adr = a1_adr;
	       i_wr_data = a1_wr_data;
	       a1_rd_data = i_rd_data;
	       a1_buf_rd = i_buf_rd;
	       i_buf_empty = a1_buf_empty;
	       i_buf_wr_data = a1_buf_wr_data; 
	    end
	  
	  2:
	    begin
	       i_wr_req = a2_wr_req;
	       i_rd_req = a2_rd_req;
	       i_bwr_req = a2_bwr_req;
	       a2_ack = i_ack; 
	       i_adr = a2_adr;
	       i_wr_data = a2_wr_data;
	       a2_rd_data = i_rd_data;
	       a2_buf_rd = i_buf_rd;
	       i_buf_empty = a2_buf_empty;
	       i_buf_wr_data = a2_buf_wr_data; 
	    end
	  
	  3:
	    begin
	       i_wr_req = a3_wr_req;
	       i_rd_req = a3_rd_req;
	       i_bwr_req = a3_bwr_req;
	       a3_ack = i_ack; 
	       i_adr = a3_adr;
	       i_wr_data = a3_wr_data;
	       a3_rd_data = i_rd_data;
	       a3_buf_rd = i_buf_rd;
	       i_buf_empty = a3_buf_empty;
	       i_buf_wr_data = a3_buf_wr_data; 
	    end
	endcase
     end
	
   // handle the indexing
   reg busy = 0;
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  i_index <= 0;
	  busy <= 0;
       end
     else
       case(i_index)
	 0:
	   begin 
	      if(a0_wr_req || a0_bwr_req || a0_rd_req || y_ack)
		begin
		   y_req <= 1;
		   busy <= 1; 
		   if(y_ack)
		     y_req <= 0;
		end
	      else if(!busy || y_ack_ne)
		begin
		   y_req <= 0;
		   i_index <= i_index + 1;
		   busy <= 0; 
		end
	      
	   end

	 1:
	   begin 
	      if(a1_wr_req || a1_bwr_req || a1_rd_req || y_ack)
		begin
		   y_req <= 1;
		   busy <= 1; 
		   if(y_ack)
		     y_req <= 0;
		end
	      else if(!busy || y_ack_ne)
		begin
		   i_index <= i_index + 1;
		   busy <= 0;
		end
	   end
	 
	 2:
	   begin 
	      if(a2_wr_req || a2_bwr_req || a2_rd_req || y_ack)
		begin
		   y_req <= 1;
		   busy <= 1; 
		   if(y_ack)
		     y_req <= 0;
		end
	      else if(!busy || y_ack_ne)
		begin
		   i_index <= i_index + 1;
		   busy <= 0;
		end
	   end
	   	 
	 3:
	   begin 
	      if(a3_wr_req || a3_bwr_req || a3_rd_req || y_ack)
		begin
		   y_req <= 1;
		   busy <= 1; 
		   if(y_ack)
		     y_req <= 0;
		end
	      else if(!busy || y_ack_ne)
		begin
		   i_index <= i_index + 1;
		   busy <= 0;
		end
	   end
       endcase

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // FSM flow
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  i_ack <= 0; 
	  y_ack <= 0;
	  i_buf_rd <= 0; 
	  i_y_wr <= 0;
	  i_y_wr_data <= 0;
	  i_y_adr <= 0; 
	  fsm <= S_IDLE; 
       end
     else
       begin
	  i_y_wr <= 0;
	  i_buf_rd <= 0; 
	  case(fsm)
	    S_IDLE: 
	      begin
		 i_ack <= 0; 
		 y_ack <= 0;
		 i_y_adr <= i_adr;
		 rd_wait_cnt <= 0;
		 if(i_wr_req)
		   begin
		      i_y_wr <= 1;
		      i_y_wr_data <= i_wr_data[15:0];
		      fsm <= S_ACK;
		   end
		 else if(i_bwr_req)
		   begin
		      fsm <= S_BWR_BUF_EMPTY;
		   end
		 else if(i_rd_req)
		   begin	    
		      fsm <= S_RD_WAIT;
		   end 
	      end
	    	    
	    S_BWR_BUF_EMPTY:
	      if(!i_buf_empty)
		begin 
		   i_buf_rd <= 1;
		   fsm <= S_BWR_WAIT_0; 
		end
	      else
		fsm <= S_ACK; 

	    S_BWR_WAIT_0: fsm <= S_BWR_WRITE; 
	    
	    S_BWR_WRITE:
	      begin
		 i_y_wr <= 1;
		 i_y_wr_data <= i_buf_wr_data[15:0];
		 i_y_adr <= i_buf_wr_data[27:16];
		 fsm <= S_BWR_BUF_EMPTY; 
	      end  
	    
	    S_ACK:
	      begin
		 i_ack <= 1;
		 y_ack <= 1;
		 i_rd_data <= i_y_rd_data;
		 if(!y_req && !i_wr_req && !i_bwr_req && !i_rd_req)
		   begin
		      y_ack <= 0;
		      i_ack <= 0; 
		      fsm <= S_IDLE;
		   end
	      end

	    S_RD_WAIT:
	      begin
		 rd_wait_cnt <= rd_wait_cnt + 1;
		 if(rd_wait_cnt == L_RD_WAIT_CNT_MAX)
		   begin
		      rd_wait_cnt <= 0;
		      fsm <= S_ACK; 
		   end
	      end
	    
	    default: fsm <= S_IDLE; 
	  endcase // case (fsm)
       end
   	    
endmodule
