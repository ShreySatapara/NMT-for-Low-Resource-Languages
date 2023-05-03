#!/usr/bin/env bash
nvidia-smi

#cd /yourpath/bertnmt
python3 -c "import torch; print(torch.__version__)"
exp_dir=$1
src=hi
tgt=en
bedropout=0.5
ARCH=transformer
DATAPATH=$exp_dir/data_bin
SAVEDIR=checkpoints/$exp_dir
mkdir -p $SAVEDIR
if [ ! -f $SAVEDIR/checkpoint_nmt.pt ]
then
    cp /your_pretrained_nmt_model $SAVEDIR/checkpoint_nmt.pt
fi
if [ ! -f "$SAVEDIR/checkpoint_last.pt" ]
then
warmup="--warmup-from-nmt --reset-lr-scheduler"
else
warmup=""
fi

export CUDA_VISIBLE_DEVICES=${2:-0,5,6,7}
python train.py $DATAPATH \
    -a $ARCH --optimizer adam --lr 0.0005 -s $src -t $tgt --label-smoothing 0.1 --max-source-positions 210 --max-target-positions 210\
    --dropout 0.2 --max-tokens 8192 --min-lr '1e-09' --lr-scheduler inverse_sqrt --weight-decay 0.0001 \
    --criterion label_smoothed_cross_entropy --warmup-updates 4000 --warmup-init-lr '1e-07' \
    --adam-betas '(0.9,0.98)' --save-dir $SAVEDIR --update-freq 4 --ddp-backend=no_c10d --keep-last-epochs 2 \
    --encoder-bert-dropout --encoder-bert-dropout-ratio $bedropout --distributed-world-size 4 --fp16 --max-epoch 15 \
    --bert-model-name bert-base-multilingual-uncased | tee -a $SAVEDIR/training.log