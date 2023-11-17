
// from https://github.com/ben-marshall/uart/
// Module: uart_rx 
// 
// Notes:
// - UART reciever module.
//

module uart_rx(
input  logic       clk          , // Top level system clock input.
input  logic       resetn       , // Asynchronous active low reset.
input  logic       uart_rxd     , // UART Recieve pin.
input  logic       uart_rx_en   , // Recieve enable
output logic       uart_rx_break, // Did we get a BREAK message?
output logic       uart_rx_valid, // Valid data recieved and available.
output logic [PAYLOAD_BITS-1:0] uart_rx_data   // The recieved data.
);

// --------------------------------------------------------------------------- 
// External parameters.
// 

//
// Input bit rate of the UART line.
parameter   BIT_RATE        = 9600; // bits / sec
localparam  BIT_P           = 1_000_000_000 * 1/BIT_RATE; // nanoseconds

//
// Clock frequency in hertz.
parameter   CLK_HZ          =    50_000_000;
localparam  CLK_P           = 1_000_000_000 * 1/CLK_HZ; // period in nanoseconds

//
// Number of data bits recieved per UART packet.
parameter   PAYLOAD_BITS    = 8;

//
// Number of stop bits indicating the end of a packet.
parameter   STOP_BITS       = 1;

// -------------------------------------------------------------------------- 
// Internal parameters.
// 

//
// Number of clock cycles per uart bit.
localparam       CYCLES_PER_BIT     = BIT_P / CLK_P;

//
// Size of the registers which store sample counts and bit durations.
localparam       COUNT_REG_LEN      = 1+$clog2(CYCLES_PER_BIT);

// -------------------------------------------------------------------------- 
// Internal registers.
// 

//
// Internally latched value of the uart_rxd line. Helps break long timing
// paths from input pins into the logic.
logic rxd_reg;
logic rxd_reg_0;

//
// Storage for the recieved serial data.
logic [PAYLOAD_BITS-1:0] recieved_data;

//
// Counter for the number of cycles over a packet bit.
logic [COUNT_REG_LEN-1:0] cycle_counter;

//
// Counter for the number of recieved bits of the packet.
logic [3:0] bit_counter;

//
// Sample of the UART input line whenever we are in the middle of a bit frame.
logic bit_sample;

//
// Current and next states of the internal FSM.
logic [2:0] fsm_state;
logic [2:0] n_fsm_state;

localparam FSM_IDLE = 0;
localparam FSM_START= 1;
localparam FSM_RECV = 2;
localparam FSM_STOP = 3;

// --------------------------------------------------------------------------- 
// Output assignment
// 

assign uart_rx_break = (uart_rx_valid && ~|recieved_data);
assign uart_rx_valid = ((fsm_state == FSM_STOP) && (n_fsm_state == FSM_IDLE));

always_ff @(posedge clk) begin
    if(!resetn) begin
        uart_rx_data  <= {PAYLOAD_BITS{1'b0}};
    end else if (fsm_state == FSM_STOP) begin
        uart_rx_data  <= recieved_data;
    end
end

// --------------------------------------------------------------------------- 
// FSM next state selection.
// 

logic next_bit     = ((cycle_counter == CYCLES_PER_BIT) ||
                    (fsm_state       == FSM_STOP) && 
                    (cycle_counter   == CYCLES_PER_BIT/2));
logic payload_done = (bit_counter   == PAYLOAD_BITS)  ;

//
// Handle picking the next state.
always_comb begin : p_n_fsm_state
    case(fsm_state)
        FSM_IDLE : n_fsm_state = rxd_logic    ? FSM_IDLE : FSM_START;
        FSM_START: n_fsm_state = next_bit     ? FSM_RECV : FSM_START;
        FSM_RECV : n_fsm_state = payload_done ? FSM_STOP : FSM_RECV ;
        FSM_STOP : n_fsm_state = next_bit     ? FSM_IDLE : FSM_STOP ;
        default  : n_fsm_state = FSM_IDLE;
    endcase
end

// --------------------------------------------------------------------------- 
// Internal register setting and re-setting.
// 

//
// Handle updates to the recieved data register.
int i = 0;
always_ff @(posedge clk) begin : p_recieved_data
    if(!resetn) begin
        recieved_data <= {PAYLOAD_BITS{1'b0}};
    end else if(fsm_state == FSM_IDLE             ) begin
        recieved_data <= {PAYLOAD_BITS{1'b0}};
    end else if(fsm_state == FSM_RECV && next_bit ) begin
        recieved_data[PAYLOAD_BITS-1] <= bit_sample;
        for ( i = PAYLOAD_BITS-2; i >= 0; i = i - 1) begin
            recieved_data[i] <= recieved_data[i+1];
        end
    end
end

//
// Increments the bit counter when recieving.
always_ff @(posedge clk) begin : p_bit_counter
    if(!resetn) begin
        bit_counter <= 4'b0;
    end else if(fsm_state != FSM_RECV) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == FSM_RECV && next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end
end

//
// Sample the recieved bit when in the middle of a bit frame.
always_ff @(posedge clk) begin : p_bit_sample
    if(!resetn) begin
        bit_sample <= 1'b0;
    end else if (cycle_counter == CYCLES_PER_BIT/2) begin
        bit_sample <= rxd_reg;
    end
end


//
// Increments the cycle counter when recieving.
always_ff @(posedge clk) begin : p_cycle_counter
    if(!resetn) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(next_bit) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == FSM_START || 
                fsm_state == FSM_RECV  || 
                fsm_state == FSM_STOP   ) begin
        cycle_counter <= cycle_counter + 1'b1;
    end
end


//
// Progresses the next FSM state.
always_ff @(posedge clk) begin : p_fsm_state
    if(!resetn) begin
        fsm_state <= FSM_IDLE;
    end else begin
        fsm_state <= n_fsm_state;
    end
end


//
// Responsible for updating the internal value of the rxd_reg.
always_ff @(posedge clk) begin : p_rxd_reg
    if(!resetn) begin
        rxd_logic   <= 1'b1;
        rxd_reg_0   <= 1'b1;
    end else if(uart_rx_en) begin
        rxd_logic   <= rxd_reg_0;
        rxd_reg_0   <= uart_rxd;
    end
end


endmodule
