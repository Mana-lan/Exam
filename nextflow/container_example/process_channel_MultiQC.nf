nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.publishDir= "${launchDir}/publish"
params.out = "${launchDir}/output"
params.accession="SRR16641606"
params.with_fastp = true
params.with_fastqc = true

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
   fastqc -o fastqc $accession
   """
 }


process fastP {
    storeDir params.storeDir
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastp%3A0.23.4--hadf994f_3"
	input:
		path accession
	output:
		path "${accession}*"
	script:
	"""
	fastp -i $accession -o ${accession}_trimmed.fastq -5
	"""
}


process Multiqc {
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


//Apply fastQC befor and after trimming with fastP

workflow {
  fastQChannel = Channel.from(params.accession)
  varfetch = prefetch(fastQChannel) | flatten
  fastQChannel = fasterqdump(varfetch)
  
  fastqcChannel = Channel.empty()
  
   if(params.with_fastp) {
       fastPresult = fastP(fastQChannel)
	}
  
  fastqcChannel = fastQChannel.concat(fastqcChannel)
  fastqcResult = fastqc(fastqcChannel)
  
  concatResult = fastPresult.concat(fastqcResult)
  collectResult = concatResult | collect
 
  Multiqc(collectResult)
}


//flatten in the pipe without bracket in the  channel with (): ...flatten()

