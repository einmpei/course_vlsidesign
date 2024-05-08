set PERIOD 20
create_clock -name "clk" -period $PERIOD -waveform {0 $PERIOD/2} [get_ports clk]
