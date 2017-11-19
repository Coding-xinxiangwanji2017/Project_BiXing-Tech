
vlog  +incdir+. +define+x2Gb +define+sg125 +define+x16 ../ip/M_DdrCtrl/user_design/sim/ddr3_model_c3.v

vsim -t ps -novopt +notimingchecks -L unisim -L secureip work.sim_tb_top

vsim -t ps -novopt +notimingchecks -L unisim -L secureip work.M_TbLcdDis

log -r /*