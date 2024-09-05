nextflow.enable.dsl=2

// download file cqbatch1

process downloadFile {
  publishDir "/home/idefix/output"
  output:
    path "batch1.fasta"
  """
  wget https://tinyurl.com/cqbatch1 -O batch1.fasta
  """
}

workflow {
 downloadFile()
}
