#! /usr/bin/bash
set -e

#device=0
device=7,4,3

task=IndicHi2En_noisy
# must set this tag
tag=RK2-learnbale-layer3-base-Hi2En


arch=ode_transformer_3_layer
criterion=label_smoothed_cross_entropy
fp16=1
lr=0.0005
warmup=4000
max_tokens=4096
update_freq=1
keep_last_epochs=3
max_epoch=20
data_dir=final_bin
src_lang=SRC
tgt_lang=TGT


save_dir=checkpoints/noisy/$task/$tag

if [ ! -d $save_dir ]; then
        mkdir -p $save_dir
fi
cp ${BASH_SOURCE[0]} $save_dir/train.sh

gpu_num=3
echo $save_dir
cmd="python3 -u train.py data_bin/noisy/IndicHi2En
  --distributed-world-size $gpu_num -s $src_lang -t $tgt_lang
  --arch $arch
  --optimizer adam --clip-norm 1.0
  --lr-scheduler inverse_sqrt --warmup-init-lr 1e-07 --warmup-updates $warmup
  --lr $lr --min-lr 1e-09
  --criterion $criterion --label-smoothing 0.1
  --max-tokens $max_tokens
  --update-freq $update_freq
  --rk-type learnable
  --enc-calculate-num 2
  --no-progress-bar
  --log-interval 100
  --seed 1
  --save-dir $save_dir
  --keep-last-epochs 5
  --tensorboard-logdir $save_dir
  --fp16
  --adam-betas '(0.9, 0.997)'
  --max-epoch 20
  --dropout 0.2
  "


export CUDA_VISIBLE_DEVICES=$device
cmd="nohup "${cmd}" > $save_dir/train.log 2>&1 &"
eval $cmd
tail -f $save_dir/train.log
