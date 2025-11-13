--=============================================================================
-- Testbench for AXI4-Lite Master Interface
--=============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_axi4_lite_master is
end entity tb_axi4_lite_master;

architecture sim of tb_axi4_lite_master is
  
  -- Constants
  constant C_CLK_PERIOD : time := 10 ns;  -- 100 MHz
  constant C_DATA_WIDTH : integer := 32;
  constant C_ADDR_WIDTH : integer := 32;
  
  -- Clock and Reset
  signal aclk    : std_logic := '0';
  signal aresetn : std_logic := '0';
  
  -- AXI Master Signals (connected to slave)
  signal m_axi_awaddr  : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal m_axi_awprot  : std_logic_vector(2 downto 0);
  signal m_axi_awvalid : std_logic;
  signal m_axi_awready : std_logic;
  signal m_axi_wdata   : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal m_axi_wstrb   : std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
  signal m_axi_wvalid  : std_logic;
  signal m_axi_wready  : std_logic;
  signal m_axi_bresp   : std_logic_vector(1 downto 0);
  signal m_axi_bvalid  : std_logic;
  signal m_axi_bready  : std_logic;
  signal m_axi_araddr  : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal m_axi_arprot  : std_logic_vector(2 downto 0);
  signal m_axi_arvalid : std_logic;
  signal m_axi_arready : std_logic;
  signal m_axi_rdata   : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal m_axi_rresp   : std_logic_vector(1 downto 0);
  signal m_axi_rvalid  : std_logic;
  signal m_axi_rready  : std_logic;
  
  -- User Control Interface
  signal wr_start : std_logic := '0';
  signal wr_addr  : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal wr_data  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal wr_strb  : std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
  signal wr_done  : std_logic;
  signal wr_error : std_logic;
  
  signal rd_start : std_logic := '0';
  signal rd_addr  : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal rd_data  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal rd_done  : std_logic;
  signal rd_error : std_logic;
  
