dataset_size=("final_100_bin" "final_250_bin" "final_500_bin")
model_list=("transformer_4x" "transformer_big" "transformer_3_layer" "transformer")
for model in "${model_list[@]}"
do 
    for data_size in "${dataset_size[@]}"
    do 
        mkdir -p ../indic-en-exp/finetuned_models/$data_size
        mkdir ../indic-en-exp/finetuned_models/$data_size/logs
        mkdir ../indic-en-exp/finetuned_models/$data_size/tensorboard
        CUDA_VISIBLE_DEVICES=2 fairseq-train ../indic-en-exp/floras_200_test/$data_size \
            --restore-file ../indic-en-exp/$model/checkpoint_best.pt \
            --train-subset train \
            --max-source-positions=210 \
            --max-target-positions=210 \
            --save-interval=1 \
            --arch=$model \
            --criterion=label_smoothed_cross_entropy \
            --source-lang=SRC \
            --lr-scheduler=inverse_sqrt \
            --target-lang=TGT \
            --label-smoothing=0.1 \
            --optimizer adam \
            --adam-betas "(0.9, 0.98)" \
            --clip-norm 1.0 \
            --warmup-init-lr 1e-07 \
            --lr 0.0005 \
            --warmup-updates 4000 \
            --dropout 0.2 \
            --save-dir ../indic-en-exp/finetuned_models/$data_size/$model \
            --keep-last-epochs 2 \
            --patience 3 \
            --skip-invalid-size-inputs-valid-test \
            --fp16 \
            --user-dir model_configs \
            --distributed-world-size 1 \
            --max-tokens 512 \
            --log-interval 10 \
            --log-file ../indic-en-exp/finetuned_models/$data_size/logs/$model.log \
            --tensorboard-logdir ../indic-en-exp/finetuned_models/$data_size/tensorboard/ \
            --max-epoch 5 \
            --reset-lr-scheduler \
            --reset-meters \
            --reset-dataloader \
            --reset-optimizer 
    done
    
done

