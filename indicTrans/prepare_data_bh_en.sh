exp_dir=$1  #../indic-en-exp/floras_200_test
src_lang=$2 #bh
tgt_lang=$3 #en

#train_data_dir=${4:-"$exp_dir/output"}
devtest_data_dir=${5:-"$exp_dir"}

echo "Running experiment ${exp_dir} on ${src_lang} to ${tgt_lang}"

train_processed_dir=$exp_dir/data 
devtest_processed_dir=$exp_dir/data

out_data_dir=$exp_dir/final_bin

mkdir -p $train_processed_dir
mkdir -p $devtest_processed_dir
mkdir -p $out_data_dir

# # train preprocessing
# train_infname_src=$train_data_dir/train.$src_lang
# train_infname_tgt=$train_data_dir/train.$tgt_lang
# train_outfname_src=$train_processed_dir/train.SRC
# train_outfname_tgt=$train_processed_dir/train.TGT
# echo "Applying normalization and script conversion for train"
# input_size=`python scripts/preprocess_translate.py $train_infname_src $train_outfname_src hi`
# input_size=`python scripts/preprocess_translate.py $train_infname_tgt $train_outfname_tgt $tgt_lang`
# echo "Number of sentences in train: $input_size"

# dev preprocessing
dev_infname_src=$devtest_data_dir/dev.$src_lang
dev_infname_tgt=$devtest_data_dir/dev.$tgt_lang
dev_outfname_src=$devtest_processed_dir/dev.SRC
dev_outfname_tgt=$devtest_processed_dir/dev.TGT
echo "Applying normalization and script conversion for dev"
input_size=`python scripts/preprocess_translate.py $dev_infname_src $dev_outfname_src hi`
input_size=`python scripts/preprocess_translate.py $dev_infname_tgt $dev_outfname_tgt $tgt_lang`
echo "Number of sentences in dev: $input_size"

# test preprocessing
test_infname_src=$devtest_data_dir/test.$src_lang
test_infname_tgt=$devtest_data_dir/test.$tgt_lang
test_outfname_src=$devtest_processed_dir/test.SRC
test_outfname_tgt=$devtest_processed_dir/test.TGT
echo "Applying normalization and script conversion for test"
input_size=`python scripts/preprocess_translate.py $test_infname_src $test_outfname_src hi`
input_size=`python scripts/preprocess_translate.py $test_infname_tgt $test_outfname_tgt $tgt_lang`
echo "Number of sentences in test: $input_size"

echo "Learning bpe. This will take a very long time depending on the size of the dataset"
echo `date`
# learn bpe for preprocessed_train files
#bash learn_bpe.sh $exp_dir
#echo `date`

####################
echo "Applying bpe"
bash apply_single_bpe_traindevtest_notag.sh $exp_dir
#########################


mkdir -p $exp_dir/final


# this is only required for joint training
# echo "Adding language tags"
# python scripts/add_tags_translate.py $outfname._bpe $outfname.bpe $src_lang $tgt_lang

# this is imporatnt step if you are training with tpu and using num_batch_buckets
# the currnet implementation does not remove outliers before bucketing and hence
# removing these large sentences ourselves helps with getting better buckets
#python scripts/remove_large_sentences.py $exp_dir/bpe/train.SRC $exp_dir/bpe/train.TGT $exp_dir/final/train.SRC $exp_dir/final/train.TGT
python scripts/remove_large_sentences.py $exp_dir/bpe/dev.SRC $exp_dir/bpe/dev.TGT $exp_dir/final/dev.SRC $exp_dir/final/dev.TGT
python scripts/remove_large_sentences.py $exp_dir/bpe/test.SRC $exp_dir/bpe/test.TGT $exp_dir/final/test.SRC $exp_dir/final/test.TGT

echo "Binarizing data"
exp_dir=$1  #../indic-en-exp/data_for_finetuning
src_lang=$2 #SRC
tgt_lang=$3 #TGT
input_dir=$4
output_dir=$5
# use cpu_count to get num_workers instead of setting it manually when running in different
# instances
num_workers=`python -c "import multiprocessing; print(multiprocessing.cpu_count())"`

data_dir=$exp_dir/$input_dir
out_data_dir=$exp_dir/$output_dir


rm -rf $out_data_dir

fairseq-preprocess \
    --source-lang SRC --target-lang TGT \
    --trainpref $data_dir/train \
    --validpref $data_dir/dev \
    --testpref $data_dir/test \
    --destdir $out_data_dir \
    --workers $num_workers \
    --thresholdtgt 5 \
    --thresholdsrc 5 \
    --srcdict ../indic-en-exp/final_bin/dict.SRC.txt \
    --tgtdict ../indic-en-exp/final_bin/dict.TGT.txt
#--trainpref $data_dir/train \

