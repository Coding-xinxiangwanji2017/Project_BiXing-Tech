vsim -novopt work.m_dvisim

restart
force -freeze sim:/m_dvisim/CpSl_Rst_iN 0 0
force -freeze sim:/m_dvisim/CpSl_Clk_i 1 0, 0 {5000 ps} -r 10ns
run 105ns
force -freeze sim:/m_dvisim/CpSl_Rst_iN 1 0
run 5ns
run 1ms
run 20ms