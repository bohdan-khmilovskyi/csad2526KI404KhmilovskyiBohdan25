-- Верхній модуль: об'єднує генератор baud_tick, UART TX та UART RX.
-- У тестбенчі вихід TX з'єднано зі входом RX.
library ieee;
use ieee.std_logic_1164.all;

entity uart_top is
    generic (
        G_CLK_FREQ_HZ : positive := 50_000_000;
        G_BAUD_RATE   : positive := 9_600
    );
    port (
        clk       : in  std_logic; -- Системний тактовий сигнал.
        rst       : in  std_logic; -- Синхронне скидання всіх модулів.
        tx_start  : in  std_logic; -- Однотактний запит передавання, коли TX не зайнятий.
        tx_data   : in  std_logic_vector(7 downto 0); -- Байт для передавання.
        tx_serial : out std_logic; -- Послідовний вихід TX.
        tx_busy   : out std_logic; -- Передавач виконує передавання.
        tx_done   : out std_logic; -- Передавання кадру завершено.
        rx_serial : in  std_logic; -- Послідовний вхід RX.
        rx_data   : out std_logic_vector(7 downto 0); -- Прийнятий байт.
        rx_valid  : out std_logic; -- Прийнятий кадр коректний.
        rx_error  : out std_logic  -- Виявлено помилку стопового біта.
    );
end entity uart_top;

architecture rtl of uart_top is
    constant C_CLKS_PER_BIT : positive := G_CLK_FREQ_HZ / G_BAUD_RATE; -- Кількість тактів clk на один біт.
    signal baud_tick_int : std_logic; -- Спільний імпульс для керування передаванням TX.
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
