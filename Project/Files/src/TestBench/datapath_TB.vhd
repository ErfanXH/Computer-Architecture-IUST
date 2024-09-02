library ieee;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_TEXTIO.all;
library std;
use std.TEXTIO.all;
library ieee;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity datapath_tb is
end datapath_tb;

architecture TB_ARCHITECTURE of datapath_tb is
	-- Component declaration of the tested unit
	component datapath
	port(
		clock : in STD_LOGIC := '0';
		reset : in STD_LOGIC := '0';
		fetch_output : out STD_LOGIC_VECTOR(15 downto 0);
		pc_p2 : out STD_LOGIC_VECTOR(15 downto 0);
		regfile_input1 : out STD_LOGIC_VECTOR(3 downto 0);
		regfile_input2 : out STD_LOGIC_VECTOR(3 downto 0);
		regfile_output1 : out STD_LOGIC_VECTOR(15 downto 0);
		regfile_output2 : out STD_LOGIC_VECTOR(15 downto 0);
		immediate_se_output : out STD_LOGIC_VECTOR(15 downto 0);
		jump_se_output : out STD_LOGIC_VECTOR(15 downto 0);
		wb_register_output : out STD_LOGIC_VECTOR(3 downto 0);
		opcode_output : out STD_LOGIC_VECTOR(3 downto 0);
		jump_value : out STD_LOGIC_VECTOR(15 downto 0);
		branch_value : out STD_LOGIC_VECTOR(15 downto 0);
		alu_output : out STD_LOGIC_VECTOR(15 downto 0);
		sr_output : out STD_LOGIC_VECTOR(15 downto 0);
		branch : out STD_LOGIC;
		mem_read : out STD_LOGIC;
		mem_write : out STD_LOGIC;
		mem_address_input : out STD_LOGIC_VECTOR(15 downto 0);
		mem_data_input : out STD_LOGIC_VECTOR(15 downto 0);
		mem_output : out STD_LOGIC_VECTOR(15 downto 0);
		wb_write : out STD_LOGIC;
		wb_reg : out STD_LOGIC_VECTOR(3 downto 0);
		wb_data : out STD_LOGIC_VECTOR(15 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clock : STD_LOGIC := '0';
	signal reset : STD_LOGIC := '0';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal fetch_output : STD_LOGIC_VECTOR(15 downto 0);
	signal pc_p2 : STD_LOGIC_VECTOR(15 downto 0);
	signal regfile_input1 : STD_LOGIC_VECTOR(3 downto 0);
	signal regfile_input2 : STD_LOGIC_VECTOR(3 downto 0);
	signal regfile_output1 : STD_LOGIC_VECTOR(15 downto 0);
	signal regfile_output2 : STD_LOGIC_VECTOR(15 downto 0);
	signal immediate_se_output : STD_LOGIC_VECTOR(15 downto 0);
	signal jump_se_output : STD_LOGIC_VECTOR(15 downto 0);
	signal wb_register_output : STD_LOGIC_VECTOR(3 downto 0);
	signal opcode_output : STD_LOGIC_VECTOR(3 downto 0);
	signal jump_value : STD_LOGIC_VECTOR(15 downto 0);
	signal branch_value : STD_LOGIC_VECTOR(15 downto 0);
	signal alu_output : STD_LOGIC_VECTOR(15 downto 0);
	signal sr_output : STD_LOGIC_VECTOR(15 downto 0);
	signal branch : STD_LOGIC;
	signal mem_read : STD_LOGIC;
	signal mem_write : STD_LOGIC;
	signal mem_address_input : STD_LOGIC_VECTOR(15 downto 0);
	signal mem_data_input : STD_LOGIC_VECTOR(15 downto 0);
	signal mem_output : STD_LOGIC_VECTOR(15 downto 0);
	signal wb_write : STD_LOGIC;
	signal wb_reg : STD_LOGIC_VECTOR(3 downto 0);
	signal wb_data : STD_LOGIC_VECTOR(15 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : datapath
		port map (
			clock => clock,
			reset => reset,
			fetch_output => fetch_output,
			pc_p2 => pc_p2,
			regfile_input1 => regfile_input1,
			regfile_input2 => regfile_input2,
			regfile_output1 => regfile_output1,
			regfile_output2 => regfile_output2,
			immediate_se_output => immediate_se_output,
			jump_se_output => jump_se_output,
			wb_register_output => wb_register_output,
			opcode_output => opcode_output,
			jump_value => jump_value,
			branch_value => branch_value,
			alu_output => alu_output,
			sr_output => sr_output,
			branch => branch,
			mem_read => mem_read,
			mem_write => mem_write,
			mem_address_input => mem_address_input,
			mem_data_input => mem_data_input,
			mem_output => mem_output,
			wb_write => wb_write,
			wb_reg => wb_reg,
			wb_data => wb_data
		);

	-- Add your stimulus here ...
	CLOCKt:
    process
    begin
        wait for 5 ns;
        clock <= not clock;
        if now > 250 ns then
            wait;
        end if;
    end process;
	
	reset <= '0';
	
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_datapath of datapath_tb is
	for TB_ARCHITECTURE
		for UUT : datapath
			use entity work.datapath(behavior);
		end for;
	end for;
end TESTBENCH_FOR_datapath;

