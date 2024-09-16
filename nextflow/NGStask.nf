nextflow.enable.dsl = 2


process downloadFile {
  publishDir "/home/idefix/output"
  output:
    path "batch1.fasta"
  """
  wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012&rettype=fasta&retmode=text" -O M21012.fasta -O batch1.fasta
  """
}


workflow {
downloadFile()
}