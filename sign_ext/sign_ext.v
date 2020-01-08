module sign_ext #(parameter P_IN_WIDTH=14, P_OUT_WIDTH=16)
   (
    input [P_IN_WIDTH-1:0] data_in,
    output [P_OUT_WIDTH-1:0] data_out
    );

   assign data_out = {{(P_OUT_WIDTH-P_IN_WIDTH){data_in[P_IN_WIDTH-1]}},data_in};

endmodule


