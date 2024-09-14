#!/bin/bash

# First open new Ubuntu shell
# Excecute programm process_channel.nf

NXF_SINGULARITY_HOME_MOUNT=true
nextflow run process_channel.nf -profile singularity
