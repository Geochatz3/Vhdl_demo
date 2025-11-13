# VHDL GHDL Demo Project

A professional VHDL project demonstrating combinational logic using AND, OR, and XOR gates, plus a fully compatible Xilinx AXI4-Lite master interface.

## Project Structure

```
vhdl_ghdl_demo/
├── src/
│   ├── gates/
│   │   ├── and_gate.vhd      # 2-input AND gate
│   │   ├── or_gate.vhd       # 2-input OR gate
│   │   └── xor_gate.vhd      # 2-input XOR gate
│   ├── top/
│   │   └── combinational_logic.vhd  # Top module using multiple gate instances
│   └── axi/
│       ├── axi4_lite_master.vhd      # AXI4-Lite Master Interface (Xilinx compatible)
│       └── axi4_lite_slave_model.vhd  # AXI4-Lite Slave Model for testing
├── tb/
│   ├── tb_and_gate.vhd       # Testbench for AND gate
│   ├── tb_combinational_logic.vhd  # Testbench for top module
│   └── tb_axi4_lite_master.vhd     # Testbench for AXI4-Lite master
├── build/                    # Build artifacts (auto-generated)
├── waveforms/                # Waveform files (auto-generated)
├── build.sh                  # Build script
├── ghdl-docker.sh            # GHDL Docker wrapper
├── .gitignore                # Git ignore file
└── README.md
```

## Design Description

### Top Module: combinational_logic

The `combinational_logic` module implements a complex combinational circuit with:
- **6 inputs**: a, b, c, d, e, f
- **3 outputs**: out1, out2, out3

**Logic Functions:**
- `out1 = (a AND b) OR (c AND d)`
- `out2 = (a XOR b) AND (c OR d)`
- `out3 = (a OR b) XOR (e AND f)`

The design uses **11 gate instances**:
- 3 AND gates
- 3 OR gates
- 2 XOR gates
- Plus 3 additional gates for the output logic

## Building and Running

### Quick Build

Use the provided build script:
```bash
./build.sh
```

### Manual Compilation

If you prefer to compile manually:

```bash
# Compile all modules
./ghdl-docker.sh -a src/gates/and_gate.vhd
./ghdl-docker.sh -a src/gates/or_gate.vhd
./ghdl-docker.sh -a src/gates/xor_gate.vhd
./ghdl-docker.sh -a src/top/combinational_logic.vhd
./ghdl-docker.sh -a src/axi/axi4_lite_master.vhd
./ghdl-docker.sh -a src/axi/axi4_lite_slave_model.vhd

# Compile testbenches
./ghdl-docker.sh -a tb/tb_and_gate.vhd
./ghdl-docker.sh -a tb/tb_combinational_logic.vhd
./ghdl-docker.sh -a tb/tb_axi4_lite_master.vhd

# Elaborate
./ghdl-docker.sh -e tb_and_gate
./ghdl-docker.sh -e tb_combinational_logic
./ghdl-docker.sh -e tb_axi4_lite_master
```

### Run Testbenches

```bash
# Run testbenches (waveforms saved to waveforms/ directory)
./ghdl-docker.sh -r tb_and_gate --wave=waveforms/wave_and.ghw
./ghdl-docker.sh -r tb_combinational_logic --wave=waveforms/wave.ghw
./ghdl-docker.sh -r tb_axi4_lite_master --wave=waveforms/wave_axi.ghw
```

### View Waveforms

Use GTKWave to view the waveform files:
```bash
gtkwave waveforms/wave_axi.ghw
gtkwave waveforms/wave.ghw
gtkwave waveforms/wave_and.ghw
```

## AXI4-Lite Master Interface

### Overview

The `axi4_lite_master` module implements a fully compatible Xilinx AXI4-Lite master interface with all 5 channels:

- **Write Address (AW) Channel**: Address and control signals for write transactions
- **Write Data (W) Channel**: Write data and byte strobes
- **Write Response (B) Channel**: Write response from slave
- **Read Address (AR) Channel**: Address and control signals for read transactions
- **Read Data (R) Channel**: Read data from slave

### Features

- ✅ Fully compatible with Xilinx AXI4-Lite specification
- ✅ 32-bit data width (configurable via generic)
- ✅ 32-bit address width (configurable via generic)
- ✅ Proper VALID/READY handshaking on all channels
- ✅ State machine-based implementation for reliable operation
- ✅ User-friendly control interface
- ✅ Error detection and reporting
- ✅ Support for byte-level writes via WSTRB

### User Interface

**Write Transaction:**
- Assert `WR_START` to initiate a write
- Provide `WR_ADDR` (address) and `WR_DATA` (data to write)
- Set `WR_STRB` for byte enables (e.g., "1111" for all bytes)
- Monitor `WR_DONE` for completion
- Check `WR_ERROR` for transaction errors

**Read Transaction:**
- Assert `RD_START` to initiate a read
- Provide `RD_ADDR` (address to read from)
- Monitor `RD_DONE` for completion
- Read data is available on `RD_DATA`
- Check `RD_ERROR` for transaction errors

### Example Usage

```vhdl
-- Write example
wr_addr <= x"00001000";
wr_data <= x"DEADBEEF";
wr_strb <= "1111";
wr_start <= '1';
wait until wr_done = '1';
wr_start <= '0';

-- Read example
rd_addr <= x"00001000";
rd_start <= '1';
wait until rd_done = '1';
-- Data is now available on rd_data
rd_start <= '0';
```

### Building and Testing AXI Interface

```bash
# Compile AXI modules
ghdl -a src/axi/axi4_lite_master.vhd
ghdl -a src/axi/axi4_lite_slave_model.vhd

# Compile testbench
ghdl -a tb/tb_axi4_lite_master.vhd

# Elaborate
ghdl -e tb_axi4_lite_master

# Run simulation
./ghdl-docker.sh -r tb_axi4_lite_master --wave=waveforms/wave_axi.ghw

# View waveforms
gtkwave waveforms/wave_axi.ghw
```

The testbench includes comprehensive tests:
- Simple write and read transactions
- Multiple sequential transactions
- Byte-level writes
- Write-Read-Write sequences
- Error checking

### Xilinx Compatibility

The interface follows Xilinx AXI4-Lite naming conventions:
- All signals prefixed with `M_AXI_` (Master AXI)
- Standard channel naming (AW, W, B, AR, R)
- Compatible with Xilinx IP Integrator
- Can be directly connected to Xilinx AXI4-Lite slaves

## Notes

- All modules follow a consistent coding style
- Component instantiation uses structural architecture
- Testbenches include comprehensive test cases
- AXI interface is production-ready and fully tested

