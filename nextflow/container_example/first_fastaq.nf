
nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.publishDir= "${launchDir}/publish"
params.out= "${launchDir}/output"
params.accession="SRR16641606"

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

//Caching: When using storeDir, Nextflow checks if the output already exists in the specified directory. If the output is found, the task is skipped, 
//which can save time when rerunning workflows.nextflow storeDir 
//directive is used to store task outputs in a permanent location. By default, Nextflow saves intermediate files 
//in temporary work directories, which are cleaned up after the pipeline finishes. However, if you want to keep certain output files for later use (e.g., to avoid re-running tasks or to easily access results), 
//you can use storeDir to specify a persistent storage directory for them.

//Permanent storage, not deleted after pipeline excecution: publishDir directive is used to copy or move the output files of a process to a user-specified directory. 
//This is useful for storing important results in a designated, 
//accessible location while allowing Nextflow to manage temporary files in its work directories.

process convert_to_fastq {
 storeDir params.storeDir
 publishDir params.publishDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
    path accession
  output:
    path "${accession}.fastq"
  script:
  """
  fasterq-dump $accession --split
  """
  }
  
//process stats_of_fastq {
//publishDir params.publishDir
//  container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
//  input: 
//   path accession
//  output: 
//   path "${accession.getSimpleName()}_stats.txt"
//  script:
//  """
//  fastqutils stats ${accession} > ${accession.getSimpleName()}_stats.txt
//  """
//} 

process fasta_qc {
storeDir params.storeDir
publishDir params.publish
  container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
  input: 
   path accession
  output: 
   path "${accession.getSimpleName()}.fastqc"
  script:
  """
  mkdir fastqc
  fastqc --noextract --nogroup -o fastqc ${accession} > ${accession.getSimpleName()}.fastqc
  """
} 

workflow {
  varfetch=prefetch(Channel.from(params.accession))
  varconvert = convert_to_fastq(varfetch) 
  fasta_qc(varconvert)
}

//Get to Singularity shell
//idefix@WIN-HVW6TOI:~/Rep1/nextflow/container_example$ cd work/16 (16 from nextflow run first_fastaq.nf -profile singularity)
//idefix@WIN-HVW6TOI:~/Rep1/nextflow/container_example/work/16$ ls
//e00d5e4a7fa614946316bed90e08c4
//idefix@WIN-HVW6TOI:~/Rep1/nextflow/container_example/work/16$ cd e00d5e4a7fa614946316bed90e08c4
//idefix@WIN-HVW6TOI:~/Rep1/nextflow/container_example/work/16/e00d5e4a7fa614946316bed90e08c4$ ls
//SRR16641606.fastq
//idefix@WIN-HVW6TOI:~/Rep1/nextflow/container_example/work/16/e00d5e4a7fa614946316bed90e08c4$ ls
//depot.galaxyproject.org-singularity-fastqc-rs%3A0.3.4--h101ab07_0.img
//depot.galaxyproject.org-singularity-ngsutils%3A0.5.9--py27h9801fc8_5.img
//depot.galaxyproject.org-singularity-sra-tools%3A2.11.0--pl5321ha49a11a_3.img 
//ncbi-sra-tools.img
//idefix@WIN-HVW6TOI:~/Rep1/nextflow/container_example$ singularity_containers
//idefix@WIN-HVW6TOI:~/Rep1/nextflow/container_example$ singularity_containers/depot.galaxyproject.org-singularity-fastqc-rs%3A0.3.4--h101ab07_0.img
//Singularity>