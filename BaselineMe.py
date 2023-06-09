import re
import sys
import os

# Regular expression patterns
const_pattern = re.compile(r'^\s*const char')
hex_pattern = re.compile(r'^\s*HexToByteString')

def extract_data(input_file_name, output_directory):
    hex_count = 0
    output_file_path = os.path.join(output_directory, 'generated_digests.c')
    with open(input_file_name, 'r') as input_file, open(output_file_path, 'w') as output_file:
        output_file.write("int register_digests(uint8_t (*digests)[INTRO_NUM_DIGESTS * DIGEST_NUM_BYTES]) {\n")  # Start of the function with new signature
        output_file.write("  int numDigests = 0;\n")  # Initialize numDigests variable
        for line in input_file:
            if const_pattern.match(line):
                output_file.write(line)
            elif hex_pattern.match(line):
                # Update HexToByteString line
                line = line.replace("&digests[DIGEST_NUM_BYTES*(numDigests++)]", "(uint8_t (*) [DIGEST_NUM_BYTES])&(((uint8_t*)digests)[DIGEST_NUM_BYTES*(numDigests++)])")
                output_file.write("  " + line)  # Indent the function call
                hex_count += 1
        output_file.write("  return numDigests;\n")  # Return numDigests of function calls
        output_file.write("}\n")  # End of the function

    print(f"Total HexToByteString calls: {hex_count}. Writing to {output_directory}.")

if __name__ == "__main__":
    # Get the current working directory
    cwd = os.getcwd()

    # Use a regex to find the Linux version in the path
    match = re.search(r'/(\d+\.\d+\.y)-linux/', cwd)
    kernel_version = match.group(1)
    input_file_name = "/mnt/workspace/dissertation/continteg/SimulationResults/result-{}".format(kernel_version)
    output_directory = "attarch/components/Measurement/"
    extract_data(input_file_name, output_directory)

