################################################################################
##           *****************          *****************
##                           **        **
##               ***          **      **           **
##              *   *          **    **           * *
##             *     *          **  **              *
##             *     *           ****               *
##             *     *          **  **              *
##              *   *          **    **             *
##               ***          **      **          *****
##                           **        **
##           *****************          *****************
################################################################################
## 版    权  :  BiXing Tech
## 文件名称  :  M_FpgaTypeTb.vhd
## 设    计  :  zhang wenjun
## 邮    件  :  wenjunzhang@bixing-tech.com
## 校    对  :
## 设计日期  :  2016/08/19
## 功能简述  :  M_FpgaType
## 版本序号  :  0.1
## 修改历史  :  1. Initial, zhang wenjun, 2016/08/19
################################################################################


############################################################
#        Set Simulation Library about IP/Netlist/Device 
############################################################




############################################################
#        Setup work library 
############################################################
vlib work
############################################################
#        Compile all the file 
############################################################
# vcom -work work -novopt ./../src/*.vhd
# vcom -work work -novopt ./../qii/*.vhd
# vlog -work work -novopt ../M_PDCapture/M_PDCapture.srcs/sources_1/*.v
vcom -work work ../src/M_UartRecvTop.vhd
vcom -work work ../src/M_RecvVol.vhd
vcom -work work ../src/M_RecvCurt.vhd
vcom -work work ../src/M_RecvCmd.vhd

vcom -work work ./tb/M_UartRecvTopTb.vhd

############################################################
#        Run simulation
############################################################

# vsim -novopt -L altera_mf -t ps work.M_TopTb
vsim -novopt -t ps work.M_UartRecvTopTb

log -r /*
# view wave
do wave.do

run 1100 us