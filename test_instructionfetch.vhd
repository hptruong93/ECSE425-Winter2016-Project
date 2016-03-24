LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;


ENTITY instructionfetch_tb IS
END instructionfetch_tb;

ARCHITECTURE behaviour OF instructionfetch_tb IS

SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

CONSTANT DUMMY_32_ZERO :	signed(32-1 downto 0) := "00000000000000000000000000000000";
CONSTANT DUMMY_32_ONE : 	signed(32-1 downto 0) := "01010110101011010010100010010010";
CONSTANT DUMMY_32_TWO : 	signed(32-1 downto 0) := "00100100110101010110110101100101";
CONSTANT DUMMY_32_THREE : 	signed(32-1 downto 0) := "11010110101001000011110101010101";

COMPONENT InstructionFetch IS
			port (	clk 	: in STD_LOGIC;
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
						clk	=> clk,
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
		WAIT FOR 1 * clk_period;
		reset	<= '0';
		ASSERT (is_busy = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN INITIALIZATION is busy != 1" SEVERITY ERROR;
		ASSERT (do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN INITIALIZATION do_read != 1" SEVERITY ERROR;


		REPORT "Read next instruction";
		branch_signal <= STD_LOGIC_VECTOR(BRANCH_NOT);
		branch_address <= STD_LOGIC_VECTOR(DUMMY_32_ONE);
		data <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
		is_mem_busy <= '0';
		--REPORT "Clock is " & STD_LOGIC'image(clk);

		WAIT FOR 2 * clk_period;
		ASSERT ( is_busy = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION is busy != 0" SEVERITY ERROR;
		ASSERT ( do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION instruction != data" SEVERITY ERROR;
		ASSERT ( instruction = data) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION instruction != data" SEVERITY ERROR;
		REPORT "End test";

		--REPORT "Read one more instruction";
		--branch_signal <= STD_LOGIC_VECTOR(BRANCH_NOT);
		--branch_address <= STD_LOGIC_VECTOR(DUMMY_32_ONE);
		--data <= STD_LOGIC_VECTOR(DUMMY_32_THREE);
		--is_mem_busy <= '0';

		--WAIT FOR 1 * clk_period;
		--ASSERT (is_busy = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION is busy != 0" SEVERITY ERROR;
		--ASSERT ( instruction = data) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION instruction != data" SEVERITY ERROR;
		--ASSERT ( do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION instruction != data" SEVERITY ERROR;

		--REPORT "Branch Always";
		--branch_signal <= STD_LOGIC_VECTOR(BRANCH_ALWAYS);
		--branch_address <= STD_LOGIC_VECTOR(DUMMY_32_ONE);
		--data <= STD_LOGIC_VECTOR(DUMMY_32_THREE);
		--is_mem_busy <= '0';

		--WAIT FOR 1 * clk_period;
		--ASSERT (is_busy = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION is busy != 0" SEVERITY ERROR;
		--ASSERT ( instruction = data) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION instruction != data" SEVERITY ERROR;
		--ASSERT ( do_read = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN READ NEXT INSTRUCTION instruction != data" SEVERITY ERROR;


	END PROCESS;
END;