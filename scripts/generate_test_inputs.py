#!/usr/bin/env python3
"""
Generate test input file for combinational logic testbench.
Creates all 2^6 = 64 input combinations in the format: abcdef 010101
"""

import os
import sys

def generate_test_inputs(output_file="test_inputs.txt"):
    """Generate all possible input combinations for 6 inputs (a, b, c, d, e, f)"""
    
    # Create output directory if it doesn't exist
    output_dir = os.path.dirname(output_file) if os.path.dirname(output_file) else "."
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    with open(output_file, 'w') as f:
        # Write header comment
        f.write("# Test input file for combinational logic\n")
        f.write("# Format: abcdef <6-bit binary value>\n")
        f.write("# Example: abcdef 010101\n")
        f.write("# Each line represents one test case\n")
        f.write("#\n")
        
        # Generate all 2^6 = 64 combinations
        for i in range(64):
            # Convert to 6-bit binary string
            binary_str = format(i, '06b')
            
            # Write in format: abcdef 010101
            f.write(f"abcdef {binary_str}\n")
    
    print(f"Generated {64} test cases in {output_file}")
    return output_file

if __name__ == "__main__":
    # Default output file
    output_file = "test_inputs.txt"
    
    # Allow custom output file via command line
    if len(sys.argv) > 1:
        output_file = sys.argv[1]
    
    generate_test_inputs(output_file)

