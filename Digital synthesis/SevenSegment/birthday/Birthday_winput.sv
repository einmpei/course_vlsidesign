module Birthday_winput (clk, nrst, cathodes, anodes);

input  logic              clk;
input  logic             nrst;
output logic [7:0]   cathodes;
output logic [7:0]     anodes;

logic    [7:0] cathodes_r;
logic    [7:0]   anodes_r;

logic    [3:0]       data  [0:7];

logic    [2:0]       addr;

function [6:0] BCD_to_Seven;
  input logic [3:0] d;
  
  begin
    case (d)
      4'd0 : BCD_to_Seven = 7'b1111110;
      4'd1 : BCD_to_Seven = 7'b0110000;
      4'd2 : BCD_to_Seven = 7'b1101101;
      4'd3 : BCD_to_Seven = 7'b1111001;
      4'd4 : BCD_to_Seven = 7'b0110011;
      4'd5 : BCD_to_Seven = 7'b1011011;
      4'd6 : BCD_to_Seven = 7'b1011111;
      4'd7 : BCD_to_Seven = 7'b1110000;
      4'd8 : BCD_to_Seven = 7'b1111111;
      4'd9 : BCD_to_Seven = 7'b1111011;
   default : BCD_to_Seven = 7'b0000000;
    endcase
  end
endfunction

initial begin //initial birthday 12.11.1967
  data[0] = 4'd1;
  data[1] = 4'd2; // with dot
  data[2] = 4'd1;
  data[3] = 4'd1; // with dot
  data[4] = 4'd1;
  data[5] = 4'd9;
  data[6] = 4'd6;
  data[7] = 4'd7;
end

//count address
always_ff @(posedge iclk or negedge nrst) begin
  if (!nrst) begin
    addr <= 4'b0000;
  end
  else begin
    addr <= addr + 1'b1;
  end
end

//forming cathodes
always_ff @(posedge iclk or negedge nrst) begin
  if (!nrst) begin
    cathodes_r <= 0;
  end
  else begin
    cathodes_r <= (addr == 4'd1 || addr == 4'd3) ? {BCD_to_Seven(data[addr]), 1'b1} : {BCD_to_Seven(data[addr]), 1'b0};
  end
end

//switching anodes
always_ff @(posedge iclk or negedge nrst) begin
  if (!nrst) begin
    anodes_r <= {8{1'b0}};
  end
  else begin
    anodes_r <= 8'b1000_0000 >> addr;
  end
end

assign cathodes = ~cathodes_r;
assign anodes   = ~anodes_r;


//inner clock 5kHz
logic [12:0]   cnt;
logic         iclk;

always_ff @(posedge clk or negedge nrst) begin
  if (!nrst) begin
     cnt  <= 0;
     iclk <= 0;
  end
  else if(cnt == 13'd5000) begin
     cnt  <= 0;
     iclk <= ~iclk;
  end
  else
     cnt  <= cnt + 1'b1;
end

endmodule
