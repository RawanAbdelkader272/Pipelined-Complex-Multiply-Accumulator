vlib work
vmap work work
vlog -sv ../rtl/spram.v
vlog -sv ../rtl/coeff_rom.v
vlog -sv ../rtl/cplx_mult.v
vlog -sv ../rtl/acc_top.v
vlog -sv acc_top_tb.v
vsim -voptargs=+acc work.acc_top_tb
do wave.do
run -all