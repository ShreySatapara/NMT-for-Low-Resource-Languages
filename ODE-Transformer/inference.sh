#!/usr/bin/bash
set -e
#model_dir_list=("RK2-learnbale-layer3-base-Hi2En" "RK2-learnbale-layer6-base-Hi2En" "RK2-learnbale-layer3-base-Hi2En" "RK2-learnbale-transformer-big-Hi2En")
model_dir_list=("RK2-learnbale-layer3-base-Hi2En")
src_lang_list=("hi" "bh" "ch" "mg")
model_root_dir=checkpoints

gpu=4
cpu=

who=test
data_dir=$task
batch_size=64
beam=5
length_penalty=0.6
src_lang=SRC
tgt_lang=TGT
sacrebleu_set=wmt14/full
checkpoint=checkpoint_last.pt
if [ -n "$cpu" ]; then
        use_cpu=--cpu
fi

export CUDA_VISIBLE_DEVICES=$gpu
#data_size=("final_100" "final_250" "final_500")
#src_lang=bh
for model_dir_tag in "${model_dir_list[@]}"
do
        for src_lang in "${src_lang_list[@]}"
        do
                echo "#################################################################################################"
                echo `date`
                echo "Inference for $model_dir_tag on $src_lang-en"
                task=IndicHi2En_noisy
                model_dir=$model_root_dir/noisy/$task/$model_dir_tag
                output=translations/$model_dir/last_checkpt/$src_lang-en/translation.log
                output_dir=translations/$model_dir/$src_lang-en
                mkdir -p $(dirname $output)
                python3 generate.py \
                        data_bin/IndicHi2En \
                        --path $model_dir/$checkpoint \
                        --gen-subset $who \
                        --batch-size $batch_size \
                        --beam $beam \
                        --lenpen $length_penalty \
                        --output $output_dir/hypo.txt \
                        --quiet \
                        --remove-bpe $use_cpu | tee $output

                python3 fix_output_for_scarebleu.py $output_dir/hypo.txt $output_dir/generated.txt

                #ref_fname=../indic-en-exp/devtest/all/$src_lang-en/test.en
                #pred_fname=$output_dir/generated.txt

                #sacrebleu $ref_fname < $pred_fname >> $pred_fname.score -m bleu chrf ter
        done
done




# set task

# set tag

# set device


# data set






