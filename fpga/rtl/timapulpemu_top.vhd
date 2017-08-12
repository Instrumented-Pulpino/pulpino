library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity timapulpemu_top is

  port (
    ref_clk  : in  std_logic;
    rst_n    : in  std_logic;
    tck_i    : in  std_logic;
    trstn_i  : in  std_logic;
    tdi_i    : in  std_logic;
    tms_i    : in  std_logic;
    tdo_o    : out std_logic;
    gpio_out : out std_logic_vector(31 downto 0);
    uart_tx  : out std_logic;
    uart_rx  : in  std_logic;
    spi_clk  : in  std_logic;
    spi_cs   : in  std_logic;
    spi_miso : out std_logic;
    spi_mosi : in  std_logic;
    sw_i     : in  std_logic_vector(7 downto 0);
    LD_o     : out std_logic_vector(7 downto 0));

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

  signal pulpino_rst_n     : std_logic;
  signal pulpino_clk       : std_logic;
  signal fetch_enable      : std_logic;
  signal spi_master_sdi0   : std_logic;
  signal spi_master_sdi1   : std_logic;
  signal spi_master_sdi2   : std_logic;
  signal spi_master_sdi3   : std_logic;
  signal monitor_valid     : std_logic;
  signal gpio_in           : std_logic_vector(31 downto 0);
  signal gpio_internal_out : std_logic_vector(31 downto 0);
  signal uart_cts          : std_logic;
  signal uart_dsr          : std_logic;

  constant cst0 : std_logic := '0';
  constant cst1 : std_logic := '1';

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
      LD_o <= monitor_valid & gpio_internal_out(14 downto 8);
    end if;
  end process LEDs;

  -- GPIO
  gpio_in(31 downto 8) <= (others => '0');
  gpio_in(7 downto 0)  <= sw_i;
  gpio_out             <= gpio_internal_out;

  clk_rst_gen_i : clk_rst_gen
    port map (
      ref_clk_i      => ref_clk,
      rst_ni         => rst_n,
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
      gpio_out          => gpio_internal_out,
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

end architecture rtl;
