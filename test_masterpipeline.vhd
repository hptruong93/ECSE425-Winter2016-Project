LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use work.memory_arbiter_lib.all;
use ieee.numeric_std_unsigned.all;


ENTITY masterpipeline_tb IS
END masterpipeline_tb;
 
ARCHITECTURE behaviour OF masterpipeline_tb IS
 
SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

COMPONENT MasterPipeline is
			port (  
				clk : in STD_LOGIC;
				reset : in STD_LOGIC;

				observed_registers : out register_array;

				-- ports connected to mem arbiter
				instruction_address : out NATURAL; -- fed to port 1 of mem arbiter, has priority
				fetched_instruction : in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
				re1 : out STD_LOGIC;
				busy1 : in STD_LOGIC;

				store_load_address : out NATURAL; -- fed to port 2 of mem arbiter
				input_memory_data : in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0); -- for load
				output_memory_data : out STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0); -- for store
				word_byte : out STD_LOGIC; -- send to arbiter to control whether we interact in bytes or words
				re2 : out STD_LOGIC;
				we2 : out STD_LOGIC;
				busy2 : in STD_LOGIC
	);
end COMPONENT;

signal observed_registers : register_array;

signal instruction_address : NATURAL; -- fed to port 1 of mem arbiter, has priority
signal fetched_instruction : STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
signal re1         : STD_LOGIC;
signal busy1       : STD_LOGIC;
signal store_load_address : NATURAL; -- fed to port 2 of mem arbiter
signal input_memory_data   : STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0); -- for load
signal output_memory_data : STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0); -- for store
signal word_byte : STD_LOGIC; -- send to arbiter to control whether we interact in bytes or words
signal re2         : STD_LOGIC;
signal we2         : STD_LOGIC;
signal busy2       : STD_LOGIC;

signal destination_reg : NATURAL;
signal count : STD_LOGIC := '0';
 
BEGIN
	masterpipeline_instance: MasterPipeline  PORT MAP (
		clk => clk,
		reset => reset,
		observed_registers	=> observed_registers,

		-- ports connected to mem arbiter
		instruction_address => instruction_address, -- fed to port 1 of mem arbiter, has priority
		fetched_instruction => fetched_instruction,
		re1 => re1,
		busy1 => busy1,
		store_load_address => store_load_address, -- fed to port 2 of mem arbiter
		input_memory_data => input_memory_data, -- for load
		output_memory_data => output_memory_data, -- for store
		word_byte => word_byte, -- send to arbiter to control whether we interact in bytes or words
		re2 => re2,
		we2 => we2,
		busy2 => busy2   
	);

   
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
		if count = '0' then count <= '1';
		WAIT FOR 1 * clk_period; --So clk starts at 1

		reset <= '1';
		WAIT FOR 1 * clk_period;
		reset <= '0';
		WAIT FOR 1 * clk_period;

-----------------------------------------------------------------------------------------------------------------------		
		busy1 <= '1';
		busy2 <= '0';
		fetched_instruction <= "00000000010000110000000000011000"; --mult $2 $3 --add 		$3 $0 $24
		input_memory_data   <= (others => '0');
		destination_reg <= 1;

		WAIT FOR 1 * clk_period;
		busy1 <= '0';

		WAIT FOR 3 * clk_period;
		fetched_instruction <= "00000000000000000000100000010010"; --mflo $1		--sub $1 $23 $3


		WAIT FOR 4 * clk_period;
		SHOW_LOVE("WRITTEN IS ", observed_registers(destination_reg));
		destination_reg <= 1;

		WAIT FOR 1 * clk_period;
		SHOW_LOVE("AWRITTEN IS ", observed_registers(destination_reg));

		SHOW(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>End test!");
		
		else
			count <= '1';
			WAIT FOR 1000 * clk_period;
		end if;
	END PROCESS;
END;