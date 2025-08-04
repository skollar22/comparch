---------------------------------------------------------------------------
-- single_cycle_core.vhd - A Single-Cycle Processor Implementation
--
-- Notes : 
--
-- See single_cycle_core.pdf for the block diagram of this single
-- cycle processor core.
--
-- Instruction Set Architecture (ISA) for the single-cycle-core:
--   Each instruction is 16-bit wide, with four 4-bit fields.
--
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |   0    | 
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity single_cycle_core is
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32;
        IMM_SIZE : integer := 16;
        REG_SIZE : integer := 5
    );
    port ( btnL   : in std_logic;
           btnR   : in std_logic;
           btnU   : in std_logic;
           btnD   : in std_logic;
           clk    : in std_logic;
           btnC   : in std_logic;
           sw     : in std_logic_vector (15 downto 0);
           led    : out std_logic_vector (15 downto 0);
           an     : out std_logic_vector (3 downto 0);
           seg    : out std_logic_vector (6 downto 0);
           dp     : out std_logic );
end single_cycle_core;

architecture structural of single_cycle_core is

component Debounce is    -- debounce code - instantiate when implementing on the board;
    port( clk : in std_logic;    -- do not instantiate when simulating your FSM
          noisy_sig : in std_logic;
          clean_sig : out std_logic);
end component;

component program_counter is
    generic (
            PC_SIZE : integer := 8 );
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector((PC_SIZE - 1) downto 0);
           addr_out : out std_logic_vector((PC_SIZE - 1) downto 0) );
end component;

component instruction_memory is
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32
    );
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           hlt      : in  std_logic;
           addr_in  : in  std_logic_vector((PC_SIZE - 1) downto 0);
           insn_out : out std_logic_vector((DATA_SIZE - 1) downto 0) );
end component;

component sign_extend is
    generic (
        DATA_SIZE : integer := 32;
        IMM_SIZE : integer := 16
    );
    port ( data_in  : in  std_logic_vector((IMM_SIZE - 1) downto 0);
           data_out : out std_logic_vector((DATA_SIZE - 1) downto 0) );
end component;

component mux_2to1 is
    generic (
        MUX_SIZE : integer
    );
    Port ( mux_select : in STD_LOGIC;
           data_a : in STD_LOGIC_VECTOR ((MUX_SIZE - 1) downto 0);
           data_b : in STD_LOGIC_VECTOR ((MUX_SIZE - 1) downto 0);
           data_out : out STD_LOGIC_VECTOR ((MUX_SIZE - 1) downto 0));
end component;

