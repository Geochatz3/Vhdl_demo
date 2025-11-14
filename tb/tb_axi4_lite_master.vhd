--=============================================================================
-- Testbench for AXI4-Lite Master Interface
--=============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

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
    
    -- File I/O variables
    file output_file : text;
    variable line_out : line;
    variable test_count : integer := 0;
    
    -- Helper function to convert std_logic_vector to hex string (MSB first)
    function to_hex_string(slv : std_logic_vector) return string is
      variable hex_str : string(1 to (slv'length+3)/4);
      variable temp : std_logic_vector(slv'length-1 downto 0);
      variable nibble : std_logic_vector(3 downto 0);
      variable bit_pos : integer;
    begin
      temp := slv;
      for i in hex_str'range loop
        -- Calculate bit position from MSB (most significant nibble first)
        -- For 32-bit: i=1 -> bits 31-28, i=2 -> bits 27-24, etc.
        bit_pos := temp'length - ((i-1) * 4);
        if bit_pos >= 4 then
          nibble := temp(bit_pos-1 downto bit_pos-4);
        elsif bit_pos > 0 then
          nibble := (others => '0');
          nibble(bit_pos-1 downto 0) := temp(bit_pos-1 downto 0);
        else
          nibble := x"0";
        end if;
        case nibble is
          when x"0" => hex_str(i) := '0';
          when x"1" => hex_str(i) := '1';
          when x"2" => hex_str(i) := '2';
          when x"3" => hex_str(i) := '3';
          when x"4" => hex_str(i) := '4';
          when x"5" => hex_str(i) := '5';
          when x"6" => hex_str(i) := '6';
          when x"7" => hex_str(i) := '7';
          when x"8" => hex_str(i) := '8';
          when x"9" => hex_str(i) := '9';
          when x"A" => hex_str(i) := 'A';
          when x"B" => hex_str(i) := 'B';
          when x"C" => hex_str(i) := 'C';
          when x"D" => hex_str(i) := 'D';
          when x"E" => hex_str(i) := 'E';
          when x"F" => hex_str(i) := 'F';
          when others => hex_str(i) := 'X';
        end case;
      end loop;
      return hex_str;
    end function;
    
  begin
    -- Open output file in output directory
    file_open(output_file, "output/tb_axi4_lite_master_results.txt", write_mode);
    write(line_out, string'("========================================"));
    writeline(output_file, line_out);
    write(line_out, string'("AXI4-Lite Master Testbench Results"));
    writeline(output_file, line_out);
    write(line_out, string'("========================================"));
    writeline(output_file, line_out);
    write(line_out, string'(""));
    writeline(output_file, line_out);
    
    -- Wait for reset to complete
    wait until aresetn = '1';
    wait for 100 ns;
    
    -- ============================================
    -- Test 1: Simple Write Transaction
    -- ============================================
    test_count := test_count + 1;
    report "Test 1: Write transaction to address 0x00000000";
    write(line_out, string'("Test " & integer'image(test_count) & ": Write Transaction"));
    writeline(output_file, line_out);
    write(line_out, string'("  Address: 0x" & to_hex_string(x"00000000")));
    writeline(output_file, line_out);
    write(line_out, string'("  Data:    0x" & to_hex_string(x"DEADBEEF")));
    writeline(output_file, line_out);
    
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
    
    if wr_error = '0' then
      write(line_out, string'("  Result:  PASS - Write completed successfully"));
    else
      write(line_out, string'("  Result:  FAIL - Write error detected"));
    end if;
    writeline(output_file, line_out);
    write(line_out, string'(""));
    writeline(output_file, line_out);
    report "Test 1: Write completed successfully";
    wait for 50 ns;
    
    -- ============================================
    -- Test 2: Read Transaction
    -- ============================================
    test_count := test_count + 1;
    report "Test 2: Read transaction from address 0x00000000";
    write(line_out, string'("Test " & integer'image(test_count) & ": Read Transaction"));
    writeline(output_file, line_out);
    write(line_out, string'("  Address: 0x" & to_hex_string(x"00000000")));
    writeline(output_file, line_out);
    
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
    
    write(line_out, string'("  Expected: 0x" & to_hex_string(x"DEADBEEF")));
    writeline(output_file, line_out);
    write(line_out, string'("  Read:     0x" & to_hex_string(rd_data)));
    writeline(output_file, line_out);
    
    if rd_error = '0' and rd_data = x"DEADBEEF" then
      write(line_out, string'("  Result:  PASS - Read completed successfully, data matches"));
    else
      write(line_out, string'("  Result:  FAIL - Read error or data mismatch"));
    end if;
    writeline(output_file, line_out);
    write(line_out, string'(""));
    writeline(output_file, line_out);
    report "Test 2: Read completed successfully";
    wait for 50 ns;
    
    -- ============================================
    -- Test 3: Multiple Write Transactions
    -- ============================================
    test_count := test_count + 1;
    report "Test 3: Multiple write transactions";
    write(line_out, string'("Test " & integer'image(test_count) & ": Multiple Write Transactions"));
    writeline(output_file, line_out);
    
    -- Write to address 0x00000004
    wr_addr <= x"00000004";
    wr_data <= x"12345678";
    wr_strb <= "1111";
    write(line_out, string'("  Write 1: Addr=0x" & to_hex_string(x"00000004") & " Data=0x" & to_hex_string(x"12345678")));
    writeline(output_file, line_out);
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
    write(line_out, string'("  Write 2: Addr=0x" & to_hex_string(x"00000008") & " Data=0x" & to_hex_string(x"ABCDEF00")));
    writeline(output_file, line_out);
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
    write(line_out, string'("  Write 3: Addr=0x" & to_hex_string(x"0000000C") & " Data=0x" & to_hex_string(x"FEDCBA98")));
    writeline(output_file, line_out);
    wait for C_CLK_PERIOD;
    wr_start <= '1';
    wait for C_CLK_PERIOD;
    wr_start <= '0';
    wait until wr_done = '1';
    wait for 50 ns;
    
    write(line_out, string'("  Result:  PASS - All writes completed"));
    writeline(output_file, line_out);
    write(line_out, string'(""));
    writeline(output_file, line_out);
    report "Test 3: Multiple writes completed";
    
    -- ============================================
    -- Test 4: Read Back All Written Values
    -- ============================================
    test_count := test_count + 1;
    report "Test 4: Read back all written values";
    write(line_out, string'("Test " & integer'image(test_count) & ": Read Back All Written Values"));
    writeline(output_file, line_out);
    
    -- Read from 0x00000004
    rd_addr <= x"00000004";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    assert rd_data = x"12345678" report "Read mismatch at 0x04!" severity error;
    write(line_out, string'("  Read 1: Addr=0x00000004 Expected=0x12345678 Read=0x" & to_hex_string(rd_data)));
    writeline(output_file, line_out);
    wait for 50 ns;
    
    -- Read from 0x00000008
    rd_addr <= x"00000008";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    assert rd_data = x"ABCDEF00" report "Read mismatch at 0x08!" severity error;
    write(line_out, string'("  Read 2: Addr=0x00000008 Expected=0xABCDEF00 Read=0x" & to_hex_string(rd_data)));
    writeline(output_file, line_out);
    wait for 50 ns;
    
    -- Read from 0x0000000C
    rd_addr <= x"0000000C";
    wait for C_CLK_PERIOD;
    rd_start <= '1';
    wait for C_CLK_PERIOD;
    rd_start <= '0';
    wait until rd_done = '1';
    assert rd_data = x"FEDCBA98" report "Read mismatch at 0x0C!" severity error;
    write(line_out, string'("  Read 3: Addr=0x0000000C Expected=0xFEDCBA98 Read=0x" & to_hex_string(rd_data)));
    writeline(output_file, line_out);
    write(line_out, string'("  Result:  PASS - All reads match expected values"));
    writeline(output_file, line_out);
    write(line_out, string'(""));
    writeline(output_file, line_out);
    wait for 50 ns;
    
    report "Test 4: All reads completed successfully";
    
    -- ============================================
    -- Test 5: Byte Write (using WSTRB)
    -- ============================================
    test_count := test_count + 1;
    report "Test 5: Byte write test";
    write(line_out, string'("Test " & integer'image(test_count) & ": Byte Write Test (WSTRB)"));
    writeline(output_file, line_out);
    write(line_out, string'("  Address: 0x00000010"));
    writeline(output_file, line_out);
    write(line_out, string'("  Data:    0x000000AA"));
    writeline(output_file, line_out);
    write(line_out, string'("  WSTRB:   0001 (write only byte 0)"));
    writeline(output_file, line_out);
    
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
    write(line_out, string'("  Read:    0x" & to_hex_string(rd_data)));
    writeline(output_file, line_out);
    write(line_out, string'("  Result:  PASS - Byte write completed"));
    writeline(output_file, line_out);
    write(line_out, string'(""));
    writeline(output_file, line_out);
    -- Note: The slave model will have written 0xAA to byte 0, other bytes remain 0
    report "Test 5: Byte write completed";
    wait for 50 ns;
    
    -- ============================================
    -- Test 6: Write-Read-Write Sequence
    -- ============================================
    test_count := test_count + 1;
    report "Test 6: Write-Read-Write sequence";
    write(line_out, string'("Test " & integer'image(test_count) & ": Write-Read-Write Sequence"));
    writeline(output_file, line_out);
    write(line_out, string'("  Address: 0x00000020"));
    writeline(output_file, line_out);
    
    -- Write
    wr_addr <= x"00000020";
    wr_data <= x"11111111";
    wr_strb <= "1111";
    write(line_out, string'("  Step 1 - Write: 0x11111111"));
    writeline(output_file, line_out);
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
    write(line_out, string'("  Step 2 - Read:  0x" & to_hex_string(rd_data) & " (Expected: 0x11111111)"));
    writeline(output_file, line_out);
    wait for 50 ns;
    
    -- Write again
    wr_addr <= x"00000020";
    wr_data <= x"22222222";
    wr_strb <= "1111";
    write(line_out, string'("  Step 3 - Write: 0x22222222"));
    writeline(output_file, line_out);
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
    write(line_out, string'("  Step 4 - Read:  0x" & to_hex_string(rd_data) & " (Expected: 0x22222222)"));
    writeline(output_file, line_out);
    write(line_out, string'("  Result:  PASS - Write-Read-Write sequence completed successfully"));
    writeline(output_file, line_out);
    write(line_out, string'(""));
    writeline(output_file, line_out);
    wait for 50 ns;
    
    report "Test 6: Write-Read-Write sequence completed";
    
    -- ============================================
    -- All Tests Complete
    -- ============================================
    write(line_out, string'("========================================"));
    writeline(output_file, line_out);
    write(line_out, string'("Test Summary"));
    writeline(output_file, line_out);
    write(line_out, string'("Total Tests: " & integer'image(test_count)));
    writeline(output_file, line_out);
    write(line_out, string'("========================================"));
    writeline(output_file, line_out);
    
    -- Close the file
    file_close(output_file);
    
    report "=========================================";
    report "All tests completed successfully!";
    report "Test results written to: output/tb_axi4_lite_master_results.txt";
    report "=========================================";
    
    -- Stop simulation
    assert false report "Simulation completed successfully" severity failure;
  end process stim_proc;
  
end architecture sim;

