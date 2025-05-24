module wptr_full
	#(
		parameter ADDRSIZE = 4
	)(
		input  logic                    wclk,
		input  logic                  wrst_n,
		input  logic                    winc,
		input  logic [ADDRSIZE  :0] wq2_rptr,
		output logic                   wfull,
		output logic                  awfull,
    output logic [ADDRSIZE-1:0]    waddr,
    output logic [ADDRSIZE  :0]     wptr
	);

    logic [ADDRSIZE:0] wbin;
    logic [ADDRSIZE:0] wgraynext, wbinnext, wgraynextp1;
    logic              awfull_val, wfull_val;

	// Указатель в коде Грэя
always_ff @(posedge wclk or negedge wrst_n) begin
  if (!wrst_n)
	  {wbin, wptr} <= 0;
  else
	{wbin, wptr} <= {wbinnext, wgraynext};
end

  // Указатель адреса для записи в память (можно использовать двоичный код для обращения к памяти)
assign waddr = wbin[ADDRSIZE-1:0];
assign wbinnext  = wbin + (winc & ~wfull);
assign wgraynext = (wbinnext >> 1) ^ wbinnext;
assign wgraynextp1 = ((wbinnext + 1'b1) >> 1) ^ (wbinnext + 1'b1);

    //------------------------------------------------------------------
    // Упрощённая версия трёх необходимых полных проверок:
    // assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
    //                   (wgnext[ADDRSIZE-1]  !=wq2_rptr[ADDRSIZE-1]) &&
    // (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
    //------------------------------------------------------------------

assign wfull_val = (wgraynext == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1],wq2_rptr[ADDRSIZE-2:0]}); // Полный FIFO
assign awfull_val = (wgraynextp1 == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1],wq2_rptr[ADDRSIZE-2:0]}); // Почти полный FIFO (есть ещё одно место под запись)

always_ff @(posedge wclk or negedge wrst_n) begin
  if (!wrst_n) begin
    awfull <= 1'b0;
    wfull  <= 1'b0;
  end else begin
    awfull <= awfull_val;
  wfull  <= wfull_val;
    end
end
endmodule
