#!/usr/bin/env bash
exp_dir=$1
src_lng=$2
tgt_lng=$3
echo "src lng $src_lng"
for sub  in train valid test
do
    sed -r 's/(@@ )|(@@ ?$)//g' $exp_dir/${sub}.${src_lng} > ${sub}.bert.${src_lng}.tok
    mosesdecoder/scripts/tokenizer/detokenizer.perl -l $src_lng < ${sub}.bert.${src_lng}.tok > $exp_dir/${sub}.bert.${src_lng}
    rm ${sub}.bert.${src_lng}.tok
done

echo "tgt lng $tgt_lng"
for sub  in train valid test
do
    sed -r 's/(@@ )|(@@ ?$)//g' $exp_dir/${sub}.${tgt_lng} > ${sub}.bert.${tgt_lng}.tok
    mosesdecoder/scripts/tokenizer/detokenizer.perl -l $tgt_lng < ${sub}.bert.${tgt_lng}.tok > $exp_dir/${sub}.bert.${tgt_lng}
    rm ${sub}.bert.${tgt_lng}.tok
done