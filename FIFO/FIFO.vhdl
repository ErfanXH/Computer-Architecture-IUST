library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity queue is    
  generic (  -- 32 x 8
    buffer_size : integer := 32;
    data_size : integer := 8
    );
  port (  
    clock : in std_logic := '1';
    data_in : in std_logic_vector(data_size - 1 downto 0); --input data
    enqueue : in std_logic;  --to push
    dequeue : in std_logic;  --to pop  
    reset : in std_logic;  
    data_out : out std_logic_vector(data_size - 1 downto 0); --output data
    queue_size : out integer; 
    queue_empty : out std_logic;
    queue_full : out std_logic
    );    
end entity queue;

architecture circuit of queue is
  signal count : integer := 0;
  signal head : integer := 0;  --pointer to head of queue(for dequeue)
  signal tail : integer := 0;  --pointer to tail of queue(for enqueue)
  type data_array is array (0 to buffer_size - 1) of std_logic_vector(data_size - 1 downto 0);  
  signal my_array : data_array;                                      
  signal tmp_out : std_logic_vector(7 downto 0) ;
begin
  
  process(clock, reset)   
      
  begin
    
   if reset = '1' then
     count <= 0; 
     head <= 0;
     tail <= 0;
  end if;
  
  if rising_edge(clock) then   
    
    if enqueue = '1' and dequeue = '0' then
      
      if count < buffer_size then
        my_array(tail) <= data_in;
        tail <= (tail + 1) mod buffer_size;
        count <= count + 1;
      end if;
      
    elsif enqueue = '0' and dequeue = '1' then    
      
      if count > 0 then
        --data_out <= my_array(head);       
        tmp_out <= my_array(head);      
          head <= (head + 1) mod buffer_size;
        count <= count - 1;    
      end if;  
      
    end if;
    
  end if;
  end process;  
  
  queue_size <= count;
  queue_empty <= '1' when count = 0 else '0';
  queue_full <= '1' when count = buffer_size else '0'; 
  data_out <= tmp_out; 
  
end circuit;

---------------------------------
    --- FIFO Testbench ---
---------------------------------

library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity queue_tb is
	-- Generic declarations of the tested unit
		generic(
		buffer_size : INTEGER := 32;
		data_size : INTEGER := 8 );
end queue_tb;

architecture TB_ARCHITECTURE of queue_tb is
	-- Component declaration of the tested unit
	component queue
		generic(
		buffer_size : INTEGER := 32;
		data_size : INTEGER := 8 );
	port(
		clock : in STD_LOGIC;
		data_in : in STD_LOGIC_VECTOR(data_size-1 downto 0);
		enqueue : in STD_LOGIC;
		dequeue : in STD_LOGIC;
		reset : in STD_LOGIC;
		data_out : out STD_LOGIC_VECTOR(data_size-1 downto 0);
		queue_size : out INTEGER;
		queue_empty : out STD_LOGIC;
		queue_full : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clock : STD_LOGIC := '0';
	signal data_in : STD_LOGIC_VECTOR(data_size-1 downto 0) := "00000000";
	signal enqueue : STD_LOGIC := '0';
	signal dequeue : STD_LOGIC := '0';
	signal reset : STD_LOGIC := '0';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal data_out : STD_LOGIC_VECTOR(data_size-1 downto 0);
	signal queue_size : INTEGER;
	signal queue_empty : STD_LOGIC;
	signal queue_full : STD_LOGIC;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : queue
		generic map (
			buffer_size => buffer_size,
			data_size => data_size
		)

		port map (
			clock => clock,
			data_in => data_in,
			enqueue => enqueue,
			dequeue => dequeue,
			reset => reset,
			data_out => data_out,
			queue_size => queue_size,
			queue_empty => queue_empty,
			queue_full => queue_full
		);

	-- Add your stimulus here ...
	-- Clock process
    clock_process :process
    begin
        clock <= '0';
        wait for 5 ns;
        clock <= '1';
        wait for 5 ns;
    end process;

    -- main process
    stim_proc: process
    begin
        -- reset
        /*reset <= '1';
        wait for 10 ns;
        reset <= '0';*/

        -- enqueue data	
		
       	--push 1
        reset <= '0';
		enqueue <= '1';
		dequeue <= '0';
        data_in <= "00000001";
		wait for 10 ns;
        enqueue <= '0';
		
		--push 2
		reset <= '0';
        enqueue <= '1';	
		dequeue <= '0';
        data_in <= "00000010";
		wait for 10 ns;
        enqueue <= '0';
			
       	--push 3
        reset <= '0';
		enqueue <= '1';
		dequeue <= '0';
        data_in <= "00000011";
		wait for 10 ns;
        enqueue <= '0';

        -- dequeue data	
		reset <= '0';			 --pop (head = 1)
		enqueue <= '0';			 
        dequeue <= '1';
        wait for 10 ns;
        dequeue <= '0';	  
						

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_queue of queue_tb is
	for TB_ARCHITECTURE
		for UUT : queue
			use entity work.queue(circuit);
		end for;
	end for;
end TESTBENCH_FOR_queue;