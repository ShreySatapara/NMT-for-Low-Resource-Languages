import random
import argparse
from tqdm import tqdm

import argparse

parser = argparse.ArgumentParser(description='Add noise to sentences in a file')
parser.add_argument('input_file', type=str, help='Path to the input file')
parser.add_argument('output_file', type=str, help='Path to the output file')
parser.add_argument('--noisy_ratio', type=float, default=0.1, help='Ratio of sentences to add noise to (default: 0.1)')
parser.add_argument('--random_seed', type=int, default=42, help='Random seed for generating noise (default: 42)')

args = parser.parse_args()

# Now you can access the arguments using the variable 'args'
input_file_path = args.input_file
output_file_path = args.output_file
noisy_ratio = args.noisy_ratio
random_seed = args.random_seed


def insert_char(s):
    """Insert a random character in the given string"""
    char = chr(random.randint(2304, 2431))  # Choose a random Hindi character code
    pos = random.randint(0, len(s))
    #print("insertion",char)

    return s[:pos] + char + s[pos:]

def substitute_char(s):
    """Substitute a random character in the given string"""
    char = chr(random.randint(2304, 2431))  # Choose a random Hindi character code
    pos = random.randint(0, len(s)-1)
    #print("subti",char)
    return s[:pos] + char + s[pos+1:]

def delete_char(s):
    """Delete a random character in the given string"""
    pos = random.randint(0, len(s)-1)
    #print("del")
    return s[:pos] + s[pos+1:]

def inject_noise(s):
    """Inject character-level noise in the given Hindi sentence"""
    words = s.split()
    num_noisy_words = max(1, round(len(words) / 10))  # Choose at least 1 word to add noise to
    noisy_word_indices = random.sample(range(len(words)), num_noisy_words)
    #print(noisy_word_indices)
    for idx in noisy_word_indices:
        word = words[idx]
        #num_ops = random.randint(1, 3)  # Choose a random number of operations to perform (1 to 3)
        #print(num_ops)
        #for i in range(num_ops):
        op = random.randint(1, 3)  # Choose a random operation (1: insertion, 2: substitution, 3: deletion)
        if op == 1:
            word = insert_char(word)
        elif op == 2:
            word = substitute_char(word)
        elif op == 3:
            word = delete_char(word)
        words[idx] = word
    return ' '.join(words)


# Read input file and add noise to sentences
with open(input_file_path, "r", encoding="utf-8") as input_file, open(output_file_path, "w", encoding="utf-8") as output_file:
    for line in tqdm(input_file):
        noisy_line = inject_noise(line.strip())
        output_file.write(noisy_line + "\n")