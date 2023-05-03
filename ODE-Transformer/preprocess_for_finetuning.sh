data_size=("final_100" "final_250" "final_500")
#src_lang_list=("bh" "ch" "mg" "hi")
#src_lang_list=("bh")
#exp_dir=testset


for ds in "${data_size[@]}"
do
    #echo $src_lang
    src=SRC
    tgt=TGT
    TEXT=../indic-en-exp/floras_200_test/$ds #testset/$src_lang-en/final
    tag=IndicHi2En_bh-en/$ds
    output=data_bin/$tag
    mkdir $output

    python3 preprocess.py --source-lang $src --target-lang $tgt --srcdict data_bin/IndicHi2En/dict.SRC.txt --tgtdict data_bin/IndicHi2En/dict.TGT.txt --trainpref $TEXT/train --validpref $TEXT/dev --testpref $TEXT/test --destdir $output --workers 32
    #python3 preprocess.py --source-lang $src --target-lang $tgt --srcdict data_bin/IndicHi2En/dict.SRC.txt --tgtdict data_bin/IndicHi2En/dict.TGT.txt --trainpref $TEXT/dev --testpref $TEXT/ --destdir $output --workers 32

done