#---------------------------------------
#   Compile library
#---------------------------------------

# Create and map a work directory
vlib work
vmap work work

#---------------------------------------
# Compile files in the work directory
#vcom ��ʾ����VHDL���룻
#vlog ��ʾ����Verilog����
#user designed part 
#---------------------------------------
vcom -work work ../src/*.vhd    

# Compile testbench source
vcom -work work ./tb/*.vhd

# Begin the test
vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip work.M_Sim


#look wave form
do wave.do

log -r /*
run 20 ms
