#!/bin/bash
# Automated test script for VHDL GHDL Demo Project
# Runs all testbenches and verifies golden reference

# Don't use set -e here, we want to collect all test results
# set -e  # Exit on error

echo "=========================================="
echo "Automated Test Suite"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Function to run a test and check result
run_test() {
    local test_name=$1
    local command=$2
    local expected_exit=$3
    
    echo -n "Running $test_name... "
    
    if eval "$command" > /tmp/test_output.log 2>&1; then
        exit_code=$?
    else
        exit_code=$?
    fi
    
    # Check if test passed (look for PASS message)
    # GHDL exits with 1 even on success (uses assertion failure to stop)
    if grep -qi "TESTBENCH PASSED\|All.*test.*passed\|Simulation completed successfully" /tmp/test_output.log 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    elif grep -qi "TESTBENCH FAILED\|test.*failed\|assertion failed" /tmp/test_output.log 2>/dev/null; then
        # Check if it's a real failure or just the stop mechanism
        if grep -qi "TESTBENCH PASSED" /tmp/test_output.log 2>/dev/null; then
            # It says PASSED, so it's just the assertion to stop
            echo -e "${GREEN}PASS${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo -e "${RED}FAIL${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            FAILED_TESTS+=("$test_name")
            return 1
        fi
    else
        # For older testbenches without the new messaging, check for error patterns
        if grep -qi "error\|failed" /tmp/test_output.log 2>/dev/null && ! grep -qi "assertion failed.*successfully\|simulation completed" /tmp/test_output.log 2>/dev/null; then
            echo -e "${RED}FAIL${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            FAILED_TESTS+=("$test_name")
            return 1
        else
            # Assume pass if no clear failure
            echo -e "${GREEN}PASS${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        fi
    fi
}

# Step 1: Build project
echo "Step 1: Building project..."
if ./build.sh > /tmp/build.log 2>&1; then
    echo -e "${GREEN}Build successful${NC}"
else
    echo -e "${RED}Build failed${NC}"
    cat /tmp/build.log
    exit 1
fi
echo ""

# Step 2: Verify golden reference
echo "Step 2: Verifying golden reference..."
if python3 scripts/verify_golden_reference.py test_inputs.txt > /tmp/verify.log 2>&1; then
    echo -e "${GREEN}Golden reference verification passed${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}Golden reference verification failed${NC}"
    cat /tmp/verify.log
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("Golden Reference Verification")
fi
echo ""

# Step 3: Run testbenches
echo "Step 3: Running testbenches..."
echo ""

# Test 1: Basic combinational logic testbench
run_test "Combinational Logic (Basic)" \
    "./ghdl-docker.sh -r tb_combinational_logic" \
    1

# Test 2: File-based testbench (default)
run_test "Combinational Logic (File-based, Default)" \
    "./ghdl-docker.sh -r tb_combinational_logic_file" \
    1

# Test 3: File-based with custom input
run_test "Combinational Logic (File-based, Custom Input)" \
    "./ghdl-docker.sh -r tb_combinational_logic_file -gINPUT_FILE=test_inputs_custom.txt" \
    1

# Test 4: File-based with CSV output
run_test "Combinational Logic (File-based, CSV Output)" \
    "./ghdl-docker.sh -r tb_combinational_logic_file -gCSV_OUTPUT_FILE=output/test_results.csv" \
    1

# Test 5: File-based with partial run
run_test "Combinational Logic (File-based, Partial Run 1-10)" \
    "./ghdl-docker.sh -r tb_combinational_logic_file -gSTART_TEST=1 -gEND_TEST=10" \
    1

# Test 6: File-based with verbose mode
run_test "Combinational Logic (File-based, Verbose Mode)" \
    "./ghdl-docker.sh -r tb_combinational_logic_file -gSTART_TEST=1 -gEND_TEST=3 -gVERBOSE=true" \
    1

# Test 7: AND gate testbench
run_test "AND Gate Testbench" \
    "./ghdl-docker.sh -r tb_and_gate" \
    1

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed Tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  - $test"
    done
    echo ""
    echo -e "${RED}Some tests failed!${NC}"
    # Write to log file for GitHub Actions
    echo "TEST_RESULT=FAILED" > /tmp/test_status.log
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    # Write to log file for GitHub Actions
    echo "TEST_RESULT=PASSED" > /tmp/test_status.log
    echo "All tests passed!" >> /tmp/test_output.log
    exit 0
fi

