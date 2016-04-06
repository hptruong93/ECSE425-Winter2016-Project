#Hours spent on this project, increment as you go: 100

proc AddWaves {} {

	;#Add the following signals to the Waves window
	add wave -label clock -position end  -radix binary sim:/masterpipeline_instance/clk
	add wave -label reset -position end  -radix binary sim:/masterpipeline_instance/reset


	#Generic
	add wave -noupdate -divider -height 16 Generic
	# add wave -label delayed_writeback_source -position end  -radix binary sim:/masterpipeline_instance/delayed_writeback_source
	# add wave -label writeback_source -position end  -radix binary sim:/masterpipeline_instance/writeback_source
	# add wave -label delayed_mem_writeback_register -position end  -radix decimal sim:/masterpipeline_instance/delayed_mem_writeback_register

	#memory_arbiter
	add wave -noupdate -divider -height 16 memory_arbiter
	add wave -label we1 -position end  -radix binary sim:/masterpipeline_instance/we1
	add wave -label re1 -position end  -radix binary sim:/masterpipeline_instance/re1
	add wave -label re2 -position end  -radix binary sim:/masterpipeline_instance/re2
	# add wave -label addr1 -position end  -radix decimal sim:/memory_arbiter_instance/addr1

	# add wave -label re2 -position end  -radix binary sim:/masterpipeline_instance/re2
	add wave -label busy2 -position end  -radix binary sim:/masterpipeline_instance/busy2
	add wave -label busy1 -position end  -radix binary sim:/masterpipeline_instance/busy1

	# add wave -label we0 -position end  -radix binary sim:/memory_arbiter_instance/main_memory/we0
	# add wave -label we1 -position end  -radix binary sim:/memory_arbiter_instance/main_memory/we1
	# add wave -label we2 -position end  -radix binary sim:/memory_arbiter_instance/main_memory/we2
	# add wave -label we3 -position end  -radix binary sim:/memory_arbiter_instance/main_memory/we3

	# add wave -label re0 -position end  -radix binary sim:/memory_arbiter_instance/main_memory/re0
	# add wave -label re1 -position end  -radix binary sim:/memory_arbiter_instance/main_memory/re1
	# add wave -label re2 -position end  -radix binary sim:/memory_arbiter_instance/main_memory/re2
	# add wave -label re3 -position end  -radix binary sim:/memory_arbiter_instance/main_memory/re3


	# add wave -label mm_initialize -position end  -radix binary sim:/memory_arbiter_instance/mm_initialize
	add wave -label mm_re -position end  -radix binary sim:/memory_arbiter_instance/mm_re
	add wave -label mm_we -position end  -radix binary sim:/memory_arbiter_instance/mm_we
	add wave -label mm_rd_ready -position end  -radix binary sim:/memory_arbiter_instance/mm_rd_ready
	add wave -label mm_wr_done -position end  -radix binary sim:/memory_arbiter_instance/mm_wr_done
	add wave -label mm_address -position end  -radix decimal sim:/memory_arbiter_instance/mm_address
	add wave -label mm_data -position end  -radix decimal sim:/memory_arbiter_instance/mm_data
	# add wave -label Word_Byte -position end  -radix decimal sim:/memory_arbiter_instance/Word_Byte
	# add wave -label input_data_line -position end  -radix decimal sim:/masterpipeline_instance/mem_stage_instance/input_data_line

	#Cache
	add wave -noupdate -divider -height 16 Cache
	# add wave -label cache_read -position end  -radix binary sim:/masterpipeline_instance/cache_read
	# add wave -label cache_busy -position end  -radix decimal sim:/masterpipeline_instance/cache_busy
	# add wave -label cache_address -position end  -radix decimal sim:/masterpipeline_instance/natural_cache_address
	# add wave -label cache_output -position end  -radix decimal sim:/masterpipeline_instance/cache_output
	# add wave -label load_address -position end  -radix decimal sim:/masterpipeline_instance/instruction_address

	#InstructionFetch
	add wave -noupdate -divider -height 16 InstructionFetch
	add wave -label fetched_instruction -position end  -radix decimal sim:/masterpipeline_instance/fetched_instruction

	#ALU
	add wave -noupdate -divider -height 16 ALU
	add wave -label alu_data1 -position end  -radix decimal sim:/masterpipeline_instance/data1
	add wave -label alu_data2 -position end  -radix decimal sim:/masterpipeline_instance/data2
	add wave -label alu_output -position end  -radix decimal sim:/masterpipeline_instance/result

	#MemStage
	add wave -noupdate -divider -height 16 MemStage
	add wave -label mem_address -position end  -radix decimal sim:/masterpipeline_instance/mem_stage_instance/mem_address
	add wave -label mem_stage_busy -position end  -radix decimal sim:/masterpipeline_instance/mem_stage_busy
	# add wave -label store_load_address -position end  -radix decimal sim:/masterpipeline_instance/store_load_address
	# add wave -label mem_writeback_register -position end  -radix decimal sim:/masterpipeline_instance/mem_writeback_register
	add wave -label signal_to_mem -position end  -radix binary sim:/masterpipeline_instance/signal_to_mem
	add wave -label delayed_signal_to_mem -position end  -radix binary sim:/masterpipeline_instance/delayed_signal_to_mem
	add wave -label is_mem_busy -position end  -radix binary sim:/masterpipeline_instance/mem_stage_instance/is_mem_busy
	add wave -label do_read -position end  -radix binary sim:/masterpipeline_instance/mem_stage_instance/do_read
	add wave -label do_write -position end  -radix binary sim:/masterpipeline_instance/mem_stage_instance/do_write



	add wave -noupdate -divider -height 16 Memory

	add wave -label registers -position end  -radix decimal sim:/masterpipeline_instance/writeback_instance/registers

  ;#Set some formating options to make the Waves window more legible
	configure wave -namecolwidth 250
	WaveRestoreZoom {0 ns} {8 ns}
}

proc AddWaves_mem_tb {} {

	;#Add the following signals to the Waves window
	add wave -label clock -position end  -radix binary sim:/mainmemory_tb/clk

	add wave -label initialize -position end  -radix binary sim:/mainmemory_tb/initialize
	add wave -label re -position end  -radix binary sim:/mainmemory_tb/re
	add wave -label we -position end  -radix binary sim:/mainmemory_tb/we
	add wave -label rd_ready -position end  -radix binary sim:/mainmemory_tb/rd_ready
	add wave -label wr_done -position end  -radix binary sim:/mainmemory_tb/wr_done
	add wave -label address -position end  -radix decimal sim:/mainmemory_tb/address
	add wave -label data -position end  -radix decimal sim:/mainmemory_tb/data


  ;#Set some formating options to make the Waves window more legible
	configure wave -namecolwidth 250
	WaveRestoreZoom {0 ns} {8 ns}
}

;#Create the work library, which is the default library used by ModelSim
vlib work

;#Compile everything
vcom Memory_in_Byte.vhd
vcom Main_Memory.vhd

vcom CPU.vhd
vcom ForwardingUtil.vhd
vcom Forwarding.vhd
vcom StallUtil.vhd
vcom CacheInfrastructure.vhd

vcom memory_arbiter_lib.vhd
vcom memory_arbiter.vhd

vcom Cache.vhd
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
# AddWaves_mem_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 22 ns

# vsim -t ps masterpipeline_tb
# AddWaves
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 10 ns

vsim -t ps thewholething_tb
AddWaves
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
run 200 ns
