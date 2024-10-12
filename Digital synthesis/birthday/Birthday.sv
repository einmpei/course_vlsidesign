module Birthday #(parameter WIDTH = 4, DEPTH = 8)
                 (data_in, clk, nrst, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7);

input  logic  [WIDTH*DEPTH-1:0] data_in;
input  logic  clk;
input  logic  nrst;
output logic  [7:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7;

logic [WIDTH-1:0] data      [DEPTH-1];
logic [7:0]       dataSeven [DEPTH-1];

function [7:0] BCD_to_Seven;
  input logic [WIDTH-1:0] d;
  
  begin
    case (d)
      4'd0 : BCD_to_Seven = 8'b11111100;
      4'd1 : BCD_to_Seven = 8'b01100000;
      4'd2 : BCD_to_Seven = 8'b11011010;
      4'd3 : BCD_to_Seven = 8'b11110010;
      4'd4 : BCD_to_Seven = 8'b01100110;
      4'd5 : BCD_to_Seven = 8'b10110110;
      4'd6 : BCD_to_Seven = 8'b10111110;
      4'd7 : BCD_to_Seven = 8'b11100000;
      4'd8 : BCD_to_Seven = 8'b11111110;
      4'd9 : BCD_to_Seven = 8'b11110110;
   default : BCD_to_Seven = 8'b00000000;
    endcase
  end
endfunction

always_comb begin
  for (int i = 0; i < DEPTH-1; i++)
    data[i] = data_in[i*(WIDTH) +: 4];  //i = 0 => data_in[3:0]
end                                     //i = 0 => data_in[3:0]

always_comb begin
  for (int j = 0; j < DEPTH-1; j++)
    dataSeven[j] = BCD_to_Seven(data[j]);
end
	 
assign Q0 = dataSeven[0];
assign Q1 = dataSeven[1];
assign Q2 = dataSeven[2];
assign Q3 = dataSeven[3];
assign Q4 = dataSeven[4];
assign Q5 = dataSeven[5];
assign Q6 = dataSeven[6];
assign Q7 = dataSeven[7];
	 
endmodule
