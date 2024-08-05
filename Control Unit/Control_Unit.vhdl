library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;	 

entity Control_Unit is
	port 
	(Opcode: in std_logic_vector (5 downto 0);
	RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp0: out std_logic);		
end Control_Unit;

architecture Circuit of Control_Unit is	 
	
	begin 
		
		RegDst <= (NOT Opcode(0)) AND (NOT Opcode(1)) AND (NOT Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (NOT Opcode(5)) after 0 ns;  
		
		MemtoReg <= (Opcode(0)) AND (Opcode(1)) AND (NOT Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (Opcode(5)) after 0 ns; 
		
		MemRead <= (Opcode(0)) AND (Opcode(1)) AND (NOT Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (Opcode(5)) after 0 ns; 
		
		MemWrite <= (Opcode(0)) AND (Opcode(1)) AND (NOT Opcode(2)) AND (Opcode(3)) AND (NOT Opcode(4)) AND (Opcode(5)) after 0 ns; 
		
		Branch <= (NOT Opcode(0)) AND (NOT Opcode(1)) AND (Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (NOT Opcode(5)) after 0 ns;
		
		ALUOp1 <= (NOT Opcode(0)) AND (NOT Opcode(1)) AND (NOT Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (NOT Opcode(5)) after 0 ns;
		
		ALUOp0 <= (NOT Opcode(0)) AND (NOT Opcode(1)) AND (Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (NOT Opcode(5)) after 0 ns;
		
		ALUSrc <= ((Opcode(0)) AND (Opcode(1)) AND (NOT Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (Opcode(5))) OR ((Opcode(0)) AND (Opcode(1)) AND (NOT Opcode(2)) AND (Opcode(3)) AND (NOT Opcode(4)) AND (Opcode(5))) after 0 ns;
		
		RegWrite <= ((Opcode(0)) AND (Opcode(1)) AND (NOT Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (Opcode(5))) OR ((NOT Opcode(0)) AND (NOT Opcode(1)) AND (NOT Opcode(2)) AND (NOT Opcode(3)) AND (NOT Opcode(4)) AND (NOT Opcode(5))) after 0 ns;

	end Circuit;	   
	
	
	
--------------

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity control_unit_tb is
end control_unit_tb;

architecture TB_ARCHITECTURE of control_unit_tb is
	-- Component declaration of the tested unit
	component control_unit
	port(
		Opcode : in STD_LOGIC_VECTOR(5 downto 0);
		RegDst : out STD_LOGIC;
		ALUSrc : out STD_LOGIC;
		MemtoReg : out STD_LOGIC;
		RegWrite : out STD_LOGIC;
		MemRead : out STD_LOGIC;
		MemWrite : out STD_LOGIC;
		Branch : out STD_LOGIC;
		ALUOp1 : out STD_LOGIC;
		ALUOp0 : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal Opcode : STD_LOGIC_VECTOR(5 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal RegDst : STD_LOGIC;
	signal ALUSrc : STD_LOGIC;
	signal MemtoReg : STD_LOGIC;
	signal RegWrite : STD_LOGIC;
	signal MemRead : STD_LOGIC;
	signal MemWrite : STD_LOGIC;
	signal Branch : STD_LOGIC;
	signal ALUOp1 : STD_LOGIC;
	signal ALUOp0 : STD_LOGIC;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : control_unit
		port map (
			Opcode => Opcode,
			RegDst => RegDst,
			ALUSrc => ALUSrc,
			MemtoReg => MemtoReg,
			RegWrite => RegWrite,
			MemRead => MemRead,
			MemWrite => MemWrite,
			Branch => Branch,
			ALUOp1 => ALUOp1,
			ALUOp0 => ALUOp0
		);

	-- Add your stimulus here ...
	process
	begin
		wait for 200 ns;
		Opcode <= "000000";	  
		wait for 200 ns;
		Opcode <= "100011";	
		wait for 200 ns;
		Opcode <= "101011"; 
		wait for 200 ns;
		Opcode <= "000100";
		wait;
	end process;
	

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_control_unit of control_unit_tb is
	for TB_ARCHITECTURE
		for UUT : control_unit
			use entity work.control_unit(circuit);
		end for;
	end for;
end TESTBENCH_FOR_control_unit;

