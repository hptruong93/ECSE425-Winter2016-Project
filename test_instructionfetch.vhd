LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use ieee.numeric_std_unsigned.all;


ENTITY instructionfetch_tb IS
END instructionfetch_tb;
 
ARCHITECTURE behaviour OF instructionfetch_tb IS
 
SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

COMPONENT InstructionFetch IS
            port (  clk     : in STD_LOGIC;
                        reset : in STD_LOGIC;
 
                        branch_signal : in  STD_LOGIC_VECTOR(2-1 downto 0);
                        branch_address : in STD_LOGIC_VECTOR(32-1 downto 0); --from decoder and ALU
                        data : in STD_LOGIC_VECTOR(32-1 downto 0); --from memory
 
                        is_mem_busy : in STD_LOGIC;
 
                        pc_reg : out STD_LOGIC_VECTOR(32-1 downto 0); --send to decoder
                        do_read : out STD_LOGIC;
                        address : out STD_LOGIC_VECTOR(32-1 downto 0); --address to fetch the next instruction
                        is_busy : out STD_LOGIC; --if waiting for memory
                        instruction : out STD_LOGIC_VECTOR(32-1 downto 0) --instruction send to decoder
                );
end COMPONENT;
 
signal branch_signal :  STD_LOGIC_VECTOR(2-1 downto 0);
signal branch_address : STD_LOGIC_VECTOR(32-1 downto 0); --from decoder and ALU
signal data : STD_LOGIC_VECTOR(32-1 downto 0); --from memory
 
signal is_mem_busy : STD_LOGIC;
 
