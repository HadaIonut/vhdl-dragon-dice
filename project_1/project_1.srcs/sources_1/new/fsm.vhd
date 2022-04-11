
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
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out std_logic_vector (3 downto 0);
           seg : out std_logic_vector (0 to 6)
         );
end fsm;

architecture Behavioral of fsm is

type int_array is array(0 to 3) of integer;

signal rnd : STD_LOGIC_VECTOR (2 downto 0);
signal diceValues:  int_array;
signal currentDice: integer;

type states is (start, get_rnd, show);
signal current_state, next_state : states;


begin

--random number generator
lfsr: process (clk, rst)
variable shiftreg : std_logic_vector(15 downto 0) := x"ABCD";
variable firstbit : std_logic;
begin
  if rst = '1' then
    shiftreg := x"ABCD";
    rnd <= x"D";
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
  elsif rising_edge(clk) then
     if current_state = get_rnd then
        diceValues(currentDice) <= to_integer(unsigned(rnd));
     end if;
  end if;
end process;

end Behavioral;
