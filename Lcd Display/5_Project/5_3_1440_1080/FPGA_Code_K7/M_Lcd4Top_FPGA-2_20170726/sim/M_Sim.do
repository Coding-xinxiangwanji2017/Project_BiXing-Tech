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
#vcom ��ʾ����VHDL���룻
#vlog ��ʾ����Verilog����
#user designed part 
#---------------------------------------
vcom -work work ../src/M_Test.vhd   

# Compile testbench source
vcom -work work ./tb/M_TestTb.vhd

# Begin the test
vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip work.M_TestTb


#look wave form
do wave.do

log -r /*
run 25 ms
