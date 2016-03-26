#Hours spent on this project, increment as you go: 50

;#Create the work library, which is the default library used by ModelSim
vlib work

;#Compile everything
vcom Memory_in_Byte.vhd
vcom Main_Memory.vhd
vcom memory_arbiter_lib.vhd
vcom memory_arbiter.vhd

vcom CPU.vhd
vcom InstructionFetch.vhd
vcom decoder.vhd
vcom ALU.vhd
vcom MemStage.vhd
vcom WriteBack.vhd
vcom MasterPipeline.vhd

#Testing files
vcom test_mainmemory.vhd
vcom test_instructionfetch.vhd
vcom test_alu.vhd
vcom test_memstage.vhd
vcom test_writeback.vhd
vcom test_memarbiter.vhd
vcom test_masterpipeline.vhd


#Start a simulation session with the fsm_tb component
# vsim -t ps alu_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 20ns

# vsim -t ps writeback_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 20ns

# vsim -t ps memstage_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 200ns


# vsim -t ps instructionfetch_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 14 ns

# vsim -t ps memarbiter_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 1000 ns

# vsim -t ps mainmemory_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 200 ns

vsim -t ps masterpipeline_tb
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
run 10 ns