signal pc_reg : STD_LOGIC_VECTOR(32-1 downto 0); --send to decoder
signal do_read : STD_LOGIC;
signal address : STD_LOGIC_VECTOR(32-1 downto 0); --address to fetch the next instruction
signal is_busy : STD_LOGIC; --if waiting for memory
signal instruction : STD_LOGIC_VECTOR(32-1 downto 0); --instruction send to decoder
 
 
BEGIN
    test_bench: InstructionFetch   
            PORT MAP (
                        clk => clk,
                        reset => reset,
 
                        branch_signal => branch_signal,
                        branch_address => branch_address,
                        data => data,
 
                        is_mem_busy => is_mem_busy,
 
                        pc_reg => pc_reg,
                        do_read => do_read,
                        address => address,
                        is_busy => is_busy,
                        instruction => instruction
                );
 
     --clock process
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period/2;
        clk <= '0';
        WAIT FOR clk_period/2;
    END PROCESS;
   
 
    --TODO: Thoroughly test the crap
    stim_process: PROCESS
    BEGIN
        WAIT FOR 1 * clk_period; --So clk starts at 1
 
        reset <= '1';
        reset <= '0';
        WAIT FOR 1 * clk_period;
 
        ASSERT (is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN INITIALIZATION is busy != 1" SEVERITY ERROR;
        ASSERT (do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN INITIALIZATION do_read != 1" SEVERITY ERROR;
 
 
        REPORT "Read next instruction";
        branch_signal <= STD_LOGIC_VECTOR(BRANCH_NOT);
        branch_address <= STD_LOGIC_VECTOR(DUMMY_32_ONE);
        data <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
        is_mem_busy <= '0';
        --REPORT "Clock is " & STD_LOGIC'image(clk);
        --REPORT "address is " & integer'image(to_integer(unsigned(address)));
        --REPORT "branch_address is " & integer'image(to_integer(unsigned(branch_address)));
 
        WAIT FOR 1 * clk_period;
        ASSERT ( is_busy = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> busy != 0" SEVERITY ERROR;
        ASSERT ( do_read = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_read != 0" SEVERITY ERROR;
        ASSERT ( instruction = data) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> instruction != data" SEVERITY ERROR;
       
 
 
        REPORT "Memory takes 2 cycle to get data SHOULD BE IN FETCHING";
        is_mem_busy <= '1';
 
        WAIT FOR 1 * clk_period;
        ASSERT ( is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  busy != 1" SEVERITY ERROR;
        ASSERT ( do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_read != 1" SEVERITY ERROR;
       
       	REPORT "Memory takes 2 cycle to get data -- SHOULD BE IN FETCHING";
        is_mem_busy <= '1';
 
        WAIT FOR 1 * clk_period;
        ASSERT ( is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  busy != 1" SEVERITY ERROR;
        ASSERT ( do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_read != 1" SEVERITY ERROR;
       

        data <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
        is_mem_busy <= '0';
 
        REPORT "Read next instruction should be in FETCHING and going to INSTRUCTION_RECEIVED";
        WAIT FOR 1 * clk_period;
        ASSERT ( is_busy = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  busy != 0" SEVERITY ERROR;
        ASSERT ( do_read = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  do_read != 1" SEVERITY ERROR;
        ASSERT ( instruction = data) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> instruction != data " SEVERITY ERROR;
   
 
        REPORT "Branch instruction";
        branch_signal  <= STD_LOGIC_VECTOR(BRANCH_ALWAYS);
        branch_address <= STD_LOGIC_VECTOR(DUMMY_32_ONE);
        is_mem_busy    <= '0';
 
        REPORT "Should go to SET_FETCH_BRANCH";
        WAIT FOR 1 * clk_period;
        ASSERT (is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  busy != 1" SEVERITY ERROR;
        ASSERT (do_read = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_read != 1" SEVERITY ERROR;
        ASSERT (address = branch_address) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> address != branch_address" SEVERITY ERROR;
       
        REPORT "Should be in FETCH_BRANCH";
        is_mem_busy    <= '1';
 
        WAIT FOR 1 * clk_period;
        ASSERT (is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   busy != 1" SEVERITY ERROR;
        ASSERT (do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_read != 1" SEVERITY ERROR;
        ASSERT (address = branch_address) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> address != branch_address" SEVERITY ERROR;
       
 
        REPORT "Should be in FETCH_BRANCH to INSTRUCTION_RECEIVED";
        is_mem_busy    <= '0';
        data <= STD_LOGIC_VECTOR(DUMMY_32_THREE);
 
        WAIT FOR 1 * clk_period;
        ASSERT (is_busy = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> busy != 0" SEVERITY ERROR;
        ASSERT (do_read = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  read != 0 " SEVERITY ERROR;
        ASSERT (instruction = data) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> instruction != data" SEVERITY ERROR;
        ASSERT (address = branch_address + 4) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> address != PC" SEVERITY ERROR;


        REPORT "INSTRUCTION_RECEIVED";
        branch_signal  <= STD_LOGIC_VECTOR(BRANCH_NOT);
        is_mem_busy    <= '1';
 
        WAIT FOR 1 * clk_period;
        ASSERT (is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  busy != 0" SEVERITY ERROR;
        ASSERT (do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_rad != 1" SEVERITY ERROR;
        ASSERT (address = branch_address + 4) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> address != PC" SEVERITY ERROR;
        
 
        REPORT "FETCHING";
        is_mem_busy    <= '0';
        data <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
 
        WAIT FOR 1 * clk_period;
        ASSERT (is_busy = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  busy != 0" SEVERITY ERROR;
        ASSERT (do_read = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_read != 1" SEVERITY ERROR;
        ASSERT (instruction = data) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> instruction != data" SEVERITY ERROR;
        ASSERT (address = branch_address + 8) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> address != PC" SEVERITY ERROR;
       
        REPORT "INSTRUCTION_RECEIVED";
        is_mem_busy    <= '1';
        data <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
 
        WAIT FOR 1 * clk_period;
        ASSERT (is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  busy != 1" SEVERITY ERROR;
        ASSERT (do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_read != 1" SEVERITY ERROR;
        ASSERT (instruction /= data) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> instruction != data" SEVERITY ERROR;
        ASSERT (address = branch_address + 8) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> address != PC" SEVERITY ERROR;
       
        REPORT "BRANCH_ALWAYS after getting instruction should go to FETCH_BRANCH_SET without puting data on the instruction line";
        is_mem_busy    <= '0';
        branch_signal  <= STD_LOGIC_VECTOR(BRANCH_ALWAYS);
        branch_address <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
        data <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
 
        WAIT FOR 1 * clk_period;
        ASSERT (is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> busy != 1" SEVERITY ERROR;
        ASSERT (do_read = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> do_read != 0" SEVERITY ERROR;
        ASSERT (address = branch_address) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  address != branch_address" SEVERITY ERROR;
       
 
 
        REPORT "#####################################################End test";
    END PROCESS;
END;