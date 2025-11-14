# Phase 3 Features: CSV Output, Partial Test Runs, and Verbose Mode

## New Generic Parameters

### CSV Output
- **`CSV_OUTPUT_FILE`** (default: `""`) - Path to CSV output file. Empty = disabled.

### Partial Test Runs
- **`START_TEST`** (default: `0`) - Start from test case N (0 = from beginning, 1-based)
- **`END_TEST`** (default: `-1`) - End at test case N (-1 = to end, 1-based)

### Verbose Mode
- **`VERBOSE`** (default: `false`) - Enable verbose output showing detailed test information

## Usage Examples

### Example 1: CSV Output Only

Generate CSV file with all test results:

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gCSV_OUTPUT_FILE=output/results.csv
```

**CSV Format:**
```csv
test_number,input_abcdef,out1,out2,out3,expected_out1,expected_out2,expected_out3,result
1,000000,0,0,0,0,0,0,PASS
2,000001,0,0,0,0,0,0,PASS
3,000010,0,0,0,0,0,0,PASS
...
```

### Example 2: Partial Test Run (Tests 1-10)

Run only the first 10 test cases:

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gSTART_TEST=1 \
  -gEND_TEST=10
```

### Example 3: Partial Test Run (Tests 50-64)

Run only the last 15 test cases:

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gSTART_TEST=50 \
  -gEND_TEST=64
```

### Example 4: Verbose Mode

Enable detailed output for debugging:

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gVERBOSE=true
```

**Verbose Output Shows:**
- Input values for each test
- Expected vs actual outputs
- Detailed comparison results

### Example 5: Combined Features

Use all features together:

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gCSV_OUTPUT_FILE=output/partial_results.csv \
  -gSTART_TEST=1 \
  -gEND_TEST=10 \
  -gVERBOSE=true
```

This will:
- Run only tests 1-10
- Generate CSV output
- Show verbose debugging information

### Example 6: Debugging a Specific Test

Run a single test case with verbose output:

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gSTART_TEST=5 \
  -gEND_TEST=5 \
  -gVERBOSE=true
```

### Example 7: CSV for Data Analysis

Generate CSV for spreadsheet analysis:

```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gCSV_OUTPUT_FILE=output/analysis.csv \
  -gOUTPUT_FILE=output/detailed_results.txt
```

Then analyze in Excel/LibreOffice:
- Filter by PASS/FAIL
- Sort by input patterns
- Create charts
- Statistical analysis

## Use Cases

### 1. **Quick Debugging**
When a test fails, run just that test with verbose mode:
```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gSTART_TEST=42 \
  -gEND_TEST=42 \
  -gVERBOSE=true
```

### 2. **Performance Testing**
Run a subset of tests to measure performance:
```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gSTART_TEST=1 \
  -gEND_TEST=10
```

### 3. **Data Export**
Export all results to CSV for external analysis:
```bash
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gCSV_OUTPUT_FILE=output/export.csv
```

### 4. **Regression Testing**
Run specific test ranges to verify fixes:
```bash
# Test range 1-20
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gSTART_TEST=1 \
  -gEND_TEST=20 \
  -gOUTPUT_FILE=output/regression_1-20.txt

# Test range 21-40
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gSTART_TEST=21 \
  -gEND_TEST=40 \
  -gOUTPUT_FILE=output/regression_21-40.txt
```

## CSV File Structure

The CSV file contains:
- **test_number**: Sequential test case number (1-based)
- **input_abcdef**: 6-bit input pattern (e.g., "010101")
- **out1, out2, out3**: Actual output values
- **expected_out1, expected_out2, expected_out3**: Expected output values
- **result**: PASS or FAIL

## Notes

1. **Test numbering is 1-based**: First test case is 1, not 0
2. **Range is inclusive**: START_TEST=1, END_TEST=10 runs tests 1 through 10
3. **CSV is optional**: If CSV_OUTPUT_FILE is empty, no CSV is generated
4. **Verbose adds overhead**: Use only when debugging
5. **Partial runs still read full file**: The testbench reads the entire file but only processes the specified range

## Integration with Other Features

All Phase 3 features work with Phase 2 features:

```bash
# Custom files + CSV + Partial run + Verbose
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gINPUT_FILE=test_inputs_custom.txt \
  -gOUTPUT_FILE=output/custom_results.txt \
  -gCSV_OUTPUT_FILE=output/custom_results.csv \
  -gSTART_TEST=1 \
  -gEND_TEST=20 \
  -gVERBOSE=true
```

