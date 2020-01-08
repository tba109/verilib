//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed 01/08/2020_14:00:29.39
//
// xfpga_regs.v
//
//////////////////////////////////////////////////////////////////////////////////

module xfpga_regs 
  (
   input 	     clk,
   input 	     rst,
   // Version number
   input [15:0]      vnum, 
   // Debug FT232R I/O
   input 	     debug_txd,
   output 	     debug_rxd,
   input 	     debug_rts_n,
   output 	     debug_cts_n,
   // Priority input
   input 	     po_wr, 
   input 	     po_en, 
   input [11:0]      po_a,
   input [15:0]      po_din,
   output [15:0]     po_dout, 
   // Local time counter
   output 	     ltc_rd_req,
   input 	     ltc_rd_ack,
   input [47:0]      ltc_rd_data,
   output 	     ltc_wr_req,
   input 	     ltc_wr_ack, 
   output reg [47:0] ltc_wr_data=0,
   // SPI master 0 (ADC SPI registers)
   output 	     spim_0_req,
   output reg [15:0] spim_0_wr_data=0,
   output reg 	     spim_0_chip_select=0,
   input [7:0] 	     spim_0_rd_data,
   input 	     spim_0_ack,
   // DPRAM  
   output reg [15:0] dpram_sel = 0,
   output [10:0]     dpram_addr,
   output [15:0]     dpram_data,
   output 	     dpram_wren,
   input [15:0]      dpram_q,
   output reg 	     dpram_done = 0,
   input [15:0]      dpram_len 
   );
   
   // Debug UART parameters
   localparam P_DEBUG_DES_START_LATCH_CNT_MAX = 7;
   localparam P_DEBUG_DES_SHIFT_LATCH_CNT_MAX = 20;
   localparam P_DEBUG_DES_STOP_LATCH_CNT_MAX = 20; 
   localparam P_DEBUG_SER_LAUNCH_CNT_MAX = 20; 
   
   ///////////////////////////////////////////////////////////////////////////////
   // 1.) Debug UART
   wire [11:0] debug_logic_adr;
   wire [15:0] debug_logic_wr_data;
   wire        debug_logic_wr_req;
   wire        debug_logic_rd_req;
   wire        debug_err_req;
   wire [31:0] debug_err_data;
   wire [15:0] debug_logic_rd_data;
   wire        debug_logic_ack;
   wire        debug_err_ack; 
   ft232r_proc_buffered 
     #(
       .P_DES_START_LATCH_CNT_MAX(P_DEBUG_DES_START_LATCH_CNT_MAX),
       .P_DES_SHIFT_LATCH_CNT_MAX(P_DEBUG_DES_SHIFT_LATCH_CNT_MAX),
       .P_DES_STOP_LATCH_CNT_MAX(P_DEBUG_DES_STOP_LATCH_CNT_MAX),
       .P_SER_LAUNCH_CNT_MAX(P_DEBUG_SER_LAUNCH_CNT_MAX)
       )
   UART_DEBUG_0
     (
      // Outputs
      .rxd		(debug_rxd),
      .cts_n		(debug_cts_n),
      .logic_adr	(debug_logic_adr[11:0]),
      .logic_wr_data	(debug_logic_wr_data[15:0]),
      .logic_wr_req	(debug_logic_wr_req),
      .logic_rd_req	(debug_logic_rd_req),
      .err_req		(debug_err_req),
      .err_data		(debug_err_data[31:0]),
      // Inputs
      .clk		(clk),
      .rst		(rst),
      .txd		(debug_txd),
      .rts_n		(debug_rts_n),
      .logic_rd_data	(debug_logic_rd_data[15:0]),
      .logic_ack	(debug_logic_ack),
      .err_ack		(debug_err_ack)
      ); 

   
   ///////////////////////////////////////////////////////////////////////////////
   // Command, repsonse, status
   wire [11:0] y_adr;
   wire [15:0] y_wr_data;
   wire        y_wr; 
   reg [15:0]  y_rd_data; 
   crs_master CRSM_0
     (
      // Outputs
      .y_adr		(y_adr[11:0]),
      .y_wr_data	(y_wr_data[15:0]),
      .y_wr		(y_wr),
      .a0_ack		(debug_logic_ack),
      .a0_rd_data	(debug_logic_rd_data[15:0]),
      .a0_buf_rd	(),
      .a1_ack		(),
      .a1_rd_data	(),
      .a1_buf_rd	(),
      .a2_ack		(),
      .a2_rd_data	(),
      .a2_buf_rd	(),
      .a3_ack		(),
      .a3_rd_data	(),
      .a3_buf_rd	(),
      // Inputs
      .clk		(clk),
      .rst		(rst),
      .y_rd_data	(y_rd_data[15:0]),
      .a0_wr_req	(debug_logic_wr_req),
      .a0_bwr_req	(1'b0),
      .a0_rd_req	(debug_logic_rd_req),
      .a0_wr_data	(debug_logic_wr_data[15:0]),
      .a0_adr		(debug_logic_adr[11:0]),
      .a0_buf_empty	(1'b1),
      .a0_buf_wr_data	(),
      .a1_wr_req	(),
      .a1_bwr_req	(),
      .a1_rd_req	(),
      .a1_wr_data	(),
      .a1_adr		(),
      .a1_buf_empty	(),
      .a1_buf_wr_data	(),
      .a2_wr_req	(),
      .a2_bwr_req	(),
      .a2_rd_req	(),
      .a2_wr_data	(),
      .a2_adr		(),
      .a2_buf_empty	(),
      .a2_buf_wr_data	(),
      .a3_wr_req	(),
      .a3_bwr_req	(),
      .a3_rd_req	(),
      .a3_wr_data	(),
      .a3_adr		(),
      .a3_buf_empty	(),
      .a3_buf_wr_data	(),
      // Priority Override
      .po_en            (po_en),
      .po_wr            (po_wr),
      .po_adr           (po_a),
      .po_wr_data       (po_din),
      .po_rd_data       (po_dout)
      ); 
   
   
   
   ///////////////////////////////////////////////////////////////////////////////
   // Registers and DPRAM
      
   // Local time counter tasks
   wire [15:0] ltc_task_val;
   wire [15:0] ltc_task_req;
   wire [15:0] ltc_task_ack; 
   task_reg #(.P_TASK_ADR(12'hffe)) LTC_TASK_REG_0
     (
      .clk(clk),
      .rst(rst),
      .adr(y_adr),
      .data(y_wr_data),
      .wr(y_wr),
      .req(ltc_task_req),
      .ack(ltc_task_ack),
      .val(ltc_task_val)
      );
   assign ltc_rd_req = ltc_task_req[0];
   assign ltc_wr_req = ltc_task_req[1];
   assign ltc_task_ack[0] = ltc_rd_ack;
   assign ltc_task_ack[1] = ltc_wr_ack; 

   // Read registers
   always @(*)
     begin
	case(y_adr)
	  12'hfff: begin y_rd_data = vnum;                                               end
	  12'hffe: begin y_rd_data = ltc_task_val;                                       end
	  12'hffd: begin y_rd_data = ltc_rd_data[47:32];                                 end
	  12'hffc: begin y_rd_data = ltc_rd_data[31:16];                                 end
	  12'hffb: begin y_rd_data = ltc_rd_data[15:0];                                  end
	  default: 
	    begin
	       y_rd_data = 16'hxxxx; 
	       if(y_adr < 12'd2048)
		 y_rd_data = dpram_q; 
	    end
	endcase   
     end

   // Write registers (not task regs)
   always @(posedge clk)
     begin 
	if(y_wr) 
	  case(y_adr)
	    12'hffe: begin ltc_wr_data[47:32]   <= y_wr_data;                                      end
	    12'hffd: begin ltc_wr_data[31:16]   <= y_wr_data;                                      end
	    12'hffc: begin ltc_wr_data[15:0]    <= y_wr_data;                                      end
	  endcase
     end // always @ (posedge clk)


   // DPRAM assignments
   assign dpram_addr = y_adr[10:0];
   assign dpram_data = y_wr_data;
   assign dpram_wren = y_wr && y_adr[11]==0; 

endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("." "../ft232r_proc_buffered/" "../crs_master/")
// End:
