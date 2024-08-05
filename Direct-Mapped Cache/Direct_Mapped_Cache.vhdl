library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DirectMappedCache is	
	port (
        clk : in std_logic;	
        address : in std_logic_vector(31 downto 0);
        data_in : in std_logic_vector(7 downto 0);
        write_enable : in std_logic;
        read_enable : in std_logic;
        hit : out std_logic;
		miss : out std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end DirectMappedCache; 

architecture Circuit of DirectMappedCache is

	type cache_data_array is array (0 to 1023) of std_logic_vector(31 downto 0);  	--array of data for all 1024 entries, each entry 4 8-bit words
    type tag_valid_array is array (0 to 1023) of std_logic_vector(20 downto 0);  	--array of tag and valid for all 1024 entries, each entry 1 bit valid + 20 bits tag
    
    signal cache_data : cache_data_array;
    signal tag_valid : tag_valid_array;
    signal index : std_logic_vector(9 downto 0);
    signal tag : std_logic_vector(19 downto 0);	
	signal offset : std_logic_vector(1 downto 0);
    signal cache_data_out : std_logic_vector(7 downto 0); 
	
	signal valid_tag_tmp : std_logic_vector(20 downto 0);
	signal valid_tmp : std_logic;
	signal tag_tmp : std_logic_vector(19 downto 0);	
	
	signal data_tmp : std_logic_vector(31 downto 0);
	
	signal write_tmp : std_logic_vector(31 downto 0);

begin
	process (clk) 
	
	begin  
		
		tag <= address(31 downto 12);
		index <= address(11 downto 2);
		offset <= address(1 downto 0); 
		
		if ( rising_edge(clk) and read_enable = '1' ) then						
			
			valid_tag_tmp <= tag_valid(to_integer(unsigned(index)));
			valid_tmp <= valid_tag_tmp(20);
			tag_tmp <= valid_tag_tmp(19 downto 0);
			
			if valid_tmp = '1' and tag_tmp = tag then 	--hit
				
				data_tmp <= cache_data(to_integer(unsigned(index)));
				
				if  offset = "00"  then
					cache_data_out <= data_tmp(31 downto 24);
				elsif offset = "01" then
	    			cache_data_out <= data_tmp(23 downto 16);
				elsif offset = "10" then
	    			cache_data_out <= data_tmp(15 downto 8); 
				else --offset = '11'
					cache_data_out <= data_tmp(7 downto 0);
				
				hit <= '1';
				miss <= '0';
					
				end if;
				
			else --miss
				  
             -- Generate random data for cache	 
				if data_in(1 downto 0) = "00" then
					write_tmp <= data_in & write_tmp(23 downto 0);
				elsif ( data_in(1 downto 0) = "01" ) then
	    			write_tmp <=  write_tmp(31 downto 24) & data_in & write_tmp(15 downto 0);	
				elsif ( data_in(1 downto 0) = "01" ) then
	    			write_tmp <=  write_tmp(31 downto 16) & data_in & write_tmp(7 downto 0);
				else
					write_tmp <= write_tmp(31 downto 8) & data_in;
				
				end if;
				
                cache_data(to_integer(unsigned(index))) <= write_tmp;
                tag_valid(to_integer(unsigned(index))) <= '1' & tag;
                cache_data_out <= data_in;	 
					
				hit <= '0';
				miss <= '1';
					
			end if;	 
			
		elsif ( rising_edge(clk) and write_enable = '1' ) then
			
			write_tmp <= cache_data(to_integer(unsigned(index)));
			
			if data_in(1 downto 0) = "00" then
				write_tmp <= data_in & write_tmp(23 downto 0);
			elsif ( data_in(1 downto 0) = "01" ) then
	    		write_tmp <=  write_tmp(31 downto 24) & data_in & write_tmp(15 downto 0);	
			elsif ( data_in(1 downto 0) = "01" ) then
	    		write_tmp <=  write_tmp(31 downto 16) & data_in & write_tmp(7 downto 0);
			else
				write_tmp <= write_tmp(31 downto 8) & data_in;
				
			end if;
				
			cache_data(to_integer(unsigned(index))) <= write_tmp;
			tag_valid(to_integer(unsigned(index))) <= '0' & tag;
			
		end if;
					
	end process;
end Circuit;	

--------------------------------------
--- Direct-Mapped Cache Testbench ---
--------------------------------------

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity directmappedcache_tb is
end directmappedcache_tb;

architecture TB_ARCHITECTURE of directmappedcache_tb is
	-- Component declaration of the tested unit
	component directmappedcache
	port(
		BLOCK_SIZE : in INTEGER;
		NUM_BLOCKS : in INTEGER;
		WORD_SIZE : in INTEGER;
		TAG_SIZE : in INTEGER;
		INDEX_SIZE : in INTEGER;
		WORD_OFFSET : in INTEGER;
		clk : in STD_LOGIC;
		address : in STD_LOGIC_VECTOR(31 downto 0);
		data_in : in STD_LOGIC_VECTOR(7 downto 0);
		write_enable : in STD_LOGIC;
		read_enable : in STD_LOGIC;
		hit : out STD_LOGIC;
		miss : out STD_LOGIC;
		data_out : out STD_LOGIC_VECTOR(7 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal BLOCK_SIZE : INTEGER;
	signal NUM_BLOCKS : INTEGER;
	signal WORD_SIZE : INTEGER;
	signal TAG_SIZE : INTEGER;
	signal INDEX_SIZE : INTEGER;
	signal WORD_OFFSET : INTEGER;
	signal clk : STD_LOGIC;
	signal address : STD_LOGIC_VECTOR(31 downto 0);
	signal data_in : STD_LOGIC_VECTOR(7 downto 0);
	signal write_enable : STD_LOGIC;
	signal read_enable : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal hit : STD_LOGIC;
	signal miss : STD_LOGIC;
	signal data_out : STD_LOGIC_VECTOR(7 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : directmappedcache
		port map (
			BLOCK_SIZE => BLOCK_SIZE,
			NUM_BLOCKS => NUM_BLOCKS,
			WORD_SIZE => WORD_SIZE,
			TAG_SIZE => TAG_SIZE,
			INDEX_SIZE => INDEX_SIZE,
			WORD_OFFSET => WORD_OFFSET,
			clk => clk,
			address => address,
			data_in => data_in,
			write_enable => write_enable,
			read_enable => read_enable,
			hit => hit,
			miss => miss,
			data_out => data_out
		);

	-- Add your stimulus here ...	
	-- Clock process
    clock_process :process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- main process
    stim_proc: process
    begin	
       	--push 1
        address <= "00000000111111110000000011111100";
		data_in <= '00000001';
		read_enable <= '0';
        write_enable <= '1';
		
		wait for 10 ns;	 
		
		address <= "11111111000000000000000011111100";
		data_in <= '00000010';
		read_enable <= '0';
        write_enable <= '1';
		
		wait for 10 ns;
		
        address <= "11111111111111110000000011111100";
		data_in <= '00000011';
		read_enable <= '0';
        write_enable <= '1';
        
		wait for 10 ns; 		
        	
		address <= "00000000111111110000000011111100";
		data_in <= '00000001';
		read_enable <= '1';
        write_enable <= '0';
		
        wait for 10 ns; 		
        	
		address <= "00001100111111110000110011111101";
		data_in <= '00000001';
		read_enable <= '1';
        write_enable <= '0'; 

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_directmappedcache of directmappedcache_tb is
	for TB_ARCHITECTURE
		for UUT : directmappedcache
			use entity work.directmappedcache(circuit);
		end for;
	end for;
end TESTBENCH_FOR_directmappedcache;