library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity timapulpemu_top is

  port (
    DDR_addr          : inout std_logic_vector(14 downto 0);
    DDR_ba            : inout std_logic_vector(2 downto 0);
    DDR_cas_n         : inout std_logic;
    DDR_ck_n          : inout std_logic;
    DDR_ck_p          : inout std_logic;
    DDR_cke           : inout std_logic;
    DDR_cs_n          : inout std_logic;
    DDR_dm            : inout std_logic_vector(3 downto 0);
    DDR_dq            : inout std_logic_vector(31 downto 0);
    DDR_dqs_n         : inout std_logic_vector(3 downto 0);
    DDR_dqs_p         : inout std_logic_vector(3 downto 0);
    DDR_odt           : inout std_logic;
    DDR_ras_n         : inout std_logic;
    DDR_reset_n       : inout std_logic;
    DDR_we_n          : inout std_logic;
    FIXED_IO_ddr_vrn  : inout std_logic;
    FIXED_IO_ddr_vrp  : inout std_logic;
    FIXED_IO_mio      : inout std_logic_vector(53 downto 0);
    FIXED_IO_ps_clk   : inout std_logic;
    FIXED_IO_ps_porb  : inout std_logic;
    FIXED_IO_ps_srstb : inout std_logic;
    LD_o              : out   std_logic_vector(7 downto 0);
    sw_i              : in    std_logic_vector(7 downto 0);
    btn_i             : in    std_logic_vector(4 downto 0);
    tck_i             : in    std_logic;
    trstn_i           : in    std_logic;
    tdi_i             : in    std_logic;
    tms_i             : in    std_logic;
    tdo_o             : out   std_logic);

end entity timapulpemu_top;

architecture rtl of timapulpemu_top is

  component clk_rst_gen is
    port (
      ref_clk_i      : in  std_logic;
      rst_ni         : in  std_logic;
      rstn_pulpino_o : out std_logic;
      clk_pulpino_o  : out std_logic);
  end component clk_rst_gen;

  component pulpino is
    port (
      clk               : in  std_logic;
      rst_n             : in  std_logic;
      fetch_enable_i    : in  std_logic;
      spi_clk_i         : in  std_logic;
      spi_cs_i          : in  std_logic;
      spi_sdo0_o        : out std_logic;
      spi_sdi0_i        : in  std_logic;
      spi_master_clk_o  : out std_logic;
      spi_master_sdi0_i : in  std_logic;
      spi_master_sdi1_i : in  std_logic;
      spi_master_sdi2_i : in  std_logic;
      spi_master_sdi3_i : in  std_logic;
      uart_tx           : out std_logic;
      uart_rx           : in  std_logic;
      uart_cts          : in  std_logic;
      uart_dsr          : in  std_logic;
      gpio_in           : in  std_logic_vector(31 downto 0);
      gpio_out          : out std_logic_vector(31 downto 0);
      monitor_valid     : out std_logic;
      tck_i             : in  std_logic;
      trstn_i           : in  std_logic;
      tms_i             : in  std_logic;
      tdi_i             : in  std_logic;
      tdo_o             : out std_logic
      );
  end component pulpino;

  component ps7_wrapper is
    port (
      DDR_addr          : inout std_logic_vector(14 downto 0);
      DDR_ba            : inout std_logic_vector(2 downto 0);
      DDR_cas_n         : inout std_logic;
      DDR_ck_n          : inout std_logic;
      DDR_ck_p          : inout std_logic;
      DDR_cke           : inout std_logic;
      DDR_cs_n          : inout std_logic;
      DDR_dm            : inout std_logic_vector(3 downto 0);
      DDR_dq            : inout std_logic_vector(31 downto 0);
      DDR_dqs_n         : inout std_logic_vector(3 downto 0);
      DDR_dqs_p         : inout std_logic_vector(3 downto 0);
      DDR_odt           : inout std_logic;
      DDR_ras_n         : inout std_logic;
      DDR_reset_n       : inout std_logic;
      DDR_we_n          : inout std_logic;
      FIXED_IO_ddr_vrn  : inout std_logic;
      FIXED_IO_ddr_vrp  : inout std_logic;
      FIXED_IO_mio      : inout std_logic_vector(53 downto 0);
      FIXED_IO_ps_clk   : inout std_logic;
      FIXED_IO_ps_porb  : inout std_logic;
      FIXED_IO_ps_srstb : inout std_logic;
      SPI0_MISO_I       : in    std_logic;
      SPI0_MOSI_I       : in    std_logic;
      SPI0_MOSI_O       : out   std_logic;
      SPI0_SCLK_I       : in    std_logic;
      SPI0_SCLK_O       : out   std_logic;
      SPI0_SS_I         : in    std_logic;
      SPI0_SS_O         : out   std_logic;
      UART_0_rxd        : in    std_logic;
      UART_0_txd        : out   std_logic;
      gpio_io_i         : in    std_logic_vector(31 downto 0);
      gpio_io_o         : out   std_logic_vector(31 downto 0);
      ps7_clk           : out   std_logic;
      ps7_rst_n         : out   std_logic);
  end component ps7_wrapper;


  signal ps7_clk         : std_logic;
  signal ps7_rst_n       : std_logic;
  signal pulpino_rst_n   : std_logic;
  signal pulpino_clk     : std_logic;
  signal fetch_enable    : std_logic;
  signal spi_clk         : std_logic;
  signal spi_cs          : std_logic;
  signal spi_miso        : std_logic;
  signal spi_mosi        : std_logic;
  signal spi_master_sdi0 : std_logic;
  signal spi_master_sdi1 : std_logic;
  signal spi_master_sdi2 : std_logic;
  signal spi_master_sdi3 : std_logic;
  signal monitor_valid   : std_logic;
  signal gpio_in_ps7     : std_logic_vector(31 downto 0);
  signal gpio_in         : std_logic_vector(31 downto 0);
  signal gpio_out        : std_logic_vector(31 downto 0);
  signal uart_tx         : std_logic;
  signal uart_rx         : std_logic;
  signal uart_cts        : std_logic;
  signal uart_dsr        : std_logic;

  constant constant0 : std_logic := '0';
  constant constant1 : std_logic := '0';

