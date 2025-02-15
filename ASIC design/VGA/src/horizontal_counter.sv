module horizontal_counter(
input clk, reset_n,
output [9:0] pixel_x,
output done_x 
);
logic [9:0] pixel_reg, pixel_next;

always_ff @(posedge clk, negedge reset_n) begin
  if(!reset_n)
   pixel_reg <= 10'b0;
  else
   pixel_reg <= pixel_next; 
end

assign  pixel_next = done_x? 10'b0 : pixel_reg + 1;  

assign pixel_x = pixel_reg;
assign done_x = (pixel_reg == 10'd320);

endmodule
