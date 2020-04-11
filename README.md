## biokits

### fxlength: output every sequence length for fasta/fastq format file
```
$cat ref.fa
>c1
ATCGA
>c2
ATCG

$zcat ref.fa.gz
>c1
ATCGA
>c2
ATCG

$zcat demo.fq.gz
@fqid1
ATCG
+
9999
@fqid2
ATCGC
+
99999

$./fxlength demo.fq.gz
4	fqid1
5	fqid2
$./fxlength ref.fa
5	c1
4	c2
$./fxlength ref.fa.gz
5	c1
4	c2

$zcat demo.fq.gz|./fxlength -
4	fqid1
5	fqid2
$cat ref.fa|./fxlength -
5	c1
4	c2
$zcat ref.fa.gz|./fxlength -
5	c1
4	c2


$ldd fxlength
	not a dynamic executable
```
