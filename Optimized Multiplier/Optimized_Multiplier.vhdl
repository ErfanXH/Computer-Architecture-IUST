library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;	--for line 36 

entity Optimized_Multiplier is
	port 
	(Multiplicand, Multiplier: in std_logic_vector (31 downto 0);
	Product: out std_logic_vector (63 downto 0));		
end Optimized_Multiplier;

architecture Circuit of Optimized_Multiplier is	  

begin
	process (Multiplier) 
	
	Variable register_64 : std_logic_vector(63 downto 0);
	Variable tmp : std_logic_vector(31 downto 0);
	Variable tmp2 : std_logic_vector(31 downto 0); 
	
	begin 
		register_64 := "00000000000000000000000000000000" & Multiplier;
		
		for i in 1 to 32 loop 
			
			if register_64(0) = '1' then	
				--product = product + multiplicand	  		   
				
				tmp := register_64(63 downto 32) + Multiplicand;
				tmp2 := register_64(31 downto 0);
				register_64 := tmp & tmp2;
				
			end if;  
		  
			register_64 := register_64 srl 1;
		  
		end loop;
		
		Product <= register_64;

	end process;
end Circuit;

--------------------------------------------------------------

-- Optimized Multiplier test bench

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity optimized_multiplier_tb is
end optimized_multiplier_tb;

architecture TB_ARCHITECTURE of optimized_multiplier_tb is
	-- Component declaration of the tested unit
	component optimized_multiplier
	port(
		Multiplicand : in STD_LOGIC_VECTOR(31 downto 0);
		Multiplier : in STD_LOGIC_VECTOR(31 downto 0);
		Product : out STD_LOGIC_VECTOR(63 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal Multiplicand : STD_LOGIC_VECTOR(31 downto 0);
	signal Multiplier : STD_LOGIC_VECTOR(31 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Product : STD_LOGIC_VECTOR(63 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : optimized_multiplier
		port map (
			Multiplicand => Multiplicand,
			Multiplier => Multiplier,
			Product => Product
		);

	-- Add your stimulus here ...
	process
	begin
		wait for 100 ns;
		Multiplicand <= "00000000000000000000000000000100";
		Multiplier <= "00000000000000000000000000000010";  
		wait for 100 ns;
		Multiplicand <= "00000000000000000000000000001000";
		Multiplier <= "00000000000000000000000000000110";	
		wait for 100 ns;
		Multiplicand <= "00000000000000000000000000000111";
		Multiplier <= "00000000000000000000000000001000";  
		wait for 100 ns;
		Multiplicand <= "00000000000000000000000100000001";
		Multiplier <= "00000000000000000011000000000000";
		wait;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_optimized_multiplier of optimized_multiplier_tb is
	for TB_ARCHITECTURE
		for UUT : optimized_multiplier
			use entity work.optimized_multiplier(circuit);
		end for;
	end for;
end TESTBENCH_FOR_optimized_multiplier;