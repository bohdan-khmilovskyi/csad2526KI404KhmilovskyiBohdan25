-- Самоперевірний тестбенч UART: передає декілька байтів і перевіряє loopback RX.
library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity uart_tb is
end entity uart_tb;

architecture sim of uart_tb is
    -- Прискорені параметри лише для симуляції: 1 МГц / 100 кбод = 10 тактів на біт.
    constant C_CLK_FREQ_HZ : positive := 1_000_000;
    constant C_BAUD_RATE   : positive := 100_000;
    constant C_CLKS_PER_BIT: positive := C_CLK_FREQ_HZ / C_BAUD_RATE;
    constant C_CLK_PERIOD  : time := 1 us;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal tx_start  : std_logic := '0';
    signal tx_data   : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_serial : std_logic;
    signal tx_busy   : std_logic;
    signal tx_done   : std_logic;
    signal rx_serial : std_logic;
    signal rx_data   : std_logic_vector(7 downto 0);
    signal rx_valid  : std_logic;
    signal rx_error  : std_logic;
begin
    clk <= not clk after C_CLK_PERIOD / 2;
    rx_serial <= tx_serial; -- Loopback: вихід передавача підключено до входу приймача.

    dut : entity work.uart_top
        generic map (
            G_CLK_FREQ_HZ => C_CLK_FREQ_HZ,
            G_BAUD_RATE   => C_BAUD_RATE
        )
        port map (
            clk       => clk,
            rst       => rst,
            tx_start  => tx_start,
            tx_data   => tx_data,
            tx_serial => tx_serial,
            tx_busy   => tx_busy,
            tx_done   => tx_done,
            rx_serial => rx_serial,
            rx_data   => rx_data,
            rx_valid  => rx_valid,
            rx_error  => rx_error
        );

    stimulus : process
        procedure send_and_check(constant value : in std_logic_vector(7 downto 0)) is
            variable wait_cycles : natural := 0;
        begin
            wait until falling_edge(clk);
            tx_data  <= value;
            tx_start <= '1';
            wait until falling_edge(clk);
            tx_start <= '0';

            wait_cycles := 0;
            while rx_valid /= '1' and wait_cycles < 250 loop
                wait until falling_edge(clk);
                wait_cycles := wait_cycles + 1;
            end loop;

            assert rx_valid = '1'
                report "Timeout: RX did not assert rx_valid"
                severity failure;
            assert rx_data = value
                report "UART loopback data mismatch"
                severity failure;
            assert rx_error = '0'
                report "UART receiver reported a framing error"
                severity failure;

            report "UART loopback OK, received byte = " & to_hstring(rx_data)
                severity note;
            if tx_busy = '1' then
                wait until tx_busy = '0';
            end if;
            wait for 2 * C_CLK_PERIOD;
        end procedure;
    begin
        rst <= '1';
        for i in 1 to 5 loop
            wait until rising_edge(clk);
        end loop;
        wait until falling_edge(clk);
        rst <= '0';

        send_and_check(x"A5");
        send_and_check(x"3C");
        send_and_check(x"00");
        send_and_check(x"FF");

        report "ALL UART TESTS PASSED" severity note;
        stop;
        wait;
    end process;
end architecture sim;
