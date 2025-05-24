module rptr_empty
    #(
    parameter ADDRSIZE = 4
    )(
    input  logic                    rclk,
    input  logic                  rrst_n,
    input  logic                    rinc,
    input  logic [ADDRSIZE  :0] rq2_wptr,
    output logic                  rempty,
    output logic                 arempty,
    output logic [ADDRSIZE-1:0]    raddr,
    output logic [ADDRSIZE  :0]     rptr
    );

    logic [ADDRSIZE:0] rbin;
    logic [ADDRSIZE:0] rgraynext, rbinnext, rgraynextm1;
    logic              arempty_val, rempty_val;

    //-------------------
    // Указатель в коде Грэя
    //-------------------
    always_ff @(posedge rclk or negedge rrst_n) begin
      if (!rrst_n)
        {rbin, rptr} <= '0;
      else
        {rbin, rptr} <= {rbinnext, rgraynext};
    end

    // Указатель адреса чтения (можно использовать двоичный код для обращения к памяти)
    assign raddr     = rbin[ADDRSIZE-1:0];
    assign rbinnext  = rbin + (rinc & ~rempty);
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;
    assign rgraynextm1 = ((rbinnext + 1'b1) >> 1) ^ (rbinnext + 1'b1);

    //---------------------------------------------------------------
    // FIFO пуст, когда указатель следующего rptr == синхронизованный wptr или при reset
    //---------------------------------------------------------------
    assign rempty_val = (rgraynext == rq2_wptr);
    assign arempty_val = (rgraynextm1 == rq2_wptr);

    always_ff @ (posedge rclk or negedge rrst_n) begin
      if (!rrst_n) begin
        arempty <= 1'b0;
        rempty  <= 1'b1;
      end else begin
        arempty <= arempty_val;
        rempty  <= rempty_val;
      end
    end
endmodule
