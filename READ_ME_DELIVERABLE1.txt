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
the logic of the memory arbitter inside the the Memory stage of the pipeline 
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
3. Run the java executable and it will print the machine code for the assembly.asm file. You can redirect
the output of the java program by using unix redirect symbol.
4. Open ModelSim.
5. Change directory to the folder containing our project.
6. Type source run.tcl in the transcript window.
7. Watch the registers in Wave window.

Thank you.
