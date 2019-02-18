module ram_dual #(parameter P_NBITS_ADDR=8, parameter P_NBITS_DATA=14) 
   (
    output reg [P_NBITS_DATA-1:0] q,
    input [P_NBITS_DATA-1:0] 	  d,
    input [P_NBITS_ADDR-1:0] 	  addr_in,
    input [P_NBITS_ADDR-1:0] 	  addr_out,
    input 			  we, 
    input 			  clk1, 
    input 			  clk2
    );

  localparam L_MEM_SIZE = {P_NBITS_ADDR{1'b1}}; 
  reg [P_NBITS_DATA-1:0]   mem [L_MEM_SIZE:0];
   
   always @(posedge clk1) 
     begin
	if (we)
	  mem[addr_in] <= d;
     end
   
   reg [P_NBITS_ADDR-1:0] 	  addr_out_reg=0;
   always @(posedge clk2) 
     begin
	q <= mem[addr_out_reg];
	addr_out_reg <= addr_out;
     end

`ifdef MODEL_TECH
   integer i; 
   initial 
     begin
	// $display("%d\n",L_MEM_SIZE); 
	for(i=0; i<=L_MEM_SIZE; i=i+1)
	  mem[i] = 0;
     end
`endif
   
endmodule
