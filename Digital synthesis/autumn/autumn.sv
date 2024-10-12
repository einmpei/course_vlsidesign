module autumn(clk, shift, nrst, cathodes, anodes);

`ifdef SHIFTER
input  [1:0]      shift;
`elsif BARREL_SHIFTER
input  [2:0]      shift;
`endif

input               clk;
input              nrst;
output [7:0]   cathodes;
output [7:0]     anodes;

reg    [7:0] cathodes_r;
reg    [7:0]   anodes_r;

reg    [3:0]       data  [0:4]; //OCEHb

reg    [2:0]       addr;

function [6:0] BCD_to_Seven;
  input  [3:0] d;
  
  begin
    case (d)
      4'd0 : BCD_to_Seven = 7'b1111110; //O
      4'd1 : BCD_to_Seven = 7'b1001110; //C
      4'd2 : BCD_to_Seven = 7'b1001111; //E
      4'd3 : BCD_to_Seven = 7'b0110111; //H
      4'd4 : BCD_to_Seven = 7'b0011111; //b
   default : BCD_to_Seven = 7'b0000000;
    endcase
  end
endfunction

initial begin //initial OCEHb
  data[0] = 4'd0;
  data[1] = 4'd1;
  data[2] = 4'd2;
  data[3] = 4'd3;
  data[4] = 4'd4;
end

//count address
always @(posedge clk or negedge nrst) begin
  if (!nrst) begin
    addr   <= 4'b0000;
  end
  else begin
    addr   <= addr + 1'b1;
    if (addr == 4'd4)
      addr <= 0;
  end
end

//forming cathodes
always @(posedge clk or negedge nrst) begin
  if (!nrst) begin
    cathodes_r <= 0;
  end
  else begin
    cathodes_r <= {BCD_to_Seven(data[addr]), 1'b0};
  end
end

//switching anodes
always @(posedge clk or negedge nrst) begin
  if (!nrst) begin
    anodes_r <= {8{1'b0}};
  end
  else begin
    anodes_r <= 8'b1000_0000 >> (addr + shift);
  end
end

`ifdef ACTING_LOW
assign cathodes = ~cathodes_r;
assign anodes   = ~anodes_r;
`elsif ACTING_HIGH
assign cathodes = cathodes_r;
assign anodes   = anodes_r;
`endif

endmodule
