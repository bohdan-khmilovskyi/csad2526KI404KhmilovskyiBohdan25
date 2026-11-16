-- UART-приймач, формат кадру 8N1, зчитування у середині кожного біта.
library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
    generic (
        G_CLKS_PER_BIT : positive := 5208
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        rx_serial : in  std_logic;
        rx_data   : out std_logic_vector(7 downto 0);
        rx_valid  : out std_logic;
        rx_error  : out std_logic
    );
end entity uart_rx;

architecture rtl of uart_rx is
    type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state     : state_t := IDLE;
    signal counter   : natural range 0 to G_CLKS_PER_BIT - 1 := 0;
    signal bit_index : natural range 0 to 7 := 0;
    signal data_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out  : std_logic_vector(7 downto 0) := (others => '0');
    signal valid_reg : std_logic := '0';
    signal error_reg : std_logic := '0';
begin
    rx_data  <= data_out;
    rx_valid <= valid_reg;
    rx_error <= error_reg;

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state     <= IDLE;
                counter   <= 0;
                bit_index <= 0;
                data_reg  <= (others => '0');
                data_out  <= (others => '0');
                valid_reg <= '0';
                error_reg <= '0';
            else
                valid_reg <= '0';
                error_reg <= '0';

                case state is
                    when IDLE =>
                        counter <= 0;
                        if rx_serial = '0' then
                            state <= START_BIT;
                        end if;

                    when START_BIT =>
                        -- Перевірка стартового біта приблизно в його середині.
                        if counter = (G_CLKS_PER_BIT / 2) - 1 then
                            counter <= 0;
                            if rx_serial = '0' then
                                bit_index <= 0;
                                state <= DATA_BITS;
                            else
                                state <= IDLE; -- Хибний стартовий імпульс.
                            end if;
                        else
                            counter <= counter + 1;
                        end if;

                    when DATA_BITS =>
                        if counter = G_CLKS_PER_BIT - 1 then
                            counter <= 0;
                            data_reg(bit_index) <= rx_serial;
                            if bit_index = 7 then
                                state <= STOP_BIT;
                            else
                                bit_index <= bit_index + 1;
                            end if;
                        else
                            counter <= counter + 1;
                        end if;

                    when STOP_BIT =>
                        if counter = G_CLKS_PER_BIT - 1 then
                            counter <= 0;
                            if rx_serial = '1' then
                                data_out  <= data_reg;
                                valid_reg <= '1';
                            else
                                error_reg <= '1'; -- Некоректний стоповий біт.
                            end if;
                            state <= IDLE;
                        else
                            counter <= counter + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture rtl;