component control_unit is
    port ( opcode     : in  std_logic_vector(5 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           mem_write  : out std_logic;
           mem_to_reg : out std_logic;
           led_write  : out std_logic;
           pc_add     : out std_logic;
           switch_in  : out std_logic );
end component;

component register_file is
    generic (
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector((REG_SIZE - 1) downto 0);
           read_register_b : in  std_logic_vector((REG_SIZE - 1) downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector((REG_SIZE - 1) downto 0);
           write_data      : in  std_logic_vector((DATA_SIZE - 1) downto 0);
           buttons         : in  std_logic_vector(3 downto 0);
           read_data_a     : out std_logic_vector((DATA_SIZE - 1) downto 0);
           read_data_b     : out std_logic_vector((DATA_SIZE - 1) downto 0);
           reg_out         : out std_logic_vector((DATA_SIZE - 1) downto 0) );
end component;

component single_register is
    port ( data_in          : in STD_LOGIC_VECTOR (15 downto 0);
           clk              : in STD_LOGIC;
           write_enable     : in STD_LOGIC;
           reset            : in STD_LOGIC;
           data_out         : out STD_LOGIC_VECTOR (15 downto 0) );
end component;

component adder is
    generic (
        ADD_SIZE : integer := 8
    );
    port ( src_a     : in  std_logic_vector((PC_SIZE - 1) downto 0);
           src_b     : in  std_logic_vector((PC_SIZE - 1) downto 0);
           sum       : out std_logic_vector((PC_SIZE - 1) downto 0);
           carry_out : out std_logic );
end component;

--component adder_32b is
--    generic (
--            ADD_SIZE : integer := 32
--        );
--    port ( src_a     : in  std_logic_vector((DATA_SIZE - 1) downto 0);
--           src_b     : in  std_logic_vector((DATA_SIZE - 1) downto 0);
--           sum       : out std_logic_vector((DATA_SIZE - 1) downto 0);
--           equal     : out std_logic;
--           carry_out : out std_logic );
--end component;

component data_memory is
    generic (
        DATA_SIZE : integer := 32;
        ADDR_SIZE : integer := 8
    );
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector((DATA_SIZE - 1) downto 0);
           addr_in      : in  std_logic_vector((PC_SIZE - 1) downto 0);
           data_out     : out std_logic_vector((DATA_SIZE - 1) downto 0) );
end component;

component alu_control is
    port ( opcode : in  std_logic_vector(5 downto 0);
           funct  : in  std_logic_vector(3 downto 0); -- for R-type
           alu_op : out std_logic_vector(3 downto 0);  -- ALU operation select
           shift  : out std_logic
    );
end component;

component mips_alu is
    generic (
        DATA_SIZE : integer := 32
    );
    Port (
        src_a      : in  std_logic_vector((DATA_SIZE - 1) downto 0);
        src_b      : in  std_logic_vector((DATA_SIZE - 1) downto 0);
        alu_op     : in  std_logic_vector(3 downto 0);
        shift      : in  std_logic;
        shfunct    : in  std_logic;
        shamnt     : in  std_logic_vector(4 downto 0);
        result     : out std_logic_vector((DATA_SIZE - 1) downto 0);
        zero       : out std_logic;
        carry_out  : out std_logic
    );
end component;

-- pipeline stuff
component hazard_unit is
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        -- in
        pc_add          : in std_logic;
        data_1          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        data_2          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        branch_pc       : in std_logic_vector((PC_SIZE - 1) downto 0);  -- sig_ex_next_pc / flush pc
        stall_pc        : in std_logic_vector((PC_SIZE - 1) downto 0);  -- pc remains the same as currently is, ie sig_if_curr_pc
        next_pc         : in std_logic_vector((PC_SIZE - 1) downto 0);  -- normal behaviour, ie sig_if_next_pc
        hlt             : in std_logic;
        imm8b           : in std_logic_vector((PC_SIZE - 1) downto 0);
        id_mem_read     : in std_logic;
        id_reg_rt       : in std_logic_vector((REG_SIZE - 1) downto 0);
        if_reg_rs       : in std_logic_vector((REG_SIZE - 1) downto 0);
        if_reg_rt       : in std_logic_vector((REG_SIZE - 1) downto 0);
        
        -- out
        if_flush        : out std_logic;
        if_stall        : out std_logic;
        new_pc          : out std_logic_vector((PC_SIZE - 1) downto 0)
    );
end component;

component halting_unit is
    generic (
        DATA_SIZE : integer := 32
    );
    Port (
        reset       : in std_logic;
        clk         : in std_logic;
        instr       : in std_logic_vector((DATA_SIZE - 1) downto 0);
        flush       : in std_logic;
        stall       : in std_logic;
        ext_resume  : in std_logic;
        hlt         : out std_logic
    );
end component;

component forwarding_unit is
    generic (
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        -- control
        id_reg_1        : in std_logic_vector((REG_SIZE - 1) downto 0);
        id_reg_2        : in std_logic_vector((REG_SIZE - 1) downto 0);
        ex_write_reg    : in std_logic_vector((REG_SIZE - 1) downto 0);
        mem_write_reg   : in std_logic_vector((REG_SIZE - 1) downto 0);
        
        -- data
        id_reg_1_data   : in std_logic_vector((DATA_SIZE - 1) downto 0);
        id_reg_2_data   : in std_logic_vector((DATA_SIZE - 1) downto 0);
        ex_wr_data      : in std_logic_vector((DATA_SIZE - 1) downto 0);
        mem_wr_data     : in std_logic_vector((DATA_SIZE - 1) downto 0);
        
        -- outputs
        reg_1_out       : out std_logic_vector((DATA_SIZE - 1) downto 0);
        reg_2_out       : out std_logic_vector((DATA_SIZE - 1) downto 0)
    );
end component;

