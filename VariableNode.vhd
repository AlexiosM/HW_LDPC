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
----------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--- Parity Node ---
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
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
------------------------------------------------------------------------------
--- Distributed Random Engine ---
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity LFSR is
  Port (
            clk : in std_logic;
            enabled : in std_logic;
            reset : in std_logic;
            seed_values : in std_logic_vector(10 downto 1);
            random_num : out std_logic_vector(10 downto 1)
            );
end LFSR;

architecture Behavioral of LFSR is
    signal lfsr_values : std_logic_vector(10 downto 1);
-- 10 -bit LFSR, for maximal length random values we use the polynomial x^10+x^7+1
begin    
    compute_LFSR: process(clk) is
    begin
    if enabled = '1' then
        if rising_edge(clk) then
            if reset = '1' then
                for i in 1 to 10 loop
                    lfsr_values(i) <= seed_values(i);
                end loop;
            else
            lfsr_values(1) <= lfsr_values(7) xor lfsr_values(10);
            lfsr_values(2) <= lfsr_values(1);
            lfsr_values(3) <= lfsr_values(2);
            lfsr_values(4) <= lfsr_values(3);
            lfsr_values(5) <= lfsr_values(4);
            lfsr_values(6) <= lfsr_values(5);
            lfsr_values(7) <= lfsr_values(6);
            lfsr_values(8) <= lfsr_values(7);
            lfsr_values(9) <= lfsr_values(8);
            lfsr_values(10) <= lfsr_values(9);
            for i in 1 to 10 loop
                random_num(i) <= lfsr_values(i);
            end loop;
            end if;
        end if;
    end if;
    end process compute_LFSR;
end architecture Behavioral;
------------------------------------------------------------------------
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
        if enable = '1' then
            if random_address = '1' then -- multiplex output between D Flip Flops outputs
                output <= d(2); 
            else 
                output <= d(1);
            end if;
        else
                d(2)<= input;
                d(1)<= d(2); 
        end if;
    end if;
end process;
end im_behavior;
----------------------------------------------------------------------------------------------
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
    if rising_edge(clk) then
        if update = '1' then -- non hold state
            output <= d(to_integer(unsigned(random_address)));-- 64 to 1 multiplexer (select of 6 signals)
            d(64)<= input;  -- Assume  input->|64|63|...|2|1|->output
        else
            for i in 63 to 2 loop
                d(i-1) <= d(i);
            end loop;
        end if;
    end if;
end process;
end em_behavior;
-------------------------------------------------------------------------------------------
-- Each Variable Node is connected to 6 Parity Nodes, takes signals from 5 PNs and sends response to 1 PN
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
-------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity VN_combinational is
    port(
    input_IM1, input_IM2, input_EM, enable_IM1, enable_IM2, update_EM, clk, in_DFF:in std_logic;
    random_address:in std_logic_vector(8 downto 1);
    output_IM1, output_IM2, output_EM, out_DFF :out std_logic
    );
end VN_combinational;

architecture VN_behav_combinational of VN_combinational is
component IM is
    Port (
        clk : in std_logic;
        random_address : in std_logic;
        input : in std_logic;
        enable : in std_logic;
        output : out std_logic
        );
end component;
component EM is
    Port (
        clk : in std_logic;
        random_address : in std_logic_vector(6 downto 1);
        input : in std_logic;
        update : in std_logic;
        output : out std_logic
        );
end component;

begin
    IM1:IM port map(clk=>clk,
    random_address=>random_address(7),
    input=>input_IM1,
    enable=>enable_IM1,
    output=>output_IM1);
    
    IM2:IM port map(clk=>clk,
    random_address=>random_address(8),
    input=>input_IM2,
    enable=>enable_IM2,
    output=>output_IM2);
    
    EMem:EM port map(clk=>clk,
    random_address(6 downto 1)=>random_address(6 downto 1),
    input=>input_EM,
    update=>update_EM,
    output=>output_EM);
    
    process(clk)
    begin
        if rising_edge(clk) then
            output_IM1 <= input_IM1;
            output_IM2 <= input_IM2;
            output_EM <= input_EM;
            out_DFF <= in_DFF;
        end if;
    end process;
end VN_behav_combinational;
-----------------------------------------------------------------------
-- creation of Variable Node with Distributed Random Engine inside
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity VariableNode is port(
    clk: in std_logic;
    inputsFromPNs: in std_logic_vector(5 downto 1);
    inputFromComparator: in std_logic;
    initialization: in std_logic;
    outputToPN: out std_logic
);
end VariableNode;
architecture VariableNodeBehavior of VariableNode is
-- components LFSR, VN_sequential, VN_combinational
component LFSR is Port(
            clk : in std_logic;
            enabled : in std_logic;
            reset : in std_logic;
            seed_values : in std_logic_vector(10 downto 1);
            random_num : out std_logic_vector(10 downto 1)
    );
end component;
component VN_sequential is Port(
    input_VN:in std_logic_vector(5 downto 1); 
    comparator, init, output_IM1, output_IM2 :in std_logic;
    input_IM1, input_IM2, enable_IM1, enable_IM2, in_DFF:out std_logic;
    output_EM,input_EM,update_EM:inout std_logic
);
end component;
component VN_combinational is Port(
    input_IM1, input_IM2, input_EM, enable_IM1, enable_IM2, update_EM, clk, in_DFF:in std_logic;
    random_address:in std_logic_vector(8 downto 1);
    output_IM1, output_IM2, output_EM, out_DFF :out std_logic
);
end component;
begin
DRE: LFSR port map ();
VN_S: VN_sequential port map (); 
VN_C: VN_combinational port map ();

end VariableNodeBehavior;
------------------------------------------------------------------------
