-------------------------------------------------------------------------------
-- Title      : pbi_OpenBlaze8
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pbi_OpenBlaze8.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2017-03-30
-- Last update: 2025-03-17
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2017 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2017-03-30  1.0      mrosiere Created
-- 2025-01-21  1.1      mrosiere Fix busy usage
-- 2025-03-09  1.2      mrosiere Use unconstrainted pbi
-- 2025-03-15  1.3      mrosiere Stall idata_i when cke desasserted
-------------------------------------------------------------------------------


library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;
library work;
library work;
use     work.pbi_pkg.all;
use     work.OpenBlaze8_pkg.all;

entity pbi_OpenBlaze8 is
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
    iaddr_o          : out std_logic_vector(ADDR_INST_WIDTH-1 downto 0);
    idata_i          : in  std_logic_vector(18-1 downto 0);
    
    -- Bus
    pbi_ini_o        : out   pbi_ini_t;
    pbi_tgt_i        : in    pbi_tgt_t;

    -- To/From IT Ctrl
    interrupt_i      : in    std_logic;
    interrupt_ack_o  : out   std_logic
    );
  
end entity pbi_OpenBlaze8;

architecture rtl of pbi_OpenBlaze8 is
  signal cke     : std_logic;
  signal arst    : std_logic;
  signal cke_r   : std_logic;
  signal idata_r : std_logic_vector(18-1 downto 0);
  signal idata   : std_logic_vector(18-1 downto 0);
begin  -- architecture rtl

  arst    <= not arstn_i;
  cke     <= cke_i and not pbi_tgt_i.busy;

  -- If Clock disable from busy bus per exemple, save the rom and send in
  -- continous -> Bus access is unchanged
  process (clk_i, arst) is
  begin  -- process
    if arst = '1'
    then               -- asynchronous reset (active low)
      cke_r   <= '0';
      idata_r <= (others => '0');
    elsif rising_edge(clk_i)
    then
      cke_r   <= cke;
      if cke
      then
        idata_r <= idata_i;
      end if;
    end if;
  end process;

  idata   <= idata_r when cke_r = '0' else
             idata_i;
  
  OpenBlaze8 : entity work.OpenBlaze8(rtl)
  generic map(
     STACK_DEPTH     => STACK_DEPTH    ,
     RAM_DEPTH       => RAM_DEPTH      ,
     DATA_WIDTH      => DATA_WIDTH     ,
     ADDR_INST_WIDTH => ADDR_INST_WIDTH,
     REGFILE_DEPTH   => REGFILE_DEPTH  ,
     MULTI_CYCLE     => MULTI_CYCLE    
     )
  port map(
    clock_i           => clk_i          ,
    clock_enable_i    => cke            ,
    reset_i           => arst           ,
    address_o         => iaddr_o        ,
    instruction_i     => idata          ,
    port_id_o         => pbi_ini_o.addr ,
    in_port_i         => pbi_tgt_i.rdata,
    out_port_o        => pbi_ini_o.wdata,
    read_strobe_o     => pbi_ini_o.re   ,
    write_strobe_o    => pbi_ini_o.we   ,
    interrupt_i       => interrupt_i    ,
    interrupt_ack_o   => interrupt_ack_o
    );

  pbi_ini_o.cs <= '1';
  
end architecture rtl;
