library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out std_logic_vector (3 downto 0);
           seg : out std_logic_vector (0 to 6);
           dp : out std_logic
           );
end fsm;

architecture Behavioral of fsm is
    
type states is (start, get_rnd, led_on, sw_on, sw_off, led_off, count);
signal current_state, next_state : states;
    
signal i : integer range 0 to 15;    
signal rnd : STD_LOGIC_VECTOR (3 downto 0);

signal score : STD_LOGIC_VECTOR (15 downto 0);

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

u : driver7seg port map (clk => clk,
                         Din => score,
                         an => an,
                         seg => seg,
                         dp_in => "0000",
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
        
process (current_state, sw, i)
begin
  case current_state is
    when start => next_state <= get_rnd;
    when get_rnd => next_state <= led_on;
    when led_on => next_state <= sw_on;
    when sw_on => if sw(i) = '1' then
                     next_state <= sw_off;
                  else
                     next_state <= sw_on;
                  end if;
    when sw_off => if sw(i) = '0' then
                     next_state <= led_off;
                   else
                     next_state <= sw_off;
                   end if;
    when led_off => next_state <= count;
    when count => next_state <= get_rnd;
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
    rnd <= x"D";
  elsif rising_edge(clk) then
    firstbit := shiftreg(1) xnor  shiftreg(0);
    shiftreg := firstbit & shiftreg(15 downto 1);
    rnd <= shiftreg(3 downto 0);   
  end if;
end process;

generate_i: process (clk, rst)
begin
  if rst = '1' then
     i <= 0;
  elsif rising_edge(clk) then
     if current_state = get_rnd then
        i <= to_integer(unsigned(rnd));
     end if;
  end if;
end process;

-- LED display
generate_led: process (clk, rst)
begin
  if rst = '1' then
    led <= (others => '0');
  elsif rising_edge(clk) then
    if current_state = led_on then
       led(i) <= '1';
    elsif current_state = led_off then
       led(i) <= '0';
    end if;
  end if;
end process; 
    
    
-- SSD display       
generate_scor: process (clk, rst)
  variable mii, sute, zeci, unitati: integer range 0 to 9 := 0;
begin
  if rst = '1' then
    score <= (others => '0');
    mii := 0;
    sute := 0;
    zeci := 0;
    unitati := 0;
  elsif rising_edge(clk) then
    if current_state = count then
      if unitati = 9 then
        unitati := 0;
        if zeci = 9 then
          zeci := 0;
          if sute = 9 then
            sute := 0;
            if mii = 9 then
              mii := 0;
            else
              mii := mii+1;
            end if;
          else
            sute := sute+1;
          end if;
        else
          zeci := zeci+1;
        end if;
      else
        unitati := unitati+1;
    end if;
    
    score <= std_logic_vector(to_unsigned(mii,4)) &
             std_logic_vector(to_unsigned(sute,4)) &
             std_logic_vector(to_unsigned(zeci,4)) &
             std_logic_vector(to_unsigned(unitati,4));
    
    end if;
  end if;
end process;     
     
end Behavioral;
