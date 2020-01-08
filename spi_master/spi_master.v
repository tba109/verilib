///////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed Feb 27 14:38:00 EST 2019
//
// spi_master.v
//
// Generic SPI master. Signaling in/out is determined by events at number of 
// cycles, rather than CPOL CPHA. Shifts out MSB first, so need to reflect the 
// data word if you need LSB first.
//
// The total execuation time words is calculated dynamically, and is based on the 
// longest of the required waveforms for mosi, miso, and sclk. 
///////////////////////////////////////////////////////////////////////////////////

module spi_master #(parameter P_RD_DATA_WIDTH=256, parameter P_WR_DATA_WIDTH=256)
  (
   // system inputs
   input 			clk, // clock
   input 			rst, // reset
   // Total number of clock cycles required

   // mosi
   input [7:0] 			nb_mosi, // number of bits to shift out
   input 			y0_mosi, // idle level
   input [31:0] 		n0_mosi, // delay from outputing the first bit
   input [31:0] 		n1_mosi, // first half cycle length
   // miso
   input [7:0] 			nb_miso, // number of bits to shift in
   input [31:0] 		n0_miso, // delay from first bit
   input [31:0] 		n1_miso, // first half cycle length
   // sclk
   input [7:0] 			nb_sclk, // number of clock cycles
   input 			y0_sclk, // idle level
   input [31:0] 		n0_sclk, // delay from first bit
   input [31:0] 		n1_sclk, // first half cycle length
   input [31:0] 		n2_sclk, // second half cycle length
   // Write data
   input 			wr_req, // write request
   input [P_WR_DATA_WIDTH-1:0] 	wr_data, // write data
   // Read data
   input 			rd_req, // read request
   output [P_RD_DATA_WIDTH-1:0] rd_data, // read data
   output reg 			ack=0, // acknowledge 
   // SPI outputs
   output 			mosi, // master out, slave in
   output 			sclk, // master in, slave out
   input 			miso // master in, slave out
   );

   ///////////////////////////////////////////////////////////////////////////////
   // Internals

   // These manage the counter
   reg 		 is_rd=0;
   reg 		 is_wr=0;
  
   // This manages determining the max count.
   reg [31:0] 	 max_cnt;
   wire 	 valid_max_cnt; 
   wire [31:0] 	 max_cnt_mosi;
   wire [31:0] 	 max_cnt_sclk;
   wire [31:0] 	 max_cnt_miso;   
   wire valid_max_cnt_mosi;
   wire valid_max_cnt_sclk;
   wire valid_max_cnt_miso;

   // Counter
   reg [31:0] 	 cnt=0; // main counter 

   // This handles the max count
   assign valid_max_cnt = valid_max_cnt_mosi && valid_max_cnt_miso && valid_max_cnt_sclk; 
   always @(*)
     if( (max_cnt_mosi >= max_cnt_sclk) && (max_cnt_mosi >= max_cnt_miso) )
       max_cnt = max_cnt_mosi;
     else if( (max_cnt_sclk >= max_cnt_mosi) && (max_cnt_sclk >= max_cnt_miso) )
       max_cnt = max_cnt_sclk;
     else if( (max_cnt_miso >= max_cnt_sclk) && (max_cnt_miso >= max_cnt_mosi) )
       max_cnt = max_cnt_miso;
     else
       max_cnt = 32'hffffffff; 
   
   // these iteratively calculate max count, so as to allow arbitrary bit lengths. 
   iter_integer_linear_calc IILC_MOSI_0
     (
      .clk(clk),
      .rst(rst),
      .wr(wr_req || rd_req),
      .m(n1_mosi),
      .x({24'b0,nb_mosi}),
      .b(n0_mosi),
      .y(max_cnt_mosi),
      .valid(valid_max_cnt_mosi)
      );
   iter_integer_linear_calc IILC_MISO_0
     (
      .clk(clk),
      .rst(rst),
      .wr(wr_req || rd_req),
      .m(n1_miso),
      .x({24'b0,nb_miso}),
      .b(n0_miso),
      .y(max_cnt_miso),
      .valid(valid_max_cnt_miso)
      );
   iter_integer_linear_calc IILC_SCLK_0
     (
      .clk(clk),
      .rst(rst),
      .wr(wr_req || rd_req),
      .m(n1_sclk + n2_sclk),
      .x({24'b0,nb_sclk}),
      .b(n0_sclk),
      .y(max_cnt_sclk),
      .valid(valid_max_cnt_sclk)
      );

   
   // The serial PHY   
   serial_ck SERIAL_CK_0(
			 // Outputs
			 .y			(sclk),
			 // Inputs
			 .clk			(clk),
			 .rst			(rst),
			 .y0			(y0_sclk),
			 .ncyc			(nb_sclk),
			 .n0			(n0_sclk),
			 .n1			(n1_sclk),
			 .n2			(n2_sclk),
			 .cnt			((is_wr || is_rd) ? cnt : 0)); 
   
   serial_rx #(.P_DATA_WIDTH(P_RD_DATA_WIDTH)) SERIAL_RX_0
     (
      // Outputs
      .data			(rd_data),
      // Inputs
      .clk			(clk),
      .rst			(rst),
      .a			(miso),
      .nbits			(nb_miso),
      .n0			(n0_miso),
      .n1			(n1_mosi),
      .cnt			(is_rd ? cnt : 0));

   serial_tx #(.P_DATA_WIDTH(P_WR_DATA_WIDTH)) SERIAL_TX_0
     (
      // Outputs
      .y			(mosi),
      // Inputs
      .clk			(clk),
      .rst			(rst),
      .y0			(y0_mosi),
      .data			(wr_data),
      .nbits			(nb_mosi),
      .n0			(n0_mosi),
      .n1			(n1_mosi),
      .cnt			(is_wr ? cnt : 0));
   
   ///////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   reg [1:0] fsm=0;
   localparam
     S_IDLE = 0,
     S_VALID_MAX_CNT_CHECK = 1, 
     S_COUNT = 2, 
     S_ACK = 3;
   

`ifdef MODEL_TECH // This works well for modelsim
   reg [127:0] state_str;
   always @(*)
     case(fsm)
       S_IDLE:                state_str = "S_IDLE";
       S_VALID_MAX_CNT_CHECK: state_str = "S_VALID_MAX_CNT_CHECK";
       S_COUNT:               state_str = "S_COUNT";
       S_ACK:                 state_str = "S_ACK";
       default:               state_str = "*** UNKNOWN ***"; 
     endcase // case (fsm)
`endif

   

   ///////////////////////////////////////////////////////////////////////////////
   // FSM Flow
   // Main counter
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  cnt <= 0;
	  ack <= 0;
	  is_wr <= 0;
	  is_rd <= 0;
	  fsm <= 0; 
       end
     else
       begin
	  case(fsm)
	    S_IDLE:
	      begin
		 is_wr <= 0;
		 is_rd <= 0;
		 cnt <= 0;
		 ack <= 0;
		 if(wr_req || rd_req)
		   begin
		      if(wr_req) is_wr <= 1;
		      if(rd_req) is_rd <= 1;
		      fsm <= S_VALID_MAX_CNT_CHECK; 
		   end
	      end

	    S_VALID_MAX_CNT_CHECK:
	      begin
		 if(valid_max_cnt)
		   fsm <= S_COUNT; 
	      end

	    S_COUNT:
	      begin
		 cnt <= cnt + 1;
		 if(cnt == max_cnt)
		   fsm <= S_ACK; 
	      end

	    S_ACK:
	      begin
		 ack <= 1;
		 if(wr_req == 0 && rd_req == 0)
		   begin
		      is_wr <= 0;
		      is_rd <= 0;
		      cnt <= 0;
		      ack <= 0;
		      fsm <= S_IDLE;
		   end
	      end

	    default: fsm <= S_IDLE;
	  endcase // case (fsm)
       end
          
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("../serial_ck/" "../serial_tx/" "../serial_rx/" "../iter_integer_linear_calc/")
// End:
