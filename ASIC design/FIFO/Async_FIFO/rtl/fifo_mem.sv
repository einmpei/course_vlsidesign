// За основу всего RTL взят код https://github.com/dpretet/async_fifo/

module fifo_mem
    #(
        parameter  DATASIZE = 8,    // Ширина слова
        parameter  ADDRSIZE = 4    // Количество бит адреса
    ) (
        input  logic                wclk,
        input  logic                wclken,
        input  logic [ADDRSIZE-1:0] waddr,
        input  logic [DATASIZE-1:0] wdata,
        input  logic                wfull,
        input  logic                rclk,
        input  logic                rclken,
        input  logic [ADDRSIZE-1:0] raddr,
        output logic [DATASIZE-1:0] rdata
    );

  localparam DEPTH = 1 << ADDRSIZE; // Глубина FIFO-буфера (количество слов)

  logic [DATASIZE-1:0] mem [0:DEPTH-1];
  logic [DATASIZE-1:0] rdata_r;

  always_ff @(posedge wclk) begin // Асинхронная запись данных в неполный FIFO
     if (wclken && !wfull)
       mem[waddr] <= wdata;
  end

  always_ff @(posedge rclk) begin // Асинхронное чтение данных из непустого FIFO
    if (rclken)
       rdata_r <= mem[raddr];
  end
    
  assign rdata = rdata_r;

endmodule
