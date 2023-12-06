## Для использования в проекте:
## - раскоммаентировать строки, связанные с назначением пинов (заточено под макетную плату EP4CE6E22C8N)
## - переименовать используемые порты (в каждой строке после команды get_ports)
##   в соответствии с названиями сигналов верхнего уровня в проекте


# Сигнал клока
# Использование опции -dict позволяет в одной строке записать значение нескольких параметров
# по аналогии со словарём Python: ключ - значение
#set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports {clk}]

# Входные пины с dip-переключателей
#set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS33} [get_ports {sw_0}]
#set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {sw_1}]

# Входные пины для приёмника и передатчика
#set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports {uart_txd}]
#set_property -dict {PACKAGE_PIN A9  IOSTANDARD LVCMOS33} [get_ports {uart_rxd}]

# Выходные пины на светодиоды
#set_property -dict { PACKAGE_PIN E1  IOSTANDARD LVCMOS33 } [get_ports {led[0]}]; # LD0
#set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS33 } [get_ports {led[1]}]; # LD1
#set_property -dict { PACKAGE_PIN H4  IOSTANDARD LVCMOS33 } [get_ports {led[2]}]; # LD2
#set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]; # LD3
#set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports {led[4]}]; # LD4
#set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports {led[5]}]; # LD5
#set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports {led[6]}]; # LD6
#set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {led[7]}]; # LD7
