# Defino WD
WD=$(/home/user16/Desktop/testsim/testsim)
cd $WD

# Descargo genoma Ecoli
mkdir res/genome
cd $_
wget -O ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
gunzip -k ecoli.fasta.gz

# indexo genoma de Ecoli
    echo "Running STAR index..."
    mkdir -p res/genome/star_index
    STAR --runThreadN 4 --runMode genomeGenerate --genomeDir res/genome/star_index/ --genomeFastaFiles res/genome/ecoli.fasta$
    echo

if [ "$#" -eq 1 ]
then
    sampleid=$1
    echo "Running FastQC..."
    mkdir -p out/fastqc
    fastqc -o out/fastqc data/${sampleid}*.fastq.gz
    echo

# proceso secuencias de manera iterativa
for sampleid in $(ls data/*.fastq.gz | cut -d"_" -f1 | cut -d"/" -f2 | sort |uniq)
do
echo "Running cutadapt..."
    mkdir -p log/cutadapt
    mkdir -p out/cutadapt
    cutadapt -m 20 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o out/cutadapt/${sampleid}_1.trimmed.fastq.gz -p out/cutadapt/${sampleid}_2.trimmed.fastq.gz data/${sampleid}_1.fastq.gz data/${sampleid}_2.fastq.gz > log/cutadapt/${sampleid}.log
    echo
    echo "Running STAR alignment..."
    mkdir -p out/star/${sampleid}
    STAR --runThreadN 4 --genomeDir res/genome/star_index/ --readFilesIn out/cutadapt/${sampleid}_1.trimmed.fastq.gz out/cutadapt/${sampleid}_2.trimmed.fastq.gz --readFilesCommand zcat --outFileNamePrefix out/star/${sampleid}/
    echo
done

multiqc -o out/multiqc $WD

else
    echo "Usage: $0 <sampleid>"
    exit 1
fi
