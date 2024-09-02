library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

-- read from file

entity filter_tb is
PORT( clk : IN std_logic;   
     filter_out : out std_logic_vector(15 downto 0) 
     );
end filter_tb;

architecture filter_tb of filter_tb is
begin

    process -- (clk)            -- process now contains wait statement
        constant filename:      string := "myFile.txt"; -- use more than once
        file file_pointer:      text;
        variable line_content:  std_logic_vector(15 downto 0) ;
        variable line_num:      line; 
        variable filestatus:    file_open_status;
    begin
        file_open (filestatus, file_pointer, filename, READ_MODE);
        report filename & LF & HT & "file_open_status = " & 
                    file_open_status'image(filestatus);
        assert filestatus = OPEN_OK 
            report "file_open_status /= file_ok"
            severity FAILURE;    -- end simulation

        while not ENDFILE (file_pointer) loop
            wait until rising_edge(clk);  -- once per clock
            readline (file_pointer, line_num); 
            read (line_num, line_content);
            filter_out <= line_content;
        end loop;

        wait until rising_edge(clk); -- the last datum can be used first
        file_close (file_pointer);
        report filename & " closed.";
        wait;

    end process;

end architecture filter_tb;

----------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
--Datapath

entity DataPath is 
	port(
		clock : in std_logic;  
		reset : in std_logic;
		
		fetch_output : out std_logic_vector(15 downto 0); 		--IF
		pc_p2 : out std_logic_vector(15 downto 0); 				--IF
		pc_p2_int : out Integer;								--IF
																   
		regfile_input1 : out std_logic_vector(3 downto 0);		--ID 
		regfile_input2 : out std_logic_vector(3 downto 0);		--ID
		regfile_output1 : out std_logic_vector(15 downto 0);	--ID
		regfile_output2 : out std_logic_vector(15 downto 0);	--ID 
		immediate_se_output : out std_logic_vector(15 downto 0);--ID 
		jump_se_output : out std_logic_vector(15 downto 0);		--ID 
		wb_register_output : out std_logic_vector(3 downto 0);	--ID
		opcode_output : out std_logic_vector(3 downto 0);		--ID 
		pc_output : out std_logic_vector(15 downto 0);			--ID  
		jump_value : out std_logic_vector(15 downto 0);		   	--ID
		branch_value : out std_logic_vector(15 downto 0);	  	--ID
		
		alu_output : out std_logic_vector(15 downto 0);		  	--EXE 
		alu_output_int : out Integer;							--EXE
		sr_output : out std_logic_vector(15 downto 0);			--EXE 
		branch : out std_logic := '0';							--EXE
		
		mem_read : out std_logic;								--MEM
		mem_write : out std_logic;							  	--MEM
		mem_address_input : out std_logic_vector(15 downto 0);	--MEM		   
		mem_data_input : out std_logic_vector(15 downto 0);	  	--MEM
		mem_output : out std_logic_vector(15 downto 0);		   	--MEM
		
		wb_write : out std_logic;							  	--WB
		wb_reg : out std_logic_vector(3 downto 0);			  	--WB
		wb_data : out std_logic_vector(15 downto 0);		  	--WB 
	);		
end DataPath;

architecture Behavior of DataPath is	  

signal D0, D1, D2, D3 : std_logic_vector(15 downto 0) := "0000000000000000";	 --Data Registers
signal A0, A1, A2, A3 : std_logic_vector(15 downto 0) := "0000000000000000";	 --Address Registers
signal Zero, SR, BA : std_logic_vector(15 downto 0) := "0000000000000000";	 --Other Registers 
signal PC : std_logic_vector(15 downto 0);

signal IF_ID : std_logic_vector(31 downto 0);	--Shift Register IF/ID 		=  (PC + 2) & Instruction
signal ID_EXE : std_logic_vector(135 downto 0);	--Shift Register ID/EXE	 	=   & & destination_reg & opcode & (pc + 2) & jump_16 & immediate_16 & data2 & data1
signal EXE_MEM : std_logic_vector(23 downto 0);	--Shift Register EXE/MEM	=  opcdoe & destination_reg & address
signal MEM_WB : std_logic_vector(23 downto 0);	--Shift Register MEM/WB	 	=  opcode & destination_reg & address

signal Instruction : std_logic_vector(15 downto 0);	--Current Instruction

type IRAM is array (0 to 1023) of std_logic_vector(7 downto 0);	--1KB Instruction 		
type DRAM is array (0 to 3071) of std_logic_vector(7 downto 0);	--3KB Data
signal IMemory : IRAM;
signal DMemory : DRAM;