component reg_to_7seg is
    generic (
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    port (
           clk       : in std_logic;
           reg_value : in std_logic_vector((DATA_SIZE - 1) downto 0);
           dp        : out std_logic;
           an        : out std_logic_vector(3 downto 0);
           seg       : out std_logic_vector(6 downto 0)
    );
end component;

component IFID_reg is
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        instr       : in std_logic_vector((DATA_SIZE - 1) downto 0);
        next_pc     : in std_logic_vector((PC_SIZE - 1) downto 0);
        flush       : in std_logic;
        stall       : in std_logic;
        clk         : in std_logic;
        opcode      : out std_logic_vector(5 downto 0);
        rs          : out std_logic_vector((REG_SIZE - 1) downto 0);
        rt          : out std_logic_vector((REG_SIZE - 1) downto 0);
        rd          : out std_logic_vector((REG_SIZE - 1) downto 0);
        imm16b      : out std_logic_vector(15 downto 0);
        shamnt      : out std_logic_vector(4 downto 0);
        shfunct     : out std_logic;
        pc_out      : out std_logic_vector((PC_SIZE - 1) downto 0)
    );
end component;

component IDEX_reg is
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        read_data_1         : in std_logic_vector((DATA_SIZE - 1) downto 0);
        read_data_2         : in std_logic_vector((DATA_SIZE - 1) downto 0);
        imm_ext32b          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        read_reg_1          : in std_logic_vector((REG_SIZE - 1) downto 0);
        read_reg_2          : in std_logic_vector((REG_SIZE - 1) downto 0);
        write_reg           : in std_logic_vector((REG_SIZE - 1) downto 0);
        next_pc             : in std_logic_vector((PC_SIZE - 1) downto 0);
        ex_ctrl             : in std_logic_vector(1 downto 0);
        mem_ctrl            : in std_logic;
        wb_ctrl             : in std_logic_vector(3 downto 0);
        clk                 : in std_logic;
        flush               : in std_logic;
        stall               : in std_logic;
        opcode              : in std_logic_vector(5 downto 0);
        shamnt              : in std_logic_vector(4 downto 0);
        shfunct             : in std_logic;
        read_out_1          : out std_logic_vector((DATA_SIZE - 1) downto 0);
        read_out_2          : out std_logic_vector((DATA_SIZE - 1) downto 0);
        imm32b              : out std_logic_vector((DATA_SIZE - 1) downto 0);
        imm8b               : out std_logic_vector((PC_SIZE - 1) downto 0);
        rr_out_1            : out std_logic_vector((REG_SIZE - 1) downto 0);
        rr_out_2            : out std_logic_vector((REG_SIZE - 1) downto 0);
        wr_out              : out std_logic_vector((REG_SIZE - 1) downto 0);
        pc_out              : out std_logic_vector((PC_SIZE - 1) downto 0);
        mem_ctrl_out        : out std_logic;
        wb_ctrl_out         : out std_logic_vector(3 downto 0);
        alu_src             : out std_logic;
        pc_add              : out std_logic;
        opcode_out          : out std_logic_vector(5 downto 0);
        shamnt_out          : out std_logic_vector(4 downto 0);
        shfunct_out         : out std_logic

    );
end component;

component EXMEM_reg is
    generic (
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        alu_result          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        read_data_2         : in std_logic_vector((DATA_SIZE - 1) downto 0);
        write_reg           : in std_logic_vector((REG_SIZE - 1) downto 0);
        mem_ctrl            : in std_logic;
        wb_ctrl             : in std_logic_vector(3 downto 0);
        clk                 : in std_logic;
        alu_res_out         : out std_logic_vector((DATA_SIZE - 1) downto 0);
        read_data_out_2     : out std_logic_vector((DATA_SIZE - 1) downto 0);
        write_reg_out       : out std_logic_vector((REG_SIZE - 1) downto 0);
        mem_write           : out std_logic;
        wb_ctrl_out         : out std_logic_vector(3 downto 0)
    );
end component;

component MEMWB_reg is
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        alu_result          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        mem_result          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        write_reg           : in std_logic_vector((REG_SIZE - 1) downto 0);
        wb_ctrl             : in std_logic_vector(3 downto 0);
        clk                 : in std_logic;
        alu_result_out      : out std_logic_vector((DATA_SIZE - 1) downto 0);
        mem_result_out      : out std_logic_vector((DATA_SIZE - 1) downto 0);
        write_reg_out       : out std_logic_vector((REG_SIZE - 1) downto 0);
        reg_write           : out std_logic;
        mem_to_reg          : out std_logic;
        switch_in           : out std_logic;
        led_write           : out std_logic
    );
