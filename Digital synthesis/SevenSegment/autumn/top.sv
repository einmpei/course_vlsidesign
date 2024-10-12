`include "global_settings.vh"
`include "cnt_iclk.v"
`include "autumn.v"
`include "shifter.v"

module top(clk, nrst, cathodes, anodes);

input clk;
input nrst;

output [7:0] cathodes;
output [7:0] anodes;

wire iclk;

`ifdef SHIFTER
wire [1:0] shift;
`elsif BARREL_SHIFTER
wire [2:0] shift;
`endif

autumn   U1( .clk      ( iclk     ),
             .shift    ( shift    ),
             .nrst     ( nrst     ),
             .cathodes ( cathodes ),
             .anodes   ( anodes   ),
           );
				
cnt_iclk U2( .clk      ( clk      ),
             .nrst     ( nrst     ),
             .iclk     ( iclk     ),
		   );
			  
shifter  U3( .clk      ( clk      ),
             .nrst     ( nrst     ),
             .shift    ( shift    ),
           );

endmodule
