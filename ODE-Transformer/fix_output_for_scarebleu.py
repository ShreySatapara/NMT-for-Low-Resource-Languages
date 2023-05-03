import pandas as pd
import argparse

def fix_format(input_file, output_file):
    df = pd.read_csv(input_file,sep="\t",header=None)
    df = df.sort_values(by=[0])
    a = df[1].values.tolist()

    with open(output_file, 'w') as f:
        for line in a:
            f.write(f"{line}\n")


if __name__ == '__main__':
    # Create argument parser
    parser = argparse.ArgumentParser(description='Convert first column of input CSV file into a list and write to output text file')
    
    # Add arguments
    parser.add_argument('csv_file', type=str, help='Name of input CSV file')
    parser.add_argument('output_file', type=str, help='Name of output text file')
    
    # Parse arguments
    args = parser.parse_args()
    
    # Call function
    fix_format(args.csv_file, args.output_file)