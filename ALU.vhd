
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use work.ForwardingUtil.all;


entity ALU is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			data1	:	in signed(32-1 downto 0);
			data2	:	in signed(32-1 downto 0);

			operation : in STD_LOGIC_VECTOR(6-1 downto 0);
			lo_reg : out signed (32-1 downto 0);
			hi_reg : out signed (32-1 downto 0);
			buffered_result : out previous_alu_array;
			result : out signed(32-1 downto 0)
	);
end ALU;

architecture behavioral of ALU is

signal hi_reg_internal, lo_reg_internal : signed (32-1 downto 0) := (others => '0');
signal mult_result : signed (64-1 downto 0) := (others => '0');
signal internal_buffered_result : previous_alu_array;

begin

	hi_reg_internal <= 	mult_result(64-1 downto 32) when operation = "011000" else
								data1 mod data2 when operation = "011010" else
								hi_reg_internal;

	lo_reg_internal <= 	mult_result(32-1 downto 0) when operation = "011000" else
								data1 / data2 when operation = "011010" else
								lo_reg_internal;

	hi_reg <= hi_reg_internal;
	lo_reg <= lo_reg_internal;

	buffered_result <= internal_buffered_result;

	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			for i in internal_buffered_result'range loop
				internal_buffered_result(i) <= (others => '0');
			end loop;
		elsif (rising_edge(clk)) then
			internal_buffered_result(0) <= internal_buffered_result(1);
			internal_buffered_result(1) <= internal_buffered_result(2);

			case( operation ) is
				when "100000" => --add
					SHOW("Adding two things " & integer'image(to_integer(data1)) & integer'image(to_integer(data2)));
					internal_buffered_result(2) <= data1 + data2;
					result <= data1 + data2;
				when "100010" => --sub
					SHOW("Subing two things " & integer'image(to_integer(data1)) & integer'image(to_integer(data2)));
					internal_buffered_result(2) <= data1 - data2;
					result <= data1 - data2; --Add overflow
				when "011000" => --mult
					SHOW("Multing two things " & integer'image(to_integer(data1)) & integer'image(to_integer(data2)));
					mult_result <= data1 * data2;
					--hi_reg <= mult_result(64-1 downto 32);
					--lo_reg <= mult_result(32-1 downto 0);
				when "011010" => --div
					--lo_reg <= data1 / data2;
					--hi_reg <= data1 mod data2;
				when "101010" => --slt
					if data1 < data2 then
						internal_buffered_result(2) <= to_signed(1, 32);
						result <= to_signed(1, 32);
					else
						internal_buffered_result(2) <= to_signed(0, 32);
						result <= to_signed(0, 32);
					end if;
				when "100100" => --and
					internal_buffered_result(2) <= data1 and data2;
					result <= data1 and data2;
				when "100101" => --or
					internal_buffered_result(2) <= data1 or data2;
					result <= data1 or data2;
				when "100111" => --nor
					internal_buffered_result(2) <= data1 nor data2;
					result <= data1 nor data2;
				when "100110" => --xor
					internal_buffered_result(2) <= data1 xor data2;
					result <= data1 xor data2;
				when "000000" => --sll
					internal_buffered_result(2) <= data1 sll to_integer(data2);
					result <= data1 sll to_integer(data2);
				when "000010" => --srl
					internal_buffered_result(2) <= data1 srl to_integer(data2);
					result <= data1 srl to_integer(data2);
				when "000011" => --sra
					internal_buffered_result(2) <= shift_right(data1, to_integer(data2));
					result <= shift_right(data1, to_integer(data2));
				when others =>
			end case ;
		end if;
	end process ; -- synced_clock
	

end behavioral;
