
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;

entity Decoder is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			instruction : in STD_LOGIC_VECTOR(32-1 downto 0);

			pc_reg : in STD_LOGIC_VECTOR(32-1 downto 0);
			registers : in register_array;

			operation : out STD_LOGIC_VECTOR(6-1 downto 0);
			mem_writeback_register : out STD_LOGIC_VECTOR(5-1 downto 0); --send to memstage or writeback
			-- for store, this represents the register that we're storing. For load, this represents the register getting the value from memory.
			signal_to_mem : out STD_LOGIC_VECTOR(3-1 downto 0); --send to mem stage
			writeback_source : out STD_LOGIC_VECTOR(3-1 downto 0); --send to writeback
			branch_signal : out STD_LOGIC_VECTOR(2-1 downto 0); --send to branch
			branch_address : out STD_LOGIC_VECTOR(32-1 downto 0);
			data1 : out STD_LOGIC_VECTOR(32-1 downto 0); --send to ALU
			data2 : out STD_LOGIC_VECTOR(32-1 downto 0) --send to ALU

	);
end Decoder;

architecture behavioral of Decoder is


signal op_code, funct : STD_LOGIC_VECTOR(6-1 downto 0);
signal rs, rt, rd ,sa : STD_LOGIC_VECTOR(5-1 downto 0);
signal immediate : STD_LOGIC_VECTOR(16-1 downto 0);
signal target : STD_LOGIC_VECTOR(26-1 downto 0);