signal tmp :  std_logic_vector(15 downto 0);
component filter_tb
  port (clk: in STD_LOGIC;
  filter_out : out std_logic_vector(15 downto 0));
end component;

begin
	G1: filter_tb port map (clock, tmp);
	Stage1 : process (clock, reset) 		    
	variable pc_plus_two : std_logic_vector(15 downto 0);	
	begin 
		
		if reset = '1' then
    		PC <= (others => '0');
			Instruction <= (others => '0');
						 
		elsif rising_edge(clock) then 
		
		pc_plus_two := std_logic_vector(to_unsigned((to_integer(signed(PC)) + 2), 16)); 
			
		if ( ID_EXE(83 downto 80) = "1110"  and SR(15) = '0' ) then 
			PC <= branch_value;	   
			--reset branch_value ?!!??!
		elsif ( ID_EXE(83 downto 80) = "1111" ) then 										
			PC <= jump_value; 
			--reset jump_value ?!!??!
		elsif (ID_EXE(83 downto 80) = "1010") then
			PC <= PC;				---makes pc changes wrong!!! for hazrad branch
		else
			PC <= pc_plus_two; 		
		end if;	
			
		IMemory(to_integer(unsigned(PC))) <= tmp(15 Downto 8);
		IMemory(to_integer(unsigned(PC) + 1)) <= tmp (7 downto 0); 						   
		
		Instruction <= tmp;												
																							 
		pc_p2 <= PC;
		pc_p2_int <= to_integer(signed(pc_p2));			
		
		fetch_output <= Instruction;	
		
		--Filling IF_ID Shift Register
		IF_ID <= pc_plus_two & Instruction;
		
		end if;
		
	end process; 
	
	Stage2 : process (clock, reset) 
	
	variable read1 : std_logic_vector(3 downto 0) := IF_ID(11 downto 8);
	variable read2 : std_logic_vector(3 downto 0) := IF_ID(7 downto 4); 
	
	variable data1 : std_logic_vector(15 downto 0);
	variable data2 : std_logic_vector(15 downto 0);	
	
	variable immediate_16 : std_logic_vector(15 downto 0) := IF_ID(7) & IF_ID(7) & IF_ID(7) & IF_ID(7) &IF_ID(7) &IF_ID(7) &IF_ID(7) &IF_ID(7) & IF_ID(7 downto 0);	--SE!	
	variable jump_16 : std_logic_vector(15 downto 0) := IF_ID(11) & IF_ID(11) & IF_ID(11) & IF_ID(11) & IF_ID(11 downto 0);	 										--SE!
	variable pc_tmp : std_logic_vector(15 downto 0) := IF_ID(31 downto 16);																							
	variable opcode_tmp : std_logic_vector(3 downto 0) := IF_ID(15 downto 12);
	
	variable count_stall : integer := 0;	
	
	begin
		
		if reset = '1' then 
			read1 := (others => '0'); 
			read2 := (others => '0');
			data1 := (others => '0');
			data2 := (others => '0');
			immediate_16 := (others => '0');
			jump_16 := (others => '0');
			pc_tmp := (others => '0');
			opcode_tmp := (others => '0');
		
		elsif rising_edge(clock) then 
			
			read1 := IF_ID(11 downto 8);	 
			read2 := IF_ID(7 downto 4);
			immediate_16 := IF_ID(7) & IF_ID(7) & IF_ID(7) & IF_ID(7) &IF_ID(7) &IF_ID(7) &IF_ID(7) &IF_ID(7) & IF_ID(7 downto 0);
			jump_16 := IF_ID(31) & IF_ID(30) & IF_ID(29) & IF_ID(11) & IF_ID(11 downto 0);	--3 last digits from pc
			pc_tmp := IF_ID(31 downto 16);
			opcode_tmp := IF_ID(15 downto 12);
			
			--Modify data1(from reg2)
			if ( read1 = "0000" ) then
				data1 := Zero;
			elsif ( read1 = "0001" ) then
				data1 := D0;  
			elsif ( read1 = "0010" ) then
				data1 := D1;
			elsif ( read1 = "0011" ) then
				data1 := D2;
			elsif ( read1 = "0100" ) then
				data1 := D3;
			elsif ( read1 = "0101" ) then
				data1 := A0; 
			elsif ( read1 = "0110" ) then
				data1 := A1;
			elsif ( read1 = "0111" ) then
				data1 := A2;
			elsif ( read1 = "1000" ) then
				data1 := A3;
			elsif ( read1 = "1001" ) then
				data1 := SR; 
			elsif ( read1 = "1010" ) then
				data1 := BA;
			else
				data1 := PC;
			end if;		
	
			--Modify data2 (from reg2)
			if ( read2 = "0000" ) then
				data2 := Zero;
			elsif ( read2 = "0001" ) then
				data2 := D0; 
			elsif ( read2 = "0010" ) then
				data2 := D1;
			elsif ( read2 = "0011" ) then
				data2 := D2;
			elsif ( read2 = "0100" ) then
				data2 := D3;
			elsif ( read2 = "0101" ) then
				data2 := A0; 
			elsif ( read2 = "0110" ) then
				data2 := A1;
			elsif ( read2 = "0111" ) then
				data2 := A2;
			elsif ( read2 = "1000" ) then
				data2 := A3;
			elsif ( read2 = "1001" ) then
				data2 := SR; 
			elsif ( read2 = "1010" ) then
				data2 := BA;
			else
				data2 := PC;
			end if;				   			
			
			regfile_input1 <= read1;	
			regfile_input2 <= read2;
			
			regfile_output1 <= data1;	
			regfile_output2 <= data2;
			immediate_se_output <= immediate_16; 
			jump_se_output <= jump_16;
			wb_register_output <= read1;
			opcode_output <= opcode_tmp;
			pc_output <= pc_tmp; 
			
			
			if ( opcode_tmp	= "1110" ) then
				branch_value <= std_logic_vector(signed(pc_tmp) + signed(immediate_16) + signed(immediate_16));		--immediate_16 wrong!!!
				jump_value <= (others => '0');
			elsif ( opcode_tmp = "1111" ) then
	    		jump_value <= std_logic_vector(signed(jump_16) + signed(jump_16));	 	--jump_16 wrong!!!
				branch_value <= (others => '0');
			--else 
				--jump_value <= (others => '0');
				--branch_value <= (others => '0');
			end if;
			
				
			--Filling ID_EXE Shift Register
			ID_EXE <= SR & jump_value & branch_value & read1 & opcode_tmp & pc_tmp & jump_16 & immediate_16 & data2 & data1;  
			
			
			
			--hazard detector
			if ( opcode_tmp = "1110" or opcode_tmp = "1111") then --branch hazard detector
				count_stall := 2; 
			
			elsif ( opcode_tmp = "0000" or opcode_tmp = "0001" or opcode_tmp = "0010" or opcode_tmp = "0011" or opcode_tmp = "0100" or opcode_tmp = "0101" or opcode_tmp = "0110" or opcode_tmp = "0111" or opcode_tmp = "1001" or opcode_tmp = "1011" or opcode_tmp = "1100" or opcode_tmp = "1101" ) then	--data hazard detector
			
				if (opcode_tmp = "0000" or opcode_tmp = "0010" or opcode_tmp = "0101" or opcode_tmp = "1101") then 	--add, sub, and, compare (r-format)
					if ( ( ID_EXE(83 downto 80) = "0000" or ID_EXE(83 downto 80) = "0000" or ID_EXE(83 downto 80) = "0001" or ID_EXE(83 downto 80) = "0010" or ID_EXE(83 downto 80) = "0011" or ID_EXE(83 downto 80) = "0100" or ID_EXE(83 downto 80) = "0101" or ID_EXE(83 downto 80) = "0110" or ID_EXE(83 downto 80) = "0111" or ID_EXE(83 downto 80) = "1011" or ID_EXE(83 downto 80) = "1100" or ID_EXE(83 downto 80) = "1101" ) and ( ID_EXE(87 downto 84) = IF_ID(11 downto 8) or ID_EXE(87 downto 84) = IF_ID(7 downto 4) ) ) then -- hazard with EXE
						count_stall := 3;
					elsif ( ( EXE_MEM(23 downto 20) = "0000" or EXE_MEM(23 downto 20) = "0000" or EXE_MEM(23 downto 20) = "0001" or EXE_MEM(23 downto 20) = "0010" or EXE_MEM(23 downto 20) = "0011" or EXE_MEM(23 downto 20) = "0100" or EXE_MEM(23 downto 20) = "0101" or EXE_MEM(23 downto 20) = "0110" or EXE_MEM(23 downto 20) = "0111" or EXE_MEM(23 downto 20) = "1011" or EXE_MEM(23 downto 20) = "1100" or EXE_MEM(23 downto 20) = "1101" ) and ( EXE_MEM(19 downto 16) = IF_ID(11 downto 8) or EXE_MEM(19 downto 16) = IF_ID(7 downto 4) ) ) then -- hazard with MEM
						count_stall := 2;
					elsif ( ( MEM_WB(23 downto 20) = "0000" or MEM_WB(23 downto 20) = "0000" or MEM_WB(23 downto 20) = "0001" or MEM_WB(23 downto 20) = "0010" or MEM_WB(23 downto 20) = "0011" or MEM_WB(23 downto 20) = "0100" or MEM_WB(23 downto 20) = "0101" or MEM_WB(23 downto 20) = "0110" or MEM_WB(23 downto 20) = "0111" or MEM_WB(23 downto 20) = "1011" or MEM_WB(23 downto 20) = "1100" or MEM_WB(23 downto 20) = "1101" ) and ( MEM_WB(19 downto 16) = IF_ID(11 downto 8) or MEM_WB(19 downto 16) = IF_ID(7 downto 4) ) ) then -- hazard with WB
						count_stall := 1;
					end if;
				
				elsif (opcode_tmp = "0011" or opcode_tmp = "0100" or opcode_tmp = "0110" or opcode_tmp = "1011" or opcode_tmp = "1100") then 	--addi, sll, clear, move (i-format(type-1))
					if ( ( ID_EXE(83 downto 80) = "0000" or ID_EXE(83 downto 80) = "0000" or ID_EXE(83 downto 80) = "0001" or ID_EXE(83 downto 80) = "0010" or ID_EXE(83 downto 80) = "0011" or ID_EXE(83 downto 80) = "0100" or ID_EXE(83 downto 80) = "0101" or ID_EXE(83 downto 80) = "0110" or ID_EXE(83 downto 80) = "0111" or ID_EXE(83 downto 80) = "1011" or ID_EXE(83 downto 80) = "1100" or ID_EXE(83 downto 80) = "1101" ) and ( ID_EXE(87 downto 84) = IF_ID(11 downto 8) ) ) then -- hazard with EXE
						count_stall := 3;
					elsif ( ( EXE_MEM(23 downto 20) = "0000" or EXE_MEM(23 downto 20) = "0000" or EXE_MEM(23 downto 20) = "0001" or EXE_MEM(23 downto 20) = "0010" or EXE_MEM(23 downto 20) = "0011" or EXE_MEM(23 downto 20) = "0100" or EXE_MEM(23 downto 20) = "0101" or EXE_MEM(23 downto 20) = "0110" or EXE_MEM(23 downto 20) = "0111" or EXE_MEM(23 downto 20) = "1011" or EXE_MEM(23 downto 20) = "1100" or EXE_MEM(23 downto 20) = "1101" ) and ( EXE_MEM(19 downto 16) = IF_ID(11 downto 8) ) ) then -- hazard with MEM
						count_stall := 2;
					elsif ( ( MEM_WB(23 downto 20) = "0000" or MEM_WB(23 downto 20) = "0000" or MEM_WB(23 downto 20) = "0001" or MEM_WB(23 downto 20) = "0010" or MEM_WB(23 downto 20) = "0011" or MEM_WB(23 downto 20) = "0100" or MEM_WB(23 downto 20) = "0101" or MEM_WB(23 downto 20) = "0110" or MEM_WB(23 downto 20) = "0111" or MEM_WB(23 downto 20) = "1011" or MEM_WB(23 downto 20) = "1100" or MEM_WB(23 downto 20) = "1101" ) and ( MEM_WB(19 downto 16) = IF_ID(11 downto 8) ) ) then -- hazard with WB
						count_stall := 1;
					end if;
					
				end if;
			
			else	
				
				if (count_stall > 0) then
					count_stall := count_stall - 1;	
					ID_EXE <= SR & jump_value & branch_value & read1 & "1010" & std_logic_vector(signed(PC) - 2) & jump_16 & immediate_16 & data2 & data1; 
				end if;
				
			end if;
			
			
			
			
			
			--data hazard detector
			--elsif ( opcode_tmp = "0000" or opcode_tmp = "0001" or opcode_tmp = "0010" or opcode_tmp = "0011" or opcode_tmp = "0100" or opcode_tmp = "0101" or opcode_tmp = "0110" or opcode_tmp = "0111" or opcode_tmp = "1001" or opcode_tmp = "1011" or opcode_tmp = "1100" or opcode_tmp = "1101" ) then
	    			
				--if (opcode_tmp = "0000" or opcode_tmp = "0010" or opcode_tmp = "0101" or opcode_tmp = "1101") then 	--add, sub, and, compare (r)
					--if ( ( ID_EXE(83 downto 80) = "0000" or ID_EXE(83 downto 80) = "0000" or ID_EXE(83 downto 80) = "0001" or ID_EXE(83 downto 80) = "0010" or ID_EXE(83 downto 80) = "0011" or ID_EXE(83 downto 80) = "0100" or ID_EXE(83 downto 80) = "0101" or ID_EXE(83 downto 80) = "0110" or ID_EXE(83 downto 80) = "0111" or ID_EXE(83 downto 80) = "1011" or ID_EXE(83 downto 80) = "1100" or ID_EXE(83 downto 80) = "1101" ) and ( ID_EXE(87 downto 84) = IF_ID(11 downto 8) or ID_EXE(87 downto 84) = IF_ID(7 downto 4) ) then -- hazard with EXE
						
						--count_stall := 3;
						
			end if;
	
	end process;
	
	Stage3 : process (clock, reset) 	
	
	variable sr_tmp : std_logic_vector(15 downto 0) := ID_EXE(135 downto 120);
	variable jump_value : std_logic_vector(15 downto 0) := ID_EXE(119 downto 104);
	variable branch_value : std_logic_vector(15 downto 0) := ID_EXE(103 downto 88);
	variable des_reg : std_logic_vector(3 downto 0) := ID_EXE(87 downto 84);
	variable opcode : std_logic_vector(3 downto 0) := ID_EXE(83 downto 80); 
	variable pc_tmp : std_logic_vector(15 downto 0) := ID_EXE(79 downto 64);
	variable jump : std_logic_vector(15 downto 0) := ID_EXE(63 downto 48);		
	variable immediate : std_logic_vector(15 downto 0) := ID_EXE(47 downto 32);	
	variable data2 : std_logic_vector(15 downto 0) := ID_EXE(31 downto 16);
	variable data1 : std_logic_vector(15 downto 0) := ID_EXE(15 downto 0);
	
	variable result : std_logic_vector(15 downto 0);
	
	begin 
		
		if reset = '1' then 
		  	
			sr_tmp := (others => '0');
			jump_value := (others => '0');
			branch_value := (others => '0');
			des_reg := (others => '0');	 
			opcode := (others => '0'); 
			pc_tmp := (others => '0');
			jump := (others => '0');		
			immediate := (others => '0');	
			data2 := (others => '0');
			data1 := (others => '0');
			result := (others => '0');
			branch <= '0';
			SR <= (others => '0');
			
		elsif rising_edge(clock) then 
		
			sr_tmp := ID_EXE(135 downto 120);
			jump_value := ID_EXE(119 downto 104);
			branch_value := ID_EXE(103 downto 88);
			des_reg := ID_EXE(87 downto 84);
			opcode := ID_EXE(83 downto 80); 
			pc_tmp := ID_EXE(79 downto 64);
			jump := ID_EXE(63 downto 48);		
			immediate := ID_EXE(47 downto 32);	
			data2 := ID_EXE(31 downto 16);
			data1 := ID_EXE(15 downto 0);	
			
			if ( opcode = "0000" ) then		--add
				result := std_logic_vector(signed(data1) + signed(data2)); 
				alu_output <= std_logic_vector(signed(data1) + signed(data2));
				
				--Modify SR
				--Overflow
				if (signed(data1) > 0 and signed(data2) > 0 and signed(result) < 0) then
					SR(12) <= '1';
				elsif (signed(data1) < 0 and signed(data2) < 0 and signed(result) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( std_logic_vector(signed(data1) + signed(data2)) = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( to_integer(signed(std_logic_vector(signed(data1) + signed(data2)))) < 0 ) then	
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(data1) + signed(data2) = signed(signed(std_logic_vector(signed(data1) + signed(data2)))))	then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;
				
				branch <= '0' ;
				
			elsif ( opcode = "0001" ) then	--add
				result := std_logic_vector(signed(ba) + signed(immediate) + signed(immediate));  
				alu_output <= std_logic_vector(signed(ba) + signed(immediate) + signed(immediate));
				--Modify SR
				--Overflow
				if (signed(ba) > 0 and signed(immediate) > 0 and signed(result) < 0) then
					SR(12) <= '1';
				elsif (signed(ba) < 0 and signed(immediate) < 0 and signed(result) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( std_logic_vector(signed(ba) + signed(immediate) + signed(immediate)) = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(ba) + signed(immediate) + signed(immediate) = signed(std_logic_vector(signed(ba) + signed(immediate) + signed(immediate)))) then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;
				
				branch <= '0' ;
				
			elsif ( opcode = "0010" ) then	--sub
				result := std_logic_vector(signed(data1) - signed(data2));  
				alu_output <= std_logic_vector(signed(data1) - signed(data2)); 
				
				--Modify SR
				--Overflow
				if (signed(data1) > 0 and signed(data2) < 0 and signed(std_logic_vector(signed(data1) - signed(data2))) < 0) then
					SR(12) <= '1';
				elsif (signed(data1) < 0 and signed(data2) > 0 and signed(std_logic_vector(signed(data1) - signed(data2))) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( result = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then	
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(data1) - signed(data2) = signed(result))	then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;
				
				branch <= '0' ;
				
			elsif ( opcode = "0011" ) then	--addi
				result :=  std_logic_vector(signed(data1) + signed(immediate));
				alu_output <= std_logic_vector(signed(data1) + signed(immediate));
				
				--Modify SR
				--Overflow
				if (signed(data1) > 0 and signed(immediate) > 0 and signed(result) < 0) then
					SR(12) <= '1';
				elsif (signed(data1) < 0 and signed(immediate) < 0 and signed(result) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( result = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then	--true??
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(data1) + signed(immediate) = signed(result))	then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;
				
				branch <= '0' ;
				
			elsif ( opcode = "0101" ) then	--and
				result :=  std_logic_vector(signed(data1) and signed(data2));	--unsigned ??	--overflow??	--carry??
				alu_output <= std_logic_vector(signed(data1) and signed(data2));
				--Modify SR	
				--Zero and Negative
				if ( result = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then	--true??
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;
			
				branch <= '0' ;
				
			elsif ( opcode = "0110" ) then	--sll
				result :=  std_logic_vector(signed(data1) sll to_integer(unsigned(immediate))); 	--negative ?!	--overflow??	--carry??
				alu_output <= std_logic_vector(signed(data1) sll to_integer(unsigned(immediate)));
				--Modify SR
				--Zero and Negative
				if ( result = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then	--true??
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				
				branch <= '0' ;
				
			elsif ( opcode = "0111" ) then	--lw
				result :=  std_logic_vector(signed(ba) + signed(immediate) + signed(immediate)); 
				alu_output <= std_logic_vector(signed(ba) + signed(immediate) + signed(immediate)); 
				--Modify SR
				--Overflow
				if (signed(ba) > 0 and signed(immediate) > 0 and signed(result) < 0) then
					SR(12) <= '1';
				elsif (signed(ba) < 0 and signed(immediate) < 0 and signed(result) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( result = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then	--true??
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(ba) + signed(immediate) + signed(immediate) = signed(result)) then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;	
				
				branch <= '0' ;
				
			elsif ( opcode = "1001" ) then	--sw
				result :=  std_logic_vector(signed(ba) + signed(immediate) + signed(immediate));
				alu_output <= std_logic_vector(signed(ba) + signed(immediate) + signed(immediate));
				--Modify SR
				--Overflow
				if (signed(ba) > 0 and signed(immediate) > 0 and signed(result) < 0) then
					SR(12) <= '1';
				elsif (signed(ba) < 0 and signed(immediate) < 0 and signed(result) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( result = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then	--true??
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(ba) + signed(immediate) + signed(immediate) = signed(result)) then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;
				
				branch <= '0' ;
				
			elsif ( opcode = "1011" or opcode = "0100") then	--clr  	-----------------------------------------------------------------------------
				result :=  "0000000000000000"; 
				alu_output <= "0000000000000000"; 
				--Modify SR
				SR(15 downto 12) <= "1000";	--no overflow, no carry, zero
				
			elsif ( opcode = "1100" ) then	--move
				result :=  (immediate);
				alu_output <= immediate;
				--Modify SR			--no overflow, no carry 
				if ( signed(result) < 0 ) then
					SR(15 downto 12) <= "0100";
				elsif ( signed(result) = 0) then 
					SR(15 downto 12) <= "1000";
				else
					SR(15 downto 12) <= "0000";
				end if;
				
				branch <= '0' ;
				
			elsif ( opcode = "1101" ) then	--compare										
				result :=  std_logic_vector(signed(data1) - signed(data2));	 		 
			   	alu_output <= std_logic_vector(signed(data1) - signed(data2));	
				--Modify SR
				--Overflow
				if (signed(data1) > 0 and signed(data2) < 0 and signed(result) < 0) then
					SR(12) <= '1';
				elsif (signed(data1) < 0 and signed(data2) > 0 and signed(result) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( result = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(data1) - signed(data2) = signed(result))	then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;
				
				branch <= '0' ;
				
			elsif ( opcode = "1110" ) then	--bne										   
				result :=  std_logic_vector(signed(jump) + signed(jump));  	--ghalat!!!!!!!		
				alu_output <= std_logic_vector(signed(jump) + signed(jump)); 
				--Modify Branch
				if ( SR(15) = '0' ) then
					branch <= '1' ;
				else
					branch <= '0' ;
				end if;	
				
				--Modify SR
				--Overflow
				if (signed(jump) > 0 and signed(result) < 0) then
					SR(12) <= '1';
				elsif (signed(jump) < 0 and signed(result) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( result = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( result(15) = '1' ) then	--true??
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(jump) + signed(jump) = signed(result))	then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;		  
				
			elsif ( opcode = "1111" ) then 	--jump
				result :=  std_logic_vector(signed(jump) + signed(jump)); 
				alu_output <= std_logic_vector(signed(jump) + signed(jump)); 
				--Modify SR
				--Overflow
				if (signed(jump) > 0 and signed(std_logic_vector(signed(jump) + signed(jump))) < 0) then
					SR(12) <= '1';
				elsif (signed(jump) < 0 and signed(std_logic_vector(signed(jump) + signed(jump))) > 0) then
					SR(12) <= '1';
				else
					SR(12) <= '0';
				end if;
				--Zero and Negative
				if ( std_logic_vector(signed(jump) + signed(jump)) = "0000000000000000" ) then
					SR(15) <= '1';
					SR(14) <= '0';
				elsif ( to_integer(signed(std_logic_vector(signed(jump) + signed(jump)))) < 0 ) then	--true??
					SR(15) <= '0';
					SR(14) <= '1' ;
				else
					SR(15 downto 14) <= "00" ;
				end if;	
				--Carry
				if (signed(jump) + signed(jump) = signed(std_logic_vector(signed(jump) + signed(jump))))	then
					SR(13) <= '0';
				else
					SR(13) <= '1';
				end if;	   
				
				branch <= '1' ;
				
			else   --no other opcode!
				result := (others => '0');
				alu_output <= (others => '0');
			end if;	
			
			--alu_output <= result;
			alu_output_int <= to_integer(signed(result));
			sr_output <= sr;
			--next_pc_output <= PC;
	
			EXE_MEM <= opcode & des_reg & result;
			
		end if;
	
	end process;
	
	Stage4 : process (clock, reset) 		    
	
	variable opcode : std_logic_vector(3 downto 0) := EXE_MEM(23 downto 20);
	variable des_reg : std_logic_vector(3 downto 0) := EXE_MEM(19 downto 16);
	variable address : std_logic_vector(15 downto 0) := EXE_MEM(15 downto 0);
	variable data_out : std_logic_vector(15 downto 0);	
	variable data_in : std_logic_vector(15 downto 0);
	
	begin
		
		if reset = '1' then
			
			opcode := (others => '0');
			des_reg := (others => '0');
			address := (others => '0');
		
		elsif rising_edge(clock) then 
		
			opcode := EXE_MEM(23 downto 20);
			des_reg := EXE_MEM(19 downto 16);
			address := EXE_MEM(15 downto 0);
			
			mem_address_input <= address;
			
			--Determine Data to Write in Mem
			if ( des_reg = "0000" ) then
				data_in := Zero;
			elsif ( des_reg = "0001" ) then
				data_in := D0;  
			elsif ( des_reg = "0010" ) then
				data_in := D1;
			elsif ( des_reg = "0011" ) then
				data_in := D2;
			elsif ( des_reg = "0100" ) then
				data_in := D3;
			elsif ( des_reg = "0101" ) then
				data_in := A0; 
			elsif ( des_reg = "0110" ) then
				data_in := A1;
			elsif ( des_reg = "0111" ) then
				data_in := A2;
			elsif ( des_reg = "1000" ) then
				data_in := A3;
			elsif ( des_reg = "1001" ) then
				data_in := SR; 
			elsif ( des_reg = "1010" ) then
				data_in := BA;
			else
				data_in := PC;
			end if;	
		   	
			mem_data_input <= data_in;
			
			--Determine Read/Write Mem
			if ( opcode = "0001" ) then
				data_out := DMemory(to_integer(unsigned(address))) & DMemory(to_integer(unsigned(address)) + 1);
				mem_read <= '1';
				mem_write <= '0';
			elsif ( opcode = "0111" ) then
				data_out := DMemory(to_integer(unsigned(address))) & DMemory(to_integer(unsigned(address)) + 1); 
				mem_read <= '1';
				mem_write <= '0';
			elsif ( opcode = "1001" ) then
				DMemory(to_integer(unsigned(address))) <= data_in(15 downto 8);
				DMemory(to_integer(unsigned(address) + 1)) <= data_in(7 downto 0); 
				mem_read <= '0';
				mem_write <= '1';
			elsif ( opcode = "0100" ) then 	--clear mem
				DMemory(to_integer(unsigned(address))) <= "00000000";
				DMemory(to_integer(unsigned(address) + 1)) <= "00000000";
				mem_read <= '0';
				mem_write <= '1';
			else
				data_out := address;
				mem_read <= '0';
				mem_write <= '0';
			end if;		
	
			mem_output <= data_out;
	
			MEM_WB <= opcode & des_reg & data_out;
			
		end if;
	
	end process;
	
	Stage5 : process (clock, reset) 		    
	
	variable opcode : std_logic_vector(3 downto 0) := MEM_WB(23 downto 20);
	variable des_reg : std_logic_vector(3 downto 0) := MEM_WB(19 downto 16);
	variable data_in1 : std_logic_vector(15 downto 0) := MEM_WB(15 downto 0);
	variable data_out : std_logic_vector(15 downto 0);	
	variable data_in2 : std_logic_vector(15 downto 0);
	
	begin
		
		if reset = '1' then
		   
			opcode := (others => '0');
			des_reg := (others => '0');
			data_in1 :=	(others => '0');
			data_in2 :=	(others => '0');
			
		elsif rising_edge(clock) then 
		
			opcode := MEM_WB(23 downto 20);
			des_reg := MEM_WB(19 downto 16);
			data_in1 := MEM_WB(15 downto 0);
			
			wb_reg <= des_reg;	
			
			if ( opcode = "0001" ) then
				if ( des_reg = "0000" ) then
					 data_in2 := Zero;
				elsif ( des_reg = "0001" ) then
					data_in2 := D0;  
				elsif ( des_reg = "0010" ) then
					data_in2 := D1;
				elsif ( des_reg = "0011" ) then
					data_in2 := D2;
				elsif ( des_reg = "0100" ) then
					data_in2 := D3;
				elsif ( des_reg = "0101" ) then
					data_in2 := A0; 
				elsif ( des_reg = "0110" ) then
					data_in2 := A1;
				elsif ( des_reg = "0111" ) then
					data_in2 := A2;
				elsif ( des_reg = "1000" ) then
					data_in2 := A3;
				elsif ( des_reg = "1001" ) then
					data_in2 := SR; 
				elsif ( des_reg = "1010" ) then
					data_in2 := BA;
				elsif ( des_reg = "1011" ) then
					data_in2 := PC;
				else
					data_in2 := "0000000000000000";
				end if;	
				
				data_out := std_logic_vector(signed(data_in1) + signed(data_in2));	   	--signed?!?
		
			elsif ( opcode = "0111" or opcode = "0000" or opcode = "0010" or opcode = "0011" or opcode = "0101" or opcode = "0110" or opcode = "1011" or opcode = "1100") then
				data_out := data_in1;
			end if;
	
			if (opcode = "0001" or opcode = "0111" or opcode = "0000" or opcode = "0010" or opcode = "0011" or opcode = "0101" or opcode = "0110" or opcode = "1011" or opcode = "1100") then
				if ( des_reg = "0001" ) then
					D0 <= data_out;  
				elsif ( des_reg = "0010" ) then
					D1 <= data_out;
				elsif ( des_reg = "0011" ) then
					D2 <= data_out;
				elsif ( des_reg = "0100" ) then
					D3 <= data_out;
				elsif ( des_reg = "0101" ) then
					A0 <= data_out; 
				elsif ( des_reg = "0110" ) then
					A1 <= data_out;
				elsif ( des_reg = "0111" ) then
					A2 <= data_out;
				elsif ( des_reg = "1000" ) then
					A3 <= data_out;	
				elsif ( des_reg = "1010" ) then
					BA <= data_out;
				end if;
				wb_write <= '1'; 
				
			else
				wb_write <= '0'; 
				
			end if;
			
			wb_data <= data_out;
			
		end if;
	
	end process;							 
	
end Behavior;