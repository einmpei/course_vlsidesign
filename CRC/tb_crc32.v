`include "crc32.v"
`timescale 1ns/1ns 

module tb_crc32;

reg [31:0] data;
reg clk, rst,rd;
wire [31:0] CRC;
wire out_ready_CRC;


crc32 uut(
.clk(clk),
.rst(rst),
.data(data),
.rd(rd),
.CRC(CRC),
.out_ready_CRC(out_ready_CRC)
);

initial begin
	#0 clk = 0;
	forever #1 clk=~clk;
end

initial begin
	#0 rst = 0;
	#0 data = 32'hAAAA5555;
	#0 rd = 0;
	#5 rst = 1;
	#1 rd = 1;
	#5 rst = 0;
	#3 rd = 0;
	#2 rd =1;
	#5 rst = 1;
	#30 rd =0;
end

initial
	$dumpvars;

initial
	#200 $finish;

endmodule