end component;

signal sig_if_next_pc              : std_logic_vector((PC_SIZE - 1) downto 0);
signal sig_if_curr_pc              : std_logic_vector((PC_SIZE - 1) downto 0);
signal sig_one_8b                  : std_logic_vector((PC_SIZE - 1) downto 0);
signal sig_if_pc_carry_out         : std_logic;
signal sig_if_insn                 : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_id_imm32b               : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_id_reg_dst              : std_logic;
signal sig_id_reg_write            : std_logic;
signal sig_id_alu_src              : std_logic;
signal sig_id_mem_write            : std_logic;
signal sig_id_mem_to_reg           : std_logic;
signal sig_id_led_write            : std_logic;
signal sig_id_pc_add               : std_logic;
signal sig_id_switch_in            : std_logic;
signal sig_id_write_reg            : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_id_read_data_a          : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_id_read_data_b          : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_ex_alu_src_b            : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_ex_alu_result           : std_logic_vector((DATA_SIZE - 1) downto 0); 
signal sig_ex_alu_carry_out        : std_logic;
signal sig_mem_data_mem_out         : std_logic_vector((DATA_SIZE - 1) downto 0);

signal sig_pc_next_actual       : std_logic_vector((PC_SIZE - 1) downto 0);
signal sig_alu_equal            : std_logic;
signal sig_wb_dispr_out         : std_logic_vector (15 downto 0);

signal sig_if_hlt               : std_logic;
signal sig_if_flush             : std_logic;
signal sig_if_stall             : std_logic;


signal sig_id_opcode      : std_logic_vector(5 downto 0);
signal sig_id_rs          : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_id_rt          : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_id_rd          : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_id_imm16b      : std_logic_vector(15 downto 0);
--signal sig_id_imm32b      : std_logic_vector(31 downto 0);
signal sig_id_pc_out      : std_logic_vector((PC_SIZE - 1) downto 0);
signal sig_id_ex_ctrl     : std_logic_vector(1 downto 0);
signal sig_id_wb_ctrl     : std_logic_vector(3 downto 0);

signal sig_ex_read_out_1          : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_ex_read_out_2          : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_ex_imm32b              : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_ex_imm8b               : std_logic_vector((PC_SIZE - 1) downto 0);
signal sig_ex_rr_out_1            : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_ex_rr_out_2            : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_ex_wr_out              : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_ex_pc_out              : std_logic_vector((PC_SIZE - 1) downto 0);
signal sig_ex_mem_ctrl_out        : std_logic;
signal sig_ex_wb_ctrl_out         : std_logic_vector(3 downto 0);
signal sig_ex_alu_src             : std_logic;
signal sig_ex_pc_add              : std_logic;

signal sig_ex_read_data_1             : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_ex_read_data_2             : std_logic_vector((DATA_SIZE - 1) downto 0);

signal sig_mem_alu_res_out         : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_mem_read_data_out_2     : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_mem_write_reg_out       : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_mem_mem_write           : std_logic;
signal sig_mem_wb_ctrl_out         : std_logic_vector(3 downto 0);

signal sig_wb_reg_write   : std_logic;
signal sig_wb_write_reg   : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_wb_write_data  : std_logic_vector((DATA_SIZE - 1) downto 0);

signal sig_wb_alu_result_out      : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_wb_mem_result_out      : std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_wb_write_reg_out       : std_logic_vector((REG_SIZE - 1) downto 0);
signal sig_wb_mem_to_reg          : std_logic;
signal sig_wb_switch_in           : std_logic;
signal sig_wb_led_write           : std_logic;

signal sig_wb_alu_or_mem            : std_logic_vector((DATA_SIZE - 1) downto 0);




signal sig_wb_sw_ext                : std_logic_vector((DATA_SIZE - 1) downto 0);


signal sig_alu_op                   : std_logic_vector(3 downto 0);
signal sig_alu_zero                 : std_logic;
signal sig_ex_opcode                : std_logic_vector(5 downto 0);
signal sig_buttons                  : std_logic_vector(3 downto 0);
signal sig_reg_out                  : std_Logic_vector((DATA_SIZE - 1) downto 0);

