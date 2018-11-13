//////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Mon Mar 30 09:28:56 EDT 2015
// config_ind.v
//
// "config_ind" 
// "FPGA Configuration indicator"  
//  A custom Verilog HDL module. 
//   
//  Output that cycles ~1Hz (e.g., for LED indicator). 
//
//////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ns

module config_ind #(parameter P_CLK_FREQ_HZ = 100000000)
   (
    input      clk, // system clk
    input      rst_n, // system reset, active low
    output reg blink_configed // blinks once per second to show FPGA is configured
    );

   // Figure out how long 0.5 seconds is
   localparam N_CYC_HALF_SEC = 5 * P_CLK_FREQ_HZ / 10;
   // localparam N_CYC_HALF_SEC = 5 * P_CLK_FREQ_HZ / 100000;
      
   // ceiling(log2()), used to figure out counter size.   
   function integer clogb2;
      input integer value;
      for(clogb2=0;value>0;clogb2=clogb2+1)
	value = value >> 1;
   endfunction // for

   localparam NBITS = clogb2(N_CYC_HALF_SEC-1);    
   
   // Counter keeps track of where we are
   reg [NBITS-1:0] count;	    
   always @(posedge clk or negedge rst_n)
     if(!rst_n)                          count <= {NBITS{1'b0}};
     else if (count == N_CYC_HALF_SEC-1) count <= {NBITS{1'b0}};
     else                                count <= count + 1'b1;
   
   // Latch enable
   always @(posedge clk or negedge rst_n)
     if(!rst_n) blink_configed <= 1'b0;
     else if( count == N_CYC_HALF_SEC-1 ) blink_configed <= !blink_configed;
      		
endmodule
