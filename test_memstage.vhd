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
					port (	
						clk 	: in STD_LOGIC;
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
						data_line : inout STD_LOGIC_VECTOR(32-1 downto 0)
						);
end COMPONENT;

signal clk	: STD_LOGIC;
signal reset : STD_LOGIC;

signal mem_address : SIGNED(32-1 downto 0); -- coming from ALU
signal --operation : STD_LOGIC_VECTOR(6-1 downto 0);
signal mem_writeback_register : STD_LOGIC_VECTOR(5-1 downto 0); -- used for store, tells which register to read from.
signal registers : register_array;
signal signal_to_mem : STD_LOGIC_VECTOR(3-1 downto 0);

signal is_mem_busy : STD_LOGIC;
signal do_read : STD_LOGIC;
signal do_write : STD_LOGIC;
signal is_busy : STD_LOGIC;
signal data_line : STD_LOGIC_VECTOR(32-1 downto 0)


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

		REPORT "Write from LO_AS_SOURCE";
		writeback_source <= LO_AS_SOURCE;
		lo_reg <= DUMMY_32_ONE;
		mem_writeback_register <= "11111";
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_ONE)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN LO_AS_SOURCE" SEVERITY ERROR;
	END PROCESS;
END;