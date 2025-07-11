# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: E:\vitisspace\sketch_system\_ide\scripts\debugger_sketch-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source E:\vitisspace\sketch_system\_ide\scripts\debugger_sketch-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-HS1 210512180081" && level==0 && jtag_device_ctx=="jsn-JTAG-HS1-210512180081-13722093-0"}
fpga -file E:/vitisspace/sketch/_ide/bitstream/systembram_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw E:/vitisspace/systembram_wrapper/export/systembram_wrapper/hw/systembram_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source E:/vitisspace/sketch/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow E:/vitisspace/sketch/Debug/sketch.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
