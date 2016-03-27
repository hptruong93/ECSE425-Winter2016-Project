#Hours spent on this project, increment as you go: 80

proc AddWaves {} {

	;#Add the following signals to the Waves window
	add wave -label clock -position end  -radix binary sim:/masterpipeline_instance/clk
	add wave -label reset -position end  -radix binary sim:/masterpipeline_instance/reset

	add wave -label re1 -position end  -radix binary sim:/masterpipeline_instance/re1
	add wave -label busy1 -position end  -radix binary sim:/masterpipeline_instance/busy1
	add wave -label mm_re -position end  -radix binary sim:/memory_arbiter_instance/mm_re
	add wave -label mm_rd_ready -position end  -radix binary sim:/memory_arbiter_instance/mm_rd_ready
	add wave -label mm_address -position end  -radix decimal sim:/memory_arbiter_instance/mm_address

	add wave -label alu_data1 -position end  -radix decimal sim:/masterpipeline_instance/data1
	add wave -label alu_data2 -position end  -radix decimal sim:/masterpipeline_instance/data2
	add wave -label alu_output -position end  -radix decimal sim:/masterpipeline_instance/result
  

  ;#Set some formating options to make the Waves window more legible
	configure wave -namecolwidth 250
	WaveRestoreZoom {0 ns} {8 ns}
}

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

# #Testing files
# vcom test_mainmemory.vhd
# vcom test_instructionfetch.vhd
# vcom test_alu.vhd
# vcom test_memstage.vhd
# vcom test_writeback.vhd
# vcom test_memarbiter.vhd
# vcom test_masterpipeline.vhd
vcom test_thewholething.vhd

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
# run 10 ns

# vsim -t ps mainmemory_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 200 ns

vsim -t ps masterpipeline_tb
AddWaves
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
run 15 ns

# vsim -t ps thewholething_tb
# AddWaves
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 20 ns
