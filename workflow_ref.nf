
//"nextflow.enable.dsl=2" indicates that the script is using Nextflow DSL2 (Domain-Specific Language 2), 
//which is a more modern and expressive syntax introduced in Nextflow for defining workflow       

nextflow.enable.dsl=2
   
//This line sets the variable "params.out" that specifies the output directory where files will be published. 
//The value of params.out is determined by the $launchDir/output path, which should be replaced 
//with an actual directory path when the workflow is executed.
  
params.out = "$launchDir/output"

//publishDir: This command specifies that files produced by the process should be copied to the directory 
//specified by params.out.
//mode: "copy": Files are copied (as opposed to symlinked) to the params.out directory.
//overwrite: true: If files with the same name already exist in the output directory, they will be overwritten.
//output: path "batch1.fasta": This declares that the process produces a file named batch1.fasta as output. 
//The path directive indicates that this is a file output. This is the actual command that will be executed in the process. 
//It uses wget to download a file from a URL (https://tinyurl.com/cqbatch1) and saves it as batch1.fasta.

process downloadFile {
  publishDir params.out, mode: "copy", overwrite: true
  output:
    path "batch1.fasta"
  """
  wget https://tinyurl.com/cqbatch1 -O batch1.fasta
  """
}

process countSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "numseq*"
  """
  grep "^>" $infile | wc -l > numseqs.txt
  """
}

process countSequencesAlt {
  publishDir params.out, mode:"copy", overwrite: true
  input:
	path infile
  output: 
    path "numseq*"
	
  """
  grep [a-zA-Z] $infile | wc -l > numseqsalt.txt
  """
}


process splitSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "seq_*.fasta"
  """
  split -d -l 2 --additional-suffix .fasta $infile seq_
  """
}

process splitSequencesPython {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "seq_*.fasta"
  """
  python3 $projectDir/split.py $infile seq_
  """
}

process countBases {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}.basecount"
  """
  grep -v "^>" $infile | wc -m > ${infile.getSimpleName()}.basecount
  """
}

process countRepeats {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}.repeatcount"
  """
  echo -n "${infile.getSimpleName()}" | cut -z -d "_" -f 2 > ${infile.getSimpleName()}.repeatcount
  echo -n ", " >> ${infile.getSimpleName()}.repeatcount
  grep -o "GCCGCG" $infile | wc -l >> ${infile.getSimpleName()}.repeatcount
  """
}

process makeReport {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "finalcount.csv"
  """
  cat * > count.csv
  echo "# Sequence number, repeats" > finalcount.csv
  cat count.csv >> finalcount.csv
  """
}

workflow {
  downloadFile()
}