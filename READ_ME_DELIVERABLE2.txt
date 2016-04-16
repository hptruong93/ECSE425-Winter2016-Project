ECSE 425 - GROUP 1:
******************

In this README we first describe what aspects of our pipelined CPU work and what aspects do not.
After that, we specify how our code can be run and testesd.

********************************
* WHAT WORKS AND WHAT DOES NOT *
********************************

The problem we have is:
1. Instruction fetch takes at least 3 cycles in case of cache miss. This is not a real problem since we already had this problem in the previous deliverable where memory arbiter introduces another cycle into instruction fetch (have to go through memory artbier to talk to the main memory). In this deliverable we have to go from instruction fetch <--> cache <--> memory arbiter <--> main memory so another cycle delay was added. However, instruction fetch would only require 1 cycle in case of cache hit.

All other aspects of our pipelines seem to work. In addition to the sample assembly programs, we tested with assembly programs we
wrote and everything seems to be running smoothly and on time. We fixed the store load error since the last subsmission.

**************************************
* HOW TO RUN OUR PIPELINED PROCESSOR *
**************************************

1. Compile the Assembler.java file.
2. Write your assembly code in a file named "assembler.asm" in the same folder as the Assembler.java file.
3. Run the java executable (compiled in step 1) and it will print the machine code for the assembler.asm file to stdout. You can redirect
the output of the java program by using unix redirect symbol.
4. Put the output into a file named "Init.dat" in the project directory (if output has not been redirected in step 3).
5. Change run time in run.tcl to match your need (last line in the file).
6. Open ModelSim.
7. Change directory to the folder containing our project.
8. Type source run.tcl in the transcript window.
9. Watch the registers in Wave window. Registers values are displayed at the bottom.

****************************************************
* WHERE TO START (IF CODE INSPECTION IS NECESSARY) *
****************************************************

1. Assembler.java contains the full source code for assembler.
2. run.tcl contains all compilation, wave form and simulation initialization
3. main test process lies within test_thewholething.vhd. Lookout for "WAIT FOR 1000 * clk_period;" if runtime exceeds 1000 clock cycles
4. Almost all custom types are defined in CPU.vhd. Others can be found in ForwardingUtil.vhd
5. Pipelined processor main wiring lies within MasterPipeline.vhd
6. All stages are in the according file names: InstructionFetch.vhd, decoder.vhd, ALU.vhd, MemStage.vhd, and WriteBack.vhd
7. Cache is implemented in Cache.vhd
8. Additional features:
 a) Branch resolution is performed in decoder.vhd (search for bne or beq)
 b) Forwarding logic is implemented in Forwarding.vhd and ForwardingUtil.vhd
 c) Stall logic is implemented in StallUtil.vhd. Decoder uses this stall logic heavily to determine stalling

Thank you. :)
