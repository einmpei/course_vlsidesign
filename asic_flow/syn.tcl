#Указание выходной директории
set OUTPUT_DIR ./outputs
#Задание имени модуля верхнего уровня
set $DESIGN top
#Указание папки, в которой лежат lib- и lef-файлы
set $LIBRARY_LOCATION ../library
#Установка пути к библиотекам
set_attribute init_lib_search_path $LIBRARY_LOCATION

#Поиск lib-файлов
set LIBRARY_FILE_NAMES [glob -directory $LIBRARY_LOCATION *.lib]
set_attribute library $LIBRARY_FILE_NAMES

#Поиск lef-файлов
set LEF_FILE_NAMES [glob -directory $LIBRARY_LOCATION *.lef]
set_attribute lef_library $LEF_FILE_NAMES

puts "\n\n\n Загрузка RTL-описания \n\n\n"
read_hdl $DESIGN.sv

puts "\n\n\n Подготовка дизайна \n\n\n"
elaborate

puts "\n\n\n Синтез на Verilog-примитивах \n\n\n"
syn_generic
write_hdl -generic > $OUTPUT_DIR/netlists/$DESIGN_generic.v

puts "\n\n\n Синтез на целевой библиотеке \n\n\n"
syn_map
write_hdl > $OUTPUT_DIR/netlists/$DESIGN_mapped.v

puts "\n\n\n Оптимизация синтеза на целевой библиотеке \n\n\n"
syn_opt
write_hdl > $OUTPUT_DIR/netlists/$DESIGN_mapped_opt.v

puts "\n\n\n Экспорт SDC и SDF \n\n\n"
write_sdc > $OUTPUT_DIR/$DESIGN.sdc
write_sdf -version 2.1 > $OUTPUT_DIR/$DESIGN.sdf

puts "\n\n\n Запись отчётов \n\n\n"
report qor > $OUTPUT_DIR/reports/qor_$DESIGN.rpt
report area > $OUTPUT_DIR/reports/area_$DESIGN.rpt
report messages > $OUTPUT_DIR/reports/messges_$DESIGN.rpt
report gates > $OUTPUT_DIR/reports/gates_$DESIGN.rpt
report timing > $OUTPUT_DIR/reports/timing_$DESIGN.rpt
report power > $OUTPUT_DIR/reports/power_$DESIGN.rpt

puts "\n\n\n Запись результатов для Innovus \n\n\n"
write_design -innovus -base_name $OUTPUT_DIR/innovus

puts "The RUNTIME is [get_attribute real_runtime /]"
puts "The MEMORY USAGE is [get_attribute memory_usage /]"

exit
