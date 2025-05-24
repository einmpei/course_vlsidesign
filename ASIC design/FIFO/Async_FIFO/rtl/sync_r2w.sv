module sync_r2w
  #(
    parameter ASIZE = 4
  )(
    input  logic                wclk,
    input  logic              wrst_n,
    input  logic [ASIZE:0]      rptr,
    output logic [ASIZE:0]  wq2_rptr
  );

logic [ASIZE:0] wq1_rptr;

always_ff @(posedge wclk or negedge wrst_n) begin
  if (!wrst_n)
    {wq2_rptr,wq1_rptr} <= '0;
  else
    {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
end

endmodule
