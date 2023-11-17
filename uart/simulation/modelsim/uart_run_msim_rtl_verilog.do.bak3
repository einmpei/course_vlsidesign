transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/abarinov/MyProject/ASIC/uart/rtl {/home/abarinov/MyProject/ASIC/uart/rtl/uart_rx.sv}

vlog -sv -work work +incdir+/home/abarinov/MyProject/ASIC/uart/test {/home/abarinov/MyProject/ASIC/uart/test/tb_rx.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run -all
