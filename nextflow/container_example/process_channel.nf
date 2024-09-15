nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.publishDir= "${launchDir}/publish"
params.out = "${launchDir}/output"
params.accession="SRR16641606"
params.with_fastqc = false
params.with_stats = false


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
    path infile
  output:
    path "${infile.getSimpleName()}*.fastq"
  script:
  """
  fasterq-dump $infile
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
  fastqutils stats ${accession} > ${accession.getSimpleName()}_stats.txt
  """
} 

process fastqc {
storeDir params.storeDir
publishDir params.out, mode:"copy", overwrite:true
  container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
  input: 
    path accession
  output: 
    path "${accession.getSimpleName()}_fastqc"
 script:
   """
   mkdir ${accession.getSimpleName()}_fastqc
   fastqc -o ${accession.getSimpleName()}_fastqc $accession
   """
} 


process multiqc {
 storeDir params.storeDir
 publishDir params.publishDir
 container "https://depot.galaxyproject.org/singularity/multiqc%3A1.24.1--pyhdfd78af_0"
 input:
   path accession
 output: 
   file  "multiqc_report.html"
   file  "multiqc_data"
 script:  
  """
   multiqc . 
  """
}




//workflow {
//  varfetch = prefetch(Channel.from(params.accession))
//  vardump = fastqc(varfetch)
//  multiqc(vardump)   
//}


//workflow {
//	prefetch(Channel.from(params.accession)) | fasterqdump | flatten | fastqc
//}


workflow {
  varfetch=prefetch(Channel.from(params.accession))
  vardump = fasterqdump(varfetch) 
  varfastq = fastqc(vardump)
  multiqc(varfastq)
}