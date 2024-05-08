#------------Предварительная настройка дизайна------------#
set FILE_NAME genus_invs_des/genus.v
set TOP_CELL top
set DIR_DEST innovus
#set CORE_SIZE 20
#set CORE_MARGIN_IO 30
set CORE_RATIO 1.0
set CORE_UTIL 0.7

#Инициализация файла Verilog-описания схемы
set init_verilog $FILE_NAME
#Инициализация ячейки верхнего уровня
set init_top_cell $TOP_CELL
#Инициализация файла входов/выходов
set init_io_file top.save.io
#Инициализация пути к mmmc-файлу
set init_mmmc_file genus_invs_des/genus.mmode.tcl
#Инициализация пути к lef-файлам
set init_lef_file {\
../lib/lef/gsclib045_tech.lef \
../lib/lef/gsclib045_macro.lef \
../lib/lef/giolib045.lef}
#Инициализация проводов питания
set init_pwr_net {VDDO VDDC}
set init_gnd_net {VSSO VSSC}

#------------Инициализация дизайна------------#
#Инициализация проекта
init_design

#Высота/Ширина Использование_ядра Расстояние_до_границы_ядра_4_шт
floorPlan -site CoreSite -r $CORE_RATIO $CORE_UTIL $CORE_MARGIN_IO $CORE_MARGIN_IO $CORE_MARIO_IO $CORE_MARGIN_IO
setFlipping -s
planDesign

#Ширина Высота Расстояния_до_границы_ядра_4_шт
#floorPlan -site CoreSite -s $CORE_SIZE $CORE_SIZE $CORE_MARGIN_IO $CORE_MARGIN_IO $CORE_MARGIN_IO $CORE_MARGIN_IO

#Добавление филлеров к контактным площадкам (west, north, south, east)
addIoFiller -cell padIORINGFEED10 -prefix FILLER -side w
addIoFiller -cell padIORINGFEED10 -prefix FILLER -side s
addIoFiller -cell padIORINGFEED1 -prefix FILLER -side w
addIoFiller -cell padIORINGFEED1 -prefix FILLER -side s

#Подключение глобальных сигналов питания к соответствующим пинам
clearGlobalNets
globalNetConnect VDDC -type pgpin -pin VDD -instanceBaseName *
globalNetConnect VSSC -type pgpin -pin VSS -instanceBaseName *
globalNetConnect VDDO -type pgpin -pin VDDIOR -instanceBaseName *
globalNetConnect VSSO -type pgpin -pin VSSIOR -instanceBaseName *

#Добавление колец питания вокруг ядра
addRing -nets {VDDC VSSC} -type core_rings -follow io -layer {top Metal3 bottom Metal3 left Metal2 right Metal2} -width 8 -spacing 1.5 -center 1
addStripe -nets {VDDC VSSC} -direction vertical -layer Metal2 -width 4 -spacing
2 -set_to_set_distance 30

#Добавление рельс питания к стандартным ячейкам
setSrouteMode -viaConnectToShape {noshape}
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { Metal1 Metal11 } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { Metal1 Metal11 } -nets { VDDC VSSC } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { Metal1 Metal11 }

#Размещение стандартных ячеек с игнорированием скановых цепей
setPlaceMode -fp false
setPlaceMode -place_global_exp_allow_missing_scan_chain true
setPlaceMode -place_global_place_io_pins true
place_design

#Создание клокового дерева
setDelayCalMode -siAware false
timeDesign -preCTS
report_timing > $DIR_DEST/$TOP_CELL/${TOP_CELL}_timing_pre.rpt
optDesign -preCTS
create_ccopt_clock_tree_spec
get_ccopt_clock_trees *
ccopt_design -cts
timeDesign -postCTS
report_timing > $DIR_DEST/$TOP_CELL/${TOP_CELL}_timing_post.rpt
optDesign -postCTS

#Оптимизация разводки
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail
timeDesign -postRoute
optDesign -postRoute

#Добавление филлеров в ядро
setFillerMode -core {FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1}
addFiller -markFixed

#Формирование отчётов
report_power > $DIR_DEST/$TOP_CELL/${TOP_CELL}_power.rpt
report_area  > $DIR_DEST/$TOP_CELL/${TOP_CELL}_area.rpt

#Экспорт DEF-файла
set dbgLefDefOutVersion 5.8
global dbgLefDefOutVersion
defOut -floorplan -netlist -routing top.def

#Экспорт GDSII файла
streamOut $DIR_DEST/$TOP_CELL/$TOP_CELL.gds2

#Экспорт LEF-файла
write_lef_abstract $DIR_DEST/$TOP_CELL/$TOP_CELL.lef

#Экспорт списка соедиений в формате Verilog
saveNetlist -includePowerGround -excludeLeafCell $DIR_DEST/$TOP_CELL/${TOP_CELL}_netlist.v

#Сохранение дизайна
saveDesign $DIR_DEST/$TOP_CELL/$TOP_CELL.enc

exit
