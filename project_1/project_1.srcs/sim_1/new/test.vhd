----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2022 07:07:30 PM
-- Design Name: 
-- Module Name: test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test is
--  Port ( );
end test;

architecture Behavioral of test is

component fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           btnC : in std_logic;
--           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out std_logic_vector (3 downto 0);
           seg : out std_logic_vector (0 to 6);
           dp : out STD_LOGIC
         );
end component;

signal clk, rst, btnC, dp : STD_logic;
signal sw : STD_LOGIC_VECTOR (15 downto 0);
signal an : std_logic_vector (3 downto 0);
signal seg : std_logic_vector (0 to 6);

begin

uut:fsm port map (clk => clk, 
                  rst => rst, 
                  btnC => btnC, 
                  dp => dp, 
                  sw => sw, 
                  an => an, 
                  seg => seg);

process begin
    clk <= '0';
    wait for 1ns;
    clk <= '1';
    wait for 1ns;
end process;

process
begin
    sw(15) <= '0';
    wait for 5ns;
    sw(15) <= '1';
    wait for 3ns;
end process;

process
begin
    btnC <= '0';
    wait for 16ns;
    btnC <= '1';
    wait for 5ns;
end process;

rst <= '0';
sw(12) <= '0';
sw(14) <= '1';
 sw(13) <= '1';

end Behavioral;
