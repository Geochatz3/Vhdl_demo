--=============================================================================
-- AXI4-Lite Master Interface
-- Fully compatible with Xilinx AXI4-Lite specification
--=============================================================================
-- Description:
--   This module implements an AXI4-Lite master interface with all 5 channels:
--   - Write Address (AW) channel
--   - Write Data (W) channel
--   - Write Response (B) channel
--   - Read Address (AR) channel
--   - Read Data (R) channel
--
-- Features:
--   - 32-bit data width (C_S_AXI_DATA_WIDTH = 32)
--   - 32-bit address width (C_S_AXI_ADDR_WIDTH = 32)
--   - Single transaction support (no bursts)
--   - Proper VALID/READY handshaking
--   - User-friendly control interface
--=============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi4_lite_master is
  generic (
    C_M_AXI_DATA_WIDTH : integer := 32;
    C_M_AXI_ADDR_WIDTH : integer := 32
  );
  port (
    -- Global Clock Signal
    M_AXI_ACLK    : in  std_logic;
    -- Global Reset Signal (active LOW)
    M_AXI_ARESETN : in  std_logic;
    
    -- ============================================
    -- Write Address (AW) Channel Signals
    -- ============================================
    M_AXI_AWADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in  std_logic;
    
    -- ============================================
    -- Write Data (W) Channel Signals
    -- ============================================
    M_AXI_WDATA   : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_WSTRB   : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
    M_AXI_WVALID  : out std_logic;
    M_AXI_WREADY  : in  std_logic;
    
    -- ============================================
    -- Write Response (B) Channel Signals
    -- ============================================
    M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_BVALID  : in  std_logic;
    M_AXI_BREADY  : out std_logic;
    
    -- ============================================
    -- Read Address (AR) Channel Signals
    -- ============================================
    M_AXI_ARADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in  std_logic;
    
    -- ============================================
    -- Read Data (R) Channel Signals
    -- ============================================
    M_AXI_RDATA   : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_RVALID  : in  std_logic;
    M_AXI_RREADY  : out std_logic;
    
    -- ============================================
    -- User Control Interface
    -- ============================================
    -- Write Transaction Control
    WR_START      : in  std_logic;
    WR_ADDR       : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    WR_DATA       : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    WR_STRB       : in  std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
    WR_DONE       : out std_logic;
    WR_ERROR      : out std_logic;
    
    -- Read Transaction Control
    RD_START      : in  std_logic;
    RD_ADDR       : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    RD_DATA       : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    RD_DONE       : out std_logic;
    RD_ERROR      : out std_logic
  );
end entity axi4_lite_master;

architecture rtl of axi4_lite_master is
  
  -- Write Address Channel State Machine
  type aw_state_type is (AW_IDLE, AW_VALID, AW_READY);
  signal aw_state : aw_state_type := AW_IDLE;
  
  -- Write Data Channel State Machine
  type w_state_type is (W_IDLE, W_VALID, W_READY);
  signal w_state : w_state_type := W_IDLE;
  
  -- Write Response Channel State Machine
  type b_state_type is (B_IDLE, B_READY, B_VALID);
  signal b_state : b_state_type := B_IDLE;
  
  -- Read Address Channel State Machine
  type ar_state_type is (AR_IDLE, AR_VALID, AR_READY);
  signal ar_state : ar_state_type := AR_IDLE;
  
  -- Read Data Channel State Machine
  type r_state_type is (R_IDLE, R_READY, R_VALID);
  signal r_state : r_state_type := R_IDLE;
  
  -- Internal registers
  signal aw_addr_reg  : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
  signal w_data_reg   : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
  signal w_strb_reg   : std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
  signal ar_addr_reg  : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
  signal r_data_reg   : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
  
  -- Control signals
  signal wr_start_pulse : std_logic;
  signal wr_start_reg   : std_logic;
  signal rd_start_pulse : std_logic;
  signal rd_start_reg   : std_logic;
  