begin  -- architecture rtl

  -- fetch enable
  fetch_enable <= '1';

  -- SPI Master
  spi_master_sdi0 <= '0';
  spi_master_sdi1 <= '0';
  spi_master_sdi2 <= '0';
  spi_master_sdi3 <= '0';

  -- UART
  uart_cts <= '0';
  uart_dsr <= '0';

  -- purpose: refreshes led state
  -- type   : sequential
  -- inputs : pulpino_clk, pulpino_rst_n, monitor_valid, gpio_out
  -- outputs: LD_o
  LEDs : process (pulpino_clk, pulpino_rst_n) is
  begin  -- process LEDs
    if pulpino_rst_n = '0' then         -- asynchronous reset (active low)
      LD_o <= (others => '0');
    elsif pulpino_clk'event and pulpino_clk = '1' then  -- rising clock edge
      LD_o <= monitor_valid & gpio_out(14 downto 8);
    end if;
  end process LEDs;

  -- GPIO
  gpio_in(31 downto 21) <= gpio_in_ps7(31 downto 21);
  gpio_in(20 downto 16) <= btn_i;
  gpio_in(15 downto 8)  <= (others => '0');
  gpio_in(7 downto 0)   <= sw_i;

  clk_rst_gen_i : clk_rst_gen
    port map (
      ref_clk_i      => ps7_clk,
      rst_ni         => ps7_rst_n,
      rstn_pulpino_o => pulpino_rst_n,
      clk_pulpino_o  => pulpino_clk);

  pulpino_wrap_i : pulpino
    port map (
      clk               => pulpino_clk,
      rst_n             => pulpino_rst_n,
      fetch_enable_i    => fetch_enable,
      spi_clk_i         => spi_clk,
      spi_cs_i          => spi_cs,
      spi_sdo0_o        => spi_miso,
      spi_sdi0_i        => spi_mosi,
      spi_master_sdi0_i => spi_master_sdi0,
      spi_master_sdi1_i => spi_master_sdi1,
      spi_master_sdi2_i => spi_master_sdi2,
      spi_master_sdi3_i => spi_master_sdi3,
      monitor_valid     => monitor_valid,
      gpio_in           => gpio_in,
      gpio_out          => gpio_out,
      uart_tx           => uart_tx,
      uart_rx           => uart_rx,
      uart_cts          => uart_cts,
      uart_dsr          => uart_dsr,
      tck_i             => tck_i,
      trstn_i           => trstn_i,
      tdi_i             => tdi_i,
      tdo_o             => tdo_o,
      tms_i             => tms_i
      );

  ps7_wrapper_i : ps7_wrapper
    port map (
      DDR_addr          => DDR_addr,
      DDR_ba            => DDR_ba,
      DDR_cas_n         => DDR_cas_n,
      DDR_ck_n          => DDR_ck_n,
      DDR_ck_p          => DDR_ck_p,
      DDR_cke           => DDR_cke,
      DDR_cs_n          => DDR_cs_n,
      DDR_dm            => DDR_dm,
      DDR_dq            => DDR_dq,
      DDR_dqs_n         => DDR_dqs_n,
      DDR_dqs_p         => DDR_dqs_p,
      DDR_odt           => DDR_odt,
      DDR_ras_n         => DDR_ras_n,
      DDR_reset_n       => DDR_reset_n,
      DDR_we_n          => DDR_we_n,
      FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
      FIXED_IO_mio      => FIXED_IO_mio,
      FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      SPI0_MISO_I       => spi_miso,
      SPI0_MOSI_O       => spi_mosi,
      SPI0_MOSI_I       => constant0,
      SPI0_SCLK_I       => constant0,
      SPI0_SCLK_O       => spi_clk,
      SPI0_SS_O         => spi_cs,
      SPI0_SS_I         => constant1,
      UART_0_rxd        => uart_tx,
      UART_0_txd        => uart_rx,
      gpio_io_i         => gpio_out,
      gpio_io_o         => gpio_in_ps7,
      ps7_clk           => ps7_clk,
      ps7_rst_n         => ps7_rst_n);

end architecture rtl;
