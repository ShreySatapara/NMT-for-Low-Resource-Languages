TEXT=$1
python preprocess.py --source-lang hi --target-lang en \
  --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
  --destdir $TEXT/data_bin --bert-model-name bert-base-multilingual-uncased --workers 32