////////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Fri Feb  8 09:51:07 EST 2019
//
// Gated integrator with delay RAM included. 
////////////////////////////////////////////////////////////////////////////////////////////////////

module gated_integrator 
  #(
    parameter P_NBITS_DATA_IN=16, 
    parameter P_NBITS_DATA_OUT=24,
    parameter P_NBITS_DELAY_A_ADDR = 9, 
    parameter P_NBITS_DELAY_B_ADDR = 14
    ) (
       input 				 clk, 
       input 				 wr, 
       input 				 init_wr,
       input [P_NBITS_DATA_OUT-1:0] 	 init_y, 
       input [P_NBITS_DELAY_A_ADDR-1:0]  delay_len, 
       input [P_NBITS_DELAY_B_ADDR-1:0]  delay_b_len,
       input [P_NBITS_DATA_IN-1:0] 	 a,
       output reg [P_NBITS_DATA_OUT-1:0] y=0
       );

   ////////////////////////////////////////////////////////////////////////////////
   // FSM for initialization and address management
   localparam
     S_RUN = 0,
     S_INIT = 1;
   reg [0:0] 				 fsm = S_RUN; 
   reg [0:0] 				 init_addr_start = 0; 
   always @(posedge clk)
     case(fsm)
       S_RUN:  begin if(init_wr) fsm <= S_INIT; end
       S_INIT: ; 
     endcase
   
   ////////////////////////////////////////////////////////////////////////////////
   // Delay A Buffer

   // Address management 
   reg [P_NBITS_DELAY_A_ADDR-1:0] 	 delay_a_addr_in   = 0;
   reg [P_NBITS_DELAY_A_ADDR-1:0] 	 delay_a_addr_out  = 2;    
   always @(posedge clk)
     begin
	if(wr)
	  begin
	     // Sample addressing
	     delay_a_addr_in  <= delay_a_addr_in  + 1;
	     delay_a_addr_out <= delay_a_addr_out + 1;
	     if(delay_a_addr_in == delay_a_len-1)
	       begin
		  delay_a_addr_in  <= 0;
		  delay_a_addr_out <= 2;
	       end
	     if(delay_a_addr_out == delay_a_len-1)
	       delay_a_addr_out <= 0; 	     
	  end 
     end // always @ (posedge clk)

   // RAM
   wire [P_NBITS_DATA_IN-1:0] i_a_0;
   wire [P_NBITS_DATA_OUT-1:0] i_y_0; 
   ram_dual #(.P_NBITS_ADR(P_NBITS_DELAY_A_ADDR),.P_NBITS_DATA(P_NBITS_DATA_IN)) DELAY_A_0 
   (
    .clk1(clk),
    .clk2(clk), 
    .d(init_busy ? init_data_in : a_0),		  
    .q(i_a_0),
    .addr_in(delay_a_addr_in),
    .addr_out(delay_a_addr_out),
    .we(wr)
    );

   
   
   ////////////////////////////////////////////////////////////////////////////////
   // Accumulator
   always @(posedge clk)
     if(init_wr)
       y <= init_y;
     else if(wr)
       y <= y + a - b; 
      
endmodule
