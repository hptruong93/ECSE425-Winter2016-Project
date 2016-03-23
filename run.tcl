;#Create the work library, which is the default library used by ModelSim
vlib work

;#Compile everything
vcom memory_arbiter_lib.vhd
vcom Main_Memory.vhd
vcom memory_arbiter.vhd
vcom CPU.vhd
vcom decoder.vhd
vcom ALU.vhd
vcom MemStage.vhd
vcom WriteBack.vhd

#Testing files
vcom test_alu.vhd
vcom test_writeback.vhd

;#Start a simulation session with the fsm_tb component
# vsim -t ps alu_tb
vsim -t ps writeback_tb

force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

run 30ns