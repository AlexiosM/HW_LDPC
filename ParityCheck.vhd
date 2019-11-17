----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2019 18:18:47
-- Design Name: 
-- Module Name: ParityCheck - Behavioral
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

entity ParityCheck is
    Port ( input : in STD_LOGIC_VECTOR (7 downto 1);
           clk : in STD_LOGIC;
           parity_check_satisfied : out STD_LOGIC;
           output : out STD_LOGIC_VECTOR (7 downto 1));
end ParityCheck;

architecture Behavioral of ParityCheck is
    signal xor_outputs : std_logic_vector(7 downto 1);
    signal xor_summary_output : std_logic;
begin
    xor_summary_output <= input(1) xor input(2) xor input(3) xor input(4) xor input(5) xor input(6) xor input(7);
    process(clk) is
    begin
    if rising_edge(clk) then
        internal_xor:for i in 1 to 7 loop
            xor_outputs(i) <= xor_summary_output xor input(i);
        end loop internal_xor;
        -- parity check outputs   
        parity_check_satisfied <= xor_summary_output;
        for i in 1 to 7 loop
            output(i) <= xor_outputs(i);
        end loop;
    end if;
    end process;
end Behavioral;
