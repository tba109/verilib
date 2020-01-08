//////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed Mar 27 11:16:34 EDT 2019
//
// uart_proc_hs.v
//
// -- Process UART commands according to dom_uart_protocol.xlsx
// -- Parameterized timeout between parsing of commands.
// -- CRCs come at the end of the packet, but this module immediately writes
//    incoming commands, generating an error only at the end. If CRC
//    verification is desired before writing, these commands need to be
//    buffered and the error needs to be sensed.
// -- The logic interface handshakes out the data, and allows a fifo to buffer
// -- the write data. 
///////////////////////////////////////////////////////////////////////////////

module uart_proc_hs
  (
   input 	     clk,
   input 	     rst,
   // uart phy interface
   input 	     uart_cmd_req, // uart has new command byte
   input [7:0] 	     uart_cmd_data, // new uart command byte
   output reg 	     uart_cmd_ack=0, // uart command acknowledge
   output reg 	     uart_rsp_req=0, // logic has new response byte
   output reg [7:0]  uart_rsp_data=0, // new logic response byte
   input 	     uart_rsp_ack, // transmission of response byte is acknowledged
   // address/data bus logic interface
   output reg [11:0] logic_adr=0, // logic address
   output reg [15:0] logic_wr_data=0, // data to write
   output reg 	     logic_wr_req=0, // single write request
   output reg 	     buf_bwr_rdreq=0, // read request for fifo data from burst write
   output reg 	     buf_bwr_wrreq=0, // write data
   output reg 	     logic_rd_req=0, // read request (includes single and burst)
   input 	     logic_ack, // acknowledge for all data
   input [15:0]      logic_rd_data, // read data
   input 	     buf_bwr_empty, // burst write fifo empty
   input [11:0]      buf_bwr_adr, // burst write address
   input [15:0]      buf_bwr_data, // burst write data
   // Error management
   output [31:0]     err_out, // error output
   output 	     err_req, // error request
   input 	     err_ack
   );

   ////////////////////////////////////////////////////////////////////////////
   // Internals
`ifdef MODEL_TECH
   parameter P_TIMEOUT_CNT_MAX = 1000; 
`else
   parameter P_TIMEOUT_CNT_MAX = 100000000; 
`endif
   wire 	     i_rst;
   wire 	     timeout; 
   reg 		     is_burst = 0;
   reg 		     is_rd = 0;
   reg [15:0] 	     n_burst = 0;
   reg 		     err = 0; 
   reg [15:0] 	     len = 0; 
   wire [15:0] 	     crc_out;
   reg [15:0] 	     crc_in; 
   reg [7:0] 	     crc_data = 0; 
   reg 		     crc_en = 0;
   reg 		     err_wr = 0;
   reg [31:0] 	     err_in = 0;
   localparam
     L_HDR1   = 8'h8f,
     L_HDR0   = 8'hc7,
     L_SINGLE = 8'h00,
     L_BURST  = 8'h80,
     L_WR     = 8'h01,
     L_RD     = 8'h02; 
   localparam
     L_ERR_CRC_WR = 32'h00000001;
   
   ////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   reg [4:0] fsm;
   localparam
     S_HDR1=0,
     S_HDR0=1, 
     S_PID1=2,
     S_PID0=3,
     S_LEN1=4,
     S_LEN0=5,
     S_ADR1=6,
     S_ADR0=7,
     S_WR_DATA0=8,
     S_WR_DATA1=9,
     S_WR_WAIT=10,
     S_WR_CRC1=11,
     S_WR_CRC0=12,
     S_BWR_RDREQ=13,
     S_BWR_WAIT_0=14, 
     S_SWR_HS=15, 
     S_BWR_HS=16,
     S_RD_HS=17,
     S_RD_DATA1=18,
     S_RD_DATA0=19,
     S_RD_WAIT=20,
     S_RD_CRC1=21,
     S_RD_CRC0=22,
     S_BWR_BUF_CLR=23;
     
`ifdef MODEL_TECH // This works well for modelsim
   reg [127:0] state_str;
   always @(*)
     case(fsm)
       S_HDR1:          state_str = "S_HDR1";
       S_HDR0:          state_str = "S_HDR0";
       S_PID1:          state_str = "S_PID1";
       S_PID0:          state_str = "S_PID0";
       S_LEN1:          state_str = "S_LEN1";
       S_LEN0:          state_str = "S_LEN0"; 
       S_ADR1:          state_str = "S_ADR1";
       S_ADR0:          state_str = "S_ADR0";
       S_WR_DATA1:      state_str = "S_WR_DATA1";
       S_WR_DATA0:      state_str = "S_WR_DATA0";
       S_WR_WAIT:       state_str = "S_WR_WAIT"; 
       S_WR_CRC1:       state_str = "S_WR_CRC1";
       S_WR_CRC0:       state_str = "S_WR_CRC0"; 
       S_BWR_RDREQ:     state_str = "S_BWR_RDREQ"; 
       S_BWR_WAIT_0:    state_str = "S_BWR_WAIT_0"; 
       S_SWR_HS:        state_str = "S_SWR_HS";
       S_BWR_HS:        state_str = "S_BWR_HS";
       S_RD_HS:         state_str = "S_RD_HS";   
       S_RD_DATA1:      state_str = "S_RD_DATA1";
       S_RD_DATA0:      state_str = "S_RD_DATA0";
       S_RD_WAIT:       state_str = "S_RD_WAIT"; 
       S_RD_CRC1:       state_str = "S_RD_CRC1";
       S_RD_CRC0:       state_str = "S_RD_CRC0";
       S_BWR_BUF_CLR:   state_str = "S_BWR_BUF_CLR"; 
     endcase // case (fsm)
