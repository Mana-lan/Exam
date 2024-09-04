nextflow.enable.dsl=2

process downloadFile {
  """
  wget https://tinyurl.com/cqbatch1 -O batch1.fasta
  """
}

workflow {
 downloadFile()
}
