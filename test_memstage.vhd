LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;


ENTITY memstage_tb IS
END memstage_tb;

ARCHITECTURE behaviour OF memstage_tb IS

SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

CONSTANT DUMMY_32_ONE : 	signed(32-1 downto 0) := "01010110101011010010100010010010";
CONSTANT DUMMY_32_TWO : 	signed(32-1 downto 0) := "00100100110101010110110101100101";
CONSTANT DUMMY_32_THREE : 	signed(32-1 downto 0) := "11010110101001000011110101010101";

COMPONENT MemStage IS
					port (	clk 	: in STD_LOGIC;
					reset : in STD_LOGIC;

					mem_address : in SIGNED(32-1 downto 0); -- coming from ALU
					--operation : out STD_LOGIC_VECTOR(6-1 downto 0);
					mem_writeback_register : in STD_LOGIC_VECTOR(5-1 downto 0); -- used for store, tells which register to read from.
					registers : in register_array;
					signal_to_mem : in STD_LOGIC_VECTOR(3-1 downto 0);

					is_mem_busy : in STD_LOGIC;
					do_read : out STD_LOGIC;
					do_write : out	STD_LOGIC;
					is_busy : out STD_LOGIC;
					address_line : out NATURAl;
					data_line : inout STD_LOGIC_VECTOR(32-1 downto 0) -- received and sent from/to memory arbiter
	);
end COMPONENT;


signal mem_address : SIGNED(32-1 downto 0); -- coming from ALU

signal mem_writeback_register : STD_LOGIC_VECTOR(5-1 downto 0); -- used for store, tells which register to read from.
signal registers : register_array;
signal signal_to_mem : STD_LOGIC_VECTOR(3-1 downto 0);

signal is_mem_busy : STD_LOGIC;
signal do_read : STD_LOGIC;
signal do_write : STD_LOGIC;
signal is_busy : STD_LOGIC;
signal data_line : STD_LOGIC_VECTOR(32-1 downto 0);
signal address_line : NATURAL;


