`include "Birthday_winput.sv"
`timescale 1ns / 1ns

module tb_Birthday_winput;

bit clk = 0;
bit nrst = 1;
logic [7:0] cathodes, anodes;

Birthday_winput #(4, 8) DUT (clk, nrst, cathodes, anodes);

always #5 clk = ~clk;

initial
  repeat(2) #2 nrst = ~nrst;

initial
  #200 $finish;

initial
  $dumpvars;

endmodule
