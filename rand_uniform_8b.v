///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue Aug 14 13:43:11 EDT 2018
//
// ru8.v
//
// 8-bit pseudo random number generator
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module random_uniform_8b
  (
   input 	clk,
   output [7:0] ru
   );

   lfsr_23_4_22 #(.P_INIT_SEED(23'd6975996)) L0(.clk(clk),.seed(0),.seed_wr(0),.y(ru[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5401410)) L1(.clk(clk),.seed(0),.seed_wr(0),.y(ru[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd962030))  L2(.clk(clk),.seed(0),.seed_wr(0),.y(ru[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd6313337)) L3(.clk(clk),.seed(0),.seed_wr(0),.y(ru[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd245880))  L4(.clk(clk),.seed(0),.seed_wr(0),.y(ru[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1915060)) L5(.clk(clk),.seed(0),.seed_wr(0),.y(ru[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd4042894)) L6(.clk(clk),.seed(0),.seed_wr(0),.y(ru[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd820197))  L7(.clk(clk),.seed(0),.seed_wr(0),.y(ru[7]));    
      
endmodule
