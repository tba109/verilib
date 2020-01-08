//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Sat 08/31/2019_23:34:37.75
//
// i2c_master.v
//
// Version log:
// Thu 09/05/2019_13:03:01.24
// For now we only support 1 master (no master sync, arb, or clock stretching)
//
/////////////////////////////////////////////////////////////////////////////////

module i2c_master
  (
   input 	clk,
   input 	rst,
   // Controller req/ack
   input 	tx_req,
   input 	rx_req,
   input 	ex_req, // transmit the contents of the I2C TX FIFO, storing any RX 
   output 	ack,
   input [7:0] 	tx_data, // transaction write data
   output [7:0] rx_data, // transaction read data
   // I2C operations controls
   input 	i2c_start, // Issue a start at the beginning of the transmission
   input 	i2c_ack, // Issue an acknowledge at the end of the transmission
   input 	i2c_stop, // Issue a stop at the end of the transmission
   input 	i2c_r_wn, // 1: read from slave, 0: write to slave
   output 	i2c_acked, // Transmission was acknowledge/not acknowledged
   output 	i2c_rx_fifo_full, 
   output 	i2c_rx_fifo_empty, 
   output 	i2c_tx_fifo_full,
   output 	i2c_tx_fifo_empty, 
   // I2C cycle lengths
   input [31:0] i2c_n0, // Number of cycles to starting the transmission
   input [31:0] i2c_start_n0, // Number of cycles from SCL ?->1 to SDA 1->0
   input [31:0] i2c_start_n1, // Number of cycles from SDA 1->0 to SCL 1->0 
   input [31:0] i2c_data_n0, // Number of cycles from SDA assert to SCL 0->1
   input [31:0] i2c_data_n1, // Number of cycles to SCL 1->0
   input [31:0] i2c_data_n2, // Number of cycles to next SDA assert
   input [31:0] i2c_ack_n0, // Number of cycles to ACK/NACK (if required) to SCL 0->1
   input [31:0] i2c_ack_n1, // Number of cycles to SCL 1->0 for ACK
   input [31:0] i2c_ack_n2, // Number of cycles SCL=1
   input [31:0] i2c_complete_n0, // Number of cycles for complete (SCL=0)
   input [31:0] i2c_stop_n0, // Number of cycles from SDA X->0 to SCL 0->1 for stop
   input [31:0] i2c_stop_n1, // Number of cycles to SDA 0->1 for stop
   input [31:0] i2c_stop_n2, // Number of cycles before ctrl ack
   // I2C lines
   output 	scl_o,
   output 	sda_o,
   input 	scl_i,
   input 	sda_i
   );
   
   
   ////////////////////////////////////////////////////////////////////////////
   // I2C byte transactions
   wire 	i_ctrl_ack;
   wire [7:0] 	i_ctrl_rx_data;
   wire 	i_i2c_acked;
   wire 	i_r_wn;
   reg 		i_ctrl_req=0;
   wire [7:0] 	i_ctrl_tx_data;
   wire 	i_i2c_start;
   wire 	i_i2c_ack;
   wire 	i_i2c_stop; 
   i2c_byte I2C_BYTE_0
     (
      // Outputs
      .ctrl_ack				(i_ctrl_ack),
      .ctrl_rd_data			(i_ctrl_rx_data[7:0]),
      .i2c_acked			(i_i2c_acked),
      .scl_o				(scl_o),
      .sda_o				(sda_o),
      // Inputs
      .clk				(clk),
      .rst				(rst),
      .scl_i				(scl_i),
      .sda_i				(sda_i),
      .r_wn				(i_r_wn),
      .ctrl_req				(i_ctrl_req),
      .ctrl_wr_data			(i_ctrl_tx_data[7:0]),
      .i2c_start			(i_i2c_start),
      .i2c_ack				(i_i2c_ack),
      .i2c_stop				(i_i2c_stop),
      .i2c_n0				(i2c_n0[31:0]),
      .i2c_start_n0			(i2c_start_n0[31:0]),
      .i2c_start_n1			(i2c_start_n1[31:0]),
      .i2c_data_n0			(i2c_data_n0[31:0]),
      .i2c_data_n1			(i2c_data_n1[31:0]),
      .i2c_data_n2			(i2c_data_n2[31:0]),
      .i2c_complete_n0                  (i2c_complete_n0[31:0]), 
      .i2c_ack_n0			(i2c_ack_n0[31:0]),
      .i2c_ack_n1			(i2c_ack_n1[31:0]),
      .i2c_ack_n2			(i2c_ack_n2[31:0]),
      .i2c_stop_n0			(i2c_stop_n0[31:0]),
      .i2c_stop_n1			(i2c_stop_n1[31:0]),
      .i2c_stop_n2			(i2c_stop_n2[31:0])
      ); 

   
   ////////////////////////////////////////////////////////////////////////////
   // Buffering for RX
   wire [15:0] 	     rx_fifo_din; 
   reg 		     rx_fifo_wr_en=0;
   reg 		     rx_fifo_rd_en=0;
   wire [15:0] 	     rx_fifo_dout;
   wire 	     rx_fifo_full;
   wire 	     rx_fifo_empty;
   FIFO_1024_16 RX_FIFO_0
     (
      .clk(clk), 
      .srst(1'b0),
      .din(rx_fifo_din),
      .wr_en(rx_fifo_wr_en),
      .rd_en(rx_fifo_rd_en),
      .dout(rx_fifo_dout),
      .full(),  
      .empty(rx_fifo_empty),
      .almost_full(rx_fifo_full),
      .almost_empty()
      );
   assign rx_fifo_din = {rx_fifo_full,6'd0,i_i2c_acked,i_ctrl_rx_data}; 
   assign i2c_rx_fifo_full = rx_fifo_dout[15];
   assign i2c_rx_fifo_empty = rx_fifo_empty;
   assign i2c_acked = rx_fifo_dout[8];
   assign rx_data = rx_fifo_dout[7:0];


   // Control for the RX FIFO read side
   reg [1:0] rx_rd_state = 0;
   reg 	     rx_ack = 0; 
   always @(posedge clk)
     if(rst)
       begin
	  rx_rd_state <= 0;
	  rx_ack <= 0; 
       end
     else
       begin
	  rx_fifo_rd_en <= 0;
	  rx_ack <= 0; 
	  case(rx_rd_state)

	    0: 
	      begin
		 if(rx_req)
		   if(!rx_fifo_empty)
		     begin 
			rx_fifo_rd_en <= 1;
			rx_rd_state <= 1;
		     end
		   else
		     rx_rd_state <= 3;
	      end

	    1: rx_rd_state <= 2; 
	      

	    2: rx_rd_state <= 3; 

	    3:
	      begin
		 rx_ack <= 1;
		 if(rx_req == 0)
		   begin
		      rx_ack <= 0;
		      rx_rd_state <= 0;
		   end
	      end
		 
	  endcase // case (rx_rd_state)
       end
   
   
   ////////////////////////////////////////////////////////////////////////////
   // Buffering for TX
   wire [15:0] 	     tx_fifo_din; 
   reg 		     tx_fifo_wr_en = 0;
   reg 		     tx_fifo_rd_en = 0;
   wire [15:0] 	     tx_fifo_dout;
   wire 	     tx_fifo_full;
   wire 	     tx_fifo_empty;
   FIFO_1024_16 TX_FIFO_0
     (
      .clk(clk), 
      .srst(1'b0),
      .din(tx_fifo_din),
      .wr_en(tx_fifo_wr_en),
      .rd_en(tx_fifo_rd_en),
      .dout(tx_fifo_dout),
      .full(),  
      .empty(tx_fifo_empty),
      .almost_full(tx_fifo_full),
      .almost_empty()
      );
   assign i2c_tx_fifo_full = tx_fifo_full;
   assign i2c_tx_fifo_empty = tx_fifo_empty; 
   assign tx_fifo_din = {i2c_start,i2c_ack,i2c_stop,i2c_r_wn,4'h0,tx_data}; 
   assign i_i2c_start = tx_fifo_dout[15];
   assign i_i2c_ack = tx_fifo_dout[14];
   assign i_i2c_stop = tx_fifo_dout[13];
   assign i_r_wn = tx_fifo_dout[12];
   assign i_ctrl_tx_data = tx_fifo_dout[7:0];
   
   // TX FIFO write controls
   reg 		     tx_wr_state = 0; 
   reg 		     tx_ack = 0; 
   always @(posedge clk)
     if(rst)
       begin
	  tx_wr_state <= 0;
	  tx_ack <= 0;
	  tx_fifo_wr_en <= 0; 
       end
     else
       begin
	  tx_ack <= 0;
	  tx_fifo_wr_en <= 0; 
	  case(tx_wr_state)
	    
	    0: 
	      begin 
		 if(tx_req && !tx_fifo_full)
		   begin
		      tx_fifo_wr_en <= 1;
		      tx_wr_state <= 1;
		   end
	      end

	    1:
	      begin
		 tx_ack <= 1;
		 if(tx_req == 0)
		   tx_wr_state <= 0;
	      end
	    
	    default: tx_wr_state <= 0; 
	    
	  endcase
       end
   
   

   ////////////////////////////////////////////////////////////////////////////
   // Execution control state machines
   
   // TX FIFO read
   wire i_ctrl_ack_ne;
   reg [1:0] wait_cnt=0; 
   negedge_detector NEDGE_0(.clk(clk),.rst_n(!rst),.a(i_ctrl_ack),.y(i_ctrl_ack_ne)); 
   reg 	     ex_ack = 0;
   localparam
     S_TX_RD_IDLE = 0,
     S_TX_RD_WAIT = 1,
     S_TX_RD_CTRL_ACK = 2,
     S_TX_RD_EX_ACK = 3;
   reg [1:0] tx_rd_state = S_TX_RD_IDLE;
   always @(posedge clk)
     if(rst)
       begin
	  tx_rd_state <= 0;
	  tx_fifo_rd_en <= 0;
	  i_ctrl_req <= 0;
	  ex_ack <= 0; 
       end
     else
       begin
	  tx_fifo_rd_en <= 0;
	  i_ctrl_req <= 0;
	  ex_ack <= 0; 
	  case(tx_rd_state)
	    
	    S_TX_RD_IDLE:
	      begin
		 wait_cnt <= 0; 
		 if(ex_req)
		   begin
		      if(!tx_fifo_empty)
			begin 
			   tx_fifo_rd_en <= 1;
			   tx_rd_state <= S_TX_RD_WAIT;
			end
		      else
			begin
			   tx_rd_state <= S_TX_RD_EX_ACK; 
			end 
		   end
	      end

	    S_TX_RD_WAIT: 
	      begin
		 wait_cnt <= wait_cnt + 1;
		 if(wait_cnt == 2'd2)
		   begin
		      wait_cnt <= 0; 
		      tx_rd_state <= S_TX_RD_CTRL_ACK;
		   end
	      end

	    S_TX_RD_CTRL_ACK:
	      begin
		 i_ctrl_req <= 1; 
		 if(i_ctrl_ack)
		   i_ctrl_req <= 0;
		 if(i_ctrl_ack_ne)
		   begin 
		      i_ctrl_req <= 0;
		      if(tx_fifo_empty)
			tx_rd_state <= S_TX_RD_EX_ACK;
		      else
			tx_rd_state <= S_TX_RD_IDLE; 
		   end
	      end

	    S_TX_RD_EX_ACK: 
	      begin 
		 ex_ack <= 1;
		 if(ex_req == 0)
		   begin 
		      ex_ack <= 0;
		      tx_rd_state <= S_TX_RD_IDLE;
		   end
	      end
	    
	    default: tx_rd_state <= S_TX_RD_IDLE;
	  	    
	  endcase
       end 

      
   // Control for the RX FIFO write side
   reg 		     rx_wr_state = 0;
   always @(posedge clk)
     if(rst)
       begin
	  rx_wr_state <= 0;
	  rx_fifo_wr_en <= 0; 
       end
     else
       begin
	  rx_fifo_wr_en <= 0; 
	  case(rx_wr_state)

	    0:
	      begin
		 if(i_ctrl_ack && i_r_wn && !rx_fifo_full) // I2C read
		   begin
		      rx_fifo_wr_en <= 1;
		      rx_wr_state <= 1; 
		   end
	      end

	    1:
	      begin
		 if(i_ctrl_ack==0)
		   rx_wr_state <= 0; 
	      end

	  endcase // case (rx_wr_state)
       end


   ////////////////////////////////////////////////////////////////////////////
   // Output assignments
   assign ack = rx_ack || tx_ack || ex_ack; 

      
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
