library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity driver7seg is
    Port ( clk : in STD_LOGIC; --100MHz board clock input
           Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
           dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
           rst : in STD_LOGIC); --global reset
end driver7seg;

architecture Behavioral of driver7seg is

signal clk1kHz : STD_LOGIC;
signal state : STD_LOGIC_VECTOR(23 downto 0);
signal addr : STD_LOGIC_VECTOR(1 downto 0);
signal cseg : STD_LOGIC_VECTOR(3 downto 0);

begin

-- frequency divider by 100k to generate 1kHz anode sweeping clock
-- counting from 0 to 99999, output is MSB 
-- 17 counter state length needed 
div1kHz: process(clk, rst)
begin
   if rst = '1' then 
        state <= X"000000";
   else
     if rising_edge(clk) then
        if state = X"98967F" then --if counte reaches 99999
            state <= X"000000"; -- reset back to 0
        else
            state <= state+1;
        end if;
     end if;
   end if;         
end process;

clk1Khz <= state(23); --assign MSB to frequency divider output


-- 2 bit counter generating 4 addresses for display multiplexing
counter_2bits: process(clk1kHz)
begin
  if rising_edge(clk1kHz) then       
           addr <= addr+1;   
  end if;   
end process;

-- 2 to 4 decoder used to select one display of 4 at each sweeping address generated by the 2 bit counter 
-- anodes are active low, decoder must provide '0' for activation
dcd3_8: process(addr)
begin
  case addr is
      when "00" =>  an <= "0111";       
      when "01" =>  an <= "1011"; 
      when "10" =>  an <= "1101"; 
      when "11" =>  an <= "1110"; 
      when others => an <= "1111";
   end case; 
end process;

--4 input multiplexer to select data to be sent to a single display
--synchronzied with addr and display activation with the anodes
data_mux4: process(addr,Din,dp_in)
begin
  case addr is
      when "00" =>  cseg <= Din(15 downto 12); --sending 4 upper bits targeted at display 3  
                    dp_out <= not dp_in(3); -- lighting up decimal point on display 3
      when "01" =>  cseg <= Din(11 downto 8); --sending next 4 bits targeted at display 2
                    dp_out <= not dp_in(2); -- lighting up decimal point on display 2
      when "10" =>  cseg <= Din(7 downto 4);  -- ....
                    dp_out <= not dp_in(1);
      when "11" =>  cseg <= Din(3 downto 0); -- ....
                    dp_out <= not dp_in(0);
      when others => cseg <= "XXXX";
                     dp_out <= 'X';
   end case; 
end process;

--binary to 7 segment decoder
--cathodes also active low, provide '0' for a lit up segment or decimal point
dcd7seg:process(cseg)
begin
  case cseg is
      when "0000" =>  seg <= "0000001"; 
      when "0001" =>  seg <= "1001111"; 
      when "0010" =>  seg <= "0010010"; 
      when "0011" =>  seg <= "0000110"; 
      when "0100" =>  seg <= "1001100"; 
      when "0101" =>  seg <= "0100100"; 
      when "0110" =>  seg <= "0100000"; 
      when "0111" =>  seg <= "0001111";
      when "1000" =>  seg <= "0000000"; 
      when "1001" =>  seg <= "0000100"; 
      when "1010" =>  seg <= "0000010"; 
      when "1011" =>  seg <= "1100000"; 
      when "1100" =>  seg <= "0110001"; 
      when "1101" =>  seg <= "1000010"; 
      when "1110" =>  seg <= "0110000"; 
      when "1111" =>  seg <= "0111000";
      when others => seg <= "XXXXXXX";
   end case; 
end process;

end Behavioral;
