library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_arbiter_lib.all;
use work.register_array.all;

-- Do not modify the port map of this structure
entity memory_arbiter is
port (clk 	: in STD_LOGIC;
      reset : in STD_LOGIC;

      		Word_Byte	: in STD_LOGIC;

			--Memory port #1
			addr1		: in NATURAL;
			data1_in	: in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			data1_out	: out STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re1			: in STD_LOGIC;
			we1			: in STD_LOGIC;
			busy1 		: out STD_LOGIC;

			--Memory port #2
			addr2		: in NATURAL;
			data2_in	: in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			data2_out	: out STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re2			: in STD_LOGIC;
			we2			: in STD_LOGIC;
			busy2 		: out STD_LOGIC
  );
end memory_arbiter;

architecture behavioral of memory_arbiter is
	--Main memory signals
	--Use these internal signals to interact with the main memory
	SIGNAL mm_address       : NATURAL                                       := 0;
	SIGNAL mm_we            : STD_LOGIC                                     := '0';
	SIGNAL mm_wr_done       : STD_LOGIC                                     := '0';
	SIGNAL mm_re            : STD_LOGIC                                     := '0';
	SIGNAL mm_rd_ready      : STD_LOGIC                                     := '0';
	SIGNAL mm_data          : STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0)   := (others => 'Z');
	SIGNAL mm_initialize    : STD_LOGIC                                     := '0';
	type state is (idle, read1, read2, write1, write2);
	signal y : state;
begin

	--Instantiation of the main memory component (DO NOT MODIFY)
	main_memory : ENTITY work.Main_Memory
      GENERIC MAP (
			Num_Bytes_in_Word	=> NUM_BYTES_IN_WORD,
			Num_Bits_in_Byte 	=> NUM_BITS_IN_BYTE,
			Read_Delay        => 0,
			Write_Delay       => 0
      )
      PORT MAP (
        clk					=> clk,
        address     => mm_address,
        Word_Byte   => Word_Byte,
        we          => mm_we,
        wr_done     => mm_wr_done,
        re          => mm_re,
        rd_ready    => mm_rd_ready,
        data        => mm_data,
        initialize  => mm_initialize,
        dump        => '0'
      );

process (clk, reset)
begin
	if reset = '1' then
		y <= idle;
		busy1 <= '0';
		busy2 <= '0';
		mm_re <= '0';
		mm_we <= '0';

		mm_initialize <= '1';
	elsif (clk'event) then
		mm_initialize <= '0';
		case y is
			when idle =>
				if re1 = '1' then
					--SHOW("Goinggggggggggggggggg to read 1");
					SHOW("Memory Arbiter started 1 reading address " & integer'image(addr1));
					mm_address <= addr1;
					mm_re <= re1;
					mm_we <= we1;
					busy1 <= '1';
					y <= read1;
				elsif we1 = '1' then
					--SHOW("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiin memory_arbiter idle we1 = 1    >>>>" & INTEGER'image(addr1));
					mm_address <= addr1;
					mm_re <= re1;
					mm_we <= we1;
					busy1 <= '1';
					y <= write1;
				elsif re2 = '1' then
					--SHOW("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiin memory_arbiter re2 = 1    >>>>" & INTEGER'image(addr2));
					mm_address <= addr2;
					mm_re <= re2;
					mm_we <= we2;
					busy2 <= '1';
					y <= read2;
				elsif we2 = '1' then
					mm_address <= addr2;
					mm_re <= re2;
					mm_we <= we2;
					busy2 <= '1';
					y <= write2;
				else
					y <= idle;
				end if;
			when read1 =>
				--SHOW("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA Read 1 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
				busy1 <= '1';
				mm_address <= addr1;
				mm_re <= re1;
				mm_we <= we1;
				--SHOW("Here Leonardo DiCaprio" & STD_LOGIC'image(mm_re));
				if (re2 = '1' or we2 = '1') then
					busy2 <= '1';
				else
					busy2 <= '0'; -- user cancels mem access on 2
				end if;

				if (mm_rd_ready = '1') then
					--SHOW("Memory Arbiter finished 1 reading address " & integer'image(addr1));
					mm_re <= '0';
					mm_we <= '0';
					busy1 <= '0';
					data1_out <= mm_data;
					--SHOW("Here Will Smith" & STD_LOGIC'image(mm_data(31)) & STD_LOGIC'image(mm_data(30)) & STD_LOGIC'image(mm_data(29)) & STD_LOGIC'image(mm_data(28)) & STD_LOGIC'image(mm_data(27)) & STD_LOGIC'image(mm_data(26)) & STD_LOGIC'image(mm_data(25)) & STD_LOGIC'image(mm_data(24)) & STD_LOGIC'image(mm_data(23)) & STD_LOGIC'image(mm_data(22)) & STD_LOGIC'image(mm_data(21)) & STD_LOGIC'image(mm_data(20)) & STD_LOGIC'image(mm_data(19)) & STD_LOGIC'image(mm_data(18)) & STD_LOGIC'image(mm_data(17)) & STD_LOGIC'image(mm_data(16)) & STD_LOGIC'image(mm_data(15)) & STD_LOGIC'image(mm_data(14)) & STD_LOGIC'image(mm_data(13)) & STD_LOGIC'image(mm_data(12)) & STD_LOGIC'image(mm_data(11)) & STD_LOGIC'image(mm_data(10)) & STD_LOGIC'image(mm_data(9)) & STD_LOGIC'image(mm_data(8)) & STD_LOGIC'image(mm_data(7)) & STD_LOGIC'image(mm_data(6)) & STD_LOGIC'image(mm_data(5)) & STD_LOGIC'image(mm_data(4)) & STD_LOGIC'image(mm_data(3)) & STD_LOGIC'image(mm_data(2)) & STD_LOGIC'image(mm_data(1)) & STD_LOGIC'image(mm_data(0)));
					y <= idle;
				else
					if (re1 = '0') then --user cancels read
						y <= idle;
					else
						y <= read1;
					end if;
				end if;
			when write1 =>
				--SHOW("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii memory_arbiter writing to memory at address: >>>" & INTEGER'image(addr1));
				busy1 <= '1';
				mm_address <= addr1;
				mm_data <= data1_in;
				mm_we <= we1;
				mm_re <= re1;
				if (re2 = '1' or we2 = '1') then
					busy2 <= '1';
				else
					busy2 <= '0'; -- user cancels mem access on 2
				end if;
				if (mm_wr_done = '1') then
					busy1 <= '0';
					y <= idle;
				else
					y <= write1;
				end if;
			when read2 =>
				--SHOW("77777777777777777777777777777777777777777 in memory_arbiter re2 = 1    >>>>" & INTEGER'image(addr2));
				busy2 <= '1';
				mm_address <= addr2;
				--mm_data <= data2;
				mm_re <= re2;
				mm_we <= we2;
				if (re1 = '1' or we1 = '1') then
					busy1 <= '1';
				else
					busy1 <= '0'; -- user cancels mem access on 1
				end if;



				if (mm_rd_ready = '1') then
					--SHOW("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA Read 2 done");
					busy2 <= '0';
					data2_out <= mm_data;
					mm_re <= '0';
					mm_we <= '0';
					y <= idle;
				else
					if (re2 = '0') then --user cancels mem access
						y <= idle;
					else
						y <= read2;
					end if;
				end if;
			when write2 =>
				busy2 <= '1';
				mm_address <= addr2;
				mm_data <= data2_in;
				mm_we <= we2;
				mm_re <= re2;
				if (re1 = '1' or we1 = '1') then
					busy1 <= '1';
				else
					busy1 <= '0'; -- user cancels mem access on 1
				end if;
				if (mm_wr_done = '1') then
					busy2 <= '0';
					data2_out <= mm_data;
					mm_re <= '0';
					mm_we <= '0';
					y <= idle;
				else
					y <= write2;
				end if;
			end case;
		end if;
end process;



end behavioral;