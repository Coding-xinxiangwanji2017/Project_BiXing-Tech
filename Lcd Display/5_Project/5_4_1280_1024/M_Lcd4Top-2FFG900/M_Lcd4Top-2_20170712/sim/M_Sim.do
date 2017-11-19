#---------------------------------------
#   Compile library
#---------------------------------------

# Create and map a work directory
vlib work
vmap work work


#---------------------------------------
#compile the "glbl.v" 
#---------------------------------------


#---------------------------------------
# Compile files in the work directory
#vcom 表示编译VHDL代码；
#vlog 表示编译Verilog代码
#user designed part 
#---------------------------------------
vcom -work work ../src/M_Test.vhd
vcom -work work ../ipcore_dir/M_DoubleDivider.vhd
vcom -work work ../ipcore_dir/M_SingDivider.vhd    


# Compile testbench source
vcom -work work ./tb/M_TestTb.vhd

# Begin the test
vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip work.M_TestTb


#look wave form
do wave.do

log -r /*
run 25 ms
