-- Генератор тактового імпульсу для заданої швидкості UART.
-- baud_tick має тривалість один такт clk та формується кожні G_CLKS_PER_BIT тактів.
library ieee;
use ieee.std_logic_1164.all;

entity baud_generator is
    generic (
        G_CLKS_PER_BIT : positive := 5208
    );
    port (
        clk       : in  std_logic; -- Системний тактовий сигнал.
        rst       : in  std_logic; -- Синхронне скидання лічильника.
        restart   : in  std_logic; -- Початок нового інтервалу передавання.
        baud_tick : out std_logic  -- Імпульс на один такт clk.
    );
end entity baud_generator;

architecture rtl of baud_generator is
    signal counter : natural range 0 to G_CLKS_PER_BIT - 1 := 0; -- Лічильник тактів у межах одного біта.
begin
    -- Комбінаційний імпульс на останньому такті інтервалу.
    baud_tick <= '1' when counter = G_CLKS_PER_BIT - 1 else '0';

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or restart = '1' then
                counter <= 0;
            elsif counter = G_CLKS_PER_BIT - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
end architecture rtl;