begin
  
  -- ============================================
  -- Write Address (AW) Channel State Machine
  -- ============================================
  aw_channel_fsm : process(M_AXI_ACLK)
  begin
    if rising_edge(M_AXI_ACLK) then
      if M_AXI_ARESETN = '0' then
        aw_state    <= AW_IDLE;
        M_AXI_AWVALID <= '0';
        M_AXI_AWADDR  <= (others => '0');
        M_AXI_AWPROT  <= "000";
        aw_addr_reg   <= (others => '0');
      else
        case aw_state is
          when AW_IDLE =>
            if wr_start_pulse = '1' then
              aw_addr_reg   <= WR_ADDR;
              M_AXI_AWADDR  <= WR_ADDR;
              M_AXI_AWPROT  <= "000";  -- Normal, Secure, Data access
              M_AXI_AWVALID <= '1';
              aw_state      <= AW_VALID;
            end if;
            
          when AW_VALID =>
            if M_AXI_AWREADY = '1' then
              M_AXI_AWVALID <= '0';
              aw_state      <= AW_READY;
            end if;
            
          when AW_READY =>
            aw_state <= AW_IDLE;
            
        end case;
      end if;
    end if;
  end process aw_channel_fsm;
  
  -- ============================================
  -- Write Data (W) Channel State Machine
  -- ============================================
  w_channel_fsm : process(M_AXI_ACLK)
  begin
    if rising_edge(M_AXI_ACLK) then
      if M_AXI_ARESETN = '0' then
        w_state     <= W_IDLE;
        M_AXI_WVALID  <= '0';
        M_AXI_WDATA   <= (others => '0');
        M_AXI_WSTRB   <= (others => '0');
        w_data_reg    <= (others => '0');
        w_strb_reg    <= (others => '0');
      else
        case w_state is
          when W_IDLE =>
            if wr_start_pulse = '1' then
              w_data_reg   <= WR_DATA;
              w_strb_reg   <= WR_STRB;
              M_AXI_WDATA  <= WR_DATA;
              M_AXI_WSTRB  <= WR_STRB;
              M_AXI_WVALID <= '1';
              w_state      <= W_VALID;
            end if;
            
          when W_VALID =>
            if M_AXI_WREADY = '1' then
              M_AXI_WVALID <= '0';
              w_state      <= W_READY;
            end if;
            
          when W_READY =>
            w_state <= W_IDLE;
            
        end case;
      end if;
    end if;
  end process w_channel_fsm;
  
  -- ============================================
  -- Write Response (B) Channel State Machine
  -- ============================================
  b_channel_fsm : process(M_AXI_ACLK)
  begin
    if rising_edge(M_AXI_ACLK) then
      if M_AXI_ARESETN = '0' then
        b_state     <= B_IDLE;
        M_AXI_BREADY  <= '0';
        WR_DONE       <= '0';
        WR_ERROR      <= '0';
      else
        case b_state is
          when B_IDLE =>
            WR_DONE  <= '0';
            WR_ERROR <= '0';
            -- Wait for both AW and W channels to complete
            if aw_state = AW_READY and w_state = W_READY then
              M_AXI_BREADY <= '1';
              b_state      <= B_READY;
            end if;
            
          when B_READY =>
            if M_AXI_BVALID = '1' then
              M_AXI_BREADY <= '0';
              if M_AXI_BRESP = "00" then  -- OKAY response
                WR_ERROR <= '0';
              else  -- SLVERR or DECERR
                WR_ERROR <= '1';
              end if;
              WR_DONE <= '1';
              b_state <= B_VALID;
            end if;
            
          when B_VALID =>
            WR_DONE  <= '0';
            b_state  <= B_IDLE;
            
        end case;
      end if;
    end if;
  end process b_channel_fsm;
  
  -- ============================================
  -- Read Address (AR) Channel State Machine
  -- ============================================
  ar_channel_fsm : process(M_AXI_ACLK)
  begin
    if rising_edge(M_AXI_ACLK) then
      if M_AXI_ARESETN = '0' then
        ar_state    <= AR_IDLE;
        M_AXI_ARVALID <= '0';
        M_AXI_ARADDR  <= (others => '0');
        M_AXI_ARPROT  <= "000";
        ar_addr_reg   <= (others => '0');
      else
        case ar_state is
          when AR_IDLE =>
            if rd_start_pulse = '1' then
              ar_addr_reg   <= RD_ADDR;
              M_AXI_ARADDR  <= RD_ADDR;
              M_AXI_ARPROT  <= "000";  -- Normal, Secure, Data access
              M_AXI_ARVALID <= '1';
              ar_state      <= AR_VALID;
            end if;
            
          when AR_VALID =>
            if M_AXI_ARREADY = '1' then
              M_AXI_ARVALID <= '0';
              ar_state      <= AR_READY;
            end if;
            
          when AR_READY =>
            ar_state <= AR_IDLE;
            
        end case;
      end if;
    end if;
  end process ar_channel_fsm;
  
  -- ============================================
  -- Read Data (R) Channel State Machine
  -- ============================================
  r_channel_fsm : process(M_AXI_ACLK)
  begin
    if rising_edge(M_AXI_ACLK) then
      if M_AXI_ARESETN = '0' then
        r_state     <= R_IDLE;
        M_AXI_RREADY  <= '0';
        RD_DATA       <= (others => '0');
        RD_DONE       <= '0';
        RD_ERROR      <= '0';
        r_data_reg    <= (others => '0');
      else
        case r_state is
          when R_IDLE =>
            RD_DONE  <= '0';
            RD_ERROR <= '0';
            -- Wait for AR channel to complete
            if ar_state = AR_READY then
              M_AXI_RREADY <= '1';
              r_state      <= R_READY;
            end if;
            
          when R_READY =>
            if M_AXI_RVALID = '1' then
              M_AXI_RREADY <= '0';
              r_data_reg   <= M_AXI_RDATA;
              RD_DATA      <= M_AXI_RDATA;
              if M_AXI_RRESP = "00" then  -- OKAY response
                RD_ERROR <= '0';
              else  -- SLVERR or DECERR
                RD_ERROR <= '1';
              end if;
              RD_DONE <= '1';
              r_state <= R_VALID;
            end if;
            
          when R_VALID =>
            RD_DONE  <= '0';
            r_state  <= R_IDLE;
            
        end case;
      end if;
    end if;
  end process r_channel_fsm;
  
  -- ============================================
  -- Start Pulse Detection
  -- ============================================
  start_pulse_detection : process(M_AXI_ACLK)
  begin
    if rising_edge(M_AXI_ACLK) then
      if M_AXI_ARESETN = '0' then
        wr_start_reg <= '0';
        rd_start_reg <= '0';
      else
        wr_start_reg <= WR_START;
        rd_start_reg <= RD_START;
      end if;
    end if;
  end process start_pulse_detection;
  
  wr_start_pulse <= WR_START and not wr_start_reg;
  rd_start_pulse <= RD_START and not rd_start_reg;
  
end architecture rtl;

