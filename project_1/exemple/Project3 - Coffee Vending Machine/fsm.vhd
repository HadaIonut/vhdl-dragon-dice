library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           btn : in std_logic_vector (2 downto 0);
           grinder, watervalve, milkvalve : out std_logic;
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           dp : out STD_LOGIC
           );
end fsm;

architecture Behavioral of fsm is

type states is (idle, add50b, add1ron, add5ron, cmp_money, more_money, sel, espresso, ristretto, cappuccino, 
                e_grind1, e_grind2, e_grind3, e_grind4, e_grind5, e_grind_off,
                e_water1, e_water2, e_water3, e_water4, e_water5, e_water6, e_water7, e_water8, e_water_off,
                c_grind1, c_grind2, c_grind3, c_grind4, c_grind5, c_grind_off,
                c_water1, c_water2, c_water3, c_water4, c_water5, c_water6, c_water7, c_water8, c_water_off,
                c_milk1, c_milk2, c_milk3, c_milk4, c_milk5, c_milk_off,
                r_grind1, r_grind2, r_grind3, r_grind4, r_grind5, r_grind_off,
                r_water1, r_water2, r_water3, r_water4, r_water_off,             
                get_money, serve, serve_delay, change, pay50b, pay_delay,
                err_state
                );
signal current_state, next_state : states;

signal plus50b, plus1ron, plus5ron : std_logic;
signal sel_espresso, sel_ristretto, sel_cappuccino : std_logic;

signal inc1sec : std_logic;
signal en_cnt : std_logic;

signal money_counter : integer;

component driver7seg is
    Port ( clk : in STD_LOGIC; --100MHz board clock input
           Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
           dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
           rst : in STD_LOGIC); --global reset
end component driver7seg;

signal Din : STD_LOGIC_VECTOR (15 downto 0); 
signal dp_in : STD_LOGIC_VECTOR (3 downto 0);

signal money_counter_bcd : std_logic_vector(15 downto 0);

component DeBouncer is
    port(   Clock : in std_logic;
            Reset : in std_logic;
            button_in : in std_logic;
            pulse_out : out std_logic
        );
end component DeBouncer;

signal btn_db : std_logic_vector (2 downto 0);

begin

db2 : DeBouncer port map (Clock => clk,
                          Reset => rst,
                          button_in => btn(2),
                          pulse_out => btn_db (2));

db1 : DeBouncer port map (Clock => clk,
                          Reset => rst,
                          button_in => btn(1),
                          pulse_out => btn_db (1));

db0 : DeBouncer port map (Clock => clk,
                          Reset => rst,
                          button_in => btn(0),
                          pulse_out => btn_db (0));                          

--btn_db <= btn;

plus50b <= btn_db(2) when (current_state = idle or current_state = more_money) else '0';
plus1ron <= btn_db(1) when (current_state = idle or current_state = more_money) else '0';
plus5ron <= btn_db(0) when (current_state = idle or current_state = more_money) else '0';
  
sel_espresso <= btn_db(2) when (current_state = sel) else '0';
sel_ristretto <= btn_db(1) when (current_state = sel) else '0';
sel_cappuccino <= btn_db(0) when (current_state = sel) else '0';

-- display
Din <= "0001110110001110" when current_state = idle
  else money_counter_bcd when current_state = more_money
  else "1001010111101000" when current_state = sel
  else "1001111001011011" when (current_state = espresso or current_state = e_grind1 or current_state = e_grind2
                  or current_state = e_grind3 or current_state = e_grind4 or current_state = e_grind5 
                  or current_state = e_grind_off
                  or current_state = e_water1 or current_state = e_water2 or current_state = e_water3 or current_state = e_water4
                  or current_state = e_water5 or current_state = e_water6 or current_state = e_water7 or current_state = e_water8
                  or current_state = e_water_off)
  else "1001110010101011" when (current_state = cappuccino or current_state = c_grind1 or current_state = c_grind2
                  or current_state = c_grind3 or current_state = c_grind4 or current_state = c_grind5 
                  or current_state = c_grind_off
                  or current_state = c_water1 or current_state = c_water2 or current_state = c_water3 or current_state = c_water4
                  or current_state = c_water5 or current_state = c_water6 or current_state = c_water7 or current_state = c_water8
                  or current_state = c_water_off
                  or current_state = c_milk1 or current_state = c_milk2
                  or current_state = c_milk3 or current_state = c_milk4 or current_state = c_milk5 
                  or current_state = c_milk_off)
  else "1001111100010101" when (current_state = ristretto or current_state = r_grind1 or current_state = r_grind2
                  or current_state = r_grind3 or current_state = r_grind4 or current_state = r_grind5 
                  or current_state = r_grind_off
                  or current_state = r_water1 or current_state = r_water2 or current_state = r_water3 or current_state = r_water4                  
                  or current_state = r_water_off)
  else "1001010111101111" when current_state = serve
  else money_counter_bcd when current_state = serve_delay 
  else money_counter_bcd when current_state = pay_delay
  else "1000100010001000" when current_state = err_state;
  
