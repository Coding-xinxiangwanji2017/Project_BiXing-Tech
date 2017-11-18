onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {Reset & Clock} /m_cmparcurttb/U_M_CmparCurt/CpSl_Rst_iN
add wave -noupdate -group {Reset & Clock} /m_cmparcurttb/U_M_CmparCurt/CpSl_Clk_i
add wave -noupdate -expand -group {Current Data } -color Magenta /m_cmparcurttb/U_M_CmparCurt/CpSl_CurtDvld_i
add wave -noupdate -expand -group {Current Data } /m_cmparcurttb/U_M_CmparCurt/CpSv_CurtData_i
add wave -noupdate -expand -group {Compare Voltage} -color Magenta /m_cmparcurttb/U_M_CmparCurt/PrSl_CmpVolVldTrig_s
add wave -noupdate -expand -group {Compare Voltage} /m_cmparcurttb/U_M_CmparCurt/CpSv_VoltageResult_i
add wave -noupdate -expand -group {Compare Voltage} /m_cmparcurttb/U_M_CmparCurt/PrSv_VolHead_s
add wave -noupdate -expand -group {Compare Voltage} /m_cmparcurttb/U_M_CmparCurt/PrSv_VolResult_s
add wave -noupdate -expand -group {Test FPGA Reset} -color Magenta /m_cmparcurttb/U_M_CmparCurt/CpSl_RstVld_i
add wave -noupdate -expand -group {Control Relay} /m_cmparcurttb/U_M_CmparCurt/PrSv_CtrlRelay_s
add wave -noupdate -expand -group {Control Relay} /m_cmparcurttb/U_M_CmparCurt/CpSv_VadjCtrl_o
add wave -noupdate -expand -group {Control Relay} /m_cmparcurttb/U_M_CmparCurt/CpSv_RelayEn_o
add wave -noupdate -expand -group {Adc State} /m_cmparcurttb/U_M_CmparCurt/CpSl_CurtAdcClk_o
add wave -noupdate -expand -group {Adc State} /m_cmparcurttb/U_M_CmparCurt/CpSl_CurtAdcCS_o
add wave -noupdate -expand -group {Adc State} /m_cmparcurttb/U_M_CmparCurt/CpSl_CurtAdcConfigData_o
add wave -noupdate -expand -group {Adc State} /m_cmparcurttb/U_M_CmparCurt/CpSl_CurtAdcData_i
add wave -noupdate -expand -group {Compare Current Result} -color Magenta /m_cmparcurttb/U_M_CmparCurt/CpSl_CmpCurtVld_o
add wave -noupdate -expand -group {Compare Current Result} /m_cmparcurttb/U_M_CmparCurt/CpSv_CmpCurtData_o
add wave -noupdate -expand -group {Base Current} /m_cmparcurttb/U_M_CmparCurt/PrSv_Head_s
add wave -noupdate -expand -group {Base Current} /m_cmparcurttb/U_M_CmparCurt/PrSv_CurtVadj_s
add wave -noupdate -expand -group {Base Current} /m_cmparcurttb/U_M_CmparCurt/PrSv_Curt3v3_s
add wave -noupdate -expand -group {Base Current} /m_cmparcurttb/U_M_CmparCurt/PrSv_Curt2v5_s
add wave -noupdate -expand -group {Base Current} /m_cmparcurttb/U_M_CmparCurt/PrSv_Curt1v5_s
add wave -noupdate -expand -group {Adc State Machine} -color Magenta /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcState_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSv_CapCurtNum_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSv_RelayCnt_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcStart_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcWait_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcStop_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcConfigNum_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcRecNum_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSl_AdcSclk_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSl_AdcSclkNum_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcConfigData_s
add wave -noupdate -expand -group {Adc State Machine} /m_cmparcurttb/U_M_CmparCurt/PrSl_AdcConfig_s
add wave -noupdate -expand -group {Adc State Machine} -expand -group {Adc Capture_A} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcDin_s
add wave -noupdate -expand -group {Adc State Machine} -expand -group {Adc Capture_A} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcCurtVadj_s
add wave -noupdate -expand -group {Adc State Machine} -expand -group {Adc Capture_A} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcCurt3V3_s
add wave -noupdate -expand -group {Adc State Machine} -expand -group {Adc Capture_A} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcCurt2V5_s
add wave -noupdate -expand -group {Adc State Machine} -expand -group {Adc Capture_A} /m_cmparcurttb/U_M_CmparCurt/PrSv_AdcCurt1V5_s
add wave -noupdate -expand -group {Compare Current State} /m_cmparcurttb/U_M_CmparCurt/PrSv_TestBoard_s
add wave -noupdate -expand -group {Compare Current State} -color Magenta /m_cmparcurttb/U_M_CmparCurt/PrSv_CmpState_s
add wave -noupdate -expand -group {Compare Current State} /m_cmparcurttb/U_M_CmparCurt/PrSv_Cnt1us_s
add wave -noupdate -expand -group {Compare Current State} /m_cmparcurttb/U_M_CmparCurt/PrSv_RelayVol_s
add wave -noupdate -expand -group {Compare Current State} /m_cmparcurttb/U_M_CmparCurt/PrSv_CmpVolResult_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3005000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 360
configure wave -valuecolwidth 77
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
WaveRestoreZoom {52783180391 ps} {52897295975 ps}
