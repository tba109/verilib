onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/UUT_0/clk
add wave -noupdate -radix hexadecimal /tb/UUT_0/rst
add wave -noupdate -divider Controls
add wave -noupdate -radix hexadecimal /tb/UUT_0/period
add wave -noupdate -radix hexadecimal /tb/UUT_0/deadtime
add wave -noupdate -divider Inputs
add wave -noupdate -color Purple -radix hexadecimal /tb/UUT_0/a_0
add wave -noupdate -color Purple -radix hexadecimal /tb/UUT_0/a_1
add wave -noupdate -color Purple -radix hexadecimal /tb/UUT_0/a_2
add wave -noupdate -color Purple -radix hexadecimal /tb/UUT_0/a_3
add wave -noupdate -divider Status
add wave -noupdate -color Orange -radix hexadecimal /tb/UUT_0/valid
add wave -noupdate -color Orange -radix hexadecimal /tb/UUT_0/update
add wave -noupdate -color Orange -radix hexadecimal /tb/UUT_0/dead
add wave -noupdate -divider Outputs
add wave -noupdate -radix hexadecimal /tb/UUT_0/cnt
add wave -noupdate -divider Internals
add wave -noupdate -color Firebrick -radix hexadecimal /tb/UUT_0/i_pe_0
add wave -noupdate -color Firebrick -radix hexadecimal /tb/UUT_0/i_inh_0
add wave -noupdate -color Firebrick -radix hexadecimal /tb/UUT_0/i_n_pe_0
add wave -noupdate -color Cyan -radix hexadecimal /tb/UUT_0/i_pe_1
add wave -noupdate -color Cyan -radix hexadecimal /tb/UUT_0/i_inh_1
add wave -noupdate -color Cyan -radix hexadecimal /tb/UUT_0/i_n_pe_1
add wave -noupdate -color Magenta -radix hexadecimal /tb/UUT_0/i_pe_2
add wave -noupdate -color Magenta -radix hexadecimal /tb/UUT_0/i_inh_2
add wave -noupdate -color Magenta -radix hexadecimal /tb/UUT_0/i_n_pe_2
add wave -noupdate -color Gold -radix hexadecimal /tb/UUT_0/i_pe_3
add wave -noupdate -color Gold -radix hexadecimal /tb/UUT_0/i_inh_3
add wave -noupdate -color Gold -radix hexadecimal /tb/UUT_0/i_n_pe_3
add wave -noupdate -radix hexadecimal /tb/UUT_0/i_deadtime_cnd
add wave -noupdate -radix hexadecimal /tb/UUT_0/i_dead
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2200 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 188
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {4224 ns}
