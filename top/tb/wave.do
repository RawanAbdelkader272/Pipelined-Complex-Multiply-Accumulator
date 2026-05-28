onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench}
add wave -noupdate /acc_top_tb/clk
add wave -noupdate /acc_top_tb/rst_n
add wave -noupdate /acc_top_tb/go
add wave -noupdate -radix decimal /acc_top_tb/sum_out
add wave -noupdate /acc_top_tb/result_vld
add wave -noupdate -divider {DUT (acc_top)}
add wave -noupdate /acc_top_tb/u_dut/iv
add wave -noupdate -radix unsigned /acc_top_tb/u_dut/rom_ptr
add wave -noupdate /acc_top_tb/u_dut/mul_din_vld
add wave -noupdate /acc_top_tb/u_dut/mul_dout_vld
add wave -noupdate -radix unsigned /acc_top_tb/u_dut/wr_cnt
add wave -noupdate -radix unsigned /acc_top_tb/u_dut/wr_addr
add wave -noupdate /acc_top_tb/u_dut/wr_en_r
add wave -noupdate /acc_top_tb/u_dut/wr_done
add wave -noupdate -radix unsigned /acc_top_tb/u_dut/rd_addr
add wave -noupdate /acc_top_tb/u_dut/rd_en
add wave -noupdate -radix decimal /acc_top_tb/u_dut/ram_dout
add wave -noupdate -radix decimal /acc_top_tb/u_dut/sum_out
add wave -noupdate /acc_top_tb/u_dut/result_vld
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1095 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 400
configure wave -valuecolwidth 200
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update