signal sig_id_shamnt                : std_logic_vector(4 downto 0);
signal sig_id_shfunct               : std_logic;

signal sig_ex_shamnt                : std_logic_vector(4 downto 0);
signal sig_ex_shfunct               : std_logic;
signal sig_ex_shift                 : std_logic;

signal sig_debounce_btnC            : std_logic;

begin

    sig_one_8b <= "00000001";
    sig_buttons <= btnL & btnR & btnU & btnD;
    
    DebounceBtnC: Debounce port map (clk, btnC, sig_debounce_btnC); -- when doing board impl
    -- sig_debounce_btnC <= btnC;                                      -- when doing simulation
    
    seven_seg : reg_to_7seg
    port map ( clk       => clk,
               reg_value => sig_reg_out,
               dp        => dp,
               an        => an,
               seg       => seg );
    
    -- =========================================================================================
    --                                     IF STAGE
    -- =========================================================================================

    pc : program_counter
    port map ( reset    => btnL,
               clk      => clk,
               addr_in  => sig_pc_next_actual,
               addr_out => sig_if_curr_pc ); 

    next_pc : adder 
    port map ( src_a     => sig_if_curr_pc, 
               src_b     => sig_one_8b,
               sum       => sig_if_next_pc,   
               carry_out => sig_if_pc_carry_out );
    
    insn_mem : instruction_memory 
    port map ( reset    => btnL,
               clk      => clk,
               hlt      => sig_if_hlt,
               addr_in  => sig_if_curr_pc,
               insn_out => sig_if_insn );
               
    haz_unit : hazard_unit
    port map (
        -- in
        pc_add          => sig_ex_pc_add,
        data_1          => sig_ex_read_data_1,
        data_2          => sig_ex_read_data_2,
        branch_pc       => sig_ex_pc_out,  -- sig_ex_next_pc / flush pc
        stall_pc        => sig_if_curr_pc,  -- pc remains the same as currently is, ie sig_if_curr_pc
        next_pc         => sig_if_next_pc,  -- normal behaviour, ie sig_if_next_pc
        hlt             => sig_if_hlt,
        imm8b           => sig_ex_imm8b,
        id_mem_read     => sig_ex_wb_ctrl_out(2),
        id_reg_rt       => sig_ex_rr_out_2,
        if_reg_rs       => sig_id_rs,
        if_reg_rt       => sig_id_rt,
        
        -- out
        if_flush        => sig_if_flush,
        if_stall        => sig_if_stall,
        new_pc          => sig_pc_next_actual
    );
    
    hlt_unit : halting_unit
    port map ( reset        => btnL,
               clk          => clk,
               instr        => sig_if_insn,
               flush        => sig_if_flush,
               stall        => sig_if_stall,
               ext_resume   => sig_debounce_btnC,
               hlt          => sig_if_hlt);
    
    if_id_reg : IFID_reg
    port map (
        instr       => sig_if_insn,
        next_pc     => sig_if_next_pc,
        flush       => sig_if_flush,
        stall       => sig_if_stall,
        clk         => clk,
        opcode      => sig_id_opcode,
        rs          => sig_id_rs,
        rt          => sig_id_rt,
        rd          => sig_id_rd,
        imm16b       => sig_id_imm16b,
        shamnt      => sig_id_shamnt,
        shfunct     => sig_id_shfunct,
        pc_out      => sig_id_pc_out
    );
    
    -- ================================================================================================
    --                                   ID STAGE                                                      
    -- ================================================================================================

    sign_extender : sign_extend
    generic map (
                DATA_SIZE => DATA_SIZE,
                IMM_SIZE => IMM_SIZE
    )
    port map ( data_in  => sig_id_imm16b,
               data_out => sig_id_imm32b );

    ctrl_unit : control_unit 
    port map ( opcode     => sig_id_opcode,
               reg_dst    => sig_id_reg_dst,
               reg_write  => sig_id_reg_write,
               alu_src    => sig_id_alu_src,
               mem_write  => sig_id_mem_write,
               mem_to_reg => sig_id_mem_to_reg,
               led_write  => sig_id_led_write,
               pc_add     => sig_id_pc_add,
               switch_in  => sig_id_switch_in );

    mux_reg_dst : mux_2to1
    generic map (
                MUX_SIZE => REG_SIZE
                )
    port map ( mux_select => sig_id_reg_dst,
               data_a     => sig_id_rt,
               data_b     => sig_id_rd,
               data_out   => sig_id_write_reg );

    reg_file : register_file 
    port map ( reset           => btnL, 
               clk             => clk,
               read_register_a => sig_id_rs,
               read_register_b => sig_id_rt,
               write_enable    => sig_wb_reg_write,
               write_register  => sig_wb_write_reg,
               write_data      => sig_wb_write_data,
               buttons         => sig_buttons,
               read_data_a     => sig_id_read_data_a,
               read_data_b     => sig_id_read_data_b,
               reg_out         => sig_reg_out );
    
    -- because vhdl dumb
    sig_id_ex_ctrl <= sig_id_alu_src & sig_id_pc_add;
    sig_id_wb_ctrl <= sig_id_reg_write & sig_id_mem_to_reg & sig_id_switch_in & sig_id_led_write;
    
    id_ex_reg : IDEX_reg
    port map (
        read_data_1         => sig_id_read_data_a,
        read_data_2         => sig_id_read_data_b,
        imm_ext32b          => sig_id_imm32b,
        read_reg_1          => sig_id_rs,
        read_reg_2          => sig_id_rt,
        write_reg           => sig_id_write_reg,
        next_pc             => sig_id_pc_out,
        ex_ctrl             => sig_id_ex_ctrl,
        mem_ctrl            => sig_id_mem_write,
        wb_ctrl             => sig_id_wb_ctrl,
        clk                 => clk,
        flush               => sig_if_flush,
        stall               => sig_if_stall,
        opcode              => sig_id_opcode,
        shamnt              => sig_id_shamnt,
        shfunct             => sig_id_shfunct,
        read_out_1          => sig_ex_read_out_1,
        read_out_2          => sig_ex_read_out_2,
        imm32b              => sig_ex_imm32b,
        imm8b               => sig_ex_imm8b,
        rr_out_1            => sig_ex_rr_out_1,
        rr_out_2            => sig_ex_rr_out_2,
        wr_out              => sig_ex_wr_out,
        pc_out              => sig_ex_pc_out,
        mem_ctrl_out        => sig_ex_mem_ctrl_out,
        wb_ctrl_out         => sig_ex_wb_ctrl_out,
        alu_src             => sig_ex_alu_src,
        pc_add              => sig_ex_pc_add,
        opcode_out          => sig_ex_opcode,
        shamnt_out          => sig_ex_shamnt,
        shfunct_out         => sig_ex_shfunct
    );
               
    -- ======================================================================================
    --                                 EX STAGE
    -- ======================================================================================

    fw_unit : forwarding_unit
    port map(
        -- control
        id_reg_1        => sig_ex_rr_out_1,
        id_reg_2        => sig_ex_rr_out_2,
        ex_write_reg    => sig_mem_write_reg_out,
        mem_write_reg   => sig_wb_write_reg,
        
        -- data
        id_reg_1_data   => sig_ex_read_out_1,
        id_reg_2_data   => sig_ex_read_out_2,
        ex_wr_data      => sig_mem_alu_res_out,
        mem_wr_data     => sig_wb_mem_result_out,
        
        -- outputs
        reg_1_out       => sig_ex_read_data_1,
        reg_2_out       => sig_ex_read_data_2
    );
    
    mux_alu_src : mux_2to1
    generic map (
                MUX_SIZE => DATA_SIZE
                )
    port map ( mux_select => sig_ex_alu_src,
               data_a     => sig_ex_read_data_2,
               data_b     => sig_ex_imm32b,
               data_out   => sig_ex_alu_src_b );

    -- alu : adder_32b 
    -- port map ( src_a     => sig_ex_read_data_1,
    --            src_b     => sig_ex_alu_src_b,
    --            sum       => sig_ex_alu_result,
    --            equal     => sig_alu_equal,
    --            carry_out => sig_ex_alu_carry_out );

    alu_ctl: alu_control
    port map ( opcode => sig_ex_opcode,
                funct => (OTHERS => '0'), -- hardcoded not used
                alu_op => sig_alu_op,
                shift => sig_ex_shift
                );

    alu: mips_alu 
    port map ( src_a => sig_ex_read_data_1,
               src_b => sig_ex_alu_src_b,
               alu_op => sig_alu_op,
               shift    => sig_ex_shift,
               shfunct  => sig_ex_shfunct,
               shamnt   => sig_ex_shamnt,
               result => sig_ex_alu_result,
               zero => sig_alu_zero,
               carry_out => sig_ex_alu_carry_out );
               
    ex_mem_reg : EXMEM_reg
    port map (
        alu_result          => sig_ex_alu_result,
        read_data_2         => sig_ex_read_data_2,
        write_reg           => sig_ex_wr_out,
        mem_ctrl            => sig_ex_mem_ctrl_out,
        wb_ctrl             => sig_ex_wb_ctrl_out,
        clk                 => clk,
        alu_res_out         => sig_mem_alu_res_out,
        read_data_out_2     => sig_mem_read_data_out_2,
        write_reg_out       => sig_mem_write_reg_out,
        mem_write           => sig_mem_mem_write,
        wb_ctrl_out         => sig_mem_wb_ctrl_out
    );
               
    -- ========================================================================================
    --                                   MEM STAGE
    -- ========================================================================================

    data_mem : data_memory 
    port map ( reset        => btnL,
               clk          => clk,
               write_enable => sig_mem_mem_write,
               write_data   => sig_mem_read_data_out_2,
               addr_in      => sig_mem_alu_res_out(7 downto 0), -- todo: genericise
               data_out     => sig_mem_data_mem_out );
    
    mem_wb_reg : MEMWB_reg
    port map (
        alu_result          => sig_mem_alu_res_out,
        mem_result          => sig_mem_data_mem_out,
        write_reg           => sig_mem_write_reg_out,
        wb_ctrl             => sig_mem_wb_ctrl_out,
        clk                 => clk,
        alu_result_out      => sig_wb_alu_result_out,
        mem_result_out      => sig_wb_mem_result_out,
        write_reg_out       => sig_wb_write_reg,
        reg_write           => sig_wb_reg_write,
        mem_to_reg          => sig_wb_mem_to_reg,
        switch_in           => sig_wb_switch_in,
        led_write           => sig_wb_led_write
    );
    
    -- =========================================================================================
    --                                     WB STAGE
    -- =========================================================================================
    
    mux_mem_to_reg : mux_2to1
    generic map (
                MUX_SIZE => DATA_SIZE
                )
    port map ( mux_select => sig_wb_mem_to_reg,
               data_a     => sig_wb_alu_result_out,
               data_b     => sig_wb_mem_result_out,
               data_out   => sig_wb_alu_or_mem );
    
    display_register : single_register
    port map ( data_in      => sig_wb_alu_or_mem(15 downto 0),
               clk          => clk,
               write_enable => sig_wb_led_write,
               reset        => btnL,
               data_out     => sig_wb_dispr_out );
    
    sw_ext : sign_extend
    generic map (
                DATA_SIZE => DATA_SIZE,
                IMM_SIZE => IMM_SIZE
                )
    port map ( data_in => sw,
               data_out => sig_wb_sw_ext );
    
    
    mux_final_data_out : mux_2to1
    generic map (
                MUX_SIZE => DATA_SIZE
                )
    port map ( mux_select => sig_wb_switch_in,
               data_a     => sig_wb_alu_or_mem,
               data_b     => sig_wb_sw_ext,
               data_out   => sig_wb_write_data );
    
    led <= sig_wb_dispr_out;
end structural;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debounce is
    port( clk : in std_logic;
          noisy_sig : in std_logic;
          clean_sig : out std_logic);
end debounce;

architecture behavioural of debounce is
    signal input_prev : std_logic;
    signal synch_count : std_logic_vector(40 downto 0);
begin
    synchronize: process
    begin
        wait until clk'event and clk = '1';
        input_prev <= noisy_sig;
        if noisy_sig /= input_prev then
            synch_count <= (others => '0');
        elsif synch_count /= x"100000" then
            synch_count <= synch_count + 1;
        end if;
        if (synch_count = x"100000" or synch_count = x"100001") and noisy_sig = '1' then
            clean_sig <= '1';
        else
            clean_sig <= '0';
        end if;
    end process;
end behavioural;