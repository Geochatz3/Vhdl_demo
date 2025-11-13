--=============================================================================
-- AXI4-Lite Slave Model for Testbench
-- Simple memory-mapped slave for testing AXI master
--=============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi4_lite_slave_model is
  generic (
    C_S_AXI_DATA_WIDTH : integer := 32;
    C_S_AXI_ADDR_WIDTH : integer := 32;
    MEMORY_SIZE        : integer := 256  -- Number of 32-bit words
  );
  port (
    -- Global Clock Signal
    S_AXI_ACLK    : in  std_logic;
    -- Global Reset Signal (active LOW)
    S_AXI_ARESETN : in  std_logic;
    
    -- Write Address (AW) Channel
    S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    
    -- Write Data (W) Channel
    S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector(C_S_AXI_DATA_WIDTH/8-1 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    
    -- Write Response (B) Channel
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    
    -- Read Address (AR) Channel
    S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    
    -- Read Data (R) Channel
    S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic
  );
end entity axi4_lite_slave_model;

architecture rtl of axi4_lite_slave_model is
  
  -- Internal memory
  type memory_type is array (0 to MEMORY_SIZE-1) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal memory : memory_type := (others => (others => '0'));
  
  -- Write Address Channel
  signal aw_ready : std_logic := '0';
  signal aw_addr_reg : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  
  -- Write Data Channel
  signal w_ready : std_logic := '0';
  
  -- Write Response Channel
  signal b_valid : std_logic := '0';
  signal b_resp  : std_logic_vector(1 downto 0) := "00";
  
  -- Read Address Channel
  signal ar_ready : std_logic := '0';
  signal ar_addr_reg : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  
  -- Read Data Channel
  signal r_valid : std_logic := '0';
  signal r_data  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal r_resp  : std_logic_vector(1 downto 0) := "00";
  
  -- Address calculation
  function addr_to_index(addr : std_logic_vector) return integer is
    variable addr_int : integer;
  begin
    addr_int := to_integer(unsigned(addr));
    -- Assume 4-byte aligned addresses
    return addr_int / 4;
  end function;
  
begin
  
  -- Write Address Channel
  aw_channel : process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        aw_ready <= '0';
        aw_addr_reg <= (others => '0');
      else
        if S_AXI_AWVALID = '1' and aw_ready = '0' then
          aw_addr_reg <= S_AXI_AWADDR;
          aw_ready <= '1';
        elsif aw_ready = '1' then
          aw_ready <= '0';
        end if;
      end if;
    end if;
  end process aw_channel;
  
  S_AXI_AWREADY <= aw_ready;
  
  -- Write Data Channel
  w_channel : process(S_AXI_ACLK)
    variable mem_index : integer;
    variable byte_enable : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        w_ready <= '0';
      else
        if S_AXI_WVALID = '1' and w_ready = '0' then
          -- Calculate memory index
          mem_index := addr_to_index(aw_addr_reg);
          
          -- Check address range
          if mem_index >= 0 and mem_index < MEMORY_SIZE then
            -- Write to memory with byte enables
            for i in 0 to C_S_AXI_DATA_WIDTH/8-1 loop
              if S_AXI_WSTRB(i) = '1' then
                memory(mem_index)((i+1)*8-1 downto i*8) <= S_AXI_WDATA((i+1)*8-1 downto i*8);
              end if;
            end loop;
          end if;
          
          w_ready <= '1';
        elsif w_ready = '1' then
          w_ready <= '0';
        end if;
      end if;
    end if;
  end process w_channel;
  
  S_AXI_WREADY <= w_ready;
  
  -- Write Response Channel
  b_channel : process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        b_valid <= '0';
        b_resp <= "00";
      else
        if aw_ready = '1' and w_ready = '1' and b_valid = '0' then
          -- Check if address is valid
          if addr_to_index(aw_addr_reg) >= 0 and addr_to_index(aw_addr_reg) < MEMORY_SIZE then
            b_resp <= "00";  -- OKAY
          else
            b_resp <= "11";  -- DECERR (decode error)
          end if;
          b_valid <= '1';
        elsif S_AXI_BREADY = '1' and b_valid = '1' then
          b_valid <= '0';
        end if;
      end if;
    end if;
  end process b_channel;
  
  S_AXI_BVALID <= b_valid;
  S_AXI_BRESP <= b_resp;
  
  -- Read Address Channel
  ar_channel : process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        ar_ready <= '0';
        ar_addr_reg <= (others => '0');
      else
        if S_AXI_ARVALID = '1' and ar_ready = '0' then
          ar_addr_reg <= S_AXI_ARADDR;
          ar_ready <= '1';
        elsif ar_ready = '1' then
          ar_ready <= '0';
        end if;
      end if;
    end if;
  end process ar_channel;
  
  S_AXI_ARREADY <= ar_ready;
  
  -- Read Data Channel
  r_channel : process(S_AXI_ACLK)
    variable mem_index : integer;
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        r_valid <= '0';
        r_data <= (others => '0');
        r_resp <= "00";
      else
        if ar_ready = '1' and r_valid = '0' then
          -- Calculate memory index
          mem_index := addr_to_index(ar_addr_reg);
          
          -- Check address range
          if mem_index >= 0 and mem_index < MEMORY_SIZE then
            r_data <= memory(mem_index);
            r_resp <= "00";  -- OKAY
          else
            r_data <= (others => '0');
            r_resp <= "11";  -- DECERR (decode error)
          end if;
          r_valid <= '1';
        elsif S_AXI_RREADY = '1' and r_valid = '1' then
          r_valid <= '0';
        end if;
      end if;
    end if;
  end process r_channel;
  
  S_AXI_RVALID <= r_valid;
  S_AXI_RDATA <= r_data;
  S_AXI_RRESP <= r_resp;
  
end architecture rtl;

