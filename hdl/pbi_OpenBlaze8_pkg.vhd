library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
library asylum;
use     asylum.pbi_pkg.all;

package pbi_OpenBlaze8_pkg is
-- [COMPONENT_INSERT][BEGIN]
component pbi_OpenBlaze8 is
  generic (
     STACK_DEPTH     : natural := 32;
     RAM_DEPTH       : natural := 64;
     DATA_WIDTH      : natural := 8;
     ADDR_INST_WIDTH : natural := 10;
     REGFILE_DEPTH   : natural := 16;
     MULTI_CYCLE     : natural := 1);
  port   (
    clk_i            : in    std_logic;
    cke_i            : in    std_logic;
    arstn_i          : in    std_logic; -- asynchronous reset

    -- Instructions
    ics_o            : out std_logic;
    iaddr_o          : out std_logic_vector(ADDR_INST_WIDTH-1 downto 0);
    idata_i          : in  std_logic_vector(18-1 downto 0);
    
    -- Bus
    pbi_ini_o        : out   pbi_ini_t;
    pbi_tgt_i        : in    pbi_tgt_t;

    -- To/From IT Ctrl
    interrupt_i      : in    std_logic;
    interrupt_ack_o  : out   std_logic
    );
  
end component pbi_OpenBlaze8;

-- [COMPONENT_INSERT][END]

end pbi_OpenBlaze8_pkg;
