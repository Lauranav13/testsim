
if ["$#" -eq 1 ]
then

	sampleid=$1

#Remove the adapters
	mkdir -p out/cutadapt
	mkdir -p log/cutadapt
	echo "Running cutadapt..."
		-m 20 \
		-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
		-A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
		-o out/cutadapt/${sampleid}_1.trimmed.fastq.gz \
		-p out/cutadapt/${sampleid}_2.trimmed.fastq.gz \
		data/${sampleid}_1.fastq.gz data/${sampleid}_2.fastq.gz > log/cutadapt/${sampleid}.log

#Index the genome
	mkdir -p res/genome/star_index
	echo " Running STAR index"
		--runThreadN 8 --runMode genomeGenerate \
		--genomeDir res/genome/star_index/ \
		--genomeFastaFiles res/genome/ecoli.fasta \
		--genomeSAindexNbases 9

#Align the adapter-free reads
	mkdir -p out/star/${sampleid}
	echo "Running STAR"
		--runThreadN 4 --genomeDir res/genome/star_index/ \
		--readFilesIn out/cutadapt/${sampleid}_1.trimmed.fastq.gz out/cutadapt/${sampleid}_2.trimmed.fastq.gz \
		--readFilesCommand zcat \
		--outFileNamePrefix out/star/${sampleid}/
else
	echo "Ussage: $0 <sampleid>"
	exit 1
fi

