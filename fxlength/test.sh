set -v
cat ref.fa
zcat ref.fa.gz
zcat demo.fq.gz

./fxlength demo.fq.gz
./fxlength ref.fa
./fxlength ref.fa.gz

zcat demo.fq.gz|./fxlength -
cat ref.fa|./fxlength -
zcat ref.fa.gz|./fxlength -
