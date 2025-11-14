#!/usr/bin/env python3
"""
Generate golden reference file for combinational logic testbench.
Creates all 2^6 = 64 input combinations with expected outputs.
Format: abcdef <6-bit input> <3-bit expected output>
Example: abcdef 010101 010
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

def generate_golden_reference(output_file="test_inputs.txt"):
    """Generate all possible input combinations with expected outputs"""
    
    # Create output directory if it doesn't exist
    output_dir = os.path.dirname(output_file) if os.path.dirname(output_file) else "."
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    with open(output_file, 'w') as file_handle:
        # Write header comment
        file_handle.write("# Golden reference file for combinational logic testbench\n")
        file_handle.write("# Format: abcdef <6-bit input> <3-bit expected output>\n")
        file_handle.write("# Example: abcdef 010101 010\n")
        file_handle.write("# Each line represents one test case with expected outputs\n")
        file_handle.write("# Logic equations:\n")
        file_handle.write("#   out1 = (a AND b) OR (c AND d)\n")
        file_handle.write("#   out2 = (a XOR b) AND (c OR d)\n")
        file_handle.write("#   out3 = (a OR b) XOR (e AND f)\n")
        file_handle.write("#\n")
        
        # Generate all 2^6 = 64 combinations
        for i in range(64):
            # Convert to 6-bit binary string
            binary_str = format(i, '06b')
            
            # Extract individual bits
            a = int(binary_str[0])
            b = int(binary_str[1])
            c = int(binary_str[2])
            d = int(binary_str[3])
            e = int(binary_str[4])
            f = int(binary_str[5])
            
            # Calculate expected outputs
            expected_output = calculate_outputs(a, b, c, d, e, f)
            
            # Write in format: abcdef 010101 010
            file_handle.write(f"abcdef {binary_str} {expected_output}\n")
    
    print(f"Generated {64} test cases with golden reference outputs in {output_file}")
    return output_file

if __name__ == "__main__":
    # Default output file
    output_file = "test_inputs.txt"
    
    # Allow custom output file via command line
    if len(sys.argv) > 1:
        output_file = sys.argv[1]
    
    generate_golden_reference(output_file)

