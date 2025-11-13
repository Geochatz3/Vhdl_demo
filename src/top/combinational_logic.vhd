library ieee;
use ieee.std_logic_1164.all;

entity combinational_logic is
  port (
    a, b, c, d, e, f : in  std_logic;
    out1, out2, out3 : out std_logic
  );
end entity combinational_logic;

architecture structural of combinational_logic is
  -- Internal signals for intermediate results
  signal and1_out, and2_out, and3_out : std_logic;
  signal or1_out, or2_out, or3_out   : std_logic;
  signal xor1_out, xor2_out          : std_logic;
  
  -- Component declarations
  component and_gate is
    port (
      a : in  std_logic;
      b : in  std_logic;
      y : out std_logic
    );
  end component and_gate;
  
  component or_gate is
    port (
      a : in  std_logic;
      b : in  std_logic;
      y : out std_logic
    );
  end component or_gate;
  
  component xor_gate is
    port (
      a : in  std_logic;
      b : in  std_logic;
      y : out std_logic
    );
  end component xor_gate;
  
begin
  -- Instance 1: AND gate (A AND B)
  u_and1 : and_gate
    port map (
      a => a,
      b => b,
      y => and1_out
    );
  
  -- Instance 2: AND gate (C AND D)
  u_and2 : and_gate
    port map (
      a => c,
      b => d,
      y => and2_out
    );
  
  -- Instance 3: AND gate (E AND F)
  u_and3 : and_gate
    port map (
      a => e,
      b => f,
      y => and3_out
    );
  
  -- Instance 4: OR gate (A OR B)
  u_or1 : or_gate
    port map (
      a => a,
      b => b,
      y => or1_out
    );
  
  -- Instance 5: OR gate (C OR D)
  u_or2 : or_gate
    port map (
      a => c,
      b => d,
      y => or2_out
    );
  
  -- Instance 6: OR gate (E OR F)
  u_or3 : or_gate
    port map (
      a => e,
      b => f,
      y => or3_out
    );
  
  -- Instance 7: XOR gate (A XOR B)
  u_xor1 : xor_gate
    port map (
      a => a,
      b => b,
      y => xor1_out
    );
  
  -- Instance 8: XOR gate (C XOR D)
  u_xor2 : xor_gate
    port map (
      a => c,
      b => d,
      y => xor2_out
    );
  
  -- Output 1: (A AND B) OR (C AND D)
  u_or_out1 : or_gate
    port map (
      a => and1_out,
      b => and2_out,
      y => out1
    );
  
  -- Output 2: (A XOR B) AND (C OR D)
  u_and_out2 : and_gate
    port map (
      a => xor1_out,
      b => or2_out,
      y => out2
    );
  
  -- Output 3: (A OR B) XOR (E AND F)
  u_xor_out3 : xor_gate
    port map (
      a => or1_out,
      b => and3_out,
      y => out3
    );
  
end architecture structural;

