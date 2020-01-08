//////////////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Tue 06/18/2019_11:03:58.05
//
// task_reg.v
//
// This is a task request register, which has the following properties
// 1.) Data bus writes a 1 in order to request task execution
// 2.) Logic writes a 0 when the task is complete
// 3.) Data bus writes are OR'ed with current contents 
//////////////////////////////////////////////////////////////////////////////////////////////////

module task_reg
  (
   input 	     clk,
   input 	     rst,
   // data bus
   input [11:0]      adr,
   input 	     wr,
   input [15:0]      data,
   // logic
   output reg [15:0] req = 0,
   input [15:0]      ack,
   output reg [15:0] val = 0
   );

   // Parameters
   parameter P_TASK_ADR=12'hffe; 
   
   // For the acknowledge
   reg [15:0] 	     ack_prev=0;
   always @(posedge clk or posedge rst)
     if(rst) ack_prev <= 0;
     else ack_prev <= ack; 
   
   // The main logic
   always @(posedge clk or posedge rst)
     if(rst)
       begin
	  val[0] <= 0;
	  req[0] <= 0;
	  val[1] <= 0;
	  req[1] <= 0;
	  val[2] <= 0;
	  req[2] <= 0;
	  val[3] <= 0;
	  req[3] <= 0;
	  val[4] <= 0;
	  req[4] <= 0;
	  val[5] <= 0;
	  req[5] <= 0;
	  val[6] <= 0;
	  req[6] <= 0;
	  val[7] <= 0;
	  req[7] <= 0;
	  val[8] <= 0;
	  req[8] <= 0;
	  val[9] <= 0;
	  req[9] <= 0;
	  val[10] <= 0;
	  req[10] <= 0;
	  val[11] <= 0;
	  req[11] <= 0;
	  val[12] <= 0;
	  req[12] <= 0;
	  val[13] <= 0;
	  req[13] <= 0;
	  val[14] <= 0;
	  req[14] <= 0;
	  val[15] <= 0;
	  req[15] <= 0;
       end
     else
       begin
	  req[0] <= 0;
	  req[1] <= 0;
	  req[2] <= 0;
	  req[3] <= 0;
	  req[4] <= 0;
	  req[5] <= 0;
	  req[6] <= 0;
	  req[7] <= 0;
	  req[8] <= 0;
	  req[9] <= 0;
	  req[10] <= 0;
	  req[11] <= 0;
	  req[12] <= 0;
	  req[13] <= 0;
	  req[14] <= 0;
	  req[15] <= 0;
	  case(val[0])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[0] <= val[0] | data[0];
	    1:
	      begin
		 req[0] <= 1;
		 if(ack[0])
		   req[0] <= 0;
		 if(ack_prev[0] && !ack[0]) // negative edge
		   begin
		      req[0] <= 0;
		      val[0] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[1])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[1] <= val[1] | data[1];
	    1:
	      begin
		 req[1] <= 1;
		 if(ack[1])
		   req[1] <= 0;
		 if(ack_prev[1] && !ack[1]) // negative edge
		   begin
		      req[1] <= 0;
		      val[1] <= 0; 
		   end
	      end // case: 1
	  endcase // case (val[1])
	  case(val[2])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[2] <= val[2] | data[2];
	    1:
	      begin
		 req[2] <= 1;
		 if(ack[2])
		   req[2] <= 0;
		 if(ack_prev[2] && !ack[2]) // negative edge
		   begin
		      req[2] <= 0;
		      val[2] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[3])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[3] <= val[3] | data[3];
	    1:
	      begin
		 req[3] <= 1;
		 if(ack[3])
		   req[3] <= 0;
		 if(ack_prev[3] && !ack[3]) // negative edge
		   begin
		      req[3] <= 0;
		      val[3] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[4])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[4] <= val[4] | data[4];
	    1:
	      begin
		 req[4] <= 1;
		 if(ack[4])
		   req[4] <= 0;
		 if(ack_prev[4] && !ack[4]) // negative edge
		   begin
		      req[4] <= 0;
		      val[4] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[5])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[5] <= val[5] | data[5];
	    1:
	      begin
		 req[5] <= 1;
		 if(ack[5])
		   req[5] <= 0;
		 if(ack_prev[5] && !ack[5]) // negative edge
		   begin
		      req[5] <= 0;
		      val[5] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[6])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[6] <= val[6] | data[6];
	    1:
	      begin
		 req[6] <= 1;
		 if(ack[6])
		   req[6] <= 0;
		 if(ack_prev[6] && !ack[6]) // negative edge
		   begin
		      req[6] <= 0;
		      val[6] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[7])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[7] <= val[7] | data[7];
	    1:
	      begin
		 req[7] <= 1;
		 if(ack[7])
		   req[7] <= 0;
		 if(ack_prev[7] && !ack[7]) // negative edge
		   begin
		      req[7] <= 0;
		      val[7] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[8])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[8] <= val[8] | data[8];
	    1:
	      begin
		 req[8] <= 1;
		 if(ack[8])
		   req[8] <= 0;
		 if(ack_prev[8] && !ack[8]) // negative edge
		   begin
		      req[8] <= 0;
		      val[8] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[9])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[9] <= val[9] | data[9];
	    1:
	      begin
		 req[9] <= 1;
		 if(ack[9])
		   req[9] <= 0;
		 if(ack_prev[9] && !ack[9]) // negative edge
		   begin
		      req[9] <= 0;
		      val[9] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[10])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[10] <= val[10] | data[10];
	    1:
	      begin
		 req[10] <= 1;
		 if(ack[10])
		   req[10] <= 0;
		 if(ack_prev[10] && !ack[10]) // negative edge
		   begin
		      req[10] <= 0;
		      val[10] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[11])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[11] <= val[11] | data[11];
	    1:
	      begin
		 req[11] <= 1;
		 if(ack[11])
		   req[11] <= 0;
		 if(ack_prev[11] && !ack[11]) // negative edge
		   begin
		      req[11] <= 0;
		      val[11] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[12])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[12] <= val[12] | data[12];
	    1:
	      begin
		 req[12] <= 1;
		 if(ack[12])
		   req[12] <= 0;
		 if(ack_prev[12] && !ack[12]) // negative edge
		   begin
		      req[12] <= 0;
		      val[12] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[13])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[13] <= val[13] | data[13];
	    1:
	      begin
		 req[13] <= 1;
		 if(ack[13])
		   req[13] <= 0;
		 if(ack_prev[13] && !ack[13]) // negative edge
		   begin
		      req[13] <= 0;
		      val[13] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[14])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[14] <= val[14] | data[14];
	    1:
	      begin
		 req[14] <= 1;
		 if(ack[14])
		   req[14] <= 0;
		 if(ack_prev[14] && !ack[14]) // negative edge
		   begin
		      req[14] <= 0;
		      val[14] <= 0; 
		   end
	      end // case: 1
	  endcase
	  case(val[15])
	    0:
	      if((adr == P_TASK_ADR) && wr) 
		val[15] <= val[15] | data[15];
	    1:
	      begin
		 req[15] <= 1;
		 if(ack[15])
		   req[15] <= 0;
		 if(ack_prev[15] && !ack[15]) // negative edge
		   begin
		      req[15] <= 0;
		      val[15] <= 0; 
		   end
	      end // case: 1
	  endcase
       end // else: !if(rst)
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:("." "../negedge_detector")
// End:
