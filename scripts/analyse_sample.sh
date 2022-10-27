
export WD=$(pwd)
cd $WD

#FastQC
	mkdir out/fastqc
	fastqc -o out/fastqc data/*.fastq.gz

	cd $WD/data
	mkdir original
	mv *.fastq.gz original

#Ecoli Genome
	mkdir -p res/genome
	wget -O res/genome/ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz

#Remove the adapters
	mkdir -p out/cutadapt
	mkdir -p log/cutadapt
	echo "Running cutadapt..."
		-m 20 \
		-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
		-A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
		-o out/cutadapt/ERR2868172_1.trimmed.fastq.gz \
		-p out/cutadapt/ERR2868172_2.trimmed.fastq.gz \
		data/ERR2868172_1.fastq.gz data/ERR2868172_2.fastq.gz > log/cutadapt/ERR2868172.log

#Index the genome
	mkdir -p res/genome/star_index
	echo " Running STAR index"
		--runThreadN 8 --runMode genomeGenerate \
		--genomeDir res/genome/star_index/ \
		--genomeFastaFiles res/genome/ecoli.fasta \
		--genomeSAindexNbases 9

#Align the adapter-free reads
	mkdir -p out/star/ERR2868172
	echo "Running STAR"
		--runThreadN 4 --genomeDir res/genome/star_index/ \
		--readFilesIn out/cutadapt/ERR2868172_1.trimmed.fastq.gz out/cutadapt/ERR2868172_2.trimmed.fastq.gz \
		--readFilesCommand zcat \
		--outFileNamePrefix out/star/ERR2868172/
#Generate a report
	echo "Running multiqc"
	multiqc -o out/multiqc $WD
