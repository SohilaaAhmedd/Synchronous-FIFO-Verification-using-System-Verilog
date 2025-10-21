vlib work
vlog -f src_files.list +define+SIM +cover -covercells
vsim -voptargs=+acc top -cover
run 0
add wave -position insertpoint sim:/top/fif/*
add wave -position insertpoint sim:/top/DUT/*
add wave -position insertpoint sim:/top/DUT/mem
add wave -position insertpoint sim:/top/MONITOR/sb/test_queue
coverage save top.ucdb -onexit
run -all
