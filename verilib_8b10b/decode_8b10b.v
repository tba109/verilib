//////////////////////////////////////////////////////////////////////////
// Tyler Anderson Wed Apr 27 13:15:32 EDT 2022
// https://en.wikipedia.org/wiki/8b/10b_encoding
//
//////////////////////////////////////////////////////////////////////////
module decode_8b10b
  (
   input 	    clk,
   input 	    rst,
   input [9:0] 	    data_in,
   output reg [7:0] data_out = 8'd0, 
   output reg 	    valid = 1'b0, // Was the word found in the list of valid words
   output reg 	    is_k = 1'b0 // This is a comma
   ); 

   wire [5:0] 	    x6b = data_in[9:4]; 
   wire [3:0] 	    x4b = data_in[3:0];
   reg [4:0] 	    x5b_n1; 
   reg 		    match_x5b_n1; 
   
   // RD = -1
   always @(*)
     case(x6b)
       6'b100111: begin x5b_n1 = 5'b00000; match_x5b_n1 = 1'b1; end //D.00 
       6'b011101: begin x5b_n1 = 5'b00001; match_x5b_n1 = 1'b1; end //D.01
       6'b101101: begin x5b_n1 = 5'b00010; match_x5b_n1 = 1'b1; end //D.02
       6'b110001: begin x5b_n1 = 5'b00011; match_x5b_n1 = 1'b1; end //D.03
       6'b110101: begin x5b_n1 = 5'b00100; match_x5b_n1 = 1'b1; end //D.04
       6'b101001: begin x5b_n1 = 5'b00101; match_x5b_n1 = 1'b1; end //D.05
       6'b011001: begin x5b_n1 = 5'b00110; match_x5b_n1 = 1'b1; end //D.06
       6'b111000: begin x5b_n1 = 5'b00111; match_x5b_n1 = 1'b1; end //D.07
       6'b111001: begin x5b_n1 = 5'b01000; match_x5b_n1 = 1'b1; end //D.08
       6'b100101: begin x5b_n1 = 5'b01001; match_x5b_n1 = 1'b1; end //D.09
       6'b010101: begin x5b_n1 = 5'b01010; match_x5b_n1 = 1'b1; end //D.10
       6'b110100: begin x5b_n1 = 5'b01011; match_x5b_n1 = 1'b1; end //D.11
       6'b001101: begin x5b_n1 = 5'b01100; match_x5b_n1 = 1'b1; end //D.12
       6'b101100: begin x5b_n1 = 5'b01101; match_x5b_n1 = 1'b1; end //D.13
       6'b011100: begin x5b_n1 = 5'b01110; match_x5b_n1 = 1'b1; end //D.14
       6'b010111: begin x5b_n1 = 5'b01111; match_x5b_n1 = 1'b1; end //D.15
       6'b011011: begin x5b_n1 = 5'b10000; match_x5b_n1 = 1'b1; end //D.16
       6'b100011: begin x5b_n1 = 5'b10001; match_x5b_n1 = 1'b1; end //D.17
       6'b010011: begin x5b_n1 = 5'b10010; match_x5b_n1 = 1'b1; end //D.18
       6'b110010: begin x5b_n1 = 5'b10011; match_x5b_n1 = 1'b1; end //D.19
       6'b001011: begin x5b_n1 = 5'b10100; match_x5b_n1 = 1'b1; end //D.20
       6'b101010: begin x5b_n1 = 5'b10101; match_x5b_n1 = 1'b1; end //D.21
       6'b011010: begin x5b_n1 = 5'b10110; match_x5b_n1 = 1'b1; end //D.22
       6'b111010: begin x5b_n1 = 5'b10111; match_x5b_n1 = 1'b1; end //D.23
       6'b110011: begin x5b_n1 = 5'b11000; match_x5b_n1 = 1'b1; end //D.24
       6'b100110: begin x5b_n1 = 5'b11001; match_x5b_n1 = 1'b1; end //D.25
       6'b010110: begin x5b_n1 = 5'b11010; match_x5b_n1 = 1'b1; end //D.26
       6'b110110: begin x5b_n1 = 5'b11011; match_x5b_n1 = 1'b1; end //D.27
       6'b001110: begin x5b_n1 = 5'b11100; match_x5b_n1 = 1'b1; end //D.28
       6'b101110: begin x5b_n1 = 5'b11101; match_x5b_n1 = 1'b1; end //D.29
       6'b011110: begin x5b_n1 = 5'b11110; match_x5b_n1 = 1'b1; end //D.30
       6'b101011: begin x5b_n1 = 5'b11111; match_x5b_n1 = 1'b1; end //D.31
       default:   begin x5b_n1 = 5'b00000; match_x5b_n1 = 1'b0; end
     endcase

   reg [4:0] x5b_p1;
   reg match_x5b_p1; 
   always @(*)
     case(x6b)
       6'b011000: begin x5b_p1 =  5'b00000; match_x5b_p1 = 1'b1; end // D.00 
       6'b100010: begin x5b_p1 =  5'b00001; match_x5b_p1 = 1'b1; end // D.01
       6'b010010: begin x5b_p1 =  5'b00010; match_x5b_p1 = 1'b1; end // D.02
       6'b110001: begin x5b_p1 =  5'b00011; match_x5b_p1 = 1'b1; end // D.03
       6'b001010: begin x5b_p1 =  5'b00100; match_x5b_p1 = 1'b1; end // D.04
       6'b101001: begin x5b_p1 =  5'b00101; match_x5b_p1 = 1'b1; end // D.05
       6'b011001: begin x5b_p1 =  5'b00110; match_x5b_p1 = 1'b1; end // D.06
       6'b000111: begin x5b_p1 =  5'b00111; match_x5b_p1 = 1'b1; end // D.07
       6'b000110: begin x5b_p1 =  5'b01000; match_x5b_p1 = 1'b1; end // D.08
       6'b100101: begin x5b_p1 =  5'b01001; match_x5b_p1 = 1'b1; end // D.09
       6'b010101: begin x5b_p1 =  5'b01010; match_x5b_p1 = 1'b1; end // D.10
       6'b110100: begin x5b_p1 =  5'b01011; match_x5b_p1 = 1'b1; end // D.11
       6'b001101: begin x5b_p1 =  5'b01100; match_x5b_p1 = 1'b1; end // D.12
       6'b101100: begin x5b_p1 =  5'b01101; match_x5b_p1 = 1'b1; end // D.13
       6'b011100: begin x5b_p1 =  5'b01110; match_x5b_p1 = 1'b1; end // D.14
       6'b101000: begin x5b_p1 =  5'b01111; match_x5b_p1 = 1'b1; end // D.15
       6'b100100: begin x5b_p1 =  5'b10000; match_x5b_p1 = 1'b1; end // D.16
       6'b100011: begin x5b_p1 =  5'b10001; match_x5b_p1 = 1'b1; end // D.17
       6'b010011: begin x5b_p1 =  5'b10010; match_x5b_p1 = 1'b1; end // D.18
       6'b110010: begin x5b_p1 =  5'b10011; match_x5b_p1 = 1'b1; end // D.19
       6'b001011: begin x5b_p1 =  5'b10100; match_x5b_p1 = 1'b1; end // D.20
       6'b101010: begin x5b_p1 =  5'b10101; match_x5b_p1 = 1'b1; end // D.21
       6'b011010: begin x5b_p1 =  5'b10110; match_x5b_p1 = 1'b1; end // D.22
       6'b000101: begin x5b_p1 =  5'b10111; match_x5b_p1 = 1'b1; end // D.23
       6'b001100: begin x5b_p1 =  5'b11000; match_x5b_p1 = 1'b1; end // D.24
       6'b100110: begin x5b_p1 =  5'b11001; match_x5b_p1 = 1'b1; end // D.25
       6'b010110: begin x5b_p1 =  5'b11010; match_x5b_p1 = 1'b1; end // D.26
       6'b001001: begin x5b_p1 =  5'b11011; match_x5b_p1 = 1'b1; end // D.27
       6'b001110: begin x5b_p1 =  5'b11100; match_x5b_p1 = 1'b1; end // D.28
       6'b010001: begin x5b_p1 =  5'b11101; match_x5b_p1 = 1'b1; end // D.29
       6'b100001: begin x5b_p1 =  5'b11110; match_x5b_p1 = 1'b1; end // D.30
       6'b010100: begin x5b_p1 =  5'b11111; match_x5b_p1 = 1'b1; end // D.31
       default:   begin x5b_p1 =  5'b00000; match_x5b_p1 = 1'b0; end  
     endcase
       
   reg [2:0] x3b_n1;
   reg match_x3b_n1;
   always @(*)
     case(x4b)
       4'b1011: begin x3b_n1 = 3'b000; match_x3b_n1 = 1'b1; end // D.x.0
       4'b1001: begin x3b_n1 = 3'b001; match_x3b_n1 = 1'b1; end // D.x.1
       4'b0101: begin x3b_n1 = 3'b010; match_x3b_n1 = 1'b1; end // D.x.2
       4'b1100: begin x3b_n1 = 3'b011; match_x3b_n1 = 1'b1; end // D.x.3
       4'b1101: begin x3b_n1 = 3'b100; match_x3b_n1 = 1'b1; end // D.x.4
       4'b1010: begin x3b_n1 = 3'b101; match_x3b_n1 = 1'b1; end // D.x.5
       4'b0110: begin x3b_n1 = 3'b110; match_x3b_n1 = 1'b1; end // D.x.6
       4'b0111: begin x3b_n1 = 3'b111; match_x3b_n1 = 1'b1; end // D.x.A7
       4'b1110: begin x3b_n1 = 3'b111; match_x3b_n1 = 1'b1; end // D.x.P7
       default: begin x3b_n1 = 3'b000; match_x3b_n1 = 1'b0; end  
     endcase

   
   reg [2:0] x3b_p1;
   reg match_x3b_p1;
   always @(*)
     case(x4b)
       4'b0100: begin x3b_p1 = 3'b000; match_x3b_p1 = 1'b1; end // D.x.0
       4'b1001: begin x3b_p1 = 3'b001; match_x3b_p1 = 1'b1; end // D.x.1
       4'b0101: begin x3b_p1 = 3'b010; match_x3b_p1 = 1'b1; end // D.x.2
       4'b0011: begin x3b_p1 = 3'b011; match_x3b_p1 = 1'b1; end // D.x.3
       4'b0010: begin x3b_p1 = 3'b100; match_x3b_p1 = 1'b1; end // D.x.4
       4'b1010: begin x3b_p1 = 3'b101; match_x3b_p1 = 1'b1; end // D.x.5
       4'b0110: begin x3b_p1 = 3'b110; match_x3b_p1 = 1'b1; end // D.x.6
       4'b1000: begin x3b_p1 = 3'b111; match_x3b_p1 = 1'b1; end // D.x.A7
       4'b0001: begin x3b_p1 = 3'b111; match_x3b_p1 = 1'b1; end // D.x.P7
       default: begin x3b_p1 = 3'b000; match_x3b_p1 = 1'b0; end 
     endcase

   reg [7:0] k_n1;
   reg match_k_n1;
   always @(*)
     case({x6b,x4b})
       10'b0011110100: begin k_n1 = 8'b00011100; match_k_n1 = 1'b1; end // K.28.0
       10'b0011111001: begin k_n1 = 8'b00111100; match_k_n1 = 1'b1; end // K.28.1
       10'b0011110101: begin k_n1 = 8'b01011100; match_k_n1 = 1'b1; end // K.28.2
       10'b0011110011: begin k_n1 = 8'b01111100; match_k_n1 = 1'b1; end // K.28.3
       10'b0011110010: begin k_n1 = 8'b10011100; match_k_n1 = 1'b1; end // K.28.4
       10'b0011111010: begin k_n1 = 8'b10111100; match_k_n1 = 1'b1; end // K.28.5
       10'b0011110110: begin k_n1 = 8'b11011100; match_k_n1 = 1'b1; end // K.28.6
       10'b0011111000: begin k_n1 = 8'b11111100; match_k_n1 = 1'b1; end // K.28.7
       10'b1110101000: begin k_n1 = 8'b11110111; match_k_n1 = 1'b1; end // K.23.7
       10'b1101101000: begin k_n1 = 8'b11111011; match_k_n1 = 1'b1; end // K.27.7
       10'b1011101000: begin k_n1 = 8'b11111101; match_k_n1 = 1'b1; end // K.29.7
       10'b0111101000: begin k_n1 = 8'b11111110; match_k_n1 = 1'b1; end // K.30.7
       default:        begin k_n1 = 8'b00000000; match_k_n1 = 1'b0; end 
     endcase

   reg [7:0] k_p1;
   reg match_k_p1; 
   always @(*)
     case({x6b,x4b})
       10'b1100001011: begin k_p1 = 8'b00011100; match_k_p1 = 1'b1; end // K.28.0                              
       10'b1100000110: begin k_p1 = 8'b00111100; match_k_p1 = 1'b1; end // K.28.1                              
       10'b1100001010: begin k_p1 = 8'b01011100; match_k_p1 = 1'b1; end // K.28.2                              
       10'b1100001100: begin k_p1 = 8'b01111100; match_k_p1 = 1'b1; end // K.28.3                              
       10'b1100001101: begin k_p1 = 8'b10011100; match_k_p1 = 1'b1; end // K.28.4                              
       10'b1100000101: begin k_p1 = 8'b10111100; match_k_p1 = 1'b1; end // K.28.5                              
       10'b1100001001: begin k_p1 = 8'b11011100; match_k_p1 = 1'b1; end // K.28.6                              
       10'b1100000111: begin k_p1 = 8'b11111100; match_k_p1 = 1'b1; end // K.28.7                              
       10'b0001010111: begin k_p1 = 8'b11110111; match_k_p1 = 1'b1; end // K.23.7                              
       10'b0010010111: begin k_p1 = 8'b11111011; match_k_p1 = 1'b1; end // K.27.7                              
       10'b0100010111: begin k_p1 = 8'b11111101; match_k_p1 = 1'b1; end // K.29.7                              
       10'b1000010111: begin k_p1 = 8'b11111110; match_k_p1 = 1'b1; end // K.30.7                              
       default:        begin k_p1 = 8'b00000000; match_k_p1 = 1'b0; end
     endcase

   always @(posedge clk)
     if(rst)
       begin
	  data_out <= 8'd0;
	  valid <= 1'b0;
	  is_k <= 1'b0;
       end
     else if(match_k_n1 || match_k_p1) // Commas
       begin
	  data_out <= match_k_n1 ? k_n1 : k_p1;
	  valid <= 1'b1;
	  is_k <= 1'b1; 
       end
     else 
       begin // Data
	  is_k <= 1'b0;
	  if(match_x5b_n1 && match_x3b_n1)
	    begin
	       data_out <= {x3b_n1,x5b_n1};
	       valid <= 1'b1;
	    end
	  else if(match_x5b_n1 && match_x3b_p1)
	    begin
	       data_out <= {x3b_p1,x5b_n1};
	       valid <= 1'b1;
	    end
	  else if(match_x5b_p1 && match_x3b_p1)
	    begin
	       data_out <= {x3b_p1,x5b_p1};
	       valid <= 1'b1;
	    end
	  else if(match_x5b_p1 && match_x3b_n1)
	    begin
	       data_out <= {x3b_n1,x5b_p1};
	       valid <= 1'b1;
	    end
	  else
	    begin
	       data_out <= 8'b0;
	       valid <= 1'b0;
	    end // else: !if(match_x5b_p1 && match_x3b_p1)
       end

endmodule
