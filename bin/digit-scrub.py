#!/usr/bin/env python3

import os
import re
import argparse
digit_counts = {}
def replace_numbers(match, min_digits, max_digits):
    # The first digit in the group
    digit = int(match.group(0)[0])
    # The number of times we've seen this digit before
    digit_count = int(digit_counts.get(digit, 0)) + 1
    # Save total for later
    digit_counts[digit] = digit_count
    # How long is the count, as a string
    digit_len = len(str(digit_count))
    repeated_val = match.group(0)[0] * (len(match.group(0)) - digit_len)
    return repeated_val + str(digit_count)
    

def process_file(file_path, output_dir, min_digits, max_digits):
    with open(file_path, 'r') as file:
        content = file.read()
    
    pattern = rf'\b\d{{{min_digits},{max_digits}}}\b'
    modified_content = re.sub(pattern, lambda m: replace_numbers(m, min_digits, max_digits), content)
    
    if output_dir:
        output_path = os.path.join(output_dir, os.path.basename(file_path))
    else:
        output_path = file_path
    
    with open(output_path, 'w') as file:
        file.write(modified_content)
    
    print(f"Processed: {file_path}")

def validate_digit_range(min_digits, max_digits):
    if min_digits > max_digits:
        raise argparse.ArgumentTypeError("Minimum digits must be less than or equal to maximum digits")
    if min_digits < 1 or max_digits > 100:  # Arbitrary upper limit
        raise argparse.ArgumentTypeError("Digit range must be between 1 and 100")
    return min_digits, max_digits

def main():
    parser = argparse.ArgumentParser(
        description="Replace numbers with repeating numbers in specified files.",
        epilog="Example: ./digit-scrubber.py *.json -o new_folder --min 4 --max 12"
    )
    parser.add_argument('files', nargs='+', help="Files to process")
    parser.add_argument('-o', '--output', help="Output directory for modified files. If not specified, original files will be overwritten.")
    parser.add_argument('--min', type=int, default=6, help="Minimum number of digits to replace (default: 6)")
    parser.add_argument('--max', type=int, default=20, help="Maximum number of digits to replace (default: 20)")
    
    args = parser.parse_args()

    try:
        min_digits, max_digits = validate_digit_range(args.min, args.max)
    except argparse.ArgumentTypeError as e:
        parser.error(str(e))

    if args.output and not os.path.exists(args.output):
        os.makedirs(args.output)
    
    for file_path in args.files:
        if os.path.isfile(file_path):
            process_file(file_path, args.output, min_digits, max_digits)
        else:
            print(f"Skipping {file_path}: Not a file")

if __name__ == "__main__":
    main()
