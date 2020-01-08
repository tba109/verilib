////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Mon Apr  1 10:42:21 EDT 2019
//
// ft232r_proc_buffered.v
//
// Stiches together ft232r_hs, uart_proc, and a buffer.  
////////////////////////////////////////////////////////////////////////////////////////////////////

module ft232r_proc_buffered
  (
   input 	 clk,
   input 	 rst,
   // FT232R interface. Signal name directions are referenced to that device. 
   input 	 txd, 
   output 	 rxd,
   input 	 rts_n,
   output 	 cts_n,
   // Logic interface. These set address and data registers. 
   output [11:0] logic_adr,
   output [15:0] logic_wr_data,
   input [15:0]  logic_rd_data,
   output 	 logic_wr_req,
   output 	 logic_rd_req,
   input 	 logic_ack,
   output 	 err_req,
   input 	 err_ack,
   output [31:0] err_data
   );

   parameter P_DES_START_LATCH_CNT_MAX = 7;
   parameter P_DES_SHIFT_LATCH_CNT_MAX = 20;
   parameter P_DES_STOP_LATCH_CNT_MAX = 20; 
   parameter P_SER_LAUNCH_CNT_MAX = 20; 
   
   // uart
   wire        uart_cmd_req;
   wire        uart_cmd_ack;
   wire        uart_rsp_req; 
   wire        uart_rsp_ack;
   wire [7:0]  uart_cmd_data;
   wire [7:0]  uart_rsp_data;
   ft232r_hs #(
	       .P_DES_START_LATCH_CNT_MAX(P_DES_START_LATCH_CNT_MAX),
	       .P_DES_SHIFT_LATCH_CNT_MAX(P_DES_SHIFT_LATCH_CNT_MAX),
	       .P_DES_STOP_LATCH_CNT_MAX(P_DES_STOP_LATCH_CNT_MAX),
	       .P_SER_LAUNCH_CNT_MAX(P_SER_LAUNCH_CNT_MAX)
	       )
   FT232R_HS_0
     (
      // Outputs
      .rxd		(rxd),
      .cts_n		(cts_n),
      .rsp_ack		(uart_rsp_ack),
      .cmd_req		(uart_cmd_req),
      .cmd_data		(uart_cmd_data),
      // Inputs
      .clk		(clk),
      .rst		(rst),
      .txd		(txd),
      .rts_n		(rts_n),
      .rsp_req		(uart_rsp_req),
      .rsp_data		(uart_rsp_data),
      .cmd_ack		(uart_cmd_ack)
      );
      
   // UART byte processor with handshaking
   wire        i_buf_bwr_rdreq; 
   wire        i_buf_bwr_wrreq;
   wire [11:0] i_buf_bwr_adr; 
   wire [15:0] i_buf_bwr_data;
   wire        i_buf_bwr_empty; 
   uart_proc_hs UART_PROC_HS_0
     (
      // Outputs
      .uart_cmd_ack			(uart_cmd_ack),
      .uart_rsp_req			(uart_rsp_req),
      .uart_rsp_data			(uart_rsp_data[7:0]),
      .logic_adr			(logic_adr[11:0]),
      .logic_wr_data			(logic_wr_data[15:0]),
      .logic_wr_req			(logic_wr_req),
      .buf_bwr_rdreq			(i_buf_bwr_rdreq),
      .buf_bwr_wrreq			(i_buf_bwr_wrreq),
      .logic_rd_req			(logic_rd_req),
      .err_out				(err_data[31:0]),
      .err_req				(err_req),
      // Inputs
      .clk				(clk),
      .rst				(rst),
      .uart_cmd_req			(uart_cmd_req),
      .uart_cmd_data			(uart_cmd_data[7:0]),
      .uart_rsp_ack			(uart_rsp_ack),
      .logic_ack			(logic_ack),
      .logic_rd_data			(logic_rd_data[15:0]),
      .buf_bwr_empty                    (i_buf_bwr_empty), 
      .buf_bwr_adr                      (i_buf_bwr_adr),
      .buf_bwr_data                     (i_buf_bwr_data), 
      .err_ack				(err_ack)); 

   // buffered block write commands
   wire [31:0] fifo_q; 
   FIFO_2048_32 FIFO_2048_32_0
     (
      .clock            (clk),
      .data             ({4'b000,logic_adr,logic_wr_data}),
      .rdreq            (i_buf_bwr_rdreq),
      .wrreq            (i_buf_bwr_wrreq),
      .empty            (i_buf_bwr_empty),
      .full             (),
      .q                (fifo_q)
      );
   assign i_buf_bwr_adr = fifo_q[27:16];
   assign i_buf_bwr_data = fifo_q[15:0];
   
      
endmodule

// Local Variables:
// verilog-library-flags:("-y ../uart_proc_hs/")
// End:
