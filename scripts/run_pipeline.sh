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

for sampleid in $(ls data/*.fastq.gz | cut -d"_" -f1 | sed "s:data/::" | sort | uniq);

do
	bash scripts/"analyse_sample.sh" $sampleid
done 

#Generate a report
        echo "Running multiqc"
	cd $WD
        multiqc -o out/multiqc $WD


