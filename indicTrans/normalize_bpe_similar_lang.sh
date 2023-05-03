#!/bin/bash
src_lang_list=("bh" "ch" "mg")
exp_dir=../indic-en-exp

for src_lang in "${src_lang_list[@]}"
do

    echo `date`
    infname=../indic-en-exp/devtest/all/$src_lang-en/test.$src_lang #$1      # input file name  
    outfname=../indic-en-exp/devtest/bin/$src_lang-en/test.$src_lang #$2     # ../indic-en-exp/devtestt/all/XX-en/test.XX
    infname_tgt=../indic-en-exp/devtest/all/$src_lang-en/test.en
    outfname_tgt=../indic-en-exp/devtest/bin/$src_lang-en/test.en
    src_lang=$src_lang #$3     #
    tgt_lang=en#$4     #
    model_name=$5   #
    exp_dir=../indic-en-exp   #$5
    #ref_fname=$6
    mkdir -p $(dirname $outfname)

    SRC_PREFIX='SRC'
    TGT_PREFIX='TGT'

    #`dirname $0`/env.sh
    SUBWORD_NMT_DIR='subword-nmt'
    ### normalization and script conversion

    echo "Applying normalization and script conversion"
    input_size=`python scripts/preprocess_translate.py $infname $outfname.norm hi true`
    input_size=`python scripts/preprocess_translate.py $infname_tgt $outfname_tgt.norm en true`
    echo "Number of sentences in input: $input_size"

    ### apply BPE to input file

    echo "Applying BPE"
    python $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py \
        -c $exp_dir/vocab/bpe_codes.32k.${SRC_PREFIX} \
        --vocabulary $exp_dir/vocab/vocab.$SRC_PREFIX \
        --vocabulary-threshold 5 \
        < $outfname.norm \
        > $outfname.bpe
    mv $outfname.bpe ../indic-en-exp/devtest/bin/$src_lang-en/test.SRC

    python $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py \
        -c $exp_dir/vocab/bpe_codes.32k.${TGT_PREFIX} \
        --vocabulary $exp_dir/vocab/vocab.$TGT_PREFIX \
        --vocabulary-threshold 5 \
        < $outfname_tgt.norm \
        > $outfname_tgt.bpe
    mv $outfname_tgt.bpe ../indic-en-exp/devtest/bin/$src_lang-en/test.TGT
done