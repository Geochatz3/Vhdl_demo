#!/bin/bash
# Example script showing how to use generic file paths with the testbench

echo "=========================================="
echo "Example: Using Generic File Paths"
echo "=========================================="
echo ""

# First, make sure the testbench is elaborated
echo "1. Elaborating testbench..."
./ghdl-docker.sh -e tb_combinational_logic_file

echo ""
echo "=========================================="
echo "Example 1: Using DEFAULT file paths"
echo "=========================================="
echo "Command: ./ghdl-docker.sh -r tb_combinational_logic_file"
echo ""
./ghdl-docker.sh -r tb_combinational_logic_file 2>&1 | head -8
echo ""

echo "=========================================="
echo "Example 2: Using CUSTOM input file"
echo "=========================================="
echo "Command: ./ghdl-docker.sh -r tb_combinational_logic_file -gINPUT_FILE=test_inputs_custom.txt"
echo ""
./ghdl-docker.sh -r tb_combinational_logic_file -gINPUT_FILE=test_inputs_custom.txt 2>&1 | head -8
echo ""

echo "=========================================="
echo "Example 3: Using CUSTOM output file"
echo "=========================================="
echo "Command: ./ghdl-docker.sh -r tb_combinational_logic_file -gOUTPUT_FILE=output/custom_results.txt"
echo ""
./ghdl-docker.sh -r tb_combinational_logic_file -gOUTPUT_FILE=output/custom_results.txt 2>&1 | head -8
echo ""

echo "=========================================="
echo "Example 4: Using BOTH custom files"
echo "=========================================="
echo "Command: ./ghdl-docker.sh -r tb_combinational_logic_file -gINPUT_FILE=test_inputs_custom.txt -gOUTPUT_FILE=output/custom_both_results.txt"
echo ""
./ghdl-docker.sh -r tb_combinational_logic_file -gINPUT_FILE=test_inputs_custom.txt -gOUTPUT_FILE=output/custom_both_results.txt 2>&1 | head -8
echo ""

echo "=========================================="
echo "Verifying custom output files were created:"
echo "=========================================="
ls -lh output/*.txt 2>/dev/null | tail -3
echo ""

echo "=========================================="
echo "Example 5: Using generics with full paths"
echo "=========================================="
echo "You can also use relative or absolute paths:"
echo "./ghdl-docker.sh -r tb_combinational_logic_file \\"
echo "  -gINPUT_FILE=test_inputs_custom.txt \\"
echo "  -gOUTPUT_FILE=output/my_test_results.txt"
echo ""

