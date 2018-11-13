///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue Aug 14 15:55:16 EDT 2018
//
// gaus_rand.v
//
// 12-bit pseudo random normal based on the central limit theorm.
// This is whipped up quickly, and very specific to the Arcus site visit. Sum of 8 trials. 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module gaus_rand
  (
   input clk,
   output reg [11:0] gr
   );

   localparam [11:0] offset = 12'h100;

   wire [7:0] 	 ru0;
   lfsr_23_4_22 #(.P_INIT_SEED(23'd6975996)) L0_0(.clk(clk),.seed(0),.seed_wr(0),.y(ru0[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5401410)) L0_1(.clk(clk),.seed(0),.seed_wr(0),.y(ru0[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd962030))  L0_2(.clk(clk),.seed(0),.seed_wr(0),.y(ru0[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd6313337)) L0_3(.clk(clk),.seed(0),.seed_wr(0),.y(ru0[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd245880))  L0_4(.clk(clk),.seed(0),.seed_wr(0),.y(ru0[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1915060)) L0_5(.clk(clk),.seed(0),.seed_wr(0),.y(ru0[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd4042894)) L0_6(.clk(clk),.seed(0),.seed_wr(0),.y(ru0[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd820197))  L0_7(.clk(clk),.seed(0),.seed_wr(0),.y(ru0[7]));
   
   wire [7:0] 	 ru1;
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5938436)) L1_0(.clk(clk),.seed(0),.seed_wr(0),.y(ru1[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd7490601)) L1_1(.clk(clk),.seed(0),.seed_wr(0),.y(ru1[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5826180)) L1_2(.clk(clk),.seed(0),.seed_wr(0),.y(ru1[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5542119)) L1_3(.clk(clk),.seed(0),.seed_wr(0),.y(ru1[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd7382964)) L1_4(.clk(clk),.seed(0),.seed_wr(0),.y(ru1[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd6235367)) L1_5(.clk(clk),.seed(0),.seed_wr(0),.y(ru1[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd155732))  L1_6(.clk(clk),.seed(0),.seed_wr(0),.y(ru1[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd7569016)) L1_7(.clk(clk),.seed(0),.seed_wr(0),.y(ru1[7]));   

   wire [7:0] 	 ru2;
   lfsr_23_4_22 #(.P_INIT_SEED(23'd7207765)) L2_0(.clk(clk),.seed(0),.seed_wr(0),.y(ru2[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd483325))  L2_1(.clk(clk),.seed(0),.seed_wr(0),.y(ru2[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd211036))  L2_2(.clk(clk),.seed(0),.seed_wr(0),.y(ru2[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5351540)) L2_3(.clk(clk),.seed(0),.seed_wr(0),.y(ru2[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd3294981)) L2_4(.clk(clk),.seed(0),.seed_wr(0),.y(ru2[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd2902965)) L2_5(.clk(clk),.seed(0),.seed_wr(0),.y(ru2[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1370152)) L2_6(.clk(clk),.seed(0),.seed_wr(0),.y(ru2[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd4467337)) L2_7(.clk(clk),.seed(0),.seed_wr(0),.y(ru2[7]));   
   
   wire [7:0] 		 ru3;
   lfsr_23_4_22 #(.P_INIT_SEED(23'd2064798)) L3_0(.clk(clk),.seed(0),.seed_wr(0),.y(ru3[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd6070827)) L3_1(.clk(clk),.seed(0),.seed_wr(0),.y(ru3[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd3026036)) L3_2(.clk(clk),.seed(0),.seed_wr(0),.y(ru3[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd2954128)) L3_3(.clk(clk),.seed(0),.seed_wr(0),.y(ru3[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd4564439)) L3_4(.clk(clk),.seed(0),.seed_wr(0),.y(ru3[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd2975558)) L3_5(.clk(clk),.seed(0),.seed_wr(0),.y(ru3[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd4436648)) L3_6(.clk(clk),.seed(0),.seed_wr(0),.y(ru3[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd2423554)) L3_7(.clk(clk),.seed(0),.seed_wr(0),.y(ru3[7]));   

   wire [7:0] 	 ru4;
   lfsr_23_4_22 #(.P_INIT_SEED(23'd571526))  L4_0(.clk(clk),.seed(0),.seed_wr(0),.y(ru4[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd7255980)) L4_1(.clk(clk),.seed(0),.seed_wr(0),.y(ru4[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd3018028)) L4_2(.clk(clk),.seed(0),.seed_wr(0),.y(ru4[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1650858)) L4_3(.clk(clk),.seed(0),.seed_wr(0),.y(ru4[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd843737))  L4_4(.clk(clk),.seed(0),.seed_wr(0),.y(ru4[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd6449354)) L4_5(.clk(clk),.seed(0),.seed_wr(0),.y(ru4[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd7084006)) L4_6(.clk(clk),.seed(0),.seed_wr(0),.y(ru4[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1659741)) L4_7(.clk(clk),.seed(0),.seed_wr(0),.y(ru4[7]));   

   wire [7:0] 	 ru5;
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1988028)) L5_0(.clk(clk),.seed(0),.seed_wr(0),.y(ru5[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd3414946)) L5_1(.clk(clk),.seed(0),.seed_wr(0),.y(ru5[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd222522))  L5_2(.clk(clk),.seed(0),.seed_wr(0),.y(ru5[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd4931442)) L5_3(.clk(clk),.seed(0),.seed_wr(0),.y(ru5[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5640845)) L5_4(.clk(clk),.seed(0),.seed_wr(0),.y(ru5[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5838279)) L5_5(.clk(clk),.seed(0),.seed_wr(0),.y(ru5[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd3992450)) L5_6(.clk(clk),.seed(0),.seed_wr(0),.y(ru5[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5255730)) L5_7(.clk(clk),.seed(0),.seed_wr(0),.y(ru5[7]));   

   wire [7:0] 	 ru6;
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1066530)) L6_0(.clk(clk),.seed(0),.seed_wr(0),.y(ru6[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd3705559)) L6_1(.clk(clk),.seed(0),.seed_wr(0),.y(ru6[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd6728343)) L6_2(.clk(clk),.seed(0),.seed_wr(0),.y(ru6[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1690695)) L6_3(.clk(clk),.seed(0),.seed_wr(0),.y(ru6[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd5979418)) L6_4(.clk(clk),.seed(0),.seed_wr(0),.y(ru6[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd950531))  L6_5(.clk(clk),.seed(0),.seed_wr(0),.y(ru6[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd7910548)) L6_6(.clk(clk),.seed(0),.seed_wr(0),.y(ru6[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1897830)) L6_7(.clk(clk),.seed(0),.seed_wr(0),.y(ru6[7]));   

   wire [7:0] 	 ru7;
   lfsr_23_4_22 #(.P_INIT_SEED(23'd2841687)) L7_0(.clk(clk),.seed(0),.seed_wr(0),.y(ru7[0]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd6291374)) L7_1(.clk(clk),.seed(0),.seed_wr(0),.y(ru7[1]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd1119700)) L7_2(.clk(clk),.seed(0),.seed_wr(0),.y(ru7[2]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd4057851)) L7_3(.clk(clk),.seed(0),.seed_wr(0),.y(ru7[3]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd4511963)) L7_4(.clk(clk),.seed(0),.seed_wr(0),.y(ru7[4]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd630510))  L7_5(.clk(clk),.seed(0),.seed_wr(0),.y(ru7[5]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd8181048)) L7_6(.clk(clk),.seed(0),.seed_wr(0),.y(ru7[6]));
   lfsr_23_4_22 #(.P_INIT_SEED(23'd3342179)) L7_7(.clk(clk),.seed(0),.seed_wr(0),.y(ru7[7]));   

   reg [2:0] 	 cnta = 0;
   reg [2:0] 	 cntb = 0;  		 
   reg [11:0] 	 sum0 = 0;
   reg [11:0] 	 sum1 = 0;
   reg [11:0] 	 sum2 = 0;
   reg [11:0] 	 sum3 = 0;
   reg [11:0] 	 sum4 = 0;
   reg [11:0] 	 sum5 = 0;
   reg [11:0] 	 sum6 = 0;
   reg [11:0] 	 sum7 = 0; 
   
   always @(posedge clk)
     case(cnta)
       0: gr <= ((sum0 + ru0 + 12'd4) >> 3) + offset;
       1: gr <= ((sum1 + ru1 + 12'd4) >> 3) + offset;
       2: gr <= ((sum2 + ru2 + 12'd4) >> 3) + offset; 
       3: gr <= ((sum3 + ru3 + 12'd4) >> 3) + offset; 
       4: gr <= ((sum4 + ru4 + 12'd4) >> 3) + offset; 
       5: gr <= ((sum5 + ru5 + 12'd4) >> 3) + offset; 
       6: gr <= ((sum6 + ru6 + 12'd4) >> 3) + offset; 
       7: gr <= ((sum7 + ru7 + 12'd4) >> 3) + offset;  
     endcase
   
   always @(posedge clk)
     begin
	sum0 <= sum0 + ru0;
	sum1 <= sum1 + ru1;
	sum2 <= sum2 + ru2;
	sum3 <= sum3 + ru3;
	sum4 <= sum4 + ru4;
	sum5 <= sum5 + ru5;
	sum6 <= sum6 + ru6;
	sum7 <= sum7 + ru7;
	cnta <= cnta + 1;
	cntb <= cnta; 
	case(cntb)
	  0: begin sum0 <= 0; end
	  1: begin sum1 <= 0; end
	  2: begin sum2 <= 0; end
	  3: begin sum3 <= 0; end
	  4: begin sum4 <= 0; end
	  5: begin sum5 <= 0; end
	  6: begin sum6 <= 0; end
	  7: begin sum7 <= 0; end
	endcase // case (cnt)
     end
	  
endmodule
