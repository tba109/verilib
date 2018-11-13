//////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Feb 13 16:11:03 EST 2014
// An N (a least two) flip-flop synchronizer
//////////////////////////////////////////////////////////////////////////////////////
module sync
  (
   ////////// inputs //////////
   input      clk, // clock
   input      rst_n, // active low reset
   input      a, // input to be synchronized
   
   ////////// outputs //////////
   output y
   ); 
   
   parameter P_DEFVAL = 1'b0;
   parameter P_NFF = 2;
   localparam NFF = (P_NFF > 1) ? P_NFF : 2; 

   // TBA Fri May 23 13:25:04 EDT 2014
   // A generic synchronizer modelled after altera/13.1/ip/altera/primitives/altera_std_synchronizer/altera_std_synchronizer.v
   (* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*sync:*|ff[0]}]\" "} *) reg [NFF-1:0]  ff;
   
   always @(posedge clk or negedge rst_n)
     begin
	if( !rst_n ) ff <= {NFF{P_DEFVAL}};
	else ff <= {ff[NFF-2:0],a};
     end

   assign y = ff[NFF-1];

endmodule // sync

