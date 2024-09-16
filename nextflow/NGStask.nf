nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.publishDir= "${launchDir}/publish"
params.out = "${launchDir}/output"
params.accession="M21013"

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

process trimalign {
 storeDir params.storeDir
 publishDir params.out, mode: "copy", overwrite: true
 container "https://depot.galaxyproject.org/singularity/trimal%3A1.5.0--h4ac6f70_0"
 input:  
   path infile
  output:
    path "${params.accession}trim.fasta"
  script:
  """
  trimal -in $infile  -out ${params.accession}trim.fasta -automated1
  """
}



workflow {
  downloadChannel = Channel.from(params.accession)
  downloadRef(downloadChannel)
  fastaChannel = Channel.fromPath(params.storeDir)
  combinedChannel = combinedFiles(fastaChannel)
  mafftaChannel = mafftalign(combinedChannel)
  trimalign(mafftaChannel)

}


