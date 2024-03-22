library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Decoder_Hamming is port(
	i_Data : in std_logic;
	i_nR : in std_logic;
	i_clk : in std_logic;
	o_err_exist : out std_logic;
	o_err_num : out integer range 0 to 7;
	o_Data : out std_logic_vector(6 downto 0)
);
end entity;

architecture RTL of Decoder_Hamming is
signal Data_tx : std_logic_vector(6 downto 0);
signal cnt_bit_input : std_logic_vector(2 downto 0);
begin
	process(i_clk, i_nR)
		variable DATA_info : std_logic_vector(3 downto 0);
		variable PARITY_in : std_logic_vector(2 downto 0);
		variable PARITY_dec : std_logic_vector(2 downto 0);
	begin
		if (i_nR = '0') then
			o_err_exist <= '0';
			o_err_num <= 0;
			Data_tx <= (others => '0');
			o_Data <= (others => '0');
			cnt_bit_input <= (others => '0');
		elsif (rising_edge(i_clk)) then
			if cnt_bit_input < "111" then
				Data_tx <= Data_tx(5 downto 0) & i_Data;
				cnt_bit_input <= cnt_bit_input + '1';
			else
				DATA_info := Data_tx(3 downto 0);
				PARITY_in := Data_tx(6 downto 4);
				PARITY_dec := (DATA_info(1) xor DATA_info(2) xor DATA_info(3))
								& (DATA_info(0) xor DATA_info(2) xor DATA_info(3))
								& (DATA_info(0) xor DATA_info(1) xor DATA_info(3));
				case (PARITY_dec xor PARITY_in) is
					when "000" => o_err_exist <= '0'; o_err_num <= 0; o_Data <= Data_tx;
					when "100" => o_err_exist <= '1'; o_err_num <= 7; o_Data <= not(Data_tx(6)) & Data_tx(5 downto 0);
					when "010" => o_err_exist <= '1'; o_err_num <= 6; o_Data <= Data_tx(6) & not(Data_tx(5)) & Data_tx(4 downto 0);
					when "001" => o_err_exist <= '1'; o_err_num <= 5; o_Data <= Data_tx(6 downto 5) & not(Data_tx(4)) & Data_tx(3 downto 0);
					when "111" => o_err_exist <= '1'; o_err_num <= 4; o_Data <= Data_tx(6 downto 4) & not(Data_tx(3)) & Data_tx(2 downto 0);
					when "110" => o_err_exist <= '1'; o_err_num <= 3; o_Data <= Data_tx(6 downto 3) & not(Data_tx(2)) & Data_tx(1 downto 0);
					when "101" => o_err_exist <= '1'; o_err_num <= 2; o_Data <= Data_tx(6 downto 2) & not(Data_tx(1)) & Data_tx(0);
					when "011" => o_err_exist <= '1'; o_err_num <= 1; o_Data <= Data_tx(6 downto 1) & not(Data_tx(0));
					when others => null;
				end case;
				cnt_bit_input <= (others => '0');
				Data_tx <= (others => '0');
			end if;
		end if;
	end process;
end architecture;