dp_in <= "0100" when (current_state = more_money or current_state = pay_delay or current_state = serve_delay) else "0000";  -- 
  
money_counter_bcd <= "0000000000000000" when money_counter = 0
                else "0000000001010000" when money_counter = 50
                else "0000000100000000" when money_counter = 100
                else "0000000101010000" when money_counter = 150
                else "0000001000000000" when money_counter = 200
                else "0000001001010000" when money_counter = 250
                else "0000001100000000" when money_counter = 300
                else "0000001101010000" when money_counter = 350
                else "0000010000000000" when money_counter = 400
                else "0000010001010000" when money_counter = 450
                else "0000010100000000" when money_counter = 500
                else "0000010101010000" when money_counter = 550
                else "0000011000000000" when money_counter = 600
                else "0000011001010000" when money_counter = 650
                else "0000011100000000" when money_counter = 700;

u_ssd: driver7seg port map ( clk => clk,
           Din => Din,
           an => an,
           seg => seg,
           dp_in => dp_in,
           dp_out => dp,
           rst => rst);

-- timer
process(clk, rst)
variable q : integer := 0;
begin
  if rst = '1' then
    q := 0;
    inc1sec <= '0';
  elsif rising_edge(clk) then
    if en_cnt = '1' then  
      if q = 10**8 - 1 then
        q := 1;
        inc1sec <= '1';
      else
        q := q + 1;
        inc1sec <= '0';
      end if;
    end if;        
  end if;  
end process;

-- CLS
process(clk, rst)
begin
  if rst = '1' then
    current_state <= idle;
  elsif rising_edge(clk) then
    current_state <= next_state;
  end if;    
end process;

