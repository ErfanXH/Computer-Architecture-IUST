SetActiveLib -work
comp -include "$dsn\src\main.vhd" 
comp -include "$dsn\src\TestBench\datapath_TB.vhd" 
asim +access +r TESTBENCH_FOR_datapath 
wave 
wave -noreg clock
wave -noreg reset
wave -noreg fetch_output
wave -noreg pc_p2
wave -noreg regfile_input1
wave -noreg regfile_input2
wave -noreg regfile_output1
wave -noreg regfile_output2
wave -noreg immediate_se_output
wave -noreg jump_se_output
wave -noreg wb_register_output
wave -noreg opcode_output
wave -noreg jump_value
wave -noreg branch_value
wave -noreg alu_output
wave -noreg sr_output
wave -noreg branch
wave -noreg mem_read
wave -noreg mem_write
wave -noreg mem_address_input
wave -noreg mem_data_input
wave -noreg mem_output
wave -noreg wb_write
wave -noreg wb_reg
wave -noreg wb_data
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\datapath_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_datapath 