begin
	op_code <= instruction(32-1 downto 26);
	rs <= instruction(25 downto 21);
	rt <= instruction(20 downto 16);
	rd <= instruction(15 downto 11);
	sa <= instruction(10 downto 6);
	funct <= instruction(5 downto 0);
	immediate <= instruction(15 downto 0);
	target <= instruction(25 downto 0);

	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif (rising_edge(clk)) then
			if instruction = STD_LOGIC_VECTOR(ALL_32_ZEROES) then
			else
				branch_signal <= BRANCH_NOT;
			
				case( op_code ) is
					
					when "000000" =>
						operation <= funct;
						mem_writeback_register <= rd;
						case( funct ) is
							when "100000" => --add
								REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ADD!!!" & integer'image(to_integer(unsigned(rs))) & integer'image(to_integer(unsigned(rt)));
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "100010" => --sub
								REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SUB!!!" & integer'image(to_integer(unsigned(rs))) & integer'image(to_integer(unsigned(rt)));
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "011000" => --mult
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "011010" => --div
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "100100" => --and
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "100101" => --or
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "100111" => --nor
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "100110" => --xor
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;

							--A wild jr appears
							when "001000" => --jr
								operation <= (others => '0'); --Tell ALU to not do anything
								writeback_source <= NO_WRITE_BACK;
								mem_writeback_register <= "00000"; --Don't write back

								branch_signal <= BRANCH_ALWAYS;
								branch_address <= registers(to_integer(unsigned(rs)));
	-------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------SHIFTS OPERATIONS-------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------------
							when "101010" => --slt
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "000000" => --sll
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= STD_LOGIC_VECTOR(resize(signed(sa), data2'length));
								writeback_source <= ALU_AS_SOURCE;
							when "000010" => --srl
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= STD_LOGIC_VECTOR(resize(signed(sa), data2'length));
								writeback_source <= ALU_AS_SOURCE;
							when "000011" => --sra
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= STD_LOGIC_VECTOR(resize(signed(sa), data2'length));
								writeback_source <= ALU_AS_SOURCE;

							when "010000" => --mfhi
								writeback_source <= HI_AS_SOURCE;
							when "010010" => --mflo
								writeback_source <= LO_AS_SOURCE;
							
							when others =>
						
						end case ;
	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------IMMEDIATE OPERATIONS----------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------
					when "001000" => -- addi
						operation <= "100000";
						data1 <= registers(to_integer(unsigned(rs)));
						data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= ALU_AS_SOURCE;
					when "001010" => -- slti
						REPORT "Here slti";
						operation <= "101010";
						data1 <= registers(to_integer(unsigned(rs)));
						data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= ALU_AS_SOURCE;
					when "001100" => -- andi
						REPORT "Here andi";
						operation <= "100100";
						data1 <= registers(to_integer(unsigned(rs)));
						data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= ALU_AS_SOURCE;
					when "001101" => -- ori
						REPORT "Here ori";
						operation <= "100101";
						data1 <= registers(to_integer(unsigned(rs)));
						data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= ALU_AS_SOURCE;
					when "001110" => -- xori
						REPORT "Here xori";
						operation <= "100110";
						data1 <= registers(to_integer(unsigned(rs)));
						data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= ALU_AS_SOURCE;

	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------MEMORY OPERATIONS-------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------
					when "001111" => --lui --We shift the immediate value by 16 using the ALU
						REPORT "Here lui";
						operation <= "000000"; --sll
						data1	<= STD_LOGIC_VECTOR(resize(signed(immediate), data1'length));
						data2	<= STD_LOGIC_VECTOR(to_unsigned(16, data2'length));
						mem_writeback_register <= rt;
						writeback_source <= ALU_AS_SOURCE;
					when "100011" => --lw
						REPORT "Here lw";
						operation <= "100000"; --add
						data1	<= registers(to_integer(unsigned(rs)));
						data2	<= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= MEM_AS_SOURCE;
						signal_to_mem <= LOAD_WORD;
					when "101011" => --sw
						REPORT "Here sw";
						operation <= "100000"; --add
						data1	<= registers(to_integer(unsigned(rs)));
						data2	<= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt; --Don't write back
						writeback_source <= NO_WRITE_BACK;
						signal_to_mem <= STORE_WORD;
					when "100000" => --lb
						REPORT "Here lb";
						operation <= "100000"; --add
						data1	<= registers(to_integer(unsigned(rs)));
						data2	<= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= MEM_AS_SOURCE;
						signal_to_mem <= LOAD_BYTE;
					when "101000" => --sb
						REPORT "Here sb";
						operation <= "100000"; --add
						data1	<= registers(to_integer(unsigned(rs)));
						data2	<= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt; --Don't write back
						writeback_source <= NO_WRITE_BACK;
						signal_to_mem <= STORE_BYTE;
	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------BRANCH AND JUMPS--------------------------------------------------------------------
	-----------------------------------------------Assume resolved in Decode-----------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------
					when "000100" => --beq
						REPORT "Here beq";
						operation <= (others => '0'); --Tell ALU to not do anything
						writeback_source <= NO_WRITE_BACK;
						mem_writeback_register <= "00000"; --Don't write back

						if registers(to_integer(unsigned(rs))) = registers(to_integer(unsigned(rt))) then --Do branch
							branch_signal <= BRANCH_ALWAYS;
							branch_address <= std_logic_vector(resize(unsigned(immediate), branch_address'length));
						else
							branch_signal <= BRANCH_NOT;
						end if;
					when "000101" => --bne
						REPORT "Here bne";
						operation <= (others => '0'); --Tell ALU to not do anything
						writeback_source <= NO_WRITE_BACK;
						mem_writeback_register <= "00000"; --Don't write back

						if registers(to_integer(unsigned(rs))) /= registers(to_integer(unsigned(rt))) then --Do branch
							branch_signal <= BRANCH_ALWAYS;
							branch_address <= std_logic_vector(resize(unsigned(immediate), branch_address'length));
						else
							branch_signal <= BRANCH_NOT;
						end if;
					when "000010" => --j
						REPORT "Here j";
						operation <= (others => '0'); --Tell ALU to not do anything
						writeback_source <= NO_WRITE_BACK;
						mem_writeback_register <= "00000"; --Don't write back
						branch_signal <= BRANCH_ALWAYS;
						branch_address <= std_logic_vector(resize(unsigned(target), branch_address'length));
					when "000011" => --jal --> $31 = $PC + 8, jump
						REPORT "Here jal";
						--The address in $ra is really PC+8. The instruction immediately following the jal instruction is in the "branch delay slot"
						operation <= "100000"; --add
						data1	<= pc_reg;
						data2	<= STD_LOGIC_VECTOR(to_unsigned(8, data2'length));
						mem_writeback_register <= "11111"; --$31 = $PC + 8
						writeback_source <= ALU_AS_SOURCE;
						branch_signal <= BRANCH_ALWAYS;
						branch_address <= std_logic_vector(resize(unsigned(target), branch_address'length));
					--when => --jr (see above)
					when others =>
				
				end case ;
			end if ;
		end if;
	end process ; -- synced_clock
	

end behavioral;
