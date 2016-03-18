
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity ALU is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			data1	:	in signed(32-1 downto 0);
			data2	:	in signed(32-1 downto 0);

			operation : in STD_LOGIC_VECTOR(6-1 downto 0);
			overflow : out STD_LOGIC;
			result : out signed(32-1 downto 0)
	);
end ALU;

architecture behavioral of ALU is

signal data1_extended, data2_extended, result_extended : signed(33-1 downto 0);

begin

	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif (rising_edge(clk)) then
			case( operation ) is
				when "100000" => --add
					data1_extended <= data1(31) & data1;
					data2_extended <= data2(31) & data2;

					result_extended <= data1_extended + data2_extended;

					if result_extended(32) /= result_extended(31) then
						overflow <= '1';
					else
						overflow <= '0';
					end if;

					result <= result_extended(32-1 downto 0);
				when "100010" => --sub
					result <= data1 - data2; --Add overflow
				when "011000" => --mult
					
				when "011010" => --div
					
				when "101010" => --slt
					if data1 < data2 then
						result <= to_signed(1, 32);
					end if;
				when "100100" => --and
					result <= data1 and data2;
				when "100101" => --or
					result <= data1 or data2;
				when "100111" => --nor
					result <= data1 nor data2;
				when "100110" => --xor
					result <= data1 xor data2;
				when "000000" => --sll
					result <= shift_left(data1, to_integer(data2));
				when "000010" => --srl
					result <= shift_right(data1, to_integer(data2)); --not right. Fix this
				when "000011" => --sra
					result <= shift_right(data1, to_integer(data2));
				when others =>
			end case ;
		end if;
	end process ; -- synced_clock
	

end behavioral;
