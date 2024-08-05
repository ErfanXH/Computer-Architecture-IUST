library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity ALU is	
	
	port (
	clock : in std_logic;
	data_in : in std_logic_vector(17 downto 0); --input data : 2op - 8in1 - 8in2  
	enqueue : in std_logic;	--to push
	--dequeue : in std_logic;	--no need to pop (happens automatically)	
	reset : in std_logic;  
	data_out : out std_logic_vector(7 downto 0); --output data
	);						
	
end ALU; 

-- input (--enqueue-->) queue (--dequeue-->) ALU --> Output	  

architecture Circuit of ALU is

	signal count : integer := 0;
	signal head : integer := 0;	--pointer to head of queue(for dequeue)
	signal tail : integer := 0;	--pointer to tail of queue(for enqueue)
	type data_array is array (0 to 999) of std_logic_vector(17 downto 0); --size of queue = 1000
	signal my_array : data_array;  

begin
	
	process(clock, reset) 
	
	variable current : std_logic_vector(17 downto 0) := my_array(head);
	variable opcode : std_logic_vector(1 downto 0) := current(17 downto 16);
	
	begin 
		
		if reset = '1' then
			count <= 0;
			head <= 0;
			tail <= 0;
		end if;
	
		if rising_edge(clock) then	
			
			if enqueue = '1' then
				my_array(tail) <= data_in;
				count <= count + 1;
				tail <= tail + 1; 
			
			elsif (count > 0) then
	    		case opcode is
                	when "00" => -- Srl							 
						data_out <= current(7 downto 0) srl to_integer(IEEE.NUMERIC_STD.unsigned(current(15 downto 8))); --data_in2 srl data_in1
						head <= head + 1;
						count <= count - 1;
                	when "01" => -- Sll					      
						data_out <= current(7 downto 0) sll to_integer(IEEE.NUMERIC_STD.unsigned(current(15 downto 8))); --data_in2 sll data_in1
						head <= head + 1;
						count <= count - 1;
                	when "10" => -- Xor					   
						data_out <= current(7 downto 0) xor current(15 downto 8);
						head <= head + 1;
						count <= count - 1;
                	when "11" => -- And					 	 
						data_out <= current(7 downto 0) and current(15 downto 8);
						head <= head + 1;
						count <= count - 1;
                	when others => --Invalid
                    	null;
            	end case;
        	end if;
			
		  end if;
		
	end process;
	
end Circuit;

-------------------------
-------------------------

library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity alu_tb is
end alu_tb;

architecture TB_ARCHITECTURE of alu_tb is
	-- Component declaration of the tested unit
	component alu
	port(
		clock : in STD_LOGIC;
		data_in : in STD_LOGIC_VECTOR(17 downto 0);
		enqueue : in STD_LOGIC;
		reset : in STD_LOGIC;
		data_out : out STD_LOGIC_VECTOR(7 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clock : STD_LOGIC;
	signal data_in : STD_LOGIC_VECTOR(17 downto 0);
	signal enqueue : STD_LOGIC;
	signal reset : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal data_out : STD_LOGIC_VECTOR(7 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : alu
		port map (
			clock => clock,
			data_in => data_in,
			enqueue => enqueue,
			reset => reset,
			data_out => data_out
		);

	-- Add your stimulus here ...	
	-- Clock process
    clock_process :process
    begin
        clock <= '0';
        wait for 50 ns;
        clock <= '1';
        wait for 50 ns;
    end process;

    -- main process
    stim_proc: process
    begin
        -- reset
        /*reset <= '1';
        wait for 100 ns;
        reset <= '0';*/

        -- enqueue 	  
		reset <= '0';
        enqueue <= '1';
		data_in <= "000000010000000010";  -- 4 srl 2
        wait for 100 ns;
        enqueue <= '0';
		
		wait for 200 ns;
		
		reset <= '0';
        enqueue <= '1';
		data_in <= "010000000100000010";  -- 1 sll 2
        wait for 100 ns;
        enqueue <= '0';
		
		wait for 200 ns;
		
		reset <= '0';
        enqueue <= '1';
		data_in <= "100000000100000010";  -- 1 xor 2
        wait for 100 ns;
        enqueue <= '0';
		
		wait for 200 ns;
		
		reset <= '0';
        enqueue <= '1';
		data_in <= "110000000100000010";  -- 1 and 2
        wait for 100 ns;
        enqueue <= '0';

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_alu of alu_tb is
	for TB_ARCHITECTURE
		for UUT : alu
			use entity work.alu(circuit);
		end for;
	end for;
end TESTBENCH_FOR_alu;