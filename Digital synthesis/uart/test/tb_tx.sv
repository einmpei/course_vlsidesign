

// 
// Module: tb
// 
// Notes:
// - Top level simulation testbench.
//

`timescale 1ns/1ns

module tb_tx;
    
logic       clk         ; // Top level system clock input.
logic       resetn      ;

logic       uart_txd    ; // UART transmit pin.
logic       uart_tx_busy; // Module busy sending previous item.
logic       uart_tx_en  ; 
logic [7:0] uart_tx_data; // The recieved data.

//
// Bit rate of the UART line we are testing.
localparam BIT_RATE = 9600;
localparam BIT_P    = (1000000000/BIT_RATE);

//
// Period and frequency of the system clock.
localparam CLK_HZ   = 50000000;
localparam CLK_P    = 1000000000/ CLK_HZ;
localparam CLK_P_2    = 500000000/ CLK_HZ;


//
// Make the clock tick.
always #CLK_P_2 clk=~clk;


//
// Sends a single byte down the UART line.
task send_byte;
    input [7:0] to_send;
    begin
        $display("Send data %b at time %d", to_send,$time);
        uart_tx_data= to_send;
        uart_tx_en  = 1'b1;
    end
endtask


//
// Run the test sequence.
logic [7:0] to_send;
initial begin
    resetn  = 1'b0;
    clk     = 1'b0;
    #40 resetn = 1'b1;
    
    repeat(20) begin
        to_send = $random;
        send_byte(to_send);
        #1000;
        wait(!uart_tx_busy);
    end

    $display("BIT RATE  : %db/s", BIT_RATE );
    $display("BIT PERIOD: %dns" , BIT_P    );
    $display("CLK PERIOD: %dns" , CLK_P    );
    $display("CYCLES/BIT: %d"   , i_uart_tx.CYCLES_PER_BIT);

    $display("Finish simulation at time %d", $time);
    $finish();
end


//
// Instance of the DUT
uart_tx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_tx(
.clk          (clk          ),
.resetn       (resetn       ),
.uart_txd     (uart_txd     ),
.uart_tx_en   (uart_tx_en   ),
.uart_tx_busy (uart_tx_busy ),
.uart_tx_data (uart_tx_data ) 
);

endmodule
