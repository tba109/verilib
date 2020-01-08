onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider System
add wave -noupdate -radix unsigned /tb/WC_0/clk
add wave -noupdate -radix unsigned /tb/WC_0/rst
add wave -noupdate -color Magenta -radix unsigned /tb/WC_0/a
add wave -noupdate -divider Controls
add wave -noupdate -color Magenta -radix unsigned /tb/WC_0/inh_pedge
add wave -noupdate -color Magenta -radix unsigned /tb/WC_0/inh_nedge
add wave -noupdate -color Magenta -radix unsigned /tb/WC_0/inh_high
add wave -noupdate -color Magenta -radix unsigned /tb/WC_0/inh_low
add wave -noupdate -color Magenta -radix unsigned /tb/WC_0/period
add wave -noupdate -divider Internals
add wave -noupdate -radix unsigned /tb/WC_0/i_n_pedge
add wave -noupdate -radix unsigned /tb/WC_0/i_n_nedge
add wave -noupdate -radix unsigned /tb/WC_0/i_n_high
add wave -noupdate -radix unsigned /tb/WC_0/i_n_low
add wave -noupdate -radix unsigned /tb/WC_0/i_cnt
add wave -noupdate -radix unsigned /tb/WC_0/i_update
add wave -noupdate -radix unsigned /tb/WC_0/valid_0
add wave -noupdate -radix unsigned /tb/WC_0/i_pedge_0
add wave -noupdate -radix unsigned /tb/WC_0/i_nedge_0
add wave -noupdate -divider {Cycle Status}
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/pedge
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/nedge
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/high
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/low
add wave -noupdate -divider {Periodic Status}
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/update
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/valid
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/n_pedge
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/n_nedge
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/n_high
add wave -noupdate -color Orange -radix unsigned /tb/WC_0/n_low
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2095 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 165
configure wave -valuecolwidth 148
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
WaveRestoreZoom {902 ns} {3528 ns}
