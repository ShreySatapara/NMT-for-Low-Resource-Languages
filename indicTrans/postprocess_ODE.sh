model_dir_list=("RK2-learnbale-layer6-base-Hi2En" "RK2-learnbale-layer3-base-Hi2En" "RK2-learnbale-transformer-big-Hi2En")
#model_dir_list=("RK2-learnbale-transformer-big-Hi2En")
src_lang_list=("hi" "bh" "ch" "mg")
base_path=../ODE-Transformer/translations/checkpoints/IndicHi2En
for model_dir_tag in "${model_dir_list[@]}"
do
        for src_lang in "${src_lang_list[@]}"
        do
            infname=$base_path/$model_dir_tag/$src_lang-en/generated.txt
            outfname=$base_path/$model_dir_tag/$src_lang-en/generated.txt
            tgt_output_fname=$base_path/$model_dir_tag/$src_lang-en/translated.txt
            tgt_output_path=$base_path/$model_dir_tag/$src_lang-en
            input_size=`python scripts/preprocess_translate.py $infname $outfname.norm hi true`
            echo $input_size
            python scripts/postprocess_translate.py $tgt_output_path/translation.log $tgt_output_fname $input_size en true

        done
done


