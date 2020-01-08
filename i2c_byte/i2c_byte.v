//////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Sat 08/31/2019_23:34:37.75
//
// i2c_byte.v
//
// An i2c byte transaction module. 
//
// Nice general resources on I2C: 
// https://www.nxp.com/docs/en/user-guide/UM10204.pdf
// https://i2c.info/i2c-bus-specification
//  
// SCL and SDA both are bidirectional and open drain. In IDLE mode, the master 
// tristates both and listens for other masters using the bus. 
//
// For Xilinx FPGAs, the open drain outputs can be configured from the _i and _o
// pins as seen here:
// https://www.xilinx.com/support/answers/1651.html
//
// SCL "gates" valid data of SDA, i.e., SCL 0->1 means that the SDA data is valid. 
// SCL 1->0 means that data is invalid. The SDA signal can only change when the 
// SCL signal is low. Data should be stable when the clock is high. 
//
// Version log:
// Thu 09/05/2019_13:03:01.24
// For now we only support 1 master (no master sync, arb, or clock stretching)
//
/////////////////////////////////////////////////////////////////////////////////

module i2c_byte
  (
   input 	    clk,
   input 	    rst,
   // Upper level controller req/ack
   input 	    r_wn, // If asserted, transaction is a read, otherwise, this is a write
   input 	    ctrl_req, // request a transaction
   output reg 	    ctrl_ack=0, // transaction acknowledged
   input [7:0] 	    ctrl_wr_data, // transaction write data
   output reg [7:0] ctrl_rd_data=0, // transaction read data
   
   // I2C Transmission controls
   input 	    i2c_start, // Issue a start at the beginning of the transmission
   input 	    i2c_ack, // Issue an acknowledge at the end of the transmission
   input 	    i2c_stop, // Issue a stop at the end of the transmission
   output reg       i2c_acked, // Transmission was acknowledge/not acknowledged
   // I2C cycle lengths
   input [31:0]     i2c_n0, // Number of cycles to starting the transmission
   input [31:0]     i2c_start_n0, // Number of cycles from SCL ?->1 to SDA 1->0
   input [31:0]     i2c_start_n1, // Number of cycles from SDA 1->0 to SCL 1->0 
   input [31:0]     i2c_data_n0, // Number of cycles from SCL 0->1 to SDA assert
   input [31:0]     i2c_data_n1, // Number of cycles from SDA assert to SCL 1->0
   input [31:0]     i2c_data_n2, // Number of cycles SCL=1
   input [31:0]     i2c_ack_n0, // Number of cycles from SCL 0->1 to ACK assert
   input [31:0]     i2c_ack_n1, // Number of cycles from ACK assert to SCL 1->0
   input [31:0]     i2c_ack_n2, // Number of cycles SCL=1
   input [31:0]     i2c_complete_n0, // Number of cycles for complete (SCL=0)
   input [31:0]     i2c_stop_n0, // Number of cycles from SDA X->0 to SCL 0->1 for stop
   input [31:0]     i2c_stop_n1, // Number of cycles to SDA 0->1 for stop
   input [31:0]     i2c_stop_n2, // Number of cycles before ctrl ack
   // I2C lines
   output reg 	    scl_o=1,
   output reg 	    sda_o=1,
   input 	    scl_i,
   input 	    sda_i
   );
   
   ////////////////////////////////////////////////////////////////////////////
   // Internals
   reg [7:0]  sr = 0; 
   reg [2:0]  sr_cnt = 0; 
   reg [31:0] cnt=0;
   
   ///////////////////////////////////////////////////////////////////////////
   // FSM definitions   
   localparam
     S_IDLE=0, 
     S_WAIT=1, 
     S_START_0=2,
     S_START_1=3,
     S_DATA_0=4,
     S_DATA_1=5,
     S_DATA_2=6,
     S_ACK_0=7,
     S_ACK_1=8,
     S_ACK_2=9,
     S_COMPLETE=10, 
     S_STOP_0=11,
     S_STOP_1=12,
     S_STOP_2=13,
     S_CTRL_ACK=14; 
   reg [3:0] fsm=0;

