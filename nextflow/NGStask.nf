nextflow.enable.dsl = 2

params.accession="M21012"
process downloadFile {
  publishDir "/home/idefix/output"
  output:
    path "${params.accession}.fasta"
  """
  wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" -O "${params.accession}.fasta"
  """
}


workflow {
downloadFile()
}