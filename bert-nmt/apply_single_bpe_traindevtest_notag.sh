#!/bin/bash
expdir=$1  # EXPDIR
output_dir=$2
SUBWORD_NMT_DIR="subword-nmt"

data_dir="$expdir"
mkdir -p $output_dir/bpe

for dset in `echo train dev test`
do
    echo $dset
    in_dset_dir="$data_dir/$dset"
    out_dset_dir="$output_dir/bpe/$dset"
    # out_dset_dir="$expdir/final/$dset"
    echo "Apply to SRC corpus"
    # for very large datasets, use gnu-parallel to speed up applying bpe
    # uncomment the below line if the apply bpe is slow

    # parallel --pipe --keep-order \
    python $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py \
        -c $output_dir/vocab/bpe_codes.SRC \
        --vocabulary $output_dir/vocab/vocab.SRC \
        --vocabulary-threshold 5 \
        --num-workers "-1" \
        < $in_dset_dir.SRC \
        > $out_dset_dir.SRC
    echo "Apply to TGT corpus"
    # for very large datasets, use gnu-parallel to speed up applying bpe
    # uncomment the below line if the apply bpe is slow

    # parallel --pipe --keep-order \
    python $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py \
        -c $output_dir/vocab/bpe_codes.TGT \
        --vocabulary $output_dir/vocab/vocab.TGT \
        --vocabulary-threshold 5 \
        --num-workers "-1" \
        < $in_dset_dir.TGT \
        > $out_dset_dir.TGT
done