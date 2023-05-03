src=SRC
tgt=TGT
TEXT=../hi-en_noisy/final
tag=IndicHi2En
output=data_bin/noisy/$tag


python3 preprocess.py --source-lang $src --target-lang $tgt --trainpref $TEXT/train  --validpref $TEXT/dev --testpref $TEXT/test --destdir $output --workers 32
