//////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue Apr 26 21:24:32 EDT 2022
// https://en.wikipedia.org/wiki/8b/10b_encoding
//
// Map displarity and running disparity onto unsigned regs n_ones and rd. 
//////////////////////////////////////////////////////////////////////////

module encode_8b10b
  (
   input 	clk,
   input 	rst,  // resets the running disparity
   input 	k_en, // interpret as control symbol 
   input [7:0] 	data_in, // HGF EDCBA
   output reg [9:0] data_out = 0, // abcdei fghj
   output reg 	rd = 1'b0, // running disparity, 0 means -1, 1 means +1
   output reg valid = 1'b0 // 
   );

   wire [4:0] 	x5b = data_in[4:0];
   wire [2:0] 	x3b = data_in[7:5]; 
   		
   // 5b/6b table, running disparity = -1   
   reg [5:0] 	x6b_n1;
   reg [3:0] 	n_ones_x6b_n1;  
   always @(*)
     case(x5b)
       5'b00000: begin x6b_n1 =  6'b100111; n_ones_x6b_n1 = 4; end //D.00 
       5'b00001: begin x6b_n1 =  6'b011101; n_ones_x6b_n1 = 4; end //D.01
       5'b00010: begin x6b_n1 =  6'b101101; n_ones_x6b_n1 = 4; end //D.02
       5'b00011: begin x6b_n1 =  6'b110001; n_ones_x6b_n1 = 3; end //D.03
       5'b00100: begin x6b_n1 =  6'b110101; n_ones_x6b_n1 = 4; end //D.04
       5'b00101: begin x6b_n1 =  6'b101001; n_ones_x6b_n1 = 3; end //D.05
       5'b00110: begin x6b_n1 =  6'b011001; n_ones_x6b_n1 = 3; end //D.06
       5'b00111: begin x6b_n1 =  6'b111000; n_ones_x6b_n1 = 3; end //D.07
       5'b01000: begin x6b_n1 =  6'b111001; n_ones_x6b_n1 = 4; end //D.08
       5'b01001: begin x6b_n1 =  6'b100101; n_ones_x6b_n1 = 3; end //D.09
       5'b01010: begin x6b_n1 =  6'b010101; n_ones_x6b_n1 = 3; end //D.10
       5'b01011: begin x6b_n1 =  6'b110100; n_ones_x6b_n1 = 3; end //D.11
       5'b01100: begin x6b_n1 =  6'b001101; n_ones_x6b_n1 = 3; end //D.12
       5'b01101: begin x6b_n1 =  6'b101100; n_ones_x6b_n1 = 3; end //D.13
       5'b01110: begin x6b_n1 =  6'b011100; n_ones_x6b_n1 = 3; end //D.14
       5'b01111: begin x6b_n1 =  6'b010111; n_ones_x6b_n1 = 4; end //D.15
       5'b10000: begin x6b_n1 =  6'b011011; n_ones_x6b_n1 = 4; end //D.16
       5'b10001: begin x6b_n1 =  6'b100011; n_ones_x6b_n1 = 3; end //D.17
       5'b10010: begin x6b_n1 =  6'b010011; n_ones_x6b_n1 = 3; end //D.18
       5'b10011: begin x6b_n1 =  6'b110010; n_ones_x6b_n1 = 3; end //D.19
       5'b10100: begin x6b_n1 =  6'b001011; n_ones_x6b_n1 = 3; end //D.20
       5'b10101: begin x6b_n1 =  6'b101010; n_ones_x6b_n1 = 3; end //D.21
       5'b10110: begin x6b_n1 =  6'b011010; n_ones_x6b_n1 = 3; end //D.22
       5'b10111: begin x6b_n1 =  6'b111010; n_ones_x6b_n1 = 4; end //D.23
       5'b11000: begin x6b_n1 =  6'b110011; n_ones_x6b_n1 = 4; end //D.24
       5'b11001: begin x6b_n1 =  6'b100110; n_ones_x6b_n1 = 3; end //D.25
       5'b11010: begin x6b_n1 =  6'b010110; n_ones_x6b_n1 = 3; end //D.26
       5'b11011: begin x6b_n1 =  6'b110110; n_ones_x6b_n1 = 4; end //D.27
       5'b11100: begin x6b_n1 =  6'b001110; n_ones_x6b_n1 = 3; end //D.28
       5'b11101: begin x6b_n1 =  6'b101110; n_ones_x6b_n1 = 4; end //D.29
       5'b11110: begin x6b_n1 =  6'b011110; n_ones_x6b_n1 = 4; end //D.30
       5'b11111: begin x6b_n1 =  6'b101011; n_ones_x6b_n1 = 4; end //D.31
       default:  begin x6b_n1 =  6'b000000; n_ones_x6b_n1 = 0; end 
     endcase // case (x5b)


      // 5b/6b table, running disparity = +1   
   reg [5:0] 	x6b_p1;
   reg [3:0] 	n_ones_x6b_p1; 
   always @(*)
     case(x5b)
       5'b00000: begin x6b_p1 =  6'b011000; n_ones_x6b_p1 = 2; end // D.00 
       5'b00001: begin x6b_p1 =  6'b100010; n_ones_x6b_p1 = 2; end // D.01
       5'b00010: begin x6b_p1 =  6'b010010; n_ones_x6b_p1 = 2; end // D.02
       5'b00011: begin x6b_p1 =  6'b110001; n_ones_x6b_p1 = 3; end // D.03
       5'b00100: begin x6b_p1 =  6'b001010; n_ones_x6b_p1 = 2; end // D.04
       5'b00101: begin x6b_p1 =  6'b101001; n_ones_x6b_p1 = 3; end // D.05
       5'b00110: begin x6b_p1 =  6'b011001; n_ones_x6b_p1 = 3; end // D.06
       5'b00111: begin x6b_p1 =  6'b000111; n_ones_x6b_p1 = 3; end // D.07
       5'b01000: begin x6b_p1 =  6'b000110; n_ones_x6b_p1 = 2; end // D.08
       5'b01001: begin x6b_p1 =  6'b100101; n_ones_x6b_p1 = 3; end // D.09
       5'b01010: begin x6b_p1 =  6'b010101; n_ones_x6b_p1 = 3; end // D.10
       5'b01011: begin x6b_p1 =  6'b110100; n_ones_x6b_p1 = 3; end // D.11
       5'b01100: begin x6b_p1 =  6'b001101; n_ones_x6b_p1 = 3; end // D.12
       5'b01101: begin x6b_p1 =  6'b101100; n_ones_x6b_p1 = 3; end // D.13
       5'b01110: begin x6b_p1 =  6'b011100; n_ones_x6b_p1 = 3; end // D.14
       5'b01111: begin x6b_p1 =  6'b101000; n_ones_x6b_p1 = 2; end // D.15
       5'b10000: begin x6b_p1 =  6'b100100; n_ones_x6b_p1 = 2; end // D.16
       5'b10001: begin x6b_p1 =  6'b100011; n_ones_x6b_p1 = 3; end // D.17
       5'b10010: begin x6b_p1 =  6'b010011; n_ones_x6b_p1 = 3; end // D.18
       5'b10011: begin x6b_p1 =  6'b110010; n_ones_x6b_p1 = 3; end // D.19
       5'b10100: begin x6b_p1 =  6'b001011; n_ones_x6b_p1 = 3; end // D.20
       5'b10101: begin x6b_p1 =  6'b101010; n_ones_x6b_p1 = 3; end // D.21
       5'b10110: begin x6b_p1 =  6'b011010; n_ones_x6b_p1 = 3; end // D.22
       5'b10111: begin x6b_p1 =  6'b000101; n_ones_x6b_p1 = 2; end // D.23
       5'b11000: begin x6b_p1 =  6'b001100; n_ones_x6b_p1 = 2; end // D.24
       5'b11001: begin x6b_p1 =  6'b100110; n_ones_x6b_p1 = 3; end // D.25
       5'b11010: begin x6b_p1 =  6'b010110; n_ones_x6b_p1 = 3; end // D.26
       5'b11011: begin x6b_p1 =  6'b001001; n_ones_x6b_p1 = 2; end // D.27
       5'b11100: begin x6b_p1 =  6'b001110; n_ones_x6b_p1 = 3; end // D.28
       5'b11101: begin x6b_p1 =  6'b010001; n_ones_x6b_p1 = 2; end // D.29
       5'b11110: begin x6b_p1 =  6'b100001; n_ones_x6b_p1 = 2; end // D.30
       5'b11111: begin x6b_p1 =  6'b010100; n_ones_x6b_p1 = 2; end // D.31
       default:  begin x6b_p1 =  6'b000000; n_ones_x6b_p1 = 0; end 
     endcase // case (x5b)

   // 3b/4b table, running disparity = -1
   reg [3:0] 	x4b_n1;
   reg [3:0] 	n_ones_x4b_n1; 
   always @(*)
     case(x3b)
       3'b000: begin x4b_n1 = 4'b1011; n_ones_x4b_n1 = 3; end // D.x.0
       3'b001: begin x4b_n1 = 4'b1001; n_ones_x4b_n1 = 2; end // D.x.1
       3'b010: begin x4b_n1 = 4'b0101; n_ones_x4b_n1 = 2; end // D.x.2
       3'b011: begin x4b_n1 = 4'b1100; n_ones_x4b_n1 = 2; end // D.x.3
       3'b100: begin x4b_n1 = 4'b1101; n_ones_x4b_n1 = 3; end // D.x.4
       3'b101: begin x4b_n1 = 4'b1010; n_ones_x4b_n1 = 2; end // D.x.5
       3'b110: begin x4b_n1 = 4'b0110; n_ones_x4b_n1 = 2; end // D.x.6
       // Special rules to avoid runs of five consecutive 0's or 1's
       3'b111:
	 begin
	    if(x5b==5'd17 || x5b==5'd18 || x5b==5'd20)
	      begin 
		 x4b_n1 = 4'b0111; // D.x.A7
		 n_ones_x4b_n1 = 3;
	      end
	    else
	      begin 
		 x4b_n1 = 4'b1110; // D.x.P7
		 n_ones_x4b_n1 = 3;
	      end
	 end
       default: begin x4b_n1 = 4'b0000; n_ones_x4b_n1 = 0; end  
     endcase

   // 3b/4b table, running disparity = +1
   reg [3:0] 	x4b_p1;
   reg [3:0] 	n_ones_x4b_p1; 
   always @(*)
     case(x3b)
       3'b000: begin x4b_p1 = 4'b0100; n_ones_x4b_p1 = 1; end // D.x.0
       3'b001: begin x4b_p1 = 4'b1001; n_ones_x4b_p1 = 2; end // D.x.1
       3'b010: begin x4b_p1 = 4'b0101; n_ones_x4b_p1 = 2; end // D.x.2
       3'b011: begin x4b_p1 = 4'b0011; n_ones_x4b_p1 = 2; end // D.x.3
       3'b100: begin x4b_p1 = 4'b0010; n_ones_x4b_p1 = 1; end // D.x.4
       3'b101: begin x4b_p1 = 4'b1010; n_ones_x4b_p1 = 2; end // D.x.5
       3'b110: begin x4b_p1 = 4'b0110; n_ones_x4b_p1 = 2; end // D.x.6
       // Special rules to avoid runs of five consecutive 0's or 1's
       3'b111: 
	 begin 
	    if(x5b==5'd11 || x5b==5'd13 || x5b==5'd14)
	      begin 
		 x4b_p1 = 4'b1000; // D.x.A7
		 n_ones_x4b_p1 = 1;
	      end
	    else
	      begin
		 x4b_p1 = 4'b0001; // D.x.P7
		 n_ones_x4b_p1 = 1;
	      end
	 end
       default: begin x4b_p1 = 4'b0000; n_ones_x4b_p1 = 0; end 
     endcase

   // Control symbol table, running disparity = -1
   reg [9:0] 	k_sym_n1;
   reg 		k_err_n1;
   reg [3:0] 	n_ones_k_n1; 
   always @(*)
     case({x3b,x5b})
       8'b00011100: begin k_sym_n1 = 10'b0011110100; k_err_n1 = 1'b0; n_ones_k_n1 = 5; end // K.28.0
       8'b00111100: begin k_sym_n1 = 10'b0011111001; k_err_n1 = 1'b0; n_ones_k_n1 = 6; end // K.28.1
       8'b01011100: begin k_sym_n1 = 10'b0011110101; k_err_n1 = 1'b0; n_ones_k_n1 = 6; end // K.28.2
       8'b01111100: begin k_sym_n1 = 10'b0011110011; k_err_n1 = 1'b0; n_ones_k_n1 = 6; end // K.28.3
       8'b10011100: begin k_sym_n1 = 10'b0011110010; k_err_n1 = 1'b0; n_ones_k_n1 = 5; end // K.28.4
       8'b10111100: begin k_sym_n1 = 10'b0011111010; k_err_n1 = 1'b0; n_ones_k_n1 = 6; end // K.28.5
       8'b11011100: begin k_sym_n1 = 10'b0011110110; k_err_n1 = 1'b0; n_ones_k_n1 = 6; end // K.28.6
       8'b11111100: begin k_sym_n1 = 10'b0011111000; k_err_n1 = 1'b0; n_ones_k_n1 = 5; end // K.28.7
       8'b11110111: begin k_sym_n1 = 10'b1110101000; k_err_n1 = 1'b0; n_ones_k_n1 = 5; end // K.23.7
       8'b11111011: begin k_sym_n1 = 10'b1101101000; k_err_n1 = 1'b0; n_ones_k_n1 = 5; end // K.27.7
       8'b11111101: begin k_sym_n1 = 10'b1011101000; k_err_n1 = 1'b0; n_ones_k_n1 = 5; end // K.29.7
       8'b11111110: begin k_sym_n1 = 10'b0111101000; k_err_n1 = 1'b0; n_ones_k_n1 = 5; end // K.30.7
       default:     begin k_sym_n1 = 10'b0000000000; k_err_n1 = 1'b1; n_ones_k_n1 = 0; end
     endcase

   // Control symbol table, running disparity = +1
   reg [9:0] k_sym_p1;
   reg 	     k_err_p1;
   reg [3:0] n_ones_k_p1; 
   always @(*)
     case({x3b,x5b})
       8'b00011100: begin k_sym_p1 = 10'b1100001011; k_err_p1 = 1'b0; n_ones_k_p1 = 5; end // K.28.0                              
       8'b00111100: begin k_sym_p1 = 10'b1100000110; k_err_p1 = 1'b0; n_ones_k_p1 = 4; end // K.28.1                              
       8'b01011100: begin k_sym_p1 = 10'b1100001010; k_err_p1 = 1'b0; n_ones_k_p1 = 4; end // K.28.2                              
       8'b01111100: begin k_sym_p1 = 10'b1100001100; k_err_p1 = 1'b0; n_ones_k_p1 = 4; end // K.28.3                              
       8'b10011100: begin k_sym_p1 = 10'b1100001101; k_err_p1 = 1'b0; n_ones_k_p1 = 5; end // K.28.4                              
       8'b10111100: begin k_sym_p1 = 10'b1100000101; k_err_p1 = 1'b0; n_ones_k_p1 = 4; end // K.28.5                              
       8'b11011100: begin k_sym_p1 = 10'b1100001001; k_err_p1 = 1'b0; n_ones_k_p1 = 4; end // K.28.6                              
       8'b11111100: begin k_sym_p1 = 10'b1100000111; k_err_p1 = 1'b0; n_ones_k_p1 = 5; end // K.28.7                              
       8'b11110111: begin k_sym_p1 = 10'b0001010111; k_err_p1 = 1'b0; n_ones_k_p1 = 5; end // K.23.7                              
       8'b11111011: begin k_sym_p1 = 10'b0010010111; k_err_p1 = 1'b0; n_ones_k_p1 = 5; end // K.27.7                              
       8'b11111101: begin k_sym_p1 = 10'b0100010111; k_err_p1 = 1'b0; n_ones_k_p1 = 5; end // K.29.7                              
       8'b11111110: begin k_sym_p1 = 10'b1000010111; k_err_p1 = 1'b0; n_ones_k_p1 = 5; end // K.30.7                              
       default:     begin k_sym_p1 = 10'b0000000000; k_err_p1 = 1'b1; n_ones_k_p1 = 0; end                               
     endcase
      		         
   // Outputs
   // Map rd=1/0, n_ones to RD=+/-1, DISP=+/-2
   always @(posedge clk)
     if(rst)
       begin 
	  rd <= 1'b0; // running disparity starts at -1
	  data_out <= 0; //K28.5
	  valid <= 1'b0; 
       end
     else
       begin
	  if(k_en) // Control symbols
	    begin 
	       if(rd==1'b0)
		 begin
		    data_out <= k_sym_n1;
		    if(n_ones_k_n1==5 || n_ones_k_n1==6)
		      begin
			 valid <= 1'b1;
			 rd <= n_ones_k_n1==6; 
		      end
		    else
		      begin
			 data_out <= 0; 
			 rd <= 1'b0;
			 valid <= 1'b0;
		      end
		 end // if (rd==1'b0)
	       else if(rd==1'b1)
		 begin
		    data_out <= k_sym_p1;
		    if(n_ones_k_p1==4 || n_ones_k_p1==5)
		      begin
			 valid <= 1'b1;
			 rd <= n_ones_k_p1==4;
		      end
		    else
		      begin
			 data_out <= 0;
			 rd <= 1'b0;
			 valid <= 'b0;
		      end
		 end // if (rd==1'b1)
	    end // if (k_en)
	  else // Normal symbols
	    begin
	       if(rd==1'b0) // rd_6b==-1, must calc rd_3b, so calc finishes in 1 clock cycle
		 begin
		    data_out[9:4] <= x6b_n1;
		    if(n_ones_x6b_n1==3) // disp_6b=2*n_ones_6b-6=2*3-6=0, so rd_3b=rd_6b+disp_6b=-1+0=-1 
		      begin
			 data_out[3:0] <= x4b_n1;
			 rd <= n_ones_x4b_n1==3; // disp_3b=2*n_ones_3b-4=+2, rd_6b_next=rd_3b+disp_3b=-1+2=+1
			 valid <= 1'b1;
			 if(!(n_ones_x4b_n1==3 || n_ones_x4b_n1==2))
			   begin
			      data_out <= 0;
			      rd <= 1'b0;
			      valid <= 1'b0; 
			   end
		      end
		    else if(n_ones_x6b_n1==4) // disp_6b is 2*n_ones_6b-6=2*4-6=+2, so rd_3b=rd_6b+disp_6b=-1+2=+1
		      begin
			 data_out[3:0] <= x4b_p1;
			 rd <= n_ones_x4b_p1==2; // disp_3b=2*n_ones_3b-4=0, rd_6b_next=rd_3b+disp_3b=+1+0=+1
			 valid <= 1'b1;
			 if(!(n_ones_x4b_p1==2 || n_ones_x4b_p1==1))
			   begin
			      data_out <= 0;
			      rd <= 1'b0;
			      valid <= 1'b0; 
			   end
		      end 
		    else // Invalid code
		      begin
			 data_out <= 0;
			 rd <= 1'b0;
			 valid <= 'b0; 
		      end // else: !if(n_ones_x6b_n1==4)
		 end // if (rd==1'b0)
	       else if(rd==1'b1) // rd_6b==+1, must calc rd_3b, so calc finishes in 1 clock cycle
		 begin
		    data_out[9:4] <= x6b_p1;
		    if(n_ones_x6b_p1==3)// disp_6b=2*n_ones_6b-6=2*3-6=0, so rd_3b=rd_6b+disp_6b=+1+0=+1
		      begin
			 data_out[3:0] <= x4b_p1;
			 rd <= !(n_ones_x4b_p1==1);// disp_3b=2*n_ones_3b-4=-2, so rd_6b_next=rd_3b+disp_3b=+1+-2=-1
			 valid <= 1'b1;
			 if(!(n_ones_x4b_p1==1 || n_ones_x4b_p1==2))
			   begin
			      data_out <= 0;
			      rd <= 1'b0;
			      valid <= 'b0;
			   end
		      end
		    else if(n_ones_x6b_p1==2)// disp_6b=2*n_ones_6b-6=2*2-6=-2, so rd_3b=rd_6b+disp_6b=+1-2=-1
		      begin
			 data_out[3:0] <= x4b_n1; 
			 rd <= !(n_ones_x4b_n1==2);// disp_3b=2*n_ones_3b-4=2*2-4=0, so rb_6b_next=rd_3b+disp_3b=-1+0=-1
			 valid <= 1'b1;
			 if(!(n_ones_x4b_n1==3 || n_ones_x4b_n1==2))
			   begin
			      data_out <= 0;
			      rd <= 1'b0;
			      valid <= 'b0;
			   end
		      end // if (n_ones_x6b_p1==2)
		    else
		      begin
			 data_out <= 0;
			 rd <= 1'b0;
			 valid <= 1'b0; 
		      end // else: !if(n_ones_x6b_p1==2)
		    
		    
		 end   
	    end
       end	
   

   
endmodule
