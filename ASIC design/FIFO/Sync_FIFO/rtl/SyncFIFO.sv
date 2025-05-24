module SyncFIFO #(
    parameter DEPTH = 8,
    parameter WIDTH = 8)
    (
        input        [WIDTH-1 : 0]  data_in,
        input                       clk,
        input                       nrst,
        input                       wr_en,
        input                       rd_en,

        output logic                valid,
        output logic                ready,

        output logic [WIDTH-1 : 0]  data_out
    );

wire                                full; // FIFO is full
wire                                empty; // FIFO is empty

logic                [WIDTH-1 : 0]          fifo_mem [DEPTH]; // FIFO memory
logic                [$clog2(DEPTH)-1 : 0]  wptr; // Read addreess pointer
logic                [$clog2(DEPTH)-1 : 0]  rptr; // Write address pointer

logic                [$clog2(DEPTH)-1 : 0]  usedwd; // Count FIFO's words

always_ff @(posedge clk) begin : FIFO_memory
    if (!nrst) begin : FIFO_init
        for (int i = 0; i < DEPTH; i++) begin
           fifo_mem[i] <= '0;
        end
        wptr <= 1'b0;
        rptr <= 1'b0;
    end
    else begin
        if (wr_en && ready) begin : Write
            fifo_mem[wptr]  <= data_in;
            wptr            <= wptr + 1'b1;
        end
        if (rd_en && valid) begin : Read
            data_out        <= fifo_mem[rptr];
            rptr            <= rptr + 1'b1;
        end
    end
end

always_ff @( posedge clk ) begin : cnt_word
    if (!nrst) begin
        usedwd <= '0;
    end else begin
        usedwd <= (wptr > rptr) ? (wptr - rptr) : (rptr - wptr);
    end
end

assign full  = (usedwd == DEPTH);
assign empty = (usedwd == 0);

assign valid = ~empty;
assign ready = ~full;

endmodule
