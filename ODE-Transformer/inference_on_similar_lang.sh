similar_lang_list=("hi" "bh" "ch" "mg")

src_lang=bh
src=SRC
tgt=TGT
TEXT=../indic-en-exp/devtest/all/src_lang-en

#NORMALIZE and BPE using indicTrans and BINARIZE using ODE



tag=IndicHi2En
output=data-bin/$tag


python3 preprocess.py --source-lang $src --target-lang $tgt --testpref $TEXT/test --destdir $output --workers 32
