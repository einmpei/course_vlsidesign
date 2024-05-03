module sync_w2r
  #(
    parameter ASIZE = 4
    )(
    input  logic               rclk,
    input  logic             rrst_n,
    output logic [ASIZE:0] rq2_wptr,
    input  logic [ASIZE:0]     wptr
    );

logic [ASIZE:0] rq1_wptr;

always_ff @(posedge rclk or negedge rrst_n) begin
  if (!rrst_n) begin
    {rq2_wptr,rq1_wptr} <= '0;
  end else begin
    {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
  end
end

endmodule
