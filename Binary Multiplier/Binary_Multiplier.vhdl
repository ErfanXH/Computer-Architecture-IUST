library ieee;
use ieee.std_logic_1164.all;

entity my_and is
	port 
	(A, B: in bit;
	O: out bit);
end my_and;

architecture equation of my_and is
begin
	o <= A and B after 0 ns;
end equation; 

entity half_adder is
	port
	(A, B: in bit;
	S, Cout: out bit);
end half_adder;

architecture equation of half_adder is
begin
	Cout <= A and B after 0 ns;
	S <= A xor B after 0 ns;
end equation;

entity Binary_Multiplier is
	port 
	(A, B: in bit_vector (1 downto 0);
	C: out bit_vector (3 downto 0) );
end Binary_Multiplier;

architecture circuit of Binary_Multiplier is
component my_and
	port 
	(A, B: in bit;
	O: out bit);	 
end component;

component half_adder
	port
	(A, B: in bit;
	S, Cout: out bit);
end component;

Signal S0, S1, S2, S3 : bit;
Signal S4, S5, S6, S7 : bit;

begin 
And0: 	my_and port map (A(0), B(0), S0);	 
And1:	my_and port map (A(0), B(1), S1);
And2:	my_and port map (A(1), B(0), S2);
And3:	my_and port map (A(1), B(1), S3);
	
HA0:	half_adder port map (S1, S2, S4, S5);
HA1:	half_adder port map (S3, S5, S6, S7);	   
	
	C(0) <= S0 after 0 ns;
	C(1) <= S4 after 0 ns;
	C(2) <= S6 after 0 ns;
	C(3) <= S7 after 0 ns;
	
end circuit;

-----------------------------------------------

--binary multiplier test bench

-- Add your library and packages declaration here ...

entity binary_multiplier_tb is
end binary_multiplier_tb;

architecture TB_ARCHITECTURE of binary_multiplier_tb is
	-- Component declaration of the tested unit
	component binary_multiplier
	port(
		A : in BIT_VECTOR(1 downto 0);
		B : in BIT_VECTOR(1 downto 0);
		C : out BIT_VECTOR(3 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal A : BIT_VECTOR(1 downto 0);
	signal B : BIT_VECTOR(1 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal C : BIT_VECTOR(3 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : binary_multiplier
		port map (
			A => A,
			B => B,
			C => C
		);

	-- Add your stimulus here ...
	process 
	begin			
		wait for 100 ns;
		A <= "11";
		B <= "11";
		wait for 100 ns;
		A <= "11";
		B <= "10";
		wait for 100 ns;
		A <= "11";
		B <= "00";
		wait for 100 ns;
		A <= "11";
		B <= "01";
		wait for 100 ns;
		A <= "10";
		B <= "10";
		wait;
	end process;
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_binary_multiplier of binary_multiplier_tb is
	for TB_ARCHITECTURE
		for UUT : binary_multiplier
			use entity work.binary_multiplier(circuit);
		end for;
	end for;
end TESTBENCH_FOR_binary_multiplier;

