#!/bin/bash
set -e
set -x
DATA_DIR=data/BEA
if [ ! -d $DATA_DIR ]; then
        mkdir -p $DATA_DIR
fi
# paths to raw data files
NUCLE_DIR=path/to/NUCLE-3.2/release3.2
LANG8V2=path/to/lang-8-20111007-L1-v2.dat
FCE_DIR=path/to/fce
BEA_DIR=path/to/wi+locness

# path to scripts directories
M2_SCRIPTS=gec_scripts/m2_scripts/
MOSES_SCRIPTS=gec_scripts/moses_scripts/
LANG8_SCRIPTS=gec_scripts/lang-8_scripts/
NLTK_SCRIPTS=gec_scripts/nltk_scripts/

REPLACE_UNICODE=$MOSES_SCRIPTS/replace-unicode-punctuation.perl
REMOVE_NON_PRINT=$MOSES_SCRIPTS/remove-non-printing-char.perl
NORMALIZE_PUNCT=$MOSES_SCRIPTS/normalize-punctuation.perl

TOKENIZER="$NLTK_SCRIPTS/word-tokenize.py"

mkdir -p $DATA_DIR/tmp



# NUCLE
#########
echo "[`date`] Preparing NUCLE data..." >&2

mkdir -p $DATA_DIR/nucle-dev
mkdir -p $DATA_DIR/nucle-train
$M2_SCRIPTS/sort_m2.py  -i $NUCLE_DIR/data/conll14st-preprocessed.m2 \
                     -o $DATA_DIR/tmp/nucle.sort.m2 \
                     -m 1 --output-remaining-lines
$M2_SCRIPTS/get_num_lines.py    -i $DATA_DIR/tmp/nucle.sort.m2 \
                             --output_m2_prefix $DATA_DIR/tmp/nucle.split \
                             -n 4 \
                             --shuffle

cat $DATA_DIR/tmp/nucle.split.1.m2 > $DATA_DIR/nucle-dev/nucle-dev.m2
( cat $DATA_DIR/tmp/nucle.split.[234].m2 ; cat $DATA_DIR/tmp/nucle.sort.m2.rem ) > $DATA_DIR/tmp/nucle.combined.m2
$M2_SCRIPTS/get_num_lines.py -i $DATA_DIR/tmp/nucle.combined.m2 --output_m2_prefix $DATA_DIR/tmp/nucle-train -n 1 --shuffle
cat $DATA_DIR/tmp/nucle-train.1.m2 > $DATA_DIR/nucle-train/nucle-train.m2

$M2_SCRIPTS/convert_m2_to_parallel.py   $DATA_DIR/nucle-train/nucle-train.m2 \
                                     $DATA_DIR/nucle-train/nucle-train.tok.src \
                                     $DATA_DIR/nucle-train/nucle-train.tok.trg
$M2_SCRIPTS/convert_m2_to_parallel.py   $DATA_DIR/nucle-dev/nucle-dev.m2 \
                                     $DATA_DIR/nucle-dev/nucle-dev.tok.src \
                                     $DATA_DIR/nucle-dev/nucle-dev.tok.trg
# removing empty target sentence pairs
paste $DATA_DIR/nucle-dev/nucle-dev.tok.src $DATA_DIR/nucle-dev/nucle-dev.tok.trg | awk -F $'\t' '$2!=""' > $DATA_DIR/nucle-dev/nucle-dev.non_empty.tok.src-trg
cut $DATA_DIR/nucle-dev/nucle-dev.non_empty.tok.src-trg -f1 > $DATA_DIR/nucle-dev/nucle-dev.non_empty.tok.src
cut $DATA_DIR/nucle-dev/nucle-dev.non_empty.tok.src-trg -f2 > $DATA_DIR/nucle-dev/nucle-dev.non_empty.tok.trg
rm $DATA_DIR/nucle-dev/nucle-dev.non_empty.tok.src-trg

# LANG-8 v2
#############
# # Preparation of Lang-8 data
echo "[`date`] Preparing Lang-8 data... (NOTE:Can take several hours, due to LangID.py filtering...)" >&2
L2=English 				 # Learning language, i.e. extract only English learners text

mkdir -p $DATA_DIR/lang-8
mkdir -p $DATA_DIR/tmp
$LANG8_SCRIPTS/extract.py -i $LANG8V2 -o $DATA_DIR/tmp/ -l2 $L2
cat $DATA_DIR/tmp/lang-8-20111007-L1-v2.dat.processed | perl -p -e 's@\[sline\].*?\[\\/sline\]@@sg' | sed 's/\[\\\/sline\]//g' | sed 's/\[\\\/f-[a-zA-Z]*\]//g' | sed 's/\[f-[a-zA-Z]*\]//g' | sed 's/rŠëyËb¢{//g' > $DATA_DIR/tmp/lang-8.$L2.cleanedup
rm $DATA_DIR/tmp/lang-8-20111007-L1-v2.dat.processed
$LANG8_SCRIPTS/langidfilter.py $DATA_DIR/tmp/lang-8.$L2.cleanedup > $DATA_DIR/tmp/lang-8.$L2.extracted
rm $DATA_DIR/tmp/lang-8.$L2.cleanedup
$LANG8_SCRIPTS/get_parallel.py -i $DATA_DIR/tmp/lang-8.$L2.extracted -o lang-8 -d $DATA_DIR/tmp/lang-8/

for EXT in src trg; do
    cat $DATA_DIR/tmp/lang-8/lang-8.$EXT | $REPLACE_UNICODE | $REMOVE_NON_PRINT | sed  's/\\"/\"/g' | sed 's/\\t/ /g' | $NORMALIZE_PUNCT |  $TOKENIZER  > $DATA_DIR/lang-8/lang-8.tok.$EXT
done

# FCE
echo "[`date`] Preparing FCE data..." >&2

mkdir -p $DATA_DIR/fce-dev
mkdir -p $DATA_DIR/fce-train

$M2_SCRIPTS/convert_m2_to_parallel.py   $FCE_DIR/m2/fce.train.gold.bea19.m2 \
                                     $DATA_DIR/fce-train/fce-train.tok.src \
                                     $DATA_DIR/fce-train/fce-train.tok.trg
$M2_SCRIPTS/convert_m2_to_parallel.py   $FCE_DIR/m2/fce.dev.gold.bea19.m2 \
                                     $DATA_DIR/fce-dev/fce-dev.tok.src \
                                     $DATA_DIR/fce-dev/fce-dev.tok.trg
# removing empty target sentence pairs
paste $DATA_DIR/fce-dev/fce-dev.tok.src $DATA_DIR/fce-dev/fce-dev.tok.trg | awk -F $'\t' '$2!=""' > $DATA_DIR/fce-dev/fce-dev.non_empty.tok.src-trg
cut $DATA_DIR/fce-dev/fce-dev.non_empty.tok.src-trg -f1 > $DATA_DIR/fce-dev/fce-dev.non_empty.tok.src
cut $DATA_DIR/fce-dev/fce-dev.non_empty.tok.src-trg -f2 > $DATA_DIR/fce-dev/fce-dev.non_empty.tok.trg
rm $DATA_DIR/fce-dev/fce-dev.non_empty.tok.src-trg



# BEA
echo "[`date`] Preparing BEA data..." >&2

mkdir -p $DATA_DIR/bea-dev
mkdir -p $DATA_DIR/bea-train

$M2_SCRIPTS/convert_m2_to_parallel.py   $BEA_DIR/m2/ABC.train.gold.bea19.m2 \
                                     $DATA_DIR/bea-train/bea-train.tok.src \
                                     $DATA_DIR/bea-train/bea-train.tok.trg
$M2_SCRIPTS/convert_m2_to_parallel.py   $BEA_DIR/m2/ABCN.dev.gold.bea19.m2 \
                                     $DATA_DIR/bea-dev/bea-dev.tok.src \
                                     $DATA_DIR/bea-dev/bea-dev.tok.trg
# removing empty target sentence pairs
paste $DATA_DIR/bea-dev/bea-dev.tok.src $DATA_DIR/bea-dev/bea-dev.tok.trg | awk -F $'\t' '$2!=""' > $DATA_DIR/bea-dev/bea-dev.non_empty.tok.src-trg
cut $DATA_DIR/bea-dev/bea-dev.non_empty.tok.src-trg -f1 > $DATA_DIR/bea-dev/bea-dev.non_empty.tok.src
cut $DATA_DIR/bea-dev/bea-dev.non_empty.tok.src-trg -f2 > $DATA_DIR/bea-dev/bea-dev.non_empty.tok.trg
rm $DATA_DIR/bea-dev/bea-dev.non_empty.tok.src-trg


# Preparing the concatenated training data.
mkdir -p $DATA_DIR/concat-train
cat $DATA_DIR/nucle-train/nucle-train.tok.src $DATA_DIR/lang-8/lang-8.tok.src $DATA_DIR/fce-train/fce-train.tok.src $DATA_DIR/bea-train/bea-train.tok.src > $DATA_DIR/concat-train/concat-train.tok.src
cat $DATA_DIR/nucle-train/nucle-train.tok.trg $DATA_DIR/lang-8/lang-8.tok.trg $DATA_DIR/fce-train/fce-train.tok.trg $DATA_DIR/bea-train/bea-train.tok.trg > $DATA_DIR/concat-train/concat-train.tok.trg
mkdir -p $DATA_DIR/concat-train/cleaned/
$MOSES_SCRIPTS/clean-corpus-n.perl $DATA_DIR/concat-train/concat-train.tok src trg $DATA_DIR/concat-train/cleaned/concat-train.clean.tok 1 80



ln -s $DATA_DIR/concat-train/cleaned/concat-train.clean.tok.src train.tok.src
ln -s $DATA_DIR/concat-train/cleaned/concat-train.clean.tok.trg train.tok.trg
ln -s $DATA_DIR/nucle-dev/nucle-dev.non_empty.tok.src dev.tok.src
ln -s $DATA_DIR/nucle-dev/nucle-dev.non_empty.tok.trg dev.tok.trg
ln -s $DATA_DIR/nucle-dev/nucle-dev.tok.src dev.all.tok.src
ln -s $DATA_DIR/nucle-dev/nucle-dev.m2 dev.all.m2

