//////////////////////////////////////////////////////////////////////////////////
// <NAME> <DATE>
//
// <MODULE NAME>.v
//
// <DESCRIPTION>
//////////////////////////////////////////////////////////////////////////////////

module <MODULE NAME>
  (
   );
   ///////////////////////////////////////////////////////////////////////////////
   // Internals

   ///////////////////////////////////////////////////////////////////////////////
   // FSM definitions
   reg [:] fsm;
   localparam
     ;

`ifdef MODEL_TECH // This works well for modelsim
   reg [:] state_str;
   always @(*)
     case(fsm)
       ;
     endcase // case (fsm)
`endif

   ///////////////////////////////////////////////////////////////////////////////
   // Helper logic

   ///////////////////////////////////////////////////////////////////////////////
   // Output assignments

   ///////////////////////////////////////////////////////////////////////////////
   // FSM Flow
      
endmodule

// For emacs verilog-mode
// Local Variables:
// verilog-library-directories:(".")
// End: