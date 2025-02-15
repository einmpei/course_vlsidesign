module memory_rom
#(parameter WIDTH = 3, DEPTH = 16)
(
input clk,
input rd_ena,
input [DEPTH-1:0] addr,
output logic [WIDTH-1:0] data
);
logic WIDTH-1:0] rom [0:2**DEPTH-1];

initial
$readmemb("bird_img.txt", rom); 
		  
always_ff @(posedge clk) begin
	if(rd_ena)
	data <= rom[addr];
end
endmodule
