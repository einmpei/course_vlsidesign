module ResetDelay(iclk, orst);

input			iclk;
output logic	orst;

logic	[19:0]	cnt;

always_ff @(posedge iclk) begin
	if (cnt != 20'hFFFFF) begin //21 ms
		cnt		<=	cnt + 1'b1;
		orst	<=	1'b0;
	end
	else begin
		orst	<=	1'b1;
	end
end

endmodule