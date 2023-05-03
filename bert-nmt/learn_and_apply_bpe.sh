#!/bin/bash
exp_dir=$1
output_dir=$2
no_operations=$3

mkdir $output_dir
bash learn_single_bpe.sh $exp_dir $output_dir $no_operations
bash apply_single_bpe_traindevtest_notag.sh $exp_dir $output_dir


mkdir $output_dir/final

python scripts/remove_large_sentences.py $output_dir/bpe/train.SRC $output_dir/bpe/train.TGT $output_dir/final/train.hi $output_dir/final/train.en
python scripts/remove_large_sentences.py $output_dir/bpe/dev.SRC $output_dir/bpe/dev.TGT $output_dir/final/valid.hi $output_dir/final/valid.en
python scripts/remove_large_sentences.py $output_dir/bpe/test.SRC $output_dir/bpe/test.TGT $output_dir/final/test.hi $output_dir/final/test.en

bash makedataforbert.sh $output_dir/final hi en

python preprocess.py --source-lang hi --target-lang en \
  --trainpref $output_dir/final/train --validpref $output_dir/final/valid --testpref $output_dir/final/test \
  --destdir $output_dir/data_bin --bert-model-name bert-base-multilingual-uncased --workers 32