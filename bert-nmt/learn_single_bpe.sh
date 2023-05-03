#!/bin/bash

expdir=$1  # EXPDIR
output_dir=$2
num_operations=$3
mkdir $output_dir
#`dirname $0`/env.sh
SUBWORD_NMT_DIR="subword-nmt"
data_dir=$expdir
train_file=$data_dir/train
# num_operations=32000

echo Input file: $train_file

mkdir -p $output_dir/vocab

echo "learning source BPE"

python $SUBWORD_NMT_DIR/subword_nmt/learn_bpe.py \
   --input $train_file.SRC \
   -s $num_operations \
   -o $output_dir/vocab/bpe_codes.SRC\
   --num-workers -1

echo "learning target BPE"
python $SUBWORD_NMT_DIR/subword_nmt/learn_bpe.py \
   --input $train_file.TGT \
   -s $num_operations \
   -o $output_dir/vocab/bpe_codes.TGT\
   --num-workers -1

echo "computing SRC vocab"
python $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py \
    -c $output_dir/vocab/bpe_codes.SRC \
    --num-workers -1  \
    -i $train_file.SRC  | \
python $SUBWORD_NMT_DIR/subword_nmt/get_vocab.py \
    > $output_dir/vocab/vocab.tmp.SRC
python scripts/clean_vocab.py $output_dir/vocab/vocab.tmp.SRC $output_dir/vocab/vocab.SRC
rm $output_dir/vocab/vocab.tmp.SRC

echo "computing TGT vocab"
python $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py \
    -c $output_dir/vocab/bpe_codes.TGT \
    --num-workers -1  \
    -i $train_file.TGT  | \
python $SUBWORD_NMT_DIR/subword_nmt/get_vocab.py \
    > $output_dir/vocab/vocab.tmp.TGT
python scripts/clean_vocab.py $output_dir/vocab/vocab.tmp.TGT $output_dir/vocab/vocab.TGT
rm $output_dir/vocab/vocab.tmp.TGT
