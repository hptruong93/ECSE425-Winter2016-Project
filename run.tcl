proc AddWaves {} {

	;#Add the following signals to the Waves window
	add wave -position end  -radix binary sim:/memarbiter_tb/clk
	add wave -position end  -radix binary sim:/memarbiter_tb/reset
  
  ;#These signals will be contained in a group named "Port 1"
	add wave -group "Port 1"  -radix hex sim:/memarbiter_tb/addr1\
                            -radix hex sim:/memarbiter_tb/data1\
                            -radix binary sim:/memarbiter_tb/re1\
                            -radix binary sim:/memarbiter_tb/we1\
                            -radix binary sim:/memarbiter_tb/busy1
                            
  ;#These signals will be contained in a group named "Port 2"
  add wave -group "Port 2"  -radix hex sim:/memarbiter_tb/addr2\
                            -radix hex sim:/memarbiter_tb/data2\
                            -radix binary sim:/memarbiter_tb/re2\
                            -radix binary sim:/memarbiter_tb/we2\
                            -radix binary sim:/memarbiter_tb/busy2
  
  # ;#These signals will be contained in a group named "Main Memory"
  # add wave -group "Main Memory" -radix binary sim:/memarbiter_tb/mm_we\
  #                               -radix binary sim:/memarbiter_tb/mm_wr_done\
  #                               -radix binary sim:/memarbiter_tb/mm_re\
  #                               -radix binary sim:/memarbiter_tb/mm_rd_ready\
  #                               -radix hex sim:/memarbiter_tb/mm_address\
  #                               -radix hex sim:/memarbiter_tb/mm_data

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

#Testing files
vcom test_instructionfetch.vhd
vcom test_alu.vhd
# vcom test_memstage.vhd
vcom test_writeback.vhd
vcom test_memarbiter.vhd


;#Start a simulation session with the fsm_tb component
# vsim -t ps alu_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 20ns

# vsim -t ps writeback_tb
# run 20ns

vsim -t ps memstage_tb
run 20ns

# vsim -t ps instructionfetch_tb
# force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
# run 14 ns

vsim -t ps memarbiter_tb
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns
AddWaves
run 10 ns