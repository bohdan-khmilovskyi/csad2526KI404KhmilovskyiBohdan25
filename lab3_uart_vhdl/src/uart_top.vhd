-- Верхній модуль: об'єднує генератор baud_tick, UART TX та UART RX.
-- Для тестування TXD з'єднується з RXD у testbench (loopback).
library ieee;
use ieee.std_logic_1164.all;

entity uart_top is
    generic (
        G_CLK_FREQ_HZ : positive := 50_000_000;
        G_BAUD_RATE   : positive := 9_600
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        tx_start  : in  std_logic;
        tx_data   : in  std_logic_vector(7 downto 0);
        tx_serial : out std_logic;
        tx_busy   : out std_logic;
        tx_done   : out std_logic;
        rx_serial : in  std_logic;
        rx_data   : out std_logic_vector(7 downto 0);
        rx_valid  : out std_logic;
        rx_error  : out std_logic
    );
end entity uart_top;

architecture rtl of uart_top is
    constant C_CLKS_PER_BIT : positive := G_CLK_FREQ_HZ / G_BAUD_RATE;
    signal baud_tick_int : std_logic;
begin
    assert C_CLKS_PER_BIT >= 2
        report "G_CLK_FREQ_HZ / G_BAUD_RATE must be at least 2"
        severity failure;

    baud_inst : entity work.baud_generator
        generic map (
            G_CLKS_PER_BIT => C_CLKS_PER_BIT
        )
        port map (
            clk       => clk,
            rst       => rst,
            restart   => tx_start,
            baud_tick => baud_tick_int
        );

    tx_inst : entity work.uart_tx
        port map (
            clk       => clk,
            rst       => rst,
            baud_tick => baud_tick_int,
            tx_start  => tx_start,
            tx_data   => tx_data,
            tx_serial => tx_serial,
            tx_busy   => tx_busy,
            tx_done   => tx_done
        );

    rx_inst : entity work.uart_rx
        generic map (
            G_CLKS_PER_BIT => C_CLKS_PER_BIT
        )
        port map (
            clk       => clk,
            rst       => rst,
            rx_serial => rx_serial,
            rx_data   => rx_data,
            rx_valid  => rx_valid,
            rx_error  => rx_error
        );
end architecture rtl;
