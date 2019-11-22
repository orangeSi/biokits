## biokits

### falength: output every sequence length for fasta format file
```
$cat ref.fa
>c1
ATCGA
>c2
ATCG

$./falength ref.fa.gz
5	c1
4	c2

$./falength ref.fa
5	c1
4	c2

# read data from stdin by pipe
$head -2 ref.fa|./falength -
5	c1

$ldd falength
	statically linked
```
