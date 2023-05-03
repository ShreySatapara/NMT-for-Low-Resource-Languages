model_list=("transformer" "transformer_3_layer" "transformer_4x" "transformer_big")
#model_list=("transformer_big")
#dataset_size=("final_100_bin" "final_250_bin" "final_500_bin")
#model_list=("big_vanilla_model")
src_lang_list=("hi" "bh" "ch" "mg")
#src_lang_list=("bh")
#src_lang_list=("ch" "mg")
data_size=zero_shot
for model in "${model_list[@]}"
do

    #for data_size in "${dataset_size[@]}"
    #do
            for src_lang in "${src_lang_list[@]}"
                do
                    echo "#########################################################"
                    echo "Translation for $model and $src_lang-en"
                    bash joint_translate.sh ../indic-en-exp/devtest/all/$src_lang-en/test.$src_lang ../indic-en-exp/generated/$data_size/$model/$src_lang-en/$src_lang-en_outputs.txt 'hi' 'en' $model
                    bash compute_bleu.sh ../indic-en-exp/generated/$data_size/$model/$src_lang-en/$src_lang-en_outputs.txt ../indic-en-exp/devtest/all/$src_lang-en/test.en 'hi' 'en'
                    echo "#########################################################"
                done
    #done
done