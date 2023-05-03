#bash joint_translate.sh ../indic-en-exp/devtest/all/en-hi/test.hi ../indic-en-exp/generated/vanilla_model/hi_en/hi_en_outputs.txt 'hi' 'en' vanilla_model
#bash compute_bleu.sh ../indic-en-exp/generated/vanilla_model/hi_en/hi_en_outputs.txt ../indic-en-exp/devtest/all/en-hi/test.en 'hi' 'en'

bash joint_translate.sh ../indic-en-exp/devtest/all/en-hi/test.hi ../indic-en-exp/generated/vanilla_model_3_layer/hi_en/hi_en_outputs.txt 'hi' 'en' vanilla_model_3_layer
bash compute_bleu.sh ../indic-en-exp/generated/vanilla_model_3_layer/hi_en/hi_en_outputs.txt ../indic-en-exp/devtest/all/en-hi/test.en 'hi' 'en'

bash joint_translate.sh ../indic-en-exp/devtest/all/en-hi/test.hi ../indic-en-exp/generated/4x_vanilla_model/hi_en/hi_en_outputs.txt 'hi' 'en' 4x_vanilla_model
bash compute_bleu.sh ../indic-en-exp/generated/4x_vanilla_model/hi_en/hi_en_outputs.txt ../indic-en-exp/devtest/all/en-hi/test.en 'hi' 'en'


bash joint_translate.sh ../indic-en-exp/devtest/all/bh-en/test.bh ../indic-en-exp/generated/vanilla_model/bh-en/bh_en_outputs.txt 'hi' 'en' vanilla_model
bash compute_bleu.sh ../indic-en-exp/generated/vanilla_model/bh-en/bh_en_outputs.txt ../indic-en-exp/devtest/all/bh-en/test.en 'hi' 'en'


model_list=("vanilla_model","vanilla_model_3_layer","4x_vanilla_model")
src_lang_list=("bh","ch","mg")
for model in "${model_list[@]}"
do
    for src_lang in "${src_lang_list[@]}"
    do
        echo $model 
        echo $src_lang
    done
done