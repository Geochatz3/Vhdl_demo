#!/usr/bin/env python3
"""
Verify golden reference file for combinational logic testbench.
Checks file format and validates expected outputs against logic equations.
"""

import os
import sys

def calculate_outputs(a_in, b_in, c_in, d_in, e_in, f_in):
    """
    Calculate expected outputs based on logic equations:
    - out1 = (a AND b) OR (c AND d)
    - out2 = (a XOR b) AND (c OR d)
    - out3 = (a OR b) XOR (e AND f)
    """
    # Convert to boolean for calculations
    a_bool = bool(a_in)
    b_bool = bool(b_in)
    c_bool = bool(c_in)
    d_bool = bool(d_in)
    e_bool = bool(e_in)
    f_bool = bool(f_in)
    
    # Calculate outputs
    out1 = (a_bool and b_bool) or (c_bool and d_bool)
    out2 = (a_bool != b_bool) and (c_bool or d_bool)  # XOR is != for booleans
    out3 = (a_bool or b_bool) != (e_bool and f_bool)   # XOR is != for booleans
    
    # Convert back to binary string
    out1_str = '1' if out1 else '0'
    out2_str = '1' if out2 else '0'
    out3_str = '1' if out3 else '0'
    
    return out1_str + out2_str + out3_str

def verify_golden_reference(input_file="test_inputs.txt"):
    """Verify golden reference file format and values"""
    
    if not os.path.exists(input_file):
        print(f"ERROR: Input file '{input_file}' does not exist")
        return False
    
    errors = []
    warnings = []
    line_num = 0
    test_count = 0
    valid_tests = 0
    
    with open(input_file, 'r') as f:
        for line in f:
            line_num += 1
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('#'):
                continue
            
            # Parse line: "abcdef 010101 010"
            parts = line.split()
            if len(parts) < 3:
                warnings.append(f"Line {line_num}: Invalid format (expected 3 parts, got {len(parts)})")
                continue
            
            if parts[0] != "abcdef":
                warnings.append(f"Line {line_num}: Expected 'abcdef' prefix, got '{parts[0]}'")
                continue
            
            if len(parts[1]) != 6:
                errors.append(f"Line {line_num}: Input must be 6 bits, got '{parts[1]}' ({len(parts[1])} bits)")
                continue
            
            if len(parts[2]) != 3:
                errors.append(f"Line {line_num}: Expected output must be 3 bits, got '{parts[2]}' ({len(parts[2])} bits)")
                continue
            
            # Extract values
            try:
                input_str = parts[1]
                expected_output = parts[2]
                
                # Validate binary format
                for bit in input_str:
                    if bit not in '01':
                        errors.append(f"Line {line_num}: Invalid input bit '{bit}' (must be 0 or 1)")
                        break
                
                for bit in expected_output:
                    if bit not in '01':
                        errors.append(f"Line {line_num}: Invalid expected output bit '{bit}' (must be 0 or 1)")
                        break
                
                # Extract individual bits
                a = int(input_str[0])
                b = int(input_str[1])
                c = int(input_str[2])
                d = int(input_str[3])
                e = int(input_str[4])
                f = int(input_str[5])
                
                # Calculate expected output
                calculated_output = calculate_outputs(a, b, c, d, e, f)
                
                # Compare with file value
                if calculated_output != expected_output:
                    errors.append(
                        f"Line {line_num}: Output mismatch for input {input_str}\n"
                        f"  Expected in file: {expected_output}\n"
                        f"  Calculated:       {calculated_output}"
                    )
                else:
                    valid_tests += 1
                
                test_count += 1
                
            except (ValueError, IndexError) as e:
                errors.append(f"Line {line_num}: Parse error - {str(e)}")
    
    # Print results
    print("=" * 60)
    print("Golden Reference Verification Report")
    print("=" * 60)
    print(f"File: {input_file}")
    print(f"Total test cases found: {test_count}")
    print(f"Valid test cases: {valid_tests}")
    print(f"Errors: {len(errors)}")
    print(f"Warnings: {len(warnings)}")
    print("=" * 60)
    
    if warnings:
        print("\nWARNINGS:")
        for warning in warnings:
            print(f"  {warning}")
    
    if errors:
        print("\nERRORS:")
        for error in errors:
            print(f"  {error}")
        print("\n❌ VERIFICATION FAILED")
        return False
    elif test_count == 0:
        print("\n⚠️  WARNING: No test cases found in file")
        return False
    else:
        print("\n✅ VERIFICATION PASSED: All test cases are valid")
        return True

if __name__ == "__main__":
    input_file = "test_inputs.txt"
    
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    
    success = verify_golden_reference(input_file)
    sys.exit(0 if success else 1)