`endif
   
   ////////////////////////////////////////////////////////////////////////////
   // Helper logic
   wire        uart_rsp_ack_ne; 
   negedge_detector NEDGE_0(.clk(clk),.rst_n(!i_rst),.a(uart_rsp_ack),.y(uart_rsp_ack_ne));    
   wire        logic_ack_ne;
   negedge_detector NEDGE_1(.clk(clk),.rst_n(!i_rst),.a(logic_ack),.y(logic_ack_ne));    
   
   ///////////////////////////////////////////////////////////////////////////
   // CRC generator
   // Note: CRCs can be manually checked using the online calculator from
   //       www.sunshine2k.de/coding/javascript/crc/crc_js.html
   // Choose the following options:
   //       CRC width = CRC-16
   //       CRC parameterization: Custom
   //       CRC detailed parmeters:
   //           Input reflected: no (unchecked)
   //           Result reflected: no (unchecked)
   //           Polynomial: 0x8005
   //           Initial Value: 0xFFFF
   //           Final Xor Value: 0x0
   crc CRC16_8B_P_0(
		    // Outputs
		    .crc_out		(crc_out),
		    // Inputs
		    .data_in		(crc_data),
		    .crc_en		(crc_en),
		    .rst		(i_rst || fsm == S_HDR1),
		    .clk		(clk)
		    ); 

   
   ///////////////////////////////////////////////////////////////////////////
   // Error management
   err_mngr EM_0(
		 // Outputs
		 .err_out		(err_out[31:0]),
		 .err_req		(err_req),
		 // Inputs
		 .clk			(clk),
		 .rst_n			(!rst),
		 .err_wr		(err_wr),
		 .err_in		(err_in[31:0]),
		 .err_ack		(err_ack)
		 ); 
   
   ///////////////////////////////////////////////////////////////////////////
   // Timeout and reset
   reg [4:0]   cur_state = S_HDR1; 
   reg [31:0]  timeout_cnt = 0;
   assign timeout = timeout_cnt == P_TIMEOUT_CNT_MAX; 
   always @(posedge clk or posedge rst)
     if(rst)
       timeout_cnt <= 0;
     else if(fsm != cur_state) // reset timeout when state changes
       begin
	  cur_state <= fsm;
	  timeout_cnt <= 0;
       end
     else if(fsm == S_HDR1) // don't run the timeout counter when 
       begin
	  cur_state <= fsm;
	  timeout_cnt <= 0;
       end
       else
	 timeout_cnt <= timeout_cnt + 1; 
       
       
   
   assign i_rst = rst || timeout; 

   ///////////////////////////////////////////////////////////////////////////
   // FSM Flow
   always @(posedge clk)
     if(i_rst)
       begin
	  fsm <= S_HDR1;
	  uart_cmd_ack <= 0;
	  uart_rsp_req <= 0;
	  uart_rsp_data <= 0;
	  logic_adr <= 0;
	  logic_wr_data <= 0;
	  buf_bwr_wrreq <= 0;
	  logic_wr_req <= 0;
	  logic_rd_req <= 0;
	  is_rd <= 0;
	  is_burst <= 0;
	  n_burst <= 0;
	  err <= 0;
	  len <= 0;
	  crc_en <= 0;
	  crc_data <= 0;
	  err_wr <= 0;
	  err_in <= 0; 
	  crc_in <= 0;
	  err_wr <= 0;
	  buf_bwr_rdreq <= 0; 
       end
     else
       begin
	  buf_bwr_wrreq <= 0;
	  buf_bwr_rdreq <= 0;
	  crc_en <= 0;
	  err_wr <= 0; 
      	  case(fsm)
	    S_HDR1: 
	      begin
		 logic_wr_req <= 0;
		 logic_rd_req <= 0; 
		 err_in <= 0; 
		 crc_in <= 0; 
		 uart_cmd_ack <= 0;
		 uart_rsp_req <= 0;
		 uart_rsp_data <= 0;
		 logic_adr <= 0;
		 is_rd <= 0;
		 is_burst <= 0;
		 n_burst <= 0;
		 err <= 0;
		 len <= 0; 
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      if(uart_cmd_data == L_HDR1) 
			fsm <= S_HDR0;
		   end		 
	      end

	    S_HDR0:
	      begin
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      if(uart_cmd_data == L_HDR0)
			fsm <= S_PID1;
		      else
			fsm <= S_HDR1;
		   end
	      end
	      
	    S_PID1:
	      begin
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      if(uart_cmd_data == L_BURST)
			begin
			   is_burst <= 1; 
			   fsm <= S_PID0;
			end
		      else if(uart_cmd_data == L_SINGLE)
			fsm <= S_PID0;
		      else
			fsm <= S_HDR1;
		   end
	      end
	    
	    S_PID0: 
	      begin
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      if(uart_cmd_data == L_RD)
			begin
			   is_rd <= 1;
			   if(is_burst)
			     fsm <= S_LEN1;
			   else
			     begin
				len <= 1; 
				fsm <= S_ADR1;
			     end
			end
		      else if(uart_cmd_data == L_WR)
			begin
			   if(is_burst)
			     fsm <= S_LEN1; 
			   else
			     begin
				len <= 1;
				fsm <= S_ADR1;
			     end
			end
		      else
			fsm <= S_HDR1;
		   end
	      end
	    
	    S_LEN1:
	      begin
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      len[15:8] <= uart_cmd_data;
		      fsm <= S_LEN0;
		   end
	      end     

	    S_LEN0: 
	      begin
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      len[7:0] <= uart_cmd_data;
		      fsm <= S_ADR1;
		   end
	      end     
	      
	    S_ADR1:
	      begin 
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      logic_adr[11:8] <= uart_cmd_data[3:0];
		      crc_en <= 1;
		      crc_data <= uart_cmd_data; 
		      fsm <= S_ADR0; 
		   end
	      end
		 
	    S_ADR0:
	      begin
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      crc_en <= 1;
		      crc_data <= uart_cmd_data; 
		      if(is_rd)
			begin
			   logic_adr <= {logic_adr[11:8],uart_cmd_data};
			   fsm <= S_RD_HS;
			end
		      else
			begin
			   logic_adr <= {logic_adr[11:8],uart_cmd_data}-12'd1;
			   fsm <= S_WR_DATA1;
			end
		   end
	      end
	    
	    S_WR_DATA1: 
	      begin
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      crc_en <= 1;
		      crc_data <= uart_cmd_data; 
		      uart_cmd_ack <= 0;
		      logic_wr_data[15:8] <= uart_cmd_data;
		      logic_adr <= logic_adr+1;
		      fsm <= S_WR_DATA0; 
		   end
	      end
	      
	    S_WR_DATA0: 
	      begin
		 if(uart_cmd_req)
		   uart_cmd_ack <= 1;
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      crc_en <= 1;
		      crc_data <= uart_cmd_data; 
		      uart_cmd_ack <= 0;
		      logic_wr_data[7:0] <= uart_cmd_data;
		      if(is_burst)
			buf_bwr_wrreq <= 1; 
		      len <= len-1;
		      if(len-1==0)
			fsm <= S_WR_WAIT; 
		      else
			fsm <= S_WR_DATA1;
		   end
	      end

	    S_WR_WAIT: fsm <= S_WR_CRC1; 
	    
	    S_WR_CRC1: 
	      begin
		 if(uart_cmd_req)
		   begin
		      crc_in[15:8] <= uart_cmd_data; 
		      uart_cmd_ack <= 1;
		   end
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      uart_cmd_ack <= 0;
		      fsm <= S_WR_CRC0;
		   end
	      end

	    S_WR_CRC0: // check the CRC 
	      begin
		 if(uart_cmd_req)
		   begin
		      crc_in[7:0] <= uart_cmd_data; 
		      uart_cmd_ack <= 1;
		   end
		 if(!uart_cmd_req && uart_cmd_ack)
		   begin
		      if(crc_in != crc_out)
			begin
			   err_wr <= 1;
			   err_in <= L_ERR_CRC_WR;
			end
		      uart_cmd_ack <= 0;
		      if(is_burst)
			begin
			   fsm <= S_BWR_RDREQ;
			   if(crc_in != crc_out)
			     fsm <= S_BWR_BUF_CLR;
			end
		      else
			fsm <= S_SWR_HS; 
		   end
	      end

	    S_BWR_RDREQ:
	      begin
		 buf_bwr_rdreq <= 1;
		 fsm <= S_BWR_WAIT_0;
	      end

	    S_BWR_WAIT_0:
	      fsm <= S_BWR_HS; 
	    
	    S_SWR_HS:
	      begin
		 logic_wr_req <= 1;
		 if(logic_ack)
		   logic_wr_req <= 0;
		 if(logic_ack_ne)
		   begin
		      logic_wr_req <= 0; 
		      fsm <= S_HDR1;
		   end
	      end

	    S_BWR_HS:
	      begin
		 logic_wr_req <= 1;
		 logic_wr_data <= buf_bwr_data; 
		 logic_adr <= buf_bwr_adr;
		 if(logic_ack)
		   logic_wr_req <= 0;
		 if(logic_ack_ne)
		   begin
		      logic_wr_req <= 0; 
		      if(buf_bwr_empty)
			fsm <= S_HDR1;
		      else
			fsm <= S_BWR_RDREQ; 
		   end
	      end

	    S_RD_HS:
	      begin
		 logic_rd_req <= 1;
		 if(logic_ack)
		   logic_rd_req <= 0;
		 if(logic_ack_ne)
		   begin
		      logic_rd_req <= 0;
		      fsm <= S_RD_DATA1;
		   end
	      end
	    
	    S_RD_DATA1: 
	      begin
		 uart_rsp_data <= logic_rd_data[15:8];
		 uart_rsp_req <= 1;
		 if(uart_rsp_ack)
		   uart_rsp_req <= 0;
		 if(uart_rsp_ack_ne)
		   begin
		      crc_en <= 1;
		      crc_data <= logic_rd_data[15:8]; 
		      uart_rsp_req <= 0;
		      fsm <= S_RD_DATA0; 
		   end
	      end 

	    S_RD_DATA0:
	      begin
		 uart_rsp_data <= logic_rd_data[7:0];
		 uart_rsp_req <= 1;
		 if(uart_rsp_ack)
		   uart_rsp_req <= 0;
		 if(uart_rsp_ack_ne)
		   begin
		      logic_adr <= logic_adr+1;
		      uart_rsp_req <= 0;
		      len <= len-1;
		      crc_en <= 1;
		      crc_data <= uart_rsp_data[7:0]; 
		      if(len-1==0)
			fsm <= S_RD_WAIT;
		      else
			begin
			   fsm <= S_RD_HS; 
			end
		   end
	      end 

	    S_RD_WAIT: fsm <= S_RD_CRC1; 
	    
	    S_RD_CRC1: // write the upper CRC byte 
	      begin
		 uart_rsp_data <= crc_out[15:8]; // TBA_NOTE: write upper CRC byte here
		 uart_rsp_req <= 1;
		 if(uart_rsp_ack)
		   uart_rsp_req <= 0;
		 if(uart_rsp_ack_ne)
		   begin
		      uart_rsp_req <= 0;
		      fsm <= S_RD_CRC0;
		   end
	      end
	    
	    S_RD_CRC0: // write the lower CRC byte
	      begin
		 uart_rsp_data <= crc_out[7:0]; // TBA_NOTE: write lower CRC byte here
		 uart_rsp_req <= 1;
		 if(uart_rsp_ack)
		   uart_rsp_req <= 0;
		 if(uart_rsp_ack_ne)
		   begin
		      uart_rsp_req <= 0;
		      fsm <= S_HDR1;
		   end
	      end

	    S_BWR_BUF_CLR:
	      begin
		 buf_bwr_rdreq <= 1;
		 if(buf_bwr_empty)
		   begin
		      buf_bwr_rdreq <= 0;
		      fsm <= S_HDR1;
		   end
	      end
	      	    
	    default: fsm <= S_HDR1;
	    
	  endcase
       end // else: !if(rst)
   
endmodule

// Local Variables:
// verilog-library-flags:("-y ../crc16_parallel/" "-y ../err_mngr/")
// End:
