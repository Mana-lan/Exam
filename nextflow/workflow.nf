nextflow.enable.dsl=2

//download cqbatch1 and put it in publishDir and presented as output for next processes

process downloadFile {
  publishDir "/home/idefix/Rep1/nextflow/publishDir", mode: "copy", overwrite: true
  output:
    path "batch1.fasta"
  """
  wget https://tinyurl.com/cqbatch1 -O batch1.fasta
  """
}

workflow {
 downloadFile()
}
