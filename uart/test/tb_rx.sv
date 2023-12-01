

// 
//Моульe: tb
// 
// Примечание:
// - Top level simulation testbench.
//

`timescale 1ns/1ns
`define WAVES_FILE "./work/waves-rx.vcd"

module tb;
    
logic       clk          ; // Системный синхросигнал
logic       resetn       ; // Глобальный сброс
logic       uart_rxd     ; // Пин принимаемых UART данных

logic       uart_rx_en   ; // Передача разрешающего сигнала
logic       uart_rx_break; // Did we get a BREAK message?
logic       uart_rx_valid; // Валидность и доступность принятых данных
    logic [7:0] uart_rx_data ; // Принятые данные

//
// Скорость передачи данных UART в тесте
    localparam BIT_RATE = 115200; // поменять на 9600, если исходный мдуль синтезируется (например в Quartus)
    localparam BIT_P    = (1_000_000_000 /BIT_RATE);

//
// Задание периода и частоты системного тактового сигнала
localparam CLK_HZ   = 50_000_000;
localparam CLK_P    = 1_000_000_000 / CLK_HZ;


//
// Определение тактового сигнала
always begin #(CLK_P/2) assign clk    = ~clk; end


//
// Отправка одиночного байта данных по UART
task send_byte;
    input [7:0] to_send;
    int i;
    begin
        #BIT_P;  uart_rxd = 1'b0;
        for(i=0; i < 8; i++) begin
            #BIT_P;  uart_rxd = to_send[i];
        end
        #BIT_P;  uart_rxd = 1'b1;
        #1000;
    end
endtask

//
    // Проверка того, что принятые UART данные соответствуют передаваемым (ожидаемым)
int passes = 0;
int fails  = 0;
task check_byte;
    input [7:0] expected_value;
    begin
        if(uart_rx_data == expected_value) begin
            passes += 1;
            $display("%d/%d/%d [PASS] Expected %b and got %b", 
                     passes,fails,passes+fails,
                     expected_value, uart_rx_data);
        end else begin
            fails  += 1;
            $display("%d/%d/%d [FAIL] Expected %b and got %b", 
                     passes,fails,passes+fails,
                     expected_value, uart_rx_data);
        end
    end
endtask

//
// Запуск теста
logic [7:0] to_send;
initial begin
    resetn  = 1'b0;
    clk     = 1'b0;
    uart_rxd = 1'b1;
    #40 resetn = 1'b1;
    
    $dumpfile(`WAVES_FILE);
    $dumpvars(0,tb);

    uart_rx_en = 1'b1;

    #1000;

    repeat(10) begin
        to_send = $random;
        send_byte(to_send); check_byte(to_send);
    end

    $display("BIT RATE      : %db/s", BIT_RATE );
    $display("CLK PERIOD    : %dns" , CLK_P    );
    $display("CYCLES/BIT    : %d"   , i_uart_rx.CYCLES_PER_BIT);
    $display("SAMPLE PERIOD : %d", CLK_P *i_uart_rx.CYCLES_PER_BIT);
    $display("BIT PERIOD    : %dns" , BIT_P    );

    $display("Test Results:");
    $display("    PASSES: %d", passes);
    $display("    FAILS : %d", fails);

    $display("Finish simulation at time %d", $time);
    $finish();
end


//
// Экземпляр тестируемого устройства
uart_rx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_rx(
.clk          (clk          ), // Top level system clock input.
.resetn       (resetn       ), // Asynchronous active low reset.
.uart_rxd     (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   (uart_rx_en   ), // Recieve enable
.uart_rx_break(uart_rx_break), // Did we get a BREAK message?
.uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
.uart_rx_data (uart_rx_data )  // The recieved data.
);

endmodule
