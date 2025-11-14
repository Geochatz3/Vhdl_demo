# Automated Testing Guide

## Quick Start

Run all tests:
```bash
./run_all_tests.sh
```

## What Gets Tested

The automated test suite (`run_all_tests.sh`) verifies:

1. **Build System**
   - Compiles all VHDL modules
   - Elaborates all testbenches
   - Verifies no compilation errors

2. **Golden Reference**
   - Validates test input file format
   - Verifies expected outputs match logic equations
   - Checks all 64 test cases

3. **Testbenches**
   - Basic combinational logic testbench
   - File-based testbench (default configuration)
   - File-based with custom input file
   - File-based with CSV output
   - File-based with partial test run (1-10)
   - File-based with verbose mode
   - AND gate testbench

## Test Results

The script provides:
- ✅ **PASS** - Test completed successfully
- ❌ **FAIL** - Test failed
- Summary with total passed/failed counts

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

This makes it suitable for CI/CD integration.

## CI/CD Integration

### GitHub Actions Example

```yaml
name: VHDL Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          chmod +x *.sh scripts/*.py
          ./run_all_tests.sh
```

### GitLab CI Example

```yaml
test:
  image: ghdl/ghdl:6.0.0-dev-gcc-ubuntu-22.04
  script:
    - chmod +x *.sh scripts/*.py
    - ./run_all_tests.sh
```

## Manual Testing

You can also run individual tests:

```bash
# Run specific testbench
./ghdl-docker.sh -r tb_combinational_logic_file

# Run with specific options
./ghdl-docker.sh -r tb_combinational_logic_file \
  -gCSV_OUTPUT_FILE=output/test.csv \
  -gSTART_TEST=1 \
  -gEND_TEST=10 \
  -gVERBOSE=true
```

## Troubleshooting

If tests fail:
1. Check build output: `cat /tmp/build.log`
2. Check test output: `cat /tmp/test_output.log`
3. Verify golden reference: `python3 scripts/verify_golden_reference.py test_inputs.txt`
4. Rebuild: `./build.sh`

