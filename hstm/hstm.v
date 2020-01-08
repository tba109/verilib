//////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Thu Feb 13 16:11:03 EST 2014
// Hand Shake Task Manager (HSTM)
//////////////////////////////////////////////////////////////////////////////////////
module hstm #(parameter P_DATA_WIDTH = 1, parameter P_BUSY_CNT = 8)
   (
    input 		      clk, // clock
    input 		      rst_n, // active low reset
    input 		      req, // task request input (internally synchronized to clk)
    output 		      busy, // active while task is underway
    input [P_DATA_WIDTH-1:0]  hstm_data_in, // input data
    output [P_DATA_WIDTH-1:0] hstm_data_out // output data
    );

   //////////////////////////////////////////////////////////////////////////////////////
   // State machine stuff
   reg [1:0] 		      fsm;
   localparam
     S_IDLE   = 2'd0,
     S_BUSY   = 2'd1,
     S_WAIT   = 2'd2,
     S_LATCH  = 2'd3;

   //////////////////////////////////////////////////////////////////////////////////////
   // Synchronizer for req   
   wire 		      req_s;
   sync SYNC0(.a(req),.y(req_s),.clk(clk),.rst_n(rst_n));

   //////////////////////////////////////////////////////////////////////////////////////
   // counter to wait for busy to be done
   function integer clogb2;
      input integer 	      value;
      for(clogb2=0;value>0;clogb2=clogb2+1)
	value = value >> 1;
   endfunction // for   
   localparam NBITS = clogb2(P_BUSY_CNT); 
   reg [NBITS:0] 	      busy_cnt;
   wire 		      busy_done;
   assign busy_done = (busy_cnt == (P_BUSY_CNT-1));
   always @(posedge clk or negedge rst_n)
     if( !rst_n ) busy_cnt <= {NBITS{1'b0}};
     else if( fsm == S_BUSY ) busy_cnt <= busy_cnt + 1'b1;
     else busy_cnt <= 0; 
     
   //////////////////////////////////////////////////////////////////////////////////////
   // output logic
   reg [P_DATA_WIDTH-1:0]     hstm_data_reg;
   assign hstm_data_out = hstm_data_reg;
   assign busy = (fsm == S_BUSY);
   always @(posedge clk or negedge rst_n)
     if( !rst_n ) hstm_data_reg <= {P_DATA_WIDTH{1'b0}};
     else if( fsm == S_LATCH ) hstm_data_reg <= hstm_data_in;

   //////////////////////////////////////////////////////////////////////////////////////
   // fsm logic
   always @(posedge clk or negedge rst_n)
     if( !rst_n ) fsm <= S_IDLE;
     else
       case(fsm)
	 S_IDLE: if(req_s) fsm <= S_BUSY;
	 S_BUSY: if(busy_done)  fsm <= S_WAIT;
	 S_WAIT: if(!req_s & !busy_done) fsm <= S_LATCH;
	 S_LATCH: fsm <= S_IDLE;
       endcase // case (fsm)
endmodule // hstm
