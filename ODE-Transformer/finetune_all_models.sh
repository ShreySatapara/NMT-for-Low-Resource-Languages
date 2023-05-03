declare -A model_dict
#model_dict[RK2-learnbale-layer3-base-Hi2En]=ode_transformer_3_layer
#model_dict[RK2-learnbale-layer6-base-Hi2En]=ode_transformer
#model_dict[RK2-learnbale-transformer-big-Hi2En]=ode_relative_transformer_t2t_wmt_en_de_big
model_dict[RK2-learnbale-layer3-base-Hi2En-big]=ode_transformer_3_layer #_big

#declare -A checkp_dir

#checkp_dir[IndicHi2En_en_bh_last_checkpoint]=checkpoint_last.pt
#checkp_dir[IndicHi2En_en_bh_best_checkpoint]=checkpoint_best.pt
#! /usr/bin/bash
set -e

#device=0
device=1


task_data=IndicHi2En_bh_en_finetuning

# must set this tag

criterion=label_smoothed_cross_entropy
fp16=1
lr=0.0005
warmup=4000
max_tokens=512
update_freq=1
keep_last_epochs=10
max_epoch=20
data_dir=final_bin
src_lang=SRC
tgt_lang=TGT

data_size=("final_100")
#"final_250" "final_500")


gpu_num=1

for ds in "${data_size[@]}"
do 

    for key in "${!model_dict[@]}"
    do
        task=$task_data/$ds
        save_dir=checkpoints/$task/$key

        if [ ! -d $save_dir ]; then
                mkdir -p $save_dir
        fi
        cp ${BASH_SOURCE[0]} $save_dir/train.sh
        tag=$key
        arch=${model_dict[$key]}
        cp checkpoints/IndicHi2En/$key/checkpoint_best.pt $save_dir/checkpoint_best.pt
        cmd="python3 -u train.py data_bin/IndicHi2En_bh-en/$ds
        --reset-lr-scheduler
        --reset-optimizer
        --distributed-world-size $gpu_num -s $src_lang -t $tgt_lang
        --arch $arch
        --train-subset valid
        --restore-file checkpoint_best.pt
        --optimizer adam --clip-norm 1.0
        --lr-scheduler inverse_sqrt --warmup-init-lr 1e-07 --warmup-updates $warmup
        --lr $lr --min-lr 1e-09
        --criterion $criterion --label-smoothing 0.1
        --max-tokens $max_tokens
        --update-freq $update_freq
        --rk-type learnable
        --enc-calculate-num 2
        --encoder-layers 6
        --decoder-layers 6
        --no-progress-bar
        --log-interval 100
        --seed 1
        --save-dir $save_dir
        --keep-last-epochs 1
        --tensorboard-logdir $save_dir
        --fp16
        --adam-betas '(0.9, 0.997)'
        --max-epoch 25
        --dropout 0.2
        "


        export CUDA_VISIBLE_DEVICES=$device
        cmd="nohup "${cmd}" > $save_dir/train.log 2>&1 &"
        eval $cmd
        tail -f $save_dir/train.log
        
    done


done