-- CLC
process(current_state, inc1sec, plus50b, plus1ron, plus5ron, sel_espresso, sel_ristretto, sel_cappuccino)
begin
  case current_state is
    when idle => if plus50b = '1' then
                   next_state <= add50b;
                 elsif plus1ron = '1' then
                   next_state <= add1ron;
                 elsif plus5ron = '1' then
                   next_state <= add5ron;
                 else
                   next_state <= idle;
                 end if;        
    when add50b => next_state <= cmp_money;
    when add1ron => next_state <= cmp_money;
    when add5ron => next_state <= cmp_money;  
    
    when cmp_money => if money_counter >= 250 then  --money_ok = '1'
                         next_state <= sel;   -- sel_delay
                      else
                        next_state <= more_money;
                      end if;    
    when more_money => if plus50b = '1' then
                          next_state <= add50b;
                       elsif plus1ron = '1' then
                          next_state <= add1ron;
                       elsif plus5ron = '1' then
                          next_state <= add5ron;
                       else
                          next_state <= more_money;
                       end if;    
    when sel => if sel_espresso = '1' then
                  next_state <= espresso;
                elsif sel_ristretto = '1' then
                  next_state <= ristretto;
                elsif sel_cappuccino = '1' then
                  next_state <= cappuccino;  
                else 
                  next_state <= sel;                              
                end if;                   
    -- espresso
    when espresso => if inc1sec = '1' then
                       next_state <= e_grind1;
                     else
                       next_state <= espresso;  
                     end if;
    when e_grind1 => if inc1sec = '1' then
                       next_state <= e_grind2;
                     end if;    
    when e_grind2 => if inc1sec = '1' then
                       next_state <= e_grind3;
                     end if;    
    when e_grind3 => if inc1sec = '1' then
                       next_state <= e_grind4;
                     end if;    
    when e_grind4 => if inc1sec = '1' then
                       next_state <= e_grind5;
                     end if;      
    when e_grind5 => if inc1sec = '1' then
                       next_state <= e_grind_off;
                     end if;                    
    when e_grind_off => next_state <= e_water1;
    when e_water1 => if inc1sec = '1' then
                       next_state <= e_water2;
                     end if;  
    when e_water2 => if inc1sec = '1' then
                       next_state <= e_water3;
                     end if;
    when e_water3 => if inc1sec = '1' then
                       next_state <= e_water4;
                     end if;
    when e_water4 => if inc1sec = '1' then
                       next_state <= e_water5;
                     end if;
    when e_water5 => if inc1sec = '1' then
                       next_state <= e_water6;
                     end if;
    when e_water6 => if inc1sec = '1' then
                       next_state <= e_water7;
                     end if;
    when e_water7 => if inc1sec = '1' then
                       next_state <= e_water8;
                     end if;    
    when e_water8 => if inc1sec = '1' then
                       next_state <= e_water_off;
                     end if;   
    -- cappuccino
    when cappuccino => if inc1sec = '1' then
                       next_state <= c_grind1;
                     end if;
    when c_grind1 => if inc1sec = '1' then
                       next_state <= c_grind2;
                     end if;    
    when c_grind2 => if inc1sec = '1' then
                       next_state <= c_grind3;
                     end if;    
    when c_grind3 => if inc1sec = '1' then
                       next_state <= c_grind4;
                     end if;    
    when c_grind4 => if inc1sec = '1' then
                       next_state <= c_grind5;
                     end if;      
    when c_grind5 => if inc1sec = '1' then
                       next_state <= c_grind_off;
                     end if;                    
    when c_grind_off => next_state <= c_water1;
    when c_water1 => if inc1sec = '1' then
                       next_state <= c_water2;
                     end if;  
    when c_water2 => if inc1sec = '1' then
                       next_state <= c_water3;
                     end if;
    when c_water3 => if inc1sec = '1' then
                       next_state <= c_water4;
                     end if;
    when c_water4 => if inc1sec = '1' then
                       next_state <= c_water5;
                     end if;
    when c_water5 => if inc1sec = '1' then
                       next_state <= c_water6;
                     end if;
    when c_water6 => if inc1sec = '1' then
                       next_state <= c_water7;
                     end if;
    when c_water7 => if inc1sec = '1' then
                       next_state <= c_water8;
                     end if;    
    when c_water8 => if inc1sec = '1' then
                       next_state <= c_water_off;
                     end if;       
    when c_water_off => next_state <= c_milk1;
    when c_milk1 => if inc1sec = '1' then
                       next_state <= c_milk2;
                     end if;    
    when c_milk2 => if inc1sec = '1' then
                       next_state <= c_milk3;
                     end if;    
    when c_milk3 => if inc1sec = '1' then
                       next_state <= c_milk4;
                     end if;    
    when c_milk4 => if inc1sec = '1' then
                       next_state <= c_milk5;
                     end if;      
    when c_milk5 => if inc1sec = '1' then
                       next_state <= c_milk_off;
                     end if;      
    -- ristretto
    when ristretto => if inc1sec = '1' then
                       next_state <= r_grind1;
                     end if;
    when r_grind1 => if inc1sec = '1' then
                       next_state <= r_grind2;
                     end if;    
    when r_grind2 => if inc1sec = '1' then
                       next_state <= r_grind3;
                     end if;    
    when r_grind3 => if inc1sec = '1' then
                       next_state <= r_grind4;
                     end if;    
    when r_grind4 => if inc1sec = '1' then
                       next_state <= r_grind5;
                     end if;      
    when r_grind5 => if inc1sec = '1' then
                       next_state <= r_grind_off;
                     end if;                    
    when r_grind_off => next_state <= r_water1;
    when r_water1 => if inc1sec = '1' then
                       next_state <= r_water2;
                     end if;  
    when r_water2 => if inc1sec = '1' then
                       next_state <= r_water3;
                     end if;
    when r_water3 => if inc1sec = '1' then
                       next_state <= r_water4;
                     end if;
    when r_water4 => if inc1sec = '1' then
                       next_state <= r_water_off;
                     end if;       
    
    when e_water_off => next_state <= get_money;
    when c_milk_off => next_state <= get_money;
    when r_water_off => next_state <= get_money;

    when get_money => next_state <= serve; 
    when serve => if inc1sec = '1' then
                    next_state <= serve_delay;
                  else
                    next_state <= serve;  
                  end if;  
    when serve_delay => if inc1sec = '1' then
                          next_state <= change;
                        else
                          next_state <= serve_delay;
                        end if;    
    when change => if money_counter > 0 then
                     next_state <= pay50b;
                   else
                     next_state <= idle;
                   end if;    
    when pay50b => next_state <= pay_delay;
    when pay_delay => if inc1sec = '1' then
                     next_state <= change;
                   else
                     next_state <= pay_delay;  
                   end if;  
    when others => next_state <= err_state;
  end case;                                                                                                                                                                                                                                                                                                                                                                                              
