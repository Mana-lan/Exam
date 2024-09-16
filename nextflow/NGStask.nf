nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.publishDir= "${launchDir}/publish"
params.accession="M21012"

process downloadRef {
  storeDir params.storeDir
  input: 
	val params.accession
  output:
    path "${params.accession}.fasta"
	
  script:	
  """
  wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" -O "${params.accession}.fasta"
  """
}

//process downloadSeq

process combinedFiles {
storeDir params.storeDir

  input: 
    path infile

  output: 
    path "${params.accession}combined.fasta"

   """
   cat $infile/*.fasta > "${params.accession}combined.fasta"
   """
}

process mafftalign {
 storeDir params.storeDir
 publishDir params.publishDir, mode:"copy", overwrite:true
 container "https://depot.galaxyproject.org/singularity/mafft%3A7.520--hec16e2b_1"
  input:  
   path infile
  output:
    path "${params.accession}mafft.fasta"
  script:
  """
  mafft $infile > ${params.accession}mafft.fasta
  """
}






workflow {
  downloadChannel = Channel.from(params.accession)
  downloadRef(downloadChannel)
  fastaChannel = Channel.fromPath(params.storeDir)
  combinedChannel = combinedFiles(fastaChannel)
  mafftalign(combinedChannel)
}


