library ieee;

use ieee.std_logic_1164.all;

entity tb_Decoder_Hamming is
end entity;

architecture tb of tb_Decoder_Hamming is
signal data : std_logic;
signal nR : std_logic;
signal clk : std_logic;
signal err_exist : std_logic;
signal err_num : integer range 0 to 7;
signal Data_recovery : std_logic_vector(6 downto 0);
begin
	process
	constant period : time := 200 ns;
	begin
		clk <= '0';
		wait for period/2;
		clk <= not(clk);
		assert (err_exist = '0') report "We have some errors" severity warning;
		wait for period/2;
	end process;
	nR <= '0', '1' after 20 ns;
	
	data <= '0',
			'1' after 150 ns,
			'0' after 350 ns,
			'1' after 550 ns,
			'0' after 950 ns,
			'1' after 1150 ns,
			
			'0' after 1550 ns,
			'1' after 1750 ns,
			'0' after 1950 ns,
			'1' after 2150 ns,
			'0' after 2350 ns,
			'1' after 2750 ns,
			
			'1' after 3150 ns,
			'1' after 3350 ns,
			'0' after 3550 ns,
			'1' after 3750 ns,
			'0' after 4150 ns,
			'1' after 4350 ns;
	DUT : entity work.Decoder_Hamming(RTL) port map(data, nR, clk, err_exist, err_num, Data_recovery);

end architecture;