BEGIN
	test_bench: MemStage	
			PORT MAP(
						clk 	=> clk,
						reset => reset,

						mem_address => mem_address,
						mem_writeback_register => mem_writeback_register,
						registers => registers,
						signal_to_mem => signal_to_mem,

						is_mem_busy => is_mem_busy,
						do_read => do_read,
						do_write => do_write,
						is_busy => is_busy,
						address_line => address_line,
						data_line => data_line
			);

	 --clock process
	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;
	

	--TODO: Thoroughly test the crap
	stim_process: PROCESS
	BEGIN
		WAIT FOR 1 * clk_period; --clock high first

		reset <= '1';
		WAIT FOR 1 * clk_period;
		reset	<= '0';
		WAIT FOR 1 * clk_period;

		REPORT "LOAD WORD, AVAILABLE MEM";
		signal_to_mem <= LOAD_WORD;
		is_mem_busy <= '0';
		mem_address <= DUMMY_32_ONE;
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '1') REPORT "is_busy should be 1" SEVERITY ERROR;
		ASSERT (do_read = '1') REPORT "do_read should be 1" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '0') REPORT "is_busy should be 0, access is done" SEVERITY ERROR;

		REPORT "LOAD WORD, BUSY MEM";
		signal_to_mem <= LOAD_WORD;
		is_mem_busy <= '1';
		mem_address <= DUMMY_32_ONE;
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '1') REPORT "is_busy should be 1, waiting on memory" SEVERITY ERROR;
		ASSERT (do_read = '0') REPORT "do_read should be 0, waiting on memory" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		is_mem_busy <= '0';
		WAIT FOR 1 * clk_period; -- What comes next repeats above test
		ASSERT (is_busy = '1') REPORT "is_busy should be 1" SEVERITY ERROR;
		ASSERT (do_read = '1') REPORT "do_read should be 1, no longer waiting on memory" SEVERITY ERROR;
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '0') REPORT "is_busy should be 0, access is done" SEVERITY ERROR;

		REPORT "STORE WORD, AVAILABLE MEM";
		signal_to_mem <= STORE_WORD;
		mem_writeback_register <= "01010"; -- write to R10
		is_mem_busy <= '0';
		mem_address <= DUMMY_32_ONE;
		mem_writeback_register <= "01010"; -- register whose value we want to store
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '1') REPORT "is_busy should be 1" SEVERITY ERROR;
		ASSERT (do_write = '1') REPORT "do_read should be 1" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		ASSERT (data_line = registers(to_integer(unsigned(mem_writeback_register))));
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '0') REPORT "is_busy should be 0, access is done" SEVERITY ERROR;

		REPORT "STORE WORD, BUSY MEM";
		signal_to_mem <= STORE_WORD;
		is_mem_busy <= '1';
		mem_address <= DUMMY_32_ONE;
		mem_writeback_register <= "01010"; -- register whose value we want to store
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '1') REPORT "is_busy should be 1, waiting on memory" SEVERITY ERROR;
		ASSERT (do_write = '0') REPORT "do_read should be 0, waiting on memory" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		is_mem_busy <= '0';
		WAIT FOR 1 * clk_period; -- What comes next repeats above test
		ASSERT (is_busy = '1') REPORT "is_busy should be 1" SEVERITY ERROR;
		ASSERT (do_write = '1') REPORT "do_read should be 1" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		ASSERT (data_line = registers(to_integer(unsigned(mem_writeback_register))));
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '0') REPORT "is_busy should be 0, access is done" SEVERITY ERROR;

		REPORT "LOAD BYTE, AVAILABLE MEM";
		signal_to_mem <= LOAD_BYTE;
		is_mem_busy <= '0';
		mem_address <= DUMMY_32_ONE;
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '1') REPORT "is_busy should be 1" SEVERITY ERROR;
		ASSERT (do_read = '1') REPORT "do_read should be 1" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '0') REPORT "is_busy should be 0, access is done" SEVERITY ERROR;


		REPORT "LOAD BYTE, BUSY MEM";
		signal_to_mem <= LOAD_BYTE;
		is_mem_busy <= '1';
		mem_address <= DUMMY_32_ONE;
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '1') REPORT "is_busy should be 1, waiting on memory" SEVERITY ERROR;
		ASSERT (do_read = '0') REPORT "do_read should be 0, waiting on memory" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		is_mem_busy <= '0';
		WAIT FOR 1 * clk_period; -- What comes next repeats above test
		ASSERT (is_busy = '1') REPORT "is_busy should be 1" SEVERITY ERROR;
		ASSERT (do_read = '1') REPORT "do_read should be 1, no longer waiting on memory" SEVERITY ERROR;
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '0') REPORT "is_busy should be 0, access is done" SEVERITY ERROR;


		REPORT "STORE BYTE, AVAILABLE MEM";
		signal_to_mem <= STORE_BYTE;
		mem_writeback_register <= "01010"; -- write to R10
		is_mem_busy <= '0';
		mem_address <= DUMMY_32_ONE;
		mem_writeback_register <= "01010"; -- register whose value we want to store
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '1') REPORT "is_busy should be 1" SEVERITY ERROR;
		ASSERT (do_write = '1') REPORT "do_read should be 1" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		ASSERT (data_line = registers(to_integer(unsigned(mem_writeback_register))));
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '0') REPORT "is_busy should be 0, access is done" SEVERITY ERROR;

		REPORT "STORE BYTE, BUSY MEM";
		signal_to_mem <= STORE_BYTE;
		is_mem_busy <= '1';
		mem_address <= DUMMY_32_ONE;
		mem_writeback_register <= "01010"; -- register whose value we want to store
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '1') REPORT "is_busy should be 1, waiting on memory" SEVERITY ERROR;
		ASSERT (do_write = '0') REPORT "do_read should be 0, waiting on memory" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		is_mem_busy <= '0';
		WAIT FOR 1 * clk_period; -- What comes next repeats above test
		ASSERT (is_busy = '1') REPORT "is_busy should be 1" SEVERITY ERROR;
		ASSERT (do_write = '1') REPORT "do_read should be 1" SEVERITY ERROR;
		ASSERT (address_line = DUMMY_32_ONE) REPORT "Wrong address on address line" SEVERITY ERROR;
		ASSERT (data_line = registers(to_integer(unsigned(mem_writeback_register))));
		WAIT FOR 1 * clk_period;
		ASSERT (is_busy = '0') REPORT "is_busy should be 0, access is done" SEVERITY ERROR;
		

	END PROCESS;
END;