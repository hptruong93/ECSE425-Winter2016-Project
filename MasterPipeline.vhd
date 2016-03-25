library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;

entity MasterPipeline is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;

			-- ports connected to mem arbiter
			instruction_address : out NATURAL; -- fed to port 1 of mem arbiter, has priority
			fetched_instruction	: in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re1			: out STD_LOGIC;
			busy1 		: in STD_LOGIC;

			store_load address		: out NATURAL; -- fed to port 2 of mem arbiter
			input_memory_data	: in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0); -- for load
			output_memory_data : out STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0); -- for store
			re2			: out STD_LOGIC;
			we2			: out STD_LOGIC;
			busy2 		: in STD_LOGIC
	);
end MasterPipeline;

architecture behavioral of MasterPipeline is

COMPONENT ALU IS
	port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			data1	:	in signed(32-1 downto 0);
			data2	:	in signed(32-1 downto 0);

			operation : in STD_LOGIC_VECTOR(6-1 downto 0);
			lo_reg : out signed (32-1 downto 0);
			hi_reg : out signed (32-1 downto 0);
			result : out signed(32-1 downto 0)
	);
end COMPONENT;

COMPONENT Decoder is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			instruction : in STD_LOGIC_VECTOR(32-1 downto 0);

			pc_reg : in STD_LOGIC_VECTOR(32-1 downto 0);
			registers : in register_array;

			operation : out STD_LOGIC_VECTOR(6-1 downto 0);
			mem_writeback_register : out STD_LOGIC_VECTOR(5-1 downto 0); --send to memstage or writeback
			-- for store, this represents the register that we're storing. For load, this represents the register getting the value from memory.
			signal_to_mem : out STD_LOGIC_VECTOR(3-1 downto 0); --send to mem stage (mem operation)
			writeback_source : out STD_LOGIC_VECTOR(3-1 downto 0); --send to writeback
			branch_signal : out STD_LOGIC_VECTOR(2-1 downto 0); --send to branch
			branch_address : out STD_LOGIC_VECTOR(32-1 downto 0);
			data1 : out STD_LOGIC_VECTOR(32-1 downto 0); --send to ALU
			data2 : out STD_LOGIC_VECTOR(32-1 downto 0) --send to ALU

	);
end COMPONENT;

signal operation : STD_LOGIC_VECTOR(6-1 downto 0); -- Decoder => ALU
signal instruction : STD_LOGIC_VECTOR(32-1 downto 0); -- Fetch unit ==> Decoder
signal data1 : STD_LOGIC_VECTOR(32-1 downto 0);
signal data2 : STD_LOGIC_VECTOR(32-1 downto 0);
signal lo_reg : signed (32-1 downto 0);
signal hi_reg : signed (32-1 downto 0);
signal result : signed(32-1 downto 0); -- ALU ==> Mem unit
signal registers : register_array;
signal pc_reg : STD_LOGIC_VECTOR(32-1 downto 0);
signal mem_writeback_register : STD_LOGIC_VECTOR(5-1 downto 0); -- Decoder ==> Write back unit
signal signal_to_mem : STD_LOGIC_VECTOR(3-1 downto 0);
signal writeback_source : STD_LOGIC_VECTOR(3-1 downto 0);
signal branch_signal : STD_LOGIC_VECTOR(2-1 downto 0); --send to branch
signal branch_address : STD_LOGIC_VECTOR(32-1 downto 0);

begin
	ALU_instance: ALU port map (
		clk => clk,
		reset => reset,
		data1 => data1,
		data2 => data2,
		operation => operation,
		lo_reg => lo_reg,
		hi_reg => hi_reg,
		result => result
	);

	decoder_instance : Decoder port map (
		clk => clk,
		reset => reset,
		instruction => instruction,
		pc_reg => pc_reg,
		registers => registers,
		operation => operation,
		mem_writeback_register => mem_writeback_register,
		signal_to_mem => signal_to_mem,
		writeback_source => writeback_source,
		branch_signal => branch_signal,
		branch_address => branch_address,
		data1 =>data1,
		data2 => data2
	); 


	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif (rising_edge(clk)) then
			
		end if;
	end process ; -- synced_clock
	

end behavioral;
