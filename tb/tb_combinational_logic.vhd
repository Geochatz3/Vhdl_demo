library ieee;
use ieee.std_logic_1164.all;

entity tb_combinational_logic is
end entity tb_combinational_logic;

architecture sim of tb_combinational_logic is
  signal a, b, c, d, e, f : std_logic := '0';
  signal out1, out2, out3 : std_logic;
  
begin
  uut: entity work.combinational_logic
    port map (
      a    => a,
      b    => b,
      c    => c,
      d    => d,
      e    => e,
      f    => f,
      out1 => out1,
      out2 => out2,
      out3 => out3
    );

  stim_proc : process
  begin
    -- Test case 1: All inputs low
    a <= '0'; b <= '0'; c <= '0'; d <= '0'; e <= '0'; f <= '0';
    wait for 10 ns;
    
    -- Test case 2: A=1, B=1, others low
    a <= '1'; b <= '1'; c <= '0'; d <= '0'; e <= '0'; f <= '0';
    wait for 10 ns;
    
    -- Test case 3: C=1, D=1, others low
    a <= '0'; b <= '0'; c <= '1'; d <= '1'; e <= '0'; f <= '0';
    wait for 10 ns;
    
    -- Test case 4: A=1, B=1, C=1, D=1
    a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '0'; f <= '0';
    wait for 10 ns;
    
    -- Test case 5: A=1, B=0 (XOR test)
    a <= '1'; b <= '0'; c <= '1'; d <= '1'; e <= '0'; f <= '0';
    wait for 10 ns;
    
    -- Test case 6: E=1, F=1
    a <= '0'; b <= '0'; c <= '0'; d <= '0'; e <= '1'; f <= '1';
    wait for 10 ns;
    
    -- Test case 7: Mixed pattern
    a <= '1'; b <= '0'; c <= '0'; d <= '1'; e <= '1'; f <= '0';
    wait for 10 ns;
    
    -- Test case 8: All inputs high
    a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '1'; f <= '1';
    wait for 10 ns;
    
    -- Test case 9: A=0, B=1, C=1, D=0, E=1, F=1
    a <= '0'; b <= '1'; c <= '1'; d <= '0'; e <= '1'; f <= '1';
    wait for 10 ns;
    
    -- Test case 10: Complex pattern
    a <= '1'; b <= '1'; c <= '0'; d <= '1'; e <= '0'; f <= '1';
    wait for 10 ns;

    wait;
  end process;
end architecture sim;

