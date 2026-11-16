-- UART-передавач, формат кадру 8N1, передавання молодшим бітом уперед.
library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        baud_tick : in  std_logic;
        tx_start  : in  std_logic;
        tx_data   : in  std_logic_vector(7 downto 0);
        tx_serial : out std_logic;
        tx_busy   : out std_logic;
        tx_done   : out std_logic
    );
end entity uart_tx;

architecture rtl of uart_tx is
    type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state      : state_t := IDLE;
    signal data_reg   : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_index  : natural range 0 to 7 := 0;
    signal serial_reg : std_logic := '1';
    signal done_reg   : std_logic := '0';
begin
    tx_serial <= serial_reg;
    tx_done   <= done_reg;
    tx_busy   <= '0' when state = IDLE else '1';

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state      <= IDLE;
                data_reg   <= (others => '0');
                bit_index  <= 0;
                serial_reg <= '1';
                done_reg   <= '0';
            else
                done_reg <= '0';

                case state is
                    when IDLE =>
                        serial_reg <= '1';
                        if tx_start = '1' then
                            data_reg   <= tx_data;
                            serial_reg <= '0'; -- Стартовий біт.
                            bit_index  <= 0;
                            state      <= START_BIT;
                        end if;

                    when START_BIT =>
                        if baud_tick = '1' then
                            serial_reg <= data_reg(0);
                            bit_index  <= 0;
                            state      <= DATA_BITS;
                        end if;

                    when DATA_BITS =>
                        if baud_tick = '1' then
                            if bit_index = 7 then
                                serial_reg <= '1'; -- Стоповий біт.
                                state      <= STOP_BIT;
                            else
                                bit_index  <= bit_index + 1;
                                serial_reg <= data_reg(bit_index + 1);
                            end if;
                        end if;

                    when STOP_BIT =>
                        if baud_tick = '1' then
                            serial_reg <= '1';
                            done_reg   <= '1';
                            state      <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture rtl;
