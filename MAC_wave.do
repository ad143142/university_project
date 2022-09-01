onerror {resume}
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/ifmaps_reg_00, /tb_MAC/u_MAC/ifmaps_reg_01, /tb_MAC/u_MAC/ifmaps_reg_02, /tb_MAC/u_MAC/ifmaps_reg_03, /tb_MAC/u_MAC/ifmaps_reg_04, /tb_MAC/u_MAC/ifmaps_reg_10 }} ifmaps_reg_row0
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/ifmaps_reg_10, /tb_MAC/u_MAC/ifmaps_reg_11, /tb_MAC/u_MAC/ifmaps_reg_12, /tb_MAC/u_MAC/ifmaps_reg_13, /tb_MAC/u_MAC/ifmaps_reg_14 }} ifmaps_reg_row1
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/ifmaps_reg_20, /tb_MAC/u_MAC/ifmaps_reg_21, /tb_MAC/u_MAC/ifmaps_reg_22, /tb_MAC/u_MAC/ifmaps_reg_23, /tb_MAC/u_MAC/ifmaps_reg_24 }} ifmaps_reg_row2
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/ifmaps_reg_30, /tb_MAC/u_MAC/ifmaps_reg_31, /tb_MAC/u_MAC/ifmaps_reg_32, /tb_MAC/u_MAC/ifmaps_reg_33, /tb_MAC/u_MAC/ifmaps_reg_34 }} ifmaps_reg_row3
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/ifmaps_reg_40, /tb_MAC/u_MAC/ifmaps_reg_41, /tb_MAC/u_MAC/ifmaps_reg_42, /tb_MAC/u_MAC/ifmaps_reg_43, /tb_MAC/u_MAC/ifmaps_reg_44 }} ifmaps_reg_row4
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/weight_reg_00, /tb_MAC/u_MAC/weight_reg_01, /tb_MAC/u_MAC/weight_reg_02, /tb_MAC/u_MAC/weight_reg_03, /tb_MAC/u_MAC/weight_reg_04 }} weight_reg_row_0
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/weight_reg_10, /tb_MAC/u_MAC/weight_reg_11, /tb_MAC/u_MAC/weight_reg_12, /tb_MAC/u_MAC/weight_reg_13, /tb_MAC/u_MAC/weight_reg_14 }} weight_reg_row_1
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/weight_reg_20, /tb_MAC/u_MAC/weight_reg_21, /tb_MAC/u_MAC/weight_reg_22, /tb_MAC/u_MAC/weight_reg_23, /tb_MAC/u_MAC/weight_reg_24 }} weight_reg_row_2
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/weight_reg_30, /tb_MAC/u_MAC/weight_reg_31, /tb_MAC/u_MAC/weight_reg_32, /tb_MAC/u_MAC/weight_reg_33, /tb_MAC/u_MAC/weight_reg_34 }} weight_reg_row_3
quietly virtual function -install /tb_MAC/u_MAC -env /tb_MAC/#INITIAL#32 { &{/tb_MAC/u_MAC/weight_reg_40, /tb_MAC/u_MAC/weight_reg_41, /tb_MAC/u_MAC/weight_reg_42, /tb_MAC/u_MAC/weight_reg_43, /tb_MAC/u_MAC/weight_reg_44 }} weight_reg_row_4
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_MAC/u_MAC/clk
add wave -noupdate /tb_MAC/u_MAC/rst_n
add wave -noupdate /tb_MAC/u_MAC/ifmaps_row0_in
add wave -noupdate /tb_MAC/u_MAC/ifmaps_row1_in
add wave -noupdate /tb_MAC/u_MAC/ifmaps_row2_in
add wave -noupdate /tb_MAC/u_MAC/ifmaps_row3_in
add wave -noupdate /tb_MAC/u_MAC/ifmaps_row4_in
add wave -noupdate /tb_MAC/u_MAC/weight_in
add wave -noupdate /tb_MAC/u_MAC/load_ifmaps
add wave -noupdate /tb_MAC/u_MAC/load_weight
add wave -noupdate /tb_MAC/u_MAC/operation
add wave -noupdate /tb_MAC/u_MAC/kernel_size
add wave -noupdate /tb_MAC/u_MAC/idx
add wave -noupdate /tb_MAC/u_MAC/ifmaps_reg_row0
add wave -noupdate /tb_MAC/u_MAC/ifmaps_reg_row1
add wave -noupdate /tb_MAC/u_MAC/ifmaps_reg_row2
add wave -noupdate /tb_MAC/u_MAC/ifmaps_reg_row3
add wave -noupdate /tb_MAC/u_MAC/ifmaps_reg_row4
add wave -noupdate /tb_MAC/u_MAC/weight_reg_row_0
add wave -noupdate /tb_MAC/u_MAC/weight_reg_row_1
add wave -noupdate /tb_MAC/u_MAC/weight_reg_row_2
add wave -noupdate /tb_MAC/u_MAC/weight_reg_row_3
add wave -noupdate /tb_MAC/u_MAC/weight_reg_row_4
add wave -noupdate -color Yellow -radix unsigned /tb_MAC/u_MAC/MAC_out
add wave -noupdate /tb_MAC/u_MAC/xnor_op
add wave -noupdate /tb_MAC/u_MAC/bitcount
add wave -noupdate /tb_MAC/u_MAC/kenel_2
add wave -noupdate /tb_MAC/u_MAC/kenel_3
add wave -noupdate /tb_MAC/u_MAC/kenel_4
add wave -noupdate /tb_MAC/u_MAC/kenel_5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {303054 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 251
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
WaveRestoreZoom {0 ps} {476714 ps}
