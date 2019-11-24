----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.11.2019 00:35:00
-- Design Name: 
-- Module Name: VariableNode - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IM is
    Port (
        clk : in std_logic;
        random_address : in std_logic;
        input : in std_logic;
        enable : in std_logic;
        output : out std_logic
        );
end IM;
architecture im_behavior of IM is
    signal d : std_logic_vector(2 downto 1);
begin
process(clk)
    begin
    if rising_edge(clk) then
        d(2)<= input;
        d(1)<= d(2);
    end if;
    if enable = '1' then
        if random_address = '1' then -- multiplex output between D Flip Flops outputs
            output <= d(2); 
        else 
            output <= d(1);
        end if;
    end if;
end process;
end im_behavior;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity EM is
    Port (
        clk : in std_logic;
        random_address : in std_logic_vector(6 downto 1);
        input : in std_logic;
        update : in std_logic;
        output : out std_logic
        );
end EM;
architecture em_behavior of EM is
    signal d : std_logic_vector(64 downto 1);
begin
process(clk)
    begin
    if rising_edge(clk) then -- hold state
        d(64)<= input;  -- Assume  input->|64|63|...|2|1|->output
        for i in 63 to 2 loop
            d(i-1) <= d(i);
        end loop;
    end if;
    if update = '1' then -- non hold state
        output <= d(to_integer(unsigned(random_address)));-- 6 to 64 multiplexer
    end if;
end process;
end em_behavior;

-- Each Variable Node is connected to 6 Parity Nodes
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity VN_sequential is
    Port(input_VN:in std_logic_vector(5 downto 1); 
    comparator, init, output_IM1, output_IM2 :in std_logic;
    input_IM1, input_IM2, enable_IM1, enable_IM2, in_DFF:out std_logic;
    output_EM,input_EM,update_EM:inout std_logic
    );
end VN_sequential;
architecture VN_sequential_behav of VN_sequential is
    signal and1,and2,and1not,and2not,or1,or2,mux1,mux2: std_logic;
begin
    and1 <= input_VN(5) and input_VN(4) and input_VN(3);
    and2 <= input_VN(2) and input_VN(1) and comparator;
    and1not <= not input_VN(5) and not input_VN(4) and not input_VN(3);
    and2not <= not input_VN(2) and not input_VN(1) and not comparator;
    or1 <= and1 or and1not;
    or2 <= and2 or and2not;
    mux1 <= and1 when or1 = '1' else output_IM1;
    mux2 <= and2 when or2 = '1' else output_IM2;
    
    input_IM1 <= and1;
    input_IM2 <= and2;
    enable_IM1 <= or1;
    enable_IM2 <= or2;
    
    update_EM <= init or((not mux1 and not mux2)or(mux1 and mux2));
    input_EM <= comparator when init = '1' else mux1 and mux2;
    
    in_DFF <= input_EM when update_EM = '1' else output_EM;
end VN_sequential_behav;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity VN_combinational is
    port(
    input_IM1, input_IM2, input_EM, enable_IM1, enable_IM2, update_EM, in_DFF, random_address, clk:in std_logic;
    output_IM1, output_IM2, out_DFF :out std_logic
    );
end VN_combinational;

architecture VN_combinational_behav of VN_combinational is
begin
    process(clk)
    begin
        if rising_edge(clk) then

        end if;
    end process;
end VN_combinational_behav;






-- Each Variable Node is connected to 6 Parity Nodes
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity VariableNode is
    Port (
    clk : in std_logic;
    initialization : in std_logic;
    inputsFromPNs : in std_logic_vector(5 downto 1);
    inputFromComparator : in std_logic;
    randomAddress : in std_logic_vector (7 downto 1);
    outputToPN : out std_logic
     );
end VariableNode;

architecture Behavioral of VariableNode is -- Variable Node with dv = 6
begin
    process(clk)
    begin
    if rising_edge(clk) then

    end if;
    end process; 
end Behavioral;
    