end process;

-- money_counter
process(clk, rst)
begin
  if rst = '1' then
    money_counter <= 0;
  elsif rising_edge(clk) then
    if current_state = add50b then
      money_counter <= money_counter + 50;
    elsif current_state = add1ron then
      money_counter <= money_counter + 100;
    elsif current_state = add5ron then
      money_counter <= money_counter + 500;
    elsif current_state = pay50b then
      money_counter <= money_counter - 50;  
    elsif current_state = get_money then
      money_counter <= money_counter - 250; 
    end if;
  end if;       
end process;

-- grinder
process (rst, clk)
begin
  if rst = '1' then
    grinder <= '0';
  elsif rising_edge(clk) then
    if current_state = e_grind1 then
      grinder <= '1';
    elsif current_state = e_grind_off then
      grinder <= '0';
    elsif current_state = c_grind1 then
      grinder <= '1';
    elsif current_state = c_grind_off then
      grinder <= '0';  
    elsif current_state = r_grind1 then
      grinder <= '1';
    elsif current_state = r_grind_off then
      grinder <= '0';        
    end if;
  end if;        
end process;

-- watervalve
process (rst, clk)
begin
  if rst = '1' then
    watervalve <= '0';
  elsif rising_edge(clk) then
    if current_state = e_water1 then
      watervalve <= '1';
    elsif current_state = e_water_off then
      watervalve <= '0';
    elsif current_state = c_water1 then
      watervalve <= '1';
    elsif current_state = c_water_off then
      watervalve <= '0'; 
    elsif current_state = r_water1 then
      watervalve <= '1';
    elsif current_state = r_water_off then
      watervalve <= '0';   
    end if;
  end if;        
end process;

-- milkvalve
process (rst, clk)
begin
  if rst = '1' then
    milkvalve <= '0';
  elsif rising_edge(clk) then
    if current_state = c_milk1 then
      milkvalve <= '1';
    elsif current_state = c_milk_off then
      milkvalve <= '0';  
    end if;
  end if;        
end process;

-- en_cnt
process(rst, clk)
begin
  if rst = '1' then
    en_cnt <= '0';
  elsif rising_edge(clk) then
    if (current_state = espresso or current_state = cappuccino or current_state = ristretto) then
      en_cnt <= '1';
    elsif (current_state = e_grind1 or current_state = e_grind2 or current_state = e_grind3 or 
           current_state = e_grind4 or current_state = e_grind5) then
      en_cnt <= '1';
    elsif (current_state = r_grind1 or current_state = r_grind2 or current_state = r_grind3 or 
           current_state = r_grind4 or current_state = r_grind5) then
      en_cnt <= '1';       
    elsif (current_state = c_grind1 or current_state = c_grind2 or current_state = c_grind3 or 
           current_state = c_grind4 or current_state = c_grind5) then
      en_cnt <= '1';       
    elsif (current_state = e_water1 or current_state = e_water2 or current_state = e_water3 or 
           current_state = e_water4 or current_state = e_water5 or current_state = e_water6 or
           current_state = e_water7  or current_state = e_water8) then
      en_cnt <= '1';
    elsif (current_state = r_water1 or current_state = r_water2 or current_state = r_water3 or 
           current_state = r_water4) then
      en_cnt <= '1';
    elsif (current_state = c_water1 or current_state = c_water2 or current_state = c_water3 or 
           current_state = c_water4 or current_state = c_water5 or current_state = c_water6 or
           current_state = c_water7  or current_state = c_water8) then
      en_cnt <= '1';      
    elsif (current_state = c_milk1 or current_state = c_milk2 or current_state = c_milk3 or 
           current_state = c_milk4 or current_state = c_milk5) then
      en_cnt <= '1';  
    elsif (current_state = serve or current_state = serve_delay or current_state = pay_delay) then
      en_cnt <= '1';
    else
      en_cnt <= '0';
    end if;
  end if;               
end process;


end Behavioral;
