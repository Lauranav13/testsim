
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

#Generate a report
	echo "Running multiqc"
	multiqc -o out/multiqc $WD
