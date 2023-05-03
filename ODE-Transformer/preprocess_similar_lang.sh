src_lang_list=("bh" "ch" "mg" "hi")
#src_lang_list=("bh")
exp_dir=testset


for src_lang in "${src_lang_list[@]}"
do
    echo $src_lang
    src=SRC
    tgt=TGT
    TEXT=testset/$src_lang-en/final
    tag=IndicHi2En_$src_lang-en
    output=data_bin/$tag
    mkdir $output

    python3 preprocess.py --source-lang $src --target-lang $tgt --srcdict data_bin/IndicHi2En/dict.SRC.txt --tgtdict data_bin/IndicHi2En/dict.TGT.txt --validpref $TEXT/dev --testpref $TEXT/test --destdir $output --workers 32
    #python3 preprocess.py --source-lang $src --target-lang $tgt --srcdict data_bin/IndicHi2En/dict.SRC.txt --tgtdict data_bin/IndicHi2En/dict.TGT.txt --trainpref $TEXT/dev --testpref $TEXT/ --destdir $output --workers 32

done