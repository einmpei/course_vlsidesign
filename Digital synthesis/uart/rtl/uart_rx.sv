// из https://github.com/ben-marshall/uart/
// Модуль: uart_rx 
// 
// Примечание:
// - UART reciever module.
//

module uart_rx (
input  logic       clk          , // Системный тактовый сигнал
input  logic       resetn       , // Асинхронный глобальный сброс (активный уровень 0)
input  logic       uart_rxd     , // Пин принимаемых UART значений
input  logic       uart_rx_en   , // Разрешение приёма данных
output logic       uart_rx_break, // Было ли получено сообщение прерывании приёма?
output logic       uart_rx_valid, // Получены и доступны достоверные данные
    output logic [PAYLOAD_BITS-1:0] uart_rx_data   // Принятые данные
);

// --------------------------------------------------------------------------- 
// Внешние параметры
// --------------------------------------------------------------------------- 

// Скорость передачи данных UART
parameter BIT_RATE = 9600;
localparam  BIT_P           = 1_000_000_000 * 1/BIT_RATE; // nanoseconds

// Частота тактового сигнала в Гц
parameter CLK_HZ = 50_000_000;
localparam  CLK_P           = 1_000_000_000 * 1/CLK_HZ; // period in nanoseconds

// Количество информационны бит-данных, принимаетмых UART
parameter PAYLOAD_BITS    = 8;

// Количество стоп-бит, определяющих завершение принимаемой посылки
parameter STOP_BITS       = 1;

// -------------------------------------------------------------------------- 
// Внутренние параметры
// ---------------------------------------------------------------------------

// Количество циклов тактового сигнала на один принимаемый бит
localparam       CYCLES_PER_BIT     = BIT_P / CLK_P;

// Размер регистров, хранящих количество выборок и длительность битов
localparam       COUNT_REG_LEN      = 1+$clog2(CYCLES_PER_BIT);

// -------------------------------------------------------------------------- 
// Внутренние регистры
// ---------------------------------------------------------------------------

    // Регистр, через который осуществляется синхронизация принимаемых извне значений (два триггера)
logic [1:0] rxd_reg;

// Регистр, хранящий принятые последовательные данные
logic [PAYLOAD_BITS-1:0] recieved_data;

// Счётчик количества циклов тактового сигнала в пакетном бите
logic [COUNT_REG_LEN-1:0] cycle_counter;

// Счётчик количества принятый в пакете бит
logic [$clog2(COUNT_REG_LEN)-1:0] bit_counter;

// Захват и хранение поступающих данных, в момент чтения середины фрейма входного бита
logic bit_sample;

// Определение текущего и следующего состояний внутреннего конечного автомата
typedef enum logic [1:0] {FSM_IDLE = 2'b00, FSM_START, FSM_RECV, FSM_STOP } state_t;
state_t fsm_state, n_fsm_state;

// --------------------------------------------------------------------------- 
// Назначение выходных данных
// ---------------------------------------------------------------------------

assign uart_rx_break = (uart_rx_valid && ~|recieved_data);
assign uart_rx_valid = ((fsm_state == FSM_STOP) && (n_fsm_state == FSM_IDLE));

always_ff @(posedge clk) begin
    if (!resetn) begin
        uart_rx_data  <= {PAYLOAD_BITS{1'b0}};
    end else if (fsm_state == FSM_STOP) begin
        uart_rx_data  <= recieved_data;
    end
end

// --------------------------------------------------------------------------- 
// Выбор следющего состояния конечного автомата
// ---------------------------------------------------------------------------

logic next_bit;
logic payload_done;

assign next_bit = ((cycle_counter == CYCLES_PER_BIT) ||
                    (fsm_state       == FSM_STOP) && 
                    (cycle_counter   == CYCLES_PER_BIT/2));
assign payload_done = (bit_counter   == PAYLOAD_BITS)  ;

// Логика выбора следующего состояния
always_comb begin : p_n_fsm_state
    case (fsm_state)
        FSM_IDLE : n_fsm_state = (rxd_reg == 2'b10 ? FSM_IDLE : FSM_START);
        FSM_START: n_fsm_state = (next_bit         ? FSM_RECV : FSM_START);
        FSM_RECV : n_fsm_state = (payload_done     ? FSM_STOP : FSM_RECV );
        FSM_STOP : n_fsm_state = (next_bit         ? FSM_IDLE : FSM_STOP );
        default  : n_fsm_state = FSM_IDLE;
    endcase
end

// --------------------------------------------------------------------------- 
// Настройка и сброс внутренних регистров
// ---------------------------------------------------------------------------

// Работа сдвигового регистра, принимающего поступающие данные
always_ff @(posedge clk) begin : p_recieved_data
    if (!resetn) begin
        recieved_data <= {PAYLOAD_BITS{1'b0}};
    end else if (fsm_state == FSM_IDLE             ) begin
        recieved_data <= {PAYLOAD_BITS{1'b0}};
    end else if (fsm_state == FSM_RECV && next_bit ) begin
        recieved_data[PAYLOAD_BITS-1] <= bit_sample;
        for (int i = PAYLOAD_BITS-2; i >= 0; i--) begin
            recieved_data[i] <= recieved_data[i+1];
        end
    end
end

// Увеличение значения счётчика поступивших бит данных
always_ff @(posedge clk) begin : p_bit_counter
    if (!resetn) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if (fsm_state != FSM_RECV) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if (fsm_state == FSM_RECV && next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end
end

// Захват принятого бита, когда находимся по центру фрейма данного бита
always_ff @(posedge clk) begin : p_bit_sample
    if (!resetn) begin
        bit_sample <= 1'b0;
    end else if (cycle_counter == CYCLES_PER_BIT/2) begin
        bit_sample <= rxd_reg[0];
    end
end

// Работа счётчика циклов тактового сигнала в течение поступившего одного бита данных
always_ff @(posedge clk) begin : p_cycle_counter
    if (!resetn) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if (next_bit) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if (fsm_state == FSM_START || 
                 fsm_state == FSM_RECV  || 
                 fsm_state == FSM_STOP   ) begin
        cycle_counter <= cycle_counter + 1'b1;
    end
end

// Условие переключения в следующее состояние
always_ff @(posedge clk) begin : p_fsm_state
    if (!resetn) begin
        fsm_state <= FSM_IDLE;
    end else begin
        fsm_state <= n_fsm_state;
    end
end

// Синхронизация данных, принятых извне через два регистра
always_ff @(posedge clk) begin : p_rxd_reg
    if (!resetn) begin
        rxd_reg <= 2'b11;
    end else if (uart_rx_en) begin
        rxd_reg <= {rxd_reg[0], uart_rxd};
    end
end


endmodule