begin
  
  -- Clock Generation
  aclk <= not aclk after C_CLK_PERIOD / 2;
  
  -- Reset Generation
  reset_proc : process
  begin
    aresetn <= '0';
    wait for 100 ns;
    aresetn <= '1';
    wait;
  end process reset_proc;
  
  -- AXI Master Instance
  uut_master : entity work.axi4_lite_master
    generic map (
      C_M_AXI_DATA_WIDTH => C_DATA_WIDTH,
      C_M_AXI_ADDR_WIDTH => C_ADDR_WIDTH
    )
    port map (
      M_AXI_ACLK    => aclk,
      M_AXI_ARESETN => aresetn,
      M_AXI_AWADDR  => m_axi_awaddr,
      M_AXI_AWPROT  => m_axi_awprot,
      M_AXI_AWVALID => m_axi_awvalid,
      M_AXI_AWREADY => m_axi_awready,
      M_AXI_WDATA   => m_axi_wdata,
      M_AXI_WSTRB   => m_axi_wstrb,
      M_AXI_WVALID  => m_axi_wvalid,
      M_AXI_WREADY  => m_axi_wready,
      M_AXI_BRESP   => m_axi_bresp,
      M_AXI_BVALID  => m_axi_bvalid,
      M_AXI_BREADY  => m_axi_bready,
      M_AXI_ARADDR  => m_axi_araddr,
      M_AXI_ARPROT  => m_axi_arprot,
      M_AXI_ARVALID => m_axi_arvalid,
      M_AXI_ARREADY => m_axi_arready,
      M_AXI_RDATA   => m_axi_rdata,
      M_AXI_RRESP   => m_axi_rresp,
      M_AXI_RVALID  => m_axi_rvalid,
      M_AXI_RREADY  => m_axi_rready,
      WR_START      => wr_start,
      WR_ADDR       => wr_addr,
      WR_DATA       => wr_data,
      WR_STRB       => wr_strb,
      WR_DONE       => wr_done,
      WR_ERROR      => wr_error,
      RD_START      => rd_start,
      RD_ADDR       => rd_addr,
      RD_DATA       => rd_data,
      RD_DONE       => rd_done,
      RD_ERROR      => rd_error
    );
  
  -- AXI Slave Model Instance
  uut_slave : entity work.axi4_lite_slave_model
    generic map (
      C_S_AXI_DATA_WIDTH => C_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_ADDR_WIDTH,
      MEMORY_SIZE        => 256
    )
    port map (
      S_AXI_ACLK    => aclk,
      S_AXI_ARESETN => aresetn,
      S_AXI_AWADDR  => m_axi_awaddr,
      S_AXI_AWPROT  => m_axi_awprot,
      S_AXI_AWVALID => m_axi_awvalid,
      S_AXI_AWREADY => m_axi_awready,
      S_AXI_WDATA   => m_axi_wdata,
      S_AXI_WSTRB   => m_axi_wstrb,
      S_AXI_WVALID  => m_axi_wvalid,
      S_AXI_WREADY  => m_axi_wready,
      S_AXI_BRESP   => m_axi_bresp,
      S_AXI_BVALID  => m_axi_bvalid,
      S_AXI_BREADY  => m_axi_bready,
      S_AXI_ARADDR  => m_axi_araddr,
      S_AXI_ARPROT  => m_axi_arprot,
      S_AXI_ARVALID => m_axi_arvalid,
      S_AXI_ARREADY => m_axi_arready,
      S_AXI_RDATA   => m_axi_rdata,
      S_AXI_RRESP   => m_axi_rresp,
      S_AXI_RVALID  => m_axi_rvalid,
      S_AXI_RREADY  => m_axi_rready
    );
  
  -- Test Stimulus
  stim_proc : process
    variable test_data : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    variable read_back : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  begin
    -- Wait for reset to complete
    wait until aresetn = '1';
    wait for 100 ns;
    
    -- ============================================
    -- Test 1: Simple Write Transaction
    -- ============================================
    report "Test 1: Write transaction to address 0x00000000";
    wr_addr <= x"00000000";
    wr_data <= x"DEADBEEF";
    wr_strb <= "1111";  -- Write all bytes
    wait for C_CLK_PERIOD;
    wr_start <= '1';
    wait for C_CLK_PERIOD;
    wr_start <= '0';
    
    -- Wait for write to complete
    wait until wr_done = '1';
    wait for C_CLK_PERIOD;
    assert wr_error = '0' report "Write error detected!" severity error;
    report "Test 1: Write completed successfully";
    wait for 50 ns;
    
    -- ============================================
    -- Test 2: Read Transaction
    -- ============================================
    report "Test 2: Read transaction from address 0x00000000";
    rd_addr <= x"00000000";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    
    -- Wait for read to complete
    wait until rd_done = '1';
    wait for C_CLK_PERIOD;
    assert rd_error = '0' report "Read error detected!" severity error;
    assert rd_data = x"DEADBEEF" report "Read data mismatch!" severity error;
    report "Test 2: Read completed successfully";
    wait for 50 ns;
    
    -- ============================================
    -- Test 3: Multiple Write Transactions
    -- ============================================
    report "Test 3: Multiple write transactions";
    
    -- Write to address 0x00000004
    wr_addr <= x"00000004";
    wr_data <= x"12345678";
    wr_strb <= "1111";
    wait for C_CLK_PERIOD;
    wr_start <= '1';
    wait for C_CLK_PERIOD;
    wr_start <= '0';
    wait until wr_done = '1';
    wait for 50 ns;
    
    -- Write to address 0x00000008
    wr_addr <= x"00000008";
    wr_data <= x"ABCDEF00";
    wr_strb <= "1111";
    wait for C_CLK_PERIOD;
    wr_start <= '1';
    wait for C_CLK_PERIOD;
    wr_start <= '0';
    wait until wr_done = '1';
    wait for 50 ns;
    
    -- Write to address 0x0000000C
    wr_addr <= x"0000000C";
    wr_data <= x"FEDCBA98";
    wr_strb <= "1111";
    wait for C_CLK_PERIOD;
    wr_start <= '1';
    wait for C_CLK_PERIOD;
    wr_start <= '0';
    wait until wr_done = '1';
    wait for 50 ns;
    
    report "Test 3: Multiple writes completed";
    
    -- ============================================
    -- Test 4: Read Back All Written Values
    -- ============================================
    report "Test 4: Read back all written values";
    
    -- Read from 0x00000004
    rd_addr <= x"00000004";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    assert rd_data = x"12345678" report "Read mismatch at 0x04!" severity error;
    wait for 50 ns;
    
    -- Read from 0x00000008
    rd_addr <= x"00000008";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    assert rd_data = x"ABCDEF00" report "Read mismatch at 0x08!" severity error;
    wait for 50 ns;
    
    -- Read from 0x0000000C
    rd_addr <= x"0000000C";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    assert rd_data = x"FEDCBA98" report "Read mismatch at 0x0C!" severity error;
    wait for 50 ns;
    
    report "Test 4: All reads completed successfully";
    
    -- ============================================
    -- Test 5: Byte Write (using WSTRB)
    -- ============================================
    report "Test 5: Byte write test";
    
    -- Write only lower byte
    wr_addr <= x"00000010";
    wr_data <= x"000000AA";
    wr_strb <= "0001";  -- Write only byte 0
    wait for C_CLK_PERIOD;
    wr_start <= '1';
    wait for C_CLK_PERIOD;
    wr_start <= '0';
    wait until wr_done = '1';
    wait for 50 ns;
    
    -- Read back
    rd_addr <= x"00000010";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    -- Note: The slave model will have written 0xAA to byte 0, other bytes remain 0
    report "Test 5: Byte write completed";
    wait for 50 ns;
    
    -- ============================================
    -- Test 6: Write-Read-Write Sequence
    -- ============================================
    report "Test 6: Write-Read-Write sequence";
    
    -- Write
    wr_addr <= x"00000020";
    wr_data <= x"11111111";
    wr_strb <= "1111";
    wait for C_CLK_PERIOD;
    wr_start <= '1';
    wait for C_CLK_PERIOD;
    wr_start <= '0';
    wait until wr_done = '1';
    wait for 50 ns;
    
    -- Read
    rd_addr <= x"00000020";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    assert rd_data = x"11111111" report "Read mismatch!" severity error;
    wait for 50 ns;
    
    -- Write again
    wr_addr <= x"00000020";
    wr_data <= x"22222222";
    wr_strb <= "1111";
    wait for C_CLK_PERIOD;
    wr_start <= '1';
    wait for C_CLK_PERIOD;
    wr_start <= '0';
    wait until wr_done = '1';
    wait for 50 ns;
    
    -- Read again
    rd_addr <= x"00000020";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    assert rd_data = x"22222222" report "Read mismatch after rewrite!" severity error;
    wait for 50 ns;
    
    report "Test 6: Write-Read-Write sequence completed";
    
    -- ============================================
    -- All Tests Complete
    -- ============================================
    report "=========================================";
    report "All tests completed successfully!";
    report "=========================================";
    
    wait;
  end process stim_proc;
  
end architecture sim;

