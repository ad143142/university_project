onerror {resume}
quietly virtual signal -install /tb_MAC/u1_MAC { (context /tb_MAC/u1_MAC )&{ifmaps_fifo_row0_in , ifmaps_fifo_row1_in , ifmaps_fifo_row2_in , ifmaps_fifo_row3_in , ifmaps_fifo_row4_in }} ifmaps_fifo_in
quietly virtual signal -install /tb_MAC/u1_MAC { (context /tb_MAC/u1_MAC )&{ifmaps_fifo_row0_out , ifmaps_fifo_row1_out , ifmaps_fifo_row2_out , ifmaps_fifo_row3_out , ifmaps_fifo_row4_out }} ifmaps_fifo_out
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/ifmaps_reg_00, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_01, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_02, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_03, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_04 }} ifmaps_reg_row0
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/ifmaps_reg_10, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_11, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_12, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_13, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_14 }} ifmaps_reg_row1
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/ifmaps_reg_20, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_21, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_22, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_23, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_24 }} ifmaps_reg_row2
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/ifmaps_reg_30, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_31, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_32, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_33, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_34 }} ifmaps_reg_row3
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/ifmaps_reg_40, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_41, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_42, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_43, /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_44 }} ifmaps_reg_row4
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/weight_reg_00, /tb_MAC/u1_MAC/u_ALU/weight_reg_01, /tb_MAC/u1_MAC/u_ALU/weight_reg_02, /tb_MAC/u1_MAC/u_ALU/weight_reg_03, /tb_MAC/u1_MAC/u_ALU/weight_reg_04 }} weight_reg_row0
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/weight_reg_10, /tb_MAC/u1_MAC/u_ALU/weight_reg_11, /tb_MAC/u1_MAC/u_ALU/weight_reg_12, /tb_MAC/u1_MAC/u_ALU/weight_reg_13, /tb_MAC/u1_MAC/u_ALU/weight_reg_14 }} weight_reg_row1
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/weight_reg_20, /tb_MAC/u1_MAC/u_ALU/weight_reg_21, /tb_MAC/u1_MAC/u_ALU/weight_reg_22, /tb_MAC/u1_MAC/u_ALU/weight_reg_23, /tb_MAC/u1_MAC/u_ALU/weight_reg_24 }} weight_reg_row2
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/weight_reg_30, /tb_MAC/u1_MAC/u_ALU/weight_reg_31, /tb_MAC/u1_MAC/u_ALU/weight_reg_32, /tb_MAC/u1_MAC/u_ALU/weight_reg_33, /tb_MAC/u1_MAC/u_ALU/weight_reg_34 }} weight_reg_row3
quietly virtual function -install /tb_MAC/u1_MAC/u_ALU -env /tb_MAC/u1_MAC/u_ALU { &{/tb_MAC/u1_MAC/u_ALU/weight_reg_40, /tb_MAC/u1_MAC/u_ALU/weight_reg_41, /tb_MAC/u1_MAC/u_ALU/weight_reg_42, /tb_MAC/u1_MAC/u_ALU/weight_reg_43, /tb_MAC/u1_MAC/u_ALU/weight_reg_44 }} weight_reg_row4
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_MAC/u1_MAC/clk
add wave -noupdate /tb_MAC/u1_MAC/rst_n
add wave -noupdate /tb_MAC/u1_MAC/ifmaps_input_valid
add wave -noupdate /tb_MAC/u1_MAC/weight_in
add wave -noupdate /tb_MAC/u1_MAC/load_ifmaps
add wave -noupdate /tb_MAC/u1_MAC/load_ifmaps_buf_1t
add wave -noupdate /tb_MAC/u1_MAC/load_weight
add wave -noupdate /tb_MAC/u1_MAC/operation
add wave -noupdate /tb_MAC/u1_MAC/kernel_size
add wave -noupdate /tb_MAC/u1_MAC/fifo_full
add wave -noupdate /tb_MAC/u1_MAC/fifo_empty
add wave -noupdate /tb_MAC/u1_MAC/u_MAC_ifmaps_FIFO/ifmaps_fifo_row0
add wave -noupdate /tb_MAC/u1_MAC/u_MAC_ifmaps_FIFO/ifmaps_fifo_row1
add wave -noupdate /tb_MAC/u1_MAC/u_MAC_ifmaps_FIFO/ifmaps_fifo_row2
add wave -noupdate /tb_MAC/u1_MAC/u_MAC_ifmaps_FIFO/ifmaps_fifo_row3
add wave -noupdate /tb_MAC/u1_MAC/u_MAC_ifmaps_FIFO/ifmaps_fifo_row4
add wave -noupdate /tb_MAC/u1_MAC/ifmaps_fifo_in
add wave -noupdate /tb_MAC/u1_MAC/ifmaps_fifo_out
add wave -noupdate -color Yellow -radix unsigned /tb_MAC/u1_MAC/MAC_out
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_row0
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_row1
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_row2
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_row3
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/ifmaps_reg_row4
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/weight_reg_row0
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/weight_reg_row1
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/weight_reg_row2
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/weight_reg_row3
add wave -noupdate /tb_MAC/u1_MAC/u_ALU/weight_reg_row4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {646026 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 324
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1214344 ps}
