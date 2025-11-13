#!/bin/bash

# Build script for VHDL GHDL Demo Project
# Uses GHDL via Docker wrapper

# Create directories if they don't exist
mkdir -p build waveforms

echo "Cleaning previous build files..."
rm -f *.o *.cf e~* tb_*
rm -f build/*.o build/*.cf build/e~* build/tb_* 2>/dev/null
rm -f waveforms/*.ghw waveforms/*.vcd 2>/dev/null

echo "Compiling gate modules..."
./ghdl-docker.sh -a src/gates/and_gate.vhd
./ghdl-docker.sh -a src/gates/or_gate.vhd
./ghdl-docker.sh -a src/gates/xor_gate.vhd

echo "Compiling top module..."
./ghdl-docker.sh -a src/top/combinational_logic.vhd

echo "Compiling AXI4-Lite modules..."
./ghdl-docker.sh -a src/axi/axi4_lite_master.vhd
./ghdl-docker.sh -a src/axi/axi4_lite_slave_model.vhd

echo "Compiling testbenches..."
./ghdl-docker.sh -a tb/tb_and_gate.vhd
./ghdl-docker.sh -a tb/tb_combinational_logic.vhd
./ghdl-docker.sh -a tb/tb_axi4_lite_master.vhd

echo "Elaborating testbenches..."
./ghdl-docker.sh -e tb_and_gate
./ghdl-docker.sh -e tb_combinational_logic
./ghdl-docker.sh -e tb_axi4_lite_master

echo ""
echo "Build complete!"
echo ""
echo "To run testbenches:"
echo "  ./ghdl-docker.sh -r tb_and_gate --wave=waveforms/wave_and.ghw"
echo "  ./ghdl-docker.sh -r tb_combinational_logic --wave=waveforms/wave.ghw"
echo "  ./ghdl-docker.sh -r tb_axi4_lite_master --wave=waveforms/wave_axi.ghw"

