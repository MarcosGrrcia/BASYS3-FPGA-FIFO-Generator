LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.STD_LOGIC_UNSIGNED.all;

ENTITY pulse IS
	port( clock: in std_logic;
	      kkey: in std_logic;
	      ppulse: out std_logic);
END pulse;

ARCHITECTURE behavorial of pulse IS
	COMPONENT SingPul 
		port( clk,key: in std_logic;
		      pulse: out std_logic);
	END COMPONENT;
	COMPONENT CDiv 
		port( Cin: in std_logic;
		      Cout: out std_logic);
	END COMPONENT;

SIGNAL clks: std_logic; 

BEGIN
	CDiv1: CDiv 
		port map(
			Cin => clock, 
			Cout => clks
		);

	SingPul1: SingPul 
		port map(
			clk => clks,
			key => kkey,
			pulse => ppulse
		); 

END behavorial;
