//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed Feb 27 14:38:00 EST 2019
//
// spi_master.v
//
// Generic SPI master. Signaling in/out is determined by events at number of cycles, rather
// than CPOL CPHA. Shifts out MSB first, so need to reflect the data word if you need LSB first.
//////////////////////////////////////////////////////////////////////////////////////////////////

module spi_master
  (
   // system inputs
   input 	     clk, // clock
   input 	     rst, // reset
   // Total number of clock cycles required
   input [31:0]      cnt_max,
   // mosi
   input [31:0]      nb_max_mosi, // number of bits to shift out
   input 	     y0_mosi, // idle level
   input [31:0]      n0_mosi, // delay from outputing the first bit
   input [31:0]      n1_mosi, // first half cycle length
   input [31:0]      n2_mosi, // second half cycle length
   input [31:0]      n3_mosi, // delay on last bit
   // miso
   input [31:0]      nb_max_miso, // number of bits to shift in
   input 	     y0_miso, // idle level
   input [31:0]      n0_miso, // delay from first bit
   input [31:0]      n1_miso, // first half cycle length
   input [31:0]      n2_miso, // second half cycle length
   input [31:0]      n3_miso, // delay on last bit before returning to idle
   // sclk
   input [31:0]      nb_max_sclk, // number of clock cycles
   input 	     y0_sclk, // idle level
   input [31:0]      n0_sclk, // delay from first bit
   input [31:0]      n1_sclk, // first half cycle length
   input [31:0]      n2_sclk, // second half cycle length
   input [31:0]      n3_sclk, // delay on last bit before returning to idle   
   // Write data
   input 	     wr_req, // write request
   input [31:0]      wr_data, // write data
   input [31:0]      wr_n, // number of bits for read/write
   // Read data
   input 	     rd_req, // read request
   output reg [31:0] rd_data=0, // read data
   input [31:0]      rd_n, // number of read bits   
   output reg 	     ack <= 0; // acknowledge 
   // SPI outputs
   output reg 	     mosi=0, // master out, slave in
   output reg 	     sclk=0, // master in, slave out
   input 	     miso // master in, slave out
   );

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Internals
   reg [31:0] 	     cnt=0; // main counter
   reg [31:0] 	     sr_miso=0;
   reg [31:0] 	     sr_mosi=0; 
   reg [31:0] 	     nb_mosi=0;
   reg [31:0] 	     nb_miso=0;
   reg [31:0] 	     nb_sclk=0; 
   reg [31:0] 	     cnt_next_miso=0;
   reg [31:0] 	     cnt_next_mosi=0;
   reg [31:0] 	     cnt_next_clk=0; 
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   localparam 
     S0=0,
     S1=1,
     S2=2, 
     S3=3;
   reg [1:0] 	     state_mosi=S0;
   reg [1:0] 	     state_miso=S0;
   reg [1:0] 	     state_sclk=S0; 
      
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Output assignments
   
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // FSM Flow
   // Main counter
   always @(posedge clk)
     begin
	ack <= 0; 
	if(cnt == 0 && (wr_req || rd_req))
	  begin 
	     cnt <= cnt + 1;
	     sr_mosi <= wr_data;
	  end
	else if(cnt == cnt_max)
	  begin
	     ack <= 1;
	     cnt <= 0;
	  end
	else
	  cnt <= cnt + 1;
     end

   always @(posedge clk)
     case(state_mosi)
       S0: 
	 begin
	    mosi <= y0_mosi;
	    nb_mosi <= 0; 
	    cnt_next_mosi <= 0; 
	    if(cnt==n0_mosi-1)
	      begin
		 state_mosi <= S1;
		 cnt_next_mosi <= n0_mosi+n1_mosi;
	      end
	 end
       S1: 
	begin 
	    if(cnt==cnt_next_mosi-1)
	      begin
		 state_mosi <= 
	      end
	 end
       S2: 
	 begin 
	    ; 
	 end
       S3: 
	 begin 
	    ; 
	 end
       default: 
	 state_mosi <= S0; 
     endcase 
   
       
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End:
