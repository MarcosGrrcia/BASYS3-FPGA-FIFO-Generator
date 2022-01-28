library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity FIFO is
	port( 	clk : in std_logic;	    --Internal clock
            btn : in std_logic;	    --Button
            RWE : in std_logic;	    --Read/Write Enable (Switch)
            data : in std_logic_vector(7 downto 0);	--Data In (Switches)
            LR : out std_logic;	    --Read LED
            LW : out std_logic;	    --Write LED
            LF : out std_logic;	    --Full Indicator LED
            LE : out std_logic;	    --Empty Indicator LED
            LAF : out std_logic;	--Almost Full Indicator LED
            LAE : out std_logic;	--Almost Empty Indicator LED
            LED : out std_logic_vector(6 downto 0);	--7 Segment Display Cathode
            an : out std_logic_vector(3 downto 0));	--7 Segment Display Anode
end FIFO;

architecture Behavioral of FIFO is

component pulse is
	port(   clock : in std_logic;
            kkey : in std_logic;
            ppulse : out std_logic);
end component;

component blk_mem is
	port(	clka : in std_logic;
            ena : in std_logic;
            wea : in std_logic_vector(0 downto 0);
            addra : in std_logic_vector(3 downto 0);
            dina : in std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0));
end component;

signal press : std_logic;	--Signal for button press
signal radd, wadd, tadd : std_logic_vector(3 downto 0) := "0000";	--Signals to keep track of addresses
signal dout : std_logic_vector(7 downto 0);	--Buffer signal for BRAM output
signal refresh : std_logic_vector(19 downto 0);	--Vector to control timing for 2 digit display
signal LED_act : std_logic_vector(1 downto 0) := "00";	--Bit to control 2 digit display (multiplexing)
signal LED_out : std_logic_vector(3 downto 0) := "0000";	--Vector to transfer data to the LED_BCD
signal tf, taf, tae : std_logic := '0';	--FIFO flags
signal te : std_logic := '1';    --FIFO flags

begin

pulse1: pulse port map(clock => clk, kkey => btn, ppulse => press);

mem: blk_mem port map(clka => press, ena => '1', wea(0) => RWE, addra => tadd, dina => data, douta => dout);

process(clk)    --process increments a refresh counter for the 7-Seg display
begin
	if(rising_edge(clk)) then
		refresh <= refresh + 1;
	end if;
end process;

LED_act <= refresh(19 downto 18);   --reads refresh vector's most significant bit

--Takes a 4 bit input and transfers it to a 7-seg code in order to output it as a decimal
process(LED_out)
begin
	case LED_out is
		when "0000" => LED <= "0000001";	--"0"
		when "0001" => LED <= "1001111";	--"1"
		when "0010" => LED <= "0010010";	--"2"
		when "0011" => LED <= "0000110";	--"3"
		when "0100" => LED <= "1001100";	--"4"
		when "0101" => LED <= "0100100";	--"5"
		when "0110" => LED <= "0100000";	--"6"
		when "0111" => LED <= "0001111";	--"7"
		when "1000" => LED <= "0000000";	--"8"
		when "1001" => LED <= "0000100";	--"9"
		when "1010" => LED <= "0000010";	--a
		when "1011" => LED <= "1100000";	--b
		when "1100" => LED <= "0110001";	--c
		when "1101" => LED <= "1000010";	--d
		when "1110" => LED <= "0110000";	--e
		when "1111" => LED <= "0111000";	--f
    end case;
end process;

--Sets FIFO flags and updates a buffer address with sensitivity to read/write enables
process(RWE)
 begin
    if (RWE = '1') then
        LR <= '0';
        LW <= '1';
        tadd <= wadd;
    else
        LR <= '1';
        LW <= '0';
        tadd <= radd;
    end if;
end process;

LF <= tf;
LE <= te;
LAF <= taf;
LAE <= tae;

--Controls the switching between the LEDs on the 7 segment display
process(LED_act)
begin
    case LED_act is 
        when "00" =>
            an <= "1110";
            if RWE = '0' then
                LED_out <= dout(3 downto 0);
            else
                LED_out <= data(3 downto 0);
            end if;
        when "01" =>
            an <= "1101";
            if RWE = '0' then
                LED_out <= dout(7 downto 4);
            else
                LED_out <= data(7 downto 4);
            end if;
        when "10" =>
            an <= "0111"; 
            LED_out <= tadd;
        when others =>
            an <= "1111";
    end case;
end process;

--FIFO logic. Increments or decrements a counter for the num of elements in the BRAM and adds
--to the read or write addresses based on RWE. THe counter checks for FIFO flags.
process(press)
variable num_el: integer := 0;
begin
    if rising_edge(press) then
        if (RWE = '1') then
            if (tf = '0') then
                wadd <= std_logic_vector(unsigned(wadd) + 1);
                num_el := num_el + 1;
            end if;
        end if;
        
        if (RWE = '0') then
            if (te = '0') then
                radd <= std_logic_vector(unsigned(radd) + 1);
                num_el := num_el - 1;
            end if;
        end if;
        
        case num_el is    
            when 0 =>
                te <= '1';
                tae <= '0';
            when 1 =>
                te <= '0';
                tae <= '1';
            when 15 =>
                tf <= '0';
                taf <= '1';
            when 16 =>
                tf <= '1';
                taf <= '0';
            when others =>
                tf <= '0';
                te <= '0';
                taf <= '0';
                tae <= '0';
        end case;
    end if;
end process;

end Behavioral;