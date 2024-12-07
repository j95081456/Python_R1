### slicer window sweep        ###
### boundary detection         ###
### bug: output highlight file ###
import sys

def replace_failed_with_zero(input_file_path, output_file_path):
    """
    Replace all occurrences of the string 'failed' with '0' in the given file.
    """
    with open(input_file_path, 'r') as file:
        lines = file.readlines()

    # Replace 'failed' with '0'
    updated_lines = [line.replace("failed", "0") for line in lines]

    # Write the updated content back to the file
    with open(output_file_path, 'w') as file:
        file.writelines(updated_lines)

# Check if the user provided a file name
if len(sys.argv) < 4:
    print("Usage: python script_name.py <input_file> <cleaned_input_file> <output_file>")
    sys.exit(1)

# Get the file name from command-line arguments
input_file         = sys.argv[1]
cleaned_input_file = sys.argv[2]
output_file        = sys.argv[3]

replace_failed_with_zero(input_file, cleaned_input_file)
# Read the file
with open(cleaned_input_file, 'r') as file:
    lines = file.readlines()

threshold = 400e-12  # Define the threshold value

# Parse and process the data
highlighted_rows = []
separated_data = []
set_size = 40  # Number of columns in each set
header_lines = []

for line in lines:
    try:
        # Attempt to split into floats; the first column is the index
        row = list(map(float, line.split()))
        index = row[0]  # The first column is the index
        data_sets = [row[1 + i * set_size:1 + (i + 1) * set_size] for i in range(len(row[1:]) // set_size)] # // is floor division
        separated_data.append((index, data_sets))
    except ValueError:
        # If line is not numeric, treat it as a header or non-data line
        header_lines.append(line)

# Highlight rows for each set
for i in range(len(separated_data) - 1):
    index, current_row_sets = separated_data[i]
    _, next_row_sets = separated_data[i + 1]
    for set_idx, (current_set, next_set) in enumerate(zip(current_row_sets, next_row_sets)):
        for col_idx, (current_value, next_value) in enumerate(zip(current_set, next_set)):
            diff = abs(current_value - next_value)
            if diff > threshold:
                highlighted_rows.append((index, set_idx, col_idx, diff))

# Write the output
with open(output_file, 'w') as out:
    # Write header lines first
    for header in header_lines:
        out.write(header)
    
    # Write data with highlights
    for i, (index, row_sets) in enumerate(separated_data):
        line_highlighted = False
        line_data = []
        for set_idx, data_set in enumerate(row_sets):
            data_string = ' '.join(f"{value:.6f}" for value in data_set)
            if any((index == highlight[0] and set_idx == highlight[1]) for highlight in highlighted_rows):
                line_highlighted = True
                data_string = f"**HIGHLIGHTED** {data_string}"
            line_data.append(data_string)
        # Write the full row
        if line_highlighted:
            out.write(f"{index} {', '.join(line_data)}\n")
        else:
            out.write(f"{index} {', '.join(line_data)}\n")

# Sort highlights by set number
highlighted_rows.sort(key=lambda x: x[1])  # Sort by set_idx (second element)

# Summary of highlights
summary_file = '/home/m111/m111061571/hspice/slicer_compare/result_all_corner/slicer_tr_highlights_summary.txt'

with open(summary_file, 'w') as summary_out:
    summary_out.write("Highlights Summary (Sorted by Set Number):\n")
    print("Highlights Summary (Sorted by Set Number):")
    for index, set_idx, col_idx, diff in highlighted_rows:
        summary_line = f"Set {set_idx + 1}, Index {index}, Column {col_idx + 1}, Difference: {diff:.2e}\n"
        summary_out.write(summary_line)
        print(summary_line.strip())  # Print without extra newline

print(f"Summary written to: {summary_file}")