// `ifdef MODEL_TECH // This works for modelsim
// `ifdef XILINX_ISIM // This works for ISE
`ifdef XILINX_SIMULATOR // This works for Vivado
   reg [127:0] state_str;
   always @(*)
     case(fsm)
       S_IDLE:     state_str = "S_IDLE";
       S_WAIT:     state_str = "S_WAIT";
       S_START_0:  state_str = "S_START_0";
       S_START_1:  state_str = "S_START_1";
       S_DATA_0:   state_str = "S_DATA_0";
       S_DATA_1:   state_str = "S_DATA_1";
       S_DATA_2:   state_str = "S_DATA_2";
       S_ACK_0:    state_str = "S_ACK_0";
       S_ACK_1:    state_str = "S_ACK_1";
       S_ACK_2:    state_str = "S_ACK_2";
       S_COMPLETE: state_str = "S_COMPLETE"; 
       S_STOP_0:   state_str = "S_STOP_0";
       S_STOP_1:   state_str = "S_STOP_1";
       S_STOP_2:   state_str = "S_STOP_2";
       S_CTRL_ACK: state_str = "S_CTRL_ACK";
       default: state_str = "*** UNKNOWN ***"; 
     endcase // case (fsm)
`endif
   
   
   ////////////////////////////////////////////////////////////////////////
   // FSM Flow
   always @(posedge clk)
     if(rst)
       begin
	  fsm <= 0;
	  ctrl_ack <= 0;
	  ctrl_rd_data <= 0;
	  i2c_acked <= 0;
	  sda_o <= 1;
	  scl_o <= 1;
	  cnt <= 0;
	  sr <= 0; 
	  sr_cnt <= 0; 
       end
     else
       begin
	  ctrl_ack <= 0; 
	  case(fsm)

	    S_IDLE:
	      begin
		 ctrl_ack <= 0;
		 ctrl_rd_data <= 0;
		 i2c_acked <= 0;
		 cnt <= 0;
		 sr <= 0;
		 sr_cnt <= 0; 
		 if(ctrl_req)
		   begin
		      fsm <= S_WAIT;
		      sr <= ctrl_wr_data; 
		   end
	      end
	    
	    S_WAIT:
	      begin
		 cnt <= cnt + 1;
		 if(cnt == i2c_n0-1)
		   begin
		      cnt <= 0;
		      if(i2c_start)
			fsm <= S_START_0;
		      else
			fsm <= S_DATA_0; 
		   end
	      end
	  	
	    S_START_0:
	      begin
		 scl_o <= 1'b1;
		 cnt <= cnt + 1;
		 if(cnt == i2c_start_n0-1)
		   begin
		      cnt <= 0;
		      fsm <= S_START_1;
		   end
	      end

	    S_START_1:
	      begin
		 sda_o <= 1'b0;
		 cnt <= cnt + 1;
		 if(cnt == i2c_start_n1-1)
		   begin
		      cnt <= 0;
		      fsm <= S_DATA_0;
		   end
	      end

	    S_DATA_0:
	      begin
		 scl_o <= 1'b0; 
		 cnt <= cnt + 1;
		 if(cnt == i2c_data_n0-1)
		   begin
		      cnt <= 0;
		      fsm <= S_DATA_1;
		      
		   end
	      end

	    S_DATA_1:
	      begin
		 cnt <= cnt + 1;
		 if(r_wn) // Read 
		   sda_o <= 1'b1;
		 else
		   sda_o <= sr[7];
		 if(cnt == i2c_data_n1-1)
		   begin
		      cnt <= 0;
		      fsm <= S_DATA_2; 
		   end
	      end
		      	    
	    S_DATA_2:
	      begin
		 cnt <= cnt + 1;
		 scl_o <= 1'b1; 
		 if(cnt == i2c_data_n2-1)
		   begin
		      sr_cnt <= sr_cnt + 1; 
		      cnt <= 0;
		      if(r_wn) // Read, release the bus
			ctrl_rd_data <= {ctrl_rd_data[6:0],sda_i};
		      if(sr_cnt == 3'd7)
			begin 
			   sr_cnt <= 0;
			   fsm <= S_ACK_0;
			   
			end
		      else
			begin
			   fsm <= S_DATA_0; 
			   if(!r_wn)
			     sr <= {sr[6:0],1'b0};
			end
		   end
	      end

	    S_ACK_0:
	      begin 
		 cnt <= cnt + 1;
		 scl_o <= 1'b0; 
		 if(cnt == i2c_ack_n0-1)
		   begin
		      cnt <= 0;
		      fsm <= S_ACK_1;
		   end 
	      end
	    
	    S_ACK_1:
	      begin
		 cnt <= cnt + 1;
		 if(i2c_ack) // we ack
		   sda_o <= 1'b0;
		 else // they ack/nack
		   sda_o <= 1'b1; 
		 if(cnt == i2c_ack_n1-1)
		   begin
		      cnt <= 0;
		      fsm <= S_ACK_2; 
		   end
	      end

	    S_ACK_2:
	      begin
		 cnt <= cnt + 1; 
	    	 scl_o <= 1'b1; 
		 if(cnt == i2c_ack_n2-1)
		   begin
		      cnt <= 0; 
		      fsm <= S_COMPLETE; 
		      if(!i2c_ack) // Check for ack or nack
			i2c_acked <= sda_i;
		   end
	      end		 
	    
	    S_COMPLETE:
	      begin
		 cnt <= cnt + 1;
		 scl_o <= 1'b0;
		 if(cnt == i2c_complete_n0-1)
		   begin
		      cnt <= 0;
		      if(i2c_stop)
			fsm <= S_STOP_0;
		      else
			fsm <= S_CTRL_ACK;
		   end
	      end
	    
	    S_STOP_0:
	      begin
		 cnt <= cnt + 1;
		 sda_o <= 1'b0; 
		 if(cnt == i2c_stop_n0-1)
		   begin
		      cnt <= 0;
		      scl_o <= 1'b1;  
		      fsm <= S_STOP_1; 
		   end
	      end    

	    S_STOP_1:
	      begin
		 cnt <= cnt + 1;
		 if(cnt == i2c_stop_n1-1)
		   begin
		      cnt <= 0;
		      sda_o <= 1'b1;
		      fsm <= S_STOP_2; 
		   end
	      end

	    S_STOP_2: 
	      begin
		 cnt <= cnt + 1;
		 if(cnt == i2c_stop_n2-1)
		   begin
		      cnt <= 0;
		      fsm <= S_CTRL_ACK;
		   end
	      end
		 
	    S_CTRL_ACK:
	      begin
		 ctrl_ack <= 1'b1;
		 if(ctrl_req==0)
		   begin
		      ctrl_ack <= 1'b0;
		      fsm <= S_IDLE;
		   end
	      end 
	    
	    default: fsm <= S_IDLE; 
	    
	  endcase // case (fsm)
       end
   
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
