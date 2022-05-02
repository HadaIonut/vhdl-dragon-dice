
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           btnC : in std_logic;
--           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out std_logic_vector (3 downto 0);
           seg : out std_logic_vector (0 to 6);
           dp : out STD_LOGIC
         );
end fsm;

architecture Behavioral of fsm is

type int_array is array(0 to 3) of integer;
signal rnd : STD_LOGIC_VECTOR (2 downto 0);
signal diceValues:  int_array;
signal currentDice: integer := 0;

type states is (start, get_rnd, show);
signal current_state, next_state : states;
signal Din : STD_LOGIC_VECTOR (15 downto 0); 
signal dp_in : STD_LOGIC_VECTOR (3 downto 0);


component driver7seg is
    Port ( clk : in STD_LOGIC; --100MHz board clock input
           Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
           dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
           rst : in STD_LOGIC); --global reset
end component driver7seg;

begin

u_ssd: driver7seg port map ( clk => clk,
               Din => Din,
               an => an,
               seg => seg,
               dp_in => dp_in,
               dp_out => dp,
               rst => rst);

process (clk, rst)
begin
  if rst = '1' then
    current_state <= start;
  elsif rising_edge(clk) then
    current_state <= next_state;
  end if;    
end process;
        
process (current_state)
begin
  case current_state is
    when start => next_state <= get_rnd;
    when get_rnd => if currentDice < 4 then
                        next_state <= get_rnd;
                    else
                        next_state <= show;
                    end if;
    when others => next_state <= start;
  end case;                                            
end process;

--random number generator
lfsr: process (clk, rst)
variable shiftreg : std_logic_vector(15 downto 0) := x"ABCD";
variable firstbit : std_logic;
begin
  if rst = '1' then
    shiftreg := x"ABCD";
    rnd <= "000";
  elsif rising_edge(clk) then
    firstbit := shiftreg(1) xnor  shiftreg(0);
    shiftreg := firstbit & shiftreg(15 downto 1);
    rnd <= shiftreg(2 downto 0);
  end if;
end process;

generate_i: process (clk, rst)
begin
  if rst = '1' then
     diceValues(currentDice) <= 0;
     currentDice <= 0;
  elsif rising_edge(clk) then
     if current_state = get_rnd then
        diceValues(currentDice) <= to_integer(unsigned(rnd)) + 1;
        currentDice <= currentDice + 1;
     end if;
  end if;
end process;

show_random_values: process (clk, rst)
begin
    if current_state = show then    
        Din <= std_logic_vector(to_unsigned(diceValues(0), 4)) & 
               std_logic_vector(to_unsigned(diceValues(1), 4)) &
               std_logic_vector(to_unsigned(diceValues(2), 4)) &
               std_logic_vector(to_unsigned(diceValues(3), 4));
    end if;
end process;

end Behavioral;
