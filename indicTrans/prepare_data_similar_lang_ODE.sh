src_lang_list=("hi" "bh" "ch" "mg")
#src_lang_list=("bh")
exp_dir=../ODE-Transformer
tgt_lang=en

for src_lang in "${src_lang_list[@]}"
do

    devtest_data_dir=../indic-en-exp/devtest/all/$src_lang-en

    echo "Running experiment ${exp_dir} on ${src_lang} to ${tgt_lang}"

    devtest_processed_dir=$exp_dir/testset/$src_lang-en/data

    out_data_dir=$exp_dir/testset/$src_lang-en/final_bin

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
    bash apply_single_bpe_traindevtest_notag.sh $exp_dir $src_lang
    #########################


    mkdir -p $exp_dir/testset/$src_lang-en/final


    # this is only required for joint training
    # echo "Adding language tags"
    # python scripts/add_tags_translate.py $outfname._bpe $outfname.bpe $src_lang $tgt_lang

    # this is imporatnt step if you are training with tpu and using num_batch_buckets
    # the currnet implementation does not remove outliers before bucketing and hence
    # removing these large sentences ourselves helps with getting better buckets
    #python scripts/remove_large_sentences.py $exp_dir/testset/$src_lang-en/bpe/train.SRC $exp_dir/testtset/$src_lang-en/bpe/train.TGT $exp_dir/$src_lang-en/final/train.SRC $exp_dir/$src_lang-en/final/train.TGT
    python scripts/remove_large_sentences.py $exp_dir/testset/$src_lang-en/bpe/dev.SRC $exp_dir/testset/$src_lang-en/bpe/dev.TGT $exp_dir/testset/$src_lang-en/final/dev.SRC $exp_dir/testset/$src_lang-en/final/dev.TGT
    python scripts/remove_large_sentences.py $exp_dir/testset/$src_lang-en/bpe/test.SRC $exp_dir/testset/$src_lang-en/bpe/test.TGT $exp_dir/testset/$src_lang-en/final/test.SRC $exp_dir/testset/$src_lang-en/final/test.TGT

    # echo "Binarizing data"
    # exp_dir=$1  #../indic-en-exp/data_for_finetuning
    # src_lang=$2 #SRC
    # tgt_lang=$3 #TGT
    # input_dir=$4
    # output_dir=$5
    # # use cpu_count to get num_workers instead of setting it manually when running in different
    # # instances
    # num_workers=`python -c "import multiprocessing; print(multiprocessing.cpu_count())"`

    # data_dir=$exp_dir/$input_dir
    # out_data_dir=$exp_dir/$output_dir


    # rm -rf $out_data_dir

    # fairseq-preprocess \
    #     --source-lang SRC --target-lang TGT \
    #     --trainpref $data_dir/train \
    #     --validpref $data_dir/dev \
    #     --testpref $data_dir/test \
    #     --destdir $out_data_dir \
    #     --workers $num_workers \
    #     --thresholdtgt 5 \
    #     --thresholdsrc 5 \
    #     --srcdict ../ODE-Transformer/data_bin//dict.SRC.txt \
    #     --tgtdict ../ODE-Transformer/data_bin//dict.TGT.txt
    # #--trainpref $data_dir/train \

done

