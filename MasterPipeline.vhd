library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use work.memory_arbiter_lib.all;

entity MasterPipeline is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;

			--For testing only
			observed_registers	: out register_array;

			-- ports connected to mem arbiter
			instruction_address : out NATURAL; -- fed to port 1 of mem arbiter, has priority
			fetched_instruction	: in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re1			: out STD_LOGIC;
			busy1 		: in STD_LOGIC;

			store_load_address : out NATURAL; -- fed to port 2 of mem arbiter
			input_memory_data	: in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0); -- for load
			output_memory_data : out STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0); -- for store
			word_byte : out STD_LOGIC; -- send to arbiter to control whether we interact in bytes or words
			re2			: out STD_LOGIC;
			we1			: out STD_LOGIC;
			busy2 		: in STD_LOGIC
	);
end MasterPipeline;

architecture behavioral of MasterPipeline is

COMPONENT InstructionFetch is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;

			branch_signal : in  STD_LOGIC_VECTOR(2-1 downto 0);
			branch_address : in STD_LOGIC_VECTOR(32-1 downto 0); --from decoder
			data : in STD_LOGIC_VECTOR(32-1 downto 0); --from memory

			is_mem_busy : in STD_LOGIC;

			pc_reg : out STD_LOGIC_VECTOR(32-1 downto 0); --send to decoder
			do_read : out STD_LOGIC;
			address : out STD_LOGIC_VECTOR(32-1 downto 0); --address to fetch the next instruction
			is_busy : out STD_LOGIC; --if waiting for memory
			instruction : out STD_LOGIC_VECTOR(32-1 downto 0) --instruction send to decoder
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


COMPONENT MemStage is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;

			mem_address : in SIGNED(32-1 downto 0); -- coming from ALU
			mem_writeback_register : in STD_LOGIC_VECTOR(5-1 downto 0); -- used for store, tells which register to read from.
			registers : in register_array;
			signal_to_mem : in STD_LOGIC_VECTOR(3-1 downto 0);
			is_mem_busy : in STD_LOGIC;

			word_byte: out STD_LOGIC; --  when '1' you are interacting with the memory in word otherwise in byte
			do_read : out STD_LOGIC;
			do_write : out	STD_LOGIC;
			is_busy : out STD_LOGIC;
			address_line : out NATURAl;
			input_data_line : in STD_LOGIC_VECTOR(32-1 downto 0); -- received and sent from/to memory arbiter
			output_data_line : out STD_LOGIC_VECTOR(32-1 downto 0);
			mem_stage_output : out STD_LOGIC_VECTOR(32-1 downto 0)
	);
end COMPONENT;

COMPONENT WriteBack is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			lo_reg : in signed (32-1 downto 0);
			hi_reg : in signed (32-1 downto 0);

			writeback_source : in STD_LOGIC_VECTOR(3-1 downto 0); --sent from decoder
			alu_output : in signed(32-1 downto 0);
			mem_stage_busy : in STD_LOGIC;
			mem_stage_output : in STD_LOGIC_VECTOR(32-1 downto 0);
			mem_writeback_register : in STD_LOGIC_VECTOR(5-1 downto 0); --sent fromm decoder

			registers : out register_array
	);
end COMPONENT;

signal operation : STD_LOGIC_VECTOR(6-1 downto 0); -- Decoder => ALU
signal instruction : STD_LOGIC_VECTOR(32-1 downto 0); -- Fetch unit ==> Decoder
signal data1 : STD_LOGIC_VECTOR(32-1 downto 0); -- Decoder ==> ALU
signal data2 : STD_LOGIC_VECTOR(32-1 downto 0); -- Decoder ==> ALU
signal signed_data1 : signed(32-1 downto 0); -- Decoder ==> ALU
signal signed_data2 : signed(32-1 downto 0); -- Decoder ==> ALU

signal lo_reg : signed (32-1 downto 0); -- ALU ==> Mem unit
signal hi_reg : signed (32-1 downto 0); -- ALU ==> Mem unit
signal result : signed(32-1 downto 0); -- ALU ==> Mem unit
signal registers : register_array;
signal pc_reg : STD_LOGIC_VECTOR(32-1 downto 0); -- Fetch ==> Decode
signal instruction_address_output : STD_LOGIC_VECTOR(32-1 downto 0);
signal mem_writeback_register : STD_LOGIC_VECTOR(5-1 downto 0); -- Decoder ==> Write back unit
signal temp_mem_writeback_register : STD_LOGIC_VECTOR(5-1 downto 0); -- Decoder ==> Write back unit

signal signal_to_mem : STD_LOGIC_VECTOR(3-1 downto 0);
signal writeback_source : STD_LOGIC_VECTOR(3-1 downto 0);
signal temp_writeback_source : STD_LOGIC_VECTOR(3-1 downto 0);

signal branch_signal : STD_LOGIC_VECTOR(2-1 downto 0); --send to branch
signal branch_address : STD_LOGIC_VECTOR(32-1 downto 0);
signal mem_stage_busy : STD_LOGIC;
signal instruction_fetch_busy : STD_LOGIC;
signal mem_stage_output : STD_LOGIC_VECTOR(32-1 downto 0);

begin
	instruction_address <= to_integer(unsigned(instruction_address_output));

	observed_registers <= registers;

	fetch_instance : InstructionFetch port map (
		clk => clk,
		reset => reset,

 		branch_signal => branch_signal,
		branch_address => branch_address,
		data => fetched_instruction,

 		is_mem_busy => busy2,

 		pc_reg => pc_reg,
		do_read => re2,
		address => instruction_address_output,--STD_LOGIC_VECTOR(unsigned(instruction_address_output, 32)),
		is_busy => instruction_fetch_busy, -- memory is busy, cannot fetch instruction
		instruction => instruction
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
		data1 => data1,
		data2 => data2
	);


	signed_data1 <= signed(data1);
	signed_data2 <= signed(data2);
	ALU_instance: ALU port map (
		clk => clk,
		reset => reset,
		data1 => signed_data1,
		data2 => signed_data2,
		operation => operation,
		lo_reg => lo_reg,
		hi_reg => hi_reg,
		result => result
	);


	mem_stage_instance : MemStage port map (
		clk => clk,
		reset => reset,
		mem_address => result, -- coming from alu
		mem_writeback_register => mem_writeback_register,
		registers => registers,
		signal_to_mem => signal_to_mem,
		is_mem_busy => busy1, -- input from memory, check if channel 2 (for data) is busy


		word_byte => word_byte,
		do_read => re1,
		do_write => we1,
		is_busy => mem_stage_busy,
		address_line => store_load_address,
		input_data_line => input_memory_data,
		output_data_line => output_memory_data,
		mem_stage_output => mem_stage_output
	);

	writeback_instance : WriteBack port map (
		clk => clk, 
		reset => reset,

		lo_reg => lo_reg,
		hi_reg => hi_reg,

		writeback_source => temp_writeback_source,
		alu_output => result,
		mem_stage_busy => mem_stage_busy,
		mem_stage_output => mem_stage_output,
		mem_writeback_register => temp_mem_writeback_register,

		registers => registers
	);

	testa : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif (rising_edge(clk)) then
			temp_writeback_source <= writeback_source;
			temp_mem_writeback_register <= mem_writeback_register;			
		end if;
	end process ; -- synced_clock

	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif (rising_edge(clk)) then
			--REPORT "++++++++++++++++++++++++++++++++++++Writing back to " & integer'image(to_integer(unsigned(mem_writeback_register)));
			
		end if;
	end process ; -- synced_clock
	

end behavioral;
