# Generic File Path Usage Examples

The `tb_combinational_logic_file` testbench supports configurable file paths through generics.

## Generic Parameters

- `INPUT_FILE` (default: `"test_inputs.txt"`) - Path to input test file
- `OUTPUT_FILE` (default: `"output/tb_combinational_logic_file_results.txt"`) - Path to output results file

## Usage Examples

### Example 1: Default Behavior (No Generics)

```bash
./ghdl-docker.sh -r tb_combinational_logic_file
```

This uses:
- Input: `test_inputs.txt`
- Output: `output/tb_combinational_logic_file_results.txt`

### Example 2: Custom Input File Only

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gINPUT_FILE=test_inputs_custom.txt
```

This uses:
- Input: `test_inputs_custom.txt`
- Output: `output/tb_combinational_logic_file_results.txt` (default)

### Example 3: Custom Output File Only

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gOUTPUT_FILE=output/my_custom_results.txt
```

This uses:
- Input: `test_inputs.txt` (default)
- Output: `output/my_custom_results.txt`

### Example 4: Both Custom Files

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gINPUT_FILE=test_inputs_custom.txt \
  -gOUTPUT_FILE=output/custom_test_results.txt
```

This uses:
- Input: `test_inputs_custom.txt`
- Output: `output/custom_test_results.txt`

### Example 5: Using Different Test Sets

You can create multiple test input files and run them separately:

```bash
# Generate different test sets
python3 scripts/generate_golden_reference.py test_inputs_set1.txt
python3 scripts/generate_golden_reference.py test_inputs_set2.txt

# Run with first set
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gINPUT_FILE=test_inputs_set1.txt \
  -gOUTPUT_FILE=output/results_set1.txt

# Run with second set
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gINPUT_FILE=test_inputs_set2.txt \
  -gOUTPUT_FILE=output/results_set2.txt
```

### Example 6: Relative Paths

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gINPUT_FILE=../tests/test_inputs.txt \
  -gOUTPUT_FILE=../results/output.txt
```

### Example 7: In a Script

```bash
#!/bin/bash
# test_multiple_configs.sh

INPUT_FILES=("test_inputs.txt" "test_inputs_custom.txt" "test_inputs_alt.txt")

for input_file in "${INPUT_FILES[@]}"; do
    output_file="output/results_$(basename $input_file .txt).txt"
    
    echo "Testing with $input_file..."
    ./ghdl-docker.sh -r tb_combinational_logic_file \
      -gINPUT_FILE="$input_file" \
      -gOUTPUT_FILE="$output_file"
    
    echo "Results saved to $output_file"
    echo ""
done
```

## Important Notes

1. **File paths are relative to the working directory** where GHDL runs
2. **Output directory must exist** - create it if needed: `mkdir -p output`
3. **Input file must exist** - the testbench will report an error if it doesn't
4. **Generics are passed using `-g` flag** in GHDL: `-gGENERIC_NAME=value`
5. **String values don't need quotes** in the command line (GHDL handles them)

## Verification

After running with custom files, verify the output:

```bash
# Check if custom output file was created
ls -lh output/custom_test_results.txt

# View the results
cat output/custom_test_results.txt

# Verify the golden reference
python3 scripts/verify_golden_reference.py test_inputs_custom.txt
```

## Error Handling

If a file doesn't exist, you'll see clear error messages:

```
ERROR: Cannot open input file 'nonexistent.txt'. Status: name_error
```

The testbench will stop with a failure status, making it easy to catch in CI/CD pipelines.

