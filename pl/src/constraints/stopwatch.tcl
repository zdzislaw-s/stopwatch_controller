# Clock
set_property PACKAGE_PIN Y9 [get_ports clk_0]
    set_property IOSTANDARD LVCMOS33 [get_ports clk_0]
    create_clock -period 10 [get_ports clk_0]
    #set_false_path -from [get_pins -hierarchical "*slv_reg0_reg[*]/C"] -to [get_pins -hierarchical "*ssd_segs_reg[*]/D"]
    set_max_delay -datapath_only -from [get_clocks clk_0] -to [get_ports "ssd_segs_0[*]"] 6.0
    set_max_delay -from [get_ports {btn_0[*]}] 2.500
    set_max_delay -from [get_ports {switch_0[*]}] 2.500
    set_max_delay -from [get_ports enc_a_0] 2.500
    set_max_delay -from [get_ports enc_b_0] 2.500
    set_max_delay -from [get_ports enc_btn_0] 2.500
    set_max_delay -from [get_ports enc_sw_0] 2.500

# LEDs
set pins "T22 T21 U22 U21 V22 W22 U19 U14"
for {set i 0} {$i < [llength $pins]} {incr i} {
    set_property PACKAGE_PIN [lindex $pins $i] [get_ports "led_0[$i]"]
}
    set_property IOSTANDARD LVCMOS33 [get_ports led_0]

# DIP switches
set pins "F22 G22 H22 F21 H19 H18 H17 M15"
for {set i 0} {$i < [llength $pins]} {incr i} {
    set_property PACKAGE_PIN [lindex $pins $i] [get_ports "switch_0[$i]"]
}
    set_property IOSTANDARD LVCMOS25 [get_ports switch_0]

# PmodSSD
# JA1->AA, JA2->AB, JA3->AC, JA4->AD, JB1->AE, JB2->AF, JB3->AG
set pins "V10 W11 W12 AA9 Y10 AA11 Y11"
for {set i 0} {$i < [llength $pins]} {incr i} {
    set_property PACKAGE_PIN [lindex $pins $i] [get_ports "ssd_segs_0[$i]"]
}
    set_property IOSTANDARD LVCMOS33 [get_ports ssd_segs_0]
# JB4->CAT
set_property PACKAGE_PIN W8 [get_ports ssd_dsp_0]
    set_property IOSTANDARD LVCMOS33 [get_ports ssd_dsp_0]

# Push buttons
set pins "N15 T18 R18 R16 P16"
for {set i 0} {$i < [llength $pins]} {incr i} {
    set_property PACKAGE_PIN [lindex $pins $i] [get_ports "btn_0[$i]"]
}
    set_property IOSTANDARD LVCMOS25 [get_ports btn_0]

# PmodENC
set_property PACKAGE_PIN AB7 [get_ports enc_a_0]
    set_property IOSTANDARD LVCMOS33 [get_ports enc_a_0]
set_property PACKAGE_PIN AB6 [get_ports enc_b_0]
    set_property IOSTANDARD LVCMOS33 [get_ports enc_b_0]
set_property PACKAGE_PIN Y4 [get_ports enc_btn_0]
    set_property IOSTANDARD LVCMOS33 [get_ports enc_btn_0]
set_property PACKAGE_PIN AA4 [get_ports enc_sw_0]
    set_property IOSTANDARD LVCMOS33 [get_ports enc_sw_0]
