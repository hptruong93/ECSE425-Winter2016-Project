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

COMPONENT MasterPipeline is
            port (  
                clk : in STD_LOGIC;
                reset : in STD_LOGIC;

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

COMPONENT memory_arbiter is
        port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            Word_Byte : in STD_LOGIC;

            --Memory port #1
            addr1 : in NATURAL;
            data1_in : in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
            data1_out : out STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
            re1 : in STD_LOGIC;
            we1 : in STD_LOGIC;
            busy1 : out STD_LOGIC;
            
            --Memory port #2
            addr2 : in NATURAL;
            data2_in : in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
            data2_out : out STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
            re2 : in STD_LOGIC;
            we2 : in STD_LOGIC;
            busy2 : out STD_LOGIC
  );
end COMPONENT;

signal clk     : STD_LOGIC;
signal reset : STD_LOGIC;

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

 
 
BEGIN
    masterpipeline_instace: MasterPipeline  PORT MAP (
        clk => clk,
        reset => reset,
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

    memory_arbiter_instance: memory_arbiter PORT MAP (
        clk  => clk,
        reset => reset,
  
        Word_Byte   => word_byte,

        --Memory port 1
        addr1 => instruction_address,
        data1_in => (others => 'Z'),
        data1_out => fetched_instruction,
        re1 => re1,
        we1 => we1,
        busy1 => busy1,

        --Memory port 2
        addr2 => store_load_address,
        data2_in => output_memory_data,
        data2_out => input_memory_data,
        re2 => re2,
        we2 => we2,
        busy2 => busy2 
    );

     -- HOW DO WE DO THIS SHIT
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
 
    END PROCESS;
END;