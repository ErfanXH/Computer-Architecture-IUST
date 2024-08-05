library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;  
use ieee.std_logic_arith.all;

entity Processor is
	Port(
	Instruction : in std_logic_vector(7 downto 0);	
	ValueR1 : in std_logic_vector(7 downto 0);	 
	ValueR2 : in std_logic_vector(7 downto 0); 
	PCin : in std_logic_vector(15 downto 0);
	Result : out std_logic_vector(7 downto 0);
	PCout : out std_logic_vector(15 downto 0));
	
end Processor;

architecture Circuit of Processor is

signal R1 : std_logic_vector(7 downto 0);
signal R2 : std_logic_vector(7 downto 0);

begin 
	
Process (Instruction)
Variable x : std_logic_vector(7 downto 0) := "11111111";
begin			
	R1 <= ValueR1;	--u?
	R2 <= ValueR2;  --u?  
	Result <= "11111111";
	
	case Instruction is
		when "00000000" => --Add 
			Result <= R1 + R2;	
		  	--x := R1 + R2;
		when "01000000" => --Sub
			Result <= R1 - R2;
			--x := R1 - R2;
		when "10000000" => --And 
			Result <= R1 and R2;
			--x := R1 and R2;
		when "11000000" => --Or	
			Result <= R1 or R2;
			--x := R1 or R2;
		when others => 	   --
			Result <= "11111111";
			--x := "11111111";
		
	end case;	 
	
	--Result <= x;								 
	PCout <= Pcin + 4;
	
end process;

end Circuit;

---------------------


library ieee;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity processor_tb is
end processor_tb;

architecture TB_ARCHITECTURE of processor_tb is
	-- Component declaration of the tested unit
	component processor
	port(
		Instruction : in STD_LOGIC_VECTOR(7 downto 0);
		ValueR1 : in STD_LOGIC_VECTOR(7 downto 0);
		ValueR2 : in STD_LOGIC_VECTOR(7 downto 0);
		PCin : in STD_LOGIC_VECTOR(15 downto 0);
		Result : out STD_LOGIC_VECTOR(7 downto 0);
		PCout : out STD_LOGIC_VECTOR(15 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal Instruction : STD_LOGIC_VECTOR(7 downto 0);
	signal ValueR1 : STD_LOGIC_VECTOR(7 downto 0);
	signal ValueR2 : STD_LOGIC_VECTOR(7 downto 0);
	signal PCin : STD_LOGIC_VECTOR(15 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Result : STD_LOGIC_VECTOR(7 downto 0);
	signal PCout : STD_LOGIC_VECTOR(15 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : processor
		port map (
			Instruction => Instruction,
			ValueR1 => ValueR1,
			ValueR2 => ValueR2,
			PCin => PCin,
			Result => Result,
			PCout => PCout
		);

	-- Add your stimulus here ...	 
	process
	begin
		wait for 100 ns;
		Instruction <= "00000000";	--add
		ValueR1 <= "00010101";
		ValueR2 <= "00001111";
		PCin <= "0000000000000100";
		wait for 100 ns;
		Instruction <= "01000000";	--sub
		ValueR1 <= "00010101";
		ValueR2 <= "00001111";
		PCin <= "0000000000000100";
		wait for 100 ns;
		Instruction <= "10000000";	--and
		ValueR1 <= "00010101";
		ValueR2 <= "00001111";
		PCin <= "0000000000000100";
		wait for 100 ns;
		Instruction <= "11000000";	--or
		ValueR1 <= "00010101";
		ValueR2 <= "00001111";
		PCin <= "0000000000000100";	 
		wait for 100 ns;
		Instruction <= "00000000";	--add
		ValueR1 <= "00010101";
		ValueR2 <= "00001111";
		PCin <= "0000000000000100";
		wait;	
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_processor of processor_tb is
	for TB_ARCHITECTURE
		for UUT : processor
			use entity work.processor(circuit);
		end for;
	end for;
end TESTBENCH_FOR_processor;

