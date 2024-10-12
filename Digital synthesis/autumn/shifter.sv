module shifter(clk, nrst, shift);

localparam FREQ_SHIFT = `FREQ_SHIFT;
localparam CLK_INNER = `CLK_INNER;
localparam WIDTH = $clog2(CLK_INNER/FREQ_SHIFT);

input                  clk;
input                 nrst;

`ifdef SHIFTER
output [1:0]         shift;
`elsif BARREL_SHIFTER
output [2:0]         shift;
`endif

`ifdef SHIFTER
reg    [1:0]       shift_r;
`elsif BARREL_SHIFTER
reg    [2:0]       shift_r;
`endif

reg    [WIDTH-1:0]     cnt;

always @(posedge clk or negedge nrst) begin
  if (!nrst) begin
    cnt     <= 0;
    shift_r <= 0;
  end
  else if (cnt == CLK_INNER/FREQ_SHIFT) begin
    cnt     <= 0;
    shift_r <= shift_r + 1'b1;
  end
  else begin
    cnt     <= cnt + 1'b1;
  end
end

assign shift = shift_r;

endmodule
