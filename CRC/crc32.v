module crc32(
input clk,
input rst,
input [31:0] data,
input rd, 				
output [31:0] CRC, 		
output out_ready_CRC
);

reg [31:0] data_CRC;
reg [63:0] ext_data;
reg [32:0] polynomial; 
reg [5:0] cnt;
reg ready_CRC;
reg [32:0] shifter;

assign CRC [31:0] = data_CRC [31:0];
assign out_ready_CRC = ready_CRC;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		data_CRC [31:0] <= {32{1'bZ}};
		ext_data [63:0] <= {64{1'b0}};
		shifter [32:0] <= {33{1'b0}};
		polynomial [32:0] <= 33'h1_04C11DB7;
		cnt [5:0] <= 6'b000000;
		ready_CRC <= 1'b0;
	end
	else begin
		if ((!rd)&&(cnt == 6'd32)) begin
			if (shifter[32]) shifter = shifter ^ polynomial;
			ready_CRC <= 1'b1;
			data_CRC [31:0] = shifter[31:0];
		end
		else if ((!rd)&&(cnt < 6'd32)) begin
			if (shifter [32]) shifter = shifter ^ polynomial;
			shifter = {shifter[31:0],ext_data[31]};
			cnt <= cnt + 1'b1;
			ext_data <= {ext_data[62:0], 1'b0};
			end
		else if (rd) begin
			shifter [32:0] <= {data[31:0],1'b0};
			ext_data [63:0] <= {data [31:0], {32{1'b0}}};
		end
	end
end
endmodule
