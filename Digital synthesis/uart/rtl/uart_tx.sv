// origin from https://github.com/ben-marshall/uart/
// Module: uart_tx 
// 
// Notes:
// - UART transmitter module.
//

module uart_tx (
input  logic         clk         , // Top level system clock input.
input  logic         resetn      , // Asynchronous active low reset.
output logic         uart_txd    , // UART transmit pin.
output logic         uart_tx_busy, // Module busy sending previous item.
input  logic         uart_tx_en  , // Send the data on uart_tx_data
input  logic [PAYLOAD_BITS-1:0]   uart_tx_data  // The data to be sent
);

// --------------------------------------------------------------------------- 
// External parameters
// ---------------------------------------------------------------------------

// Input bit rate of the UART line
parameter BIT_RATE = 9600; // bit per second
localparam  BIT_P           = 1_000_000_000 * 1/BIT_RATE; // nanoseconds

// Clock frequency
parameter CLK_HZ = 50_000_000; // Hz
localparam  CLK_P           = 1_000_000_000 * 1/CLK_HZ; // period in nanoseconds

// Number of data bits recieved per UART packet.
parameter PAYLOAD_BITS    = 8;

// Number of stop bits indicating the end of a packet.
parameter STOP_BITS       = 1;

// --------------------------------------------------------------------------- 
// Internal parameters
// ---------------------------------------------------------------------------

// Number of clock cycles per uart bit
localparam       CYCLES_PER_BIT     = BIT_P / CLK_P;

// Size of the registers which store sample counts and bit durations
localparam       COUNT_REG_LEN      = 1+$clog2(CYCLES_PER_BIT);

// --------------------------------------------------------------------------- 
// Internal registers
// ---------------------------------------------------------------------------

// Internally latched value of the uart_txd line. Helps break long timing
// paths from the logic to the output pins
logic txd_reg;

// Storage for the serial data to be sent
logic [PAYLOAD_BITS-1:0] data_to_send;

// Counter for the number of cycles over a packet bit
logic [COUNT_REG_LEN-1:0] cycle_counter;

// Counter for the number of sent bits of the packet
logic [COUNT_REG_LEN-1:0] bit_counter;

// Current and next states of the internal FSM
typedef enum logic [1:0] {FSM_IDLE = 2'b00, FSM_START, FSM_SEND, FSM_STOP} state_t;
state_t fsm_state, n_fsm_state;


// --------------------------------------------------------------------------- 
// FSM next state selection
// --------------------------------------------------------------------------- 

assign uart_tx_busy = (fsm_state != FSM_IDLE);
assign uart_txd     = txd_reg;

logic next_bit;
logic payload_done;
logic stop_done;

assign next_bit     = (cycle_counter == CYCLES_PER_BIT);
assign payload_done = (bit_counter   == PAYLOAD_BITS)  ;
assign stop_done    = ((bit_counter   == STOP_BITS) && (fsm_state == FSM_STOP));

// Handle picking the next state
always_comb begin
    case(fsm_state)
        FSM_IDLE : n_fsm_state = (uart_tx_en   ? FSM_START: FSM_IDLE );
        FSM_START: n_fsm_state = (next_bit     ? FSM_SEND : FSM_START);
        FSM_SEND : n_fsm_state = (payload_done ? FSM_STOP : FSM_SEND );
        FSM_STOP : n_fsm_state = (stop_done    ? FSM_IDLE : FSM_STOP );
        default  : n_fsm_state = FSM_IDLE;
    endcase
end

// --------------------------------------------------------------------------- 
// Internal register setting and re-setting
// --------------------------------------------------------------------------- 

// Handle updates to the sent data register.
always_ff @(posedge clk) begin : p_data_to_send
    if(!resetn) begin
        data_to_send <= {PAYLOAD_BITS{1'b0}};
    end else if(fsm_state == FSM_IDLE && uart_tx_en) begin
        data_to_send <= uart_tx_data;
    end else if(fsm_state       == FSM_SEND && next_bit ) begin
        data_to_send <= data_to_send >> 1;
    end
end

// Increments the bit counter each time a new bit frame is sent
always_ff @(posedge clk) begin : p_bit_counter
    if(!resetn) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if((fsm_state != FSM_SEND) && (fsm_state != FSM_STOP)) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if((fsm_state == FSM_SEND) && (n_fsm_state == FSM_STOP)) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if((fsm_state == FSM_STOP) && next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end else if((fsm_state == FSM_SEND) && next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end
end

// Increments the cycle counter when sending
always_ff @(posedge clk) begin : p_cycle_counter
    if(!resetn) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(next_bit) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if((fsm_state == FSM_START) || 
                (fsm_state == FSM_SEND)  || 
                (fsm_state == FSM_STOP)   ) begin
        cycle_counter <= cycle_counter + 1'b1;
    end
end

// Progresses the next FSM state
always_ff @(posedge clk) begin : p_fsm_state
    if(!resetn) begin
        fsm_state <= FSM_IDLE;
    end else begin
        fsm_state <= n_fsm_state;
    end
end

// Responsible for updating the internal value of the txd_reg
always_ff @(posedge clk) begin : p_txd_reg
    if(!resetn) begin
        txd_reg <= 1'b1;
    end else if(fsm_state == FSM_IDLE) begin
        txd_reg <= 1'b1;
    end else if(fsm_state == FSM_START) begin
        txd_reg <= 1'b0;
    end else if(fsm_state == FSM_SEND) begin
        txd_reg <= data_to_send[0];
    end else if(fsm_state == FSM_STOP) begin
        txd_reg <= 1'b1;
    end
end

endmodule
