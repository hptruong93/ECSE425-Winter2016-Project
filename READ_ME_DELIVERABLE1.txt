ECSE 425 - GROUP 1:
******************

In this README we first describe what aspects of our pipelined CPU work and what aspects do not.
After that, we specify how our code can be run and testesd.

********************************
* WHAT WORKS AND WHAT DOES NOT *
********************************

The problems we have are:
1. Erroneous load after store at same address. We are able to load in general
but if we try to retrieve a value which we have stored programmatically (ie
through a store command). We get a value of ZZZZZZZZZZZZZZ.
2. Memory takes 2 cycles. This is not a problem per se. It is due to an
additional clock cycle introduced by the memory arbiter. We could have moved
the logic of the memory arbitter inside the Memory stage of the pipeline
to fix this problem. However, we had not foreseen at the design phase and
decided to go with it instead. We modified our stall and forwarding logic
accordingly. An odd behavior that is due to this is the interleaving of "stall"
instructions between every instruction we are fetching.

All other aspects of our pipelines seem to work. We tested assembly programs we
wrote and everything seems to be running smoothly and on time (accounting for
the 2 clock cycle memory access).

**************************************
* HOW TO RUN OUR PIPELINED PROCESSOR *
**************************************

1. Compile the Assembler.java file.
2. Write your assembly code in a file named "assembly.asm" in the same folder as the Assembler.java file.
3. Run the java executable (compiled in step 1) and it will print the machine code for the assembly.asm file to stdout. You can redirect
the output of the java program by using unix redirect symbol.
4. Put the output into a file named "Init.dat" in the project directory (if output has not been redirected in step 3)
5. Open ModelSim.
6. Change directory to the folder containing our project.
7. Type source run.tcl in the transcript window.
8. Watch the registers in Wave window. Registers values are displayed at the bottom.

****************************************************
* WHERE TO START (IF CODE INSPECTION IS NECESSARY) *
****************************************************

1. run.tcl contains all compilation, wave form and simulation initialization
2. main test process lies within test_thewholething.vhd
3. Almost all custom types are defined in CPU.vhd. Others can be found in ForwardingUtil.vhd
4. Pipelined processor main wiring lies within MasterPipeline.vhd
5. All stages are in the according file names: InstructionFetch.vhd, decoder.vhd, ALU.vhd, MemStage.vhd, and WriteBack.vhd
6. Additional features:
 a) Branch resolution is performed in decoder.vhd (search for bne or beq)
 b) Forwarding logic is implemented in Forwarding.vhd and ForwardingUtil.vhd
 c) Stall logic is implemented in StallUtil.vhd. Decoder uses this stall logic heavily to determine stalling

Thank you. :)
