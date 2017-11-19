onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Rst & clk} /m_lcd4top_tb/U_M_Lcd4Top_0/CpSl_Rst_iN
add wave -noupdate -expand -group {Rst & clk} /m_lcd4top_tb/U_M_Lcd4Top_0/CpSl_Clk_i
add wave -noupdate -expand -group DviScdt -color Khaki /m_lcd4top_tb/U_M_Lcd4Top_0/CpSl_Dvi0Scdt_i
add wave -noupdate -expand -group DviScdt /m_lcd4top_tb/U_M_Lcd4Top_0/CpSl_Dvi1Scdt_i
add wave -noupdate /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_FreCtrl_0/PrSv_StateVld_s
add wave -noupdate -expand -group {Double & FreChoice} /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_FreCtrl_0/PrSl_RisFlage_s
add wave -noupdate -expand -group {Double & FreChoice} /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_FreCtrl_0/PrSl_FalFlage_s
add wave -noupdate -expand -group {Double & FreChoice} /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_FreCtrl_0/PrSv_VsyncTrigCnt_s
add wave -noupdate -expand -group {Double & FreChoice} /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_FreCtrl_0/PrSv_FreChoice_s
add wave -noupdate -expand -group M_Test /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_Test_0/CpSl_Vsync_o
add wave -noupdate -expand -group M_Test /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_Test_0/CpSl_Test_o
add wave -noupdate -expand -group LcdVsync_Choice /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_LcdVsync_0/CpSl_ExtVsync_i
add wave -noupdate -expand -group LcdVsync_Choice /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_LcdVsync_0/CpSl_IntVsync_i
add wave -noupdate -expand -group LcdVsync_Choice -color {Medium Orchid} /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_LcdVsync_0/CpSl_LcdVsync_o
add wave -noupdate -expand -group LcdVsync_Choice /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_LcdVsync_0/CpSl_ExtVld_o
add wave -noupdate -expand -group Lcd -radix unsigned /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_DdrIf_0/PrSv_HCnt_s
add wave -noupdate -expand -group Lcd /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_DdrIf_0/PrSl_Hsync_s
add wave -noupdate -expand -group Lcd -radix unsigned /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_DdrIf_0/PrSv_VCnt_s
add wave -noupdate -expand -group Lcd /m_lcd4top_tb/U_M_Lcd4Top_0/U_M_DdrIf_0/PrSl_Vsync_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 8} {845464767918 ps} 0} {{Cursor 9} {496094118 ps} 0} {{Cursor 3} {9680894 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 391
configure wave -valuecolwidth 45
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
WaveRestoreZoom {0 ps} {59163648 ps}
