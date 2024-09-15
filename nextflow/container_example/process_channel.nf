nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.publishDir= "${launchDir}/publish"
params.out = "${launchDir}/output"
params.accession="SRR16641606"
params.with_fastqc = true
params.with_stats = false

//process: download a file form the NCBI with the accession number

process prefetch {
  storeDir params.storeDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
    val accession
  output:
    path "${accession}"
  script:
  """
  prefetch $accession
  """
}

//process: retrieves sequence data from the SRA database (1) and converting the compressed SRA format into FASTQ format. For paired-end reads  
// The --split-3 three delivers separate files as an output: _1.fastq and _2.fastaq for the two paired reads (sequences from oposed direction) and the file 
//_3.fastq for reads which has no oposed paire because this one was not properly sequenced

process fasterqdump {
 storeDir params.storeDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
    path accession
  output:
    path "${accession.getSimpleName()}*.fastq"
  script:
  """
  fasterq-dump $accession --split-3
  """
}

//process: analysis the sequencing data contained in a FASTQ file and provide information such as in text file output: Number of reads, 
//read length base composition in percentage of A,T,C,G), quality score and the content of GC (-i und -i st nicht notwendig es klärt aber 
//den input und output im script

process fastqstats {
storeDir params.storeDir
publishDir params.publishDir, mode:"copy", overwrite:true
  container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
  input: 
   path accession
  output: 
   path "${accession.getSimpleName()}_stats.txt"
  script:
  """
  fastqutils -i stats ${accession} > -o ${accession.getSimpleName()}_stats.txt
  """
} 


//process: generates a quality control report of fastq files. providing information such as per-base quality scores, GC content, 
//sequence length distribution, and more. Option "-o" specifies the output directory where the fastaq report will be saved.


process fastqc {
storeDir params.storeDir
publishDir params.out, mode:"copy", overwrite:true
  container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
  input: 
    path accession
  output: 
    path "fastqc"
 script:
   """
   mkdir fastqc
   fastqc -o fastqc ${accession}
   """
} 

//process: Make pre-processing tasks on fastq files for quality control for adapter trimming, quality filtering etc.. 
//The -5 in script tells fastp to tri, the first five bases from the 5´end (beginning) of each read as sliding window. Option "-i" specifies 
//the input raw fastaq which should be pre-processed. input are fastq files.

process fastP {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastp%3A0.23.4--hadf994f_3"
	input:
		path accession
	output:
		path "${accession.getSimpleName()}_trimmed.fastq"
	
	"""
	fastp -i $accession -o ${accession.getSimpleName()}_trimmed.fastq -5
	"""
}

//process: multiqc tool used in bioinformatics to aggregate and visualize the quality control (QC) reports from multiple tools 
//across many samples into a single report. It supports a wide variety of bioinformatics tools such as FastQC, fastp, samtools, 
//STAR, Salmon, and many others. MultiQC is typically used in pipelines where data from several samples and sequencing runs need 
//to be processed and reviewed together. It takes as input among others fastqc and fastp files

process multiqc {
 storeDir params.storeDir
 publishDir params.publishDir, mode: "copy", overwrite: true
 container "https://depot.galaxyproject.org/singularity/multiqc%3A1.24.1--pyhdfd78af_0"
 input:
   path accession
 output: 
   path  "multiqc_report.html"
   path  "multiqc_data"
 script:  
  """
   multiqc . 
  """
}


workflow {
  prefetchChannel = Channel.from(params.accession)
  varfetch = prefetch(prefetchChannel) | flatten
  vardump = fasterqdump(varfetch) 
   if(params.with_stats) {
      varfastq = fastqstats(vardump)
   }
   if(params.with_fastqc) {
      varfastq = fastqc(vardump)
   }   
  multiqc(varfastq)
}

//definition with one channel and an option



//(1) SRA sequencing data refers to the sequencing data deposited in the Sequence Read Archive (SRA), a large public repository maintained 
//by organizations like NCBI (National Center for Biotechnology Information), EBI (European Bioinformatics Institute), 
//and DDBJ (DNA Data Bank of Japan). The SRA contains raw next-generation sequencing (NGS) data, 
//such as whole-genome sequencing, RNA-seq, ChIP-seq, and other high-throughput sequencing experiments.