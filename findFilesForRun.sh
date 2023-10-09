#!/bin/bash

if [ "$#" -lt 3 ]; then
  echo "Usage of the script:"
  echo "$0 dataset runNumber outputFileName [-v]"
  echo "dataset = Name of the searched dataset. Wildcards are allowed."
  echo "runNumber = Number of the run for which the files are searched."
  echo "outputFileName = Name given for the output file containing the file list."
  echo "-v = Verbose mode. Print messages about what the script is doing."
  exit
fi

DATASET=$1     # Name of the dataset
RUNNUMBER=$2   # Run number
OUTPUTNAME=$3  # Name of the file list
shift 3        # Shift the positional parameters to read the optional ones

# Read the optional arguments. (Semicolon after letter: expects argument)
while getopts ":v" opt; do
case $opt in
v) VERBOSE=true
;;
\?) echo "Invalid option -$OPTARG" >&2
exit 1
;;
esac
done

# Do not use verbose mode unless specified by the user
VERBOSE=${VERBOSE:-false}

# First check that a GRID proxy exists. This is needed to call the dasgoclient command.
if $VERBOSE; then echo "Checking that you have valid GRID proxy."; fi
voms-proxy-info --exists
if [ "$?" -eq "1" ]; then
  echo "ERROR! No valid grid proxy."
  echo "To use this script, you will need to create a new proxy with"
  echo "voms-proxy-init --voms cms"
  exit
fi

# Find all datasets that fulfill the wild card condition and put them to the array
if $VERBOSE; then echo "Expanding wild cards in dataset name."; fi
ALLDATASETS=($(dasgoclient --query="dataset dataset=${DATASET}"))

# In verbose mode, print all found datasets to console
if $VERBOSE; then
  echo "The following datasets match the wild card:"
  for CURRENTDATASET in "${ALLDATASETS[@]}"; do
    echo "${CURRENTDATASET}"
  done
fi
  

# Create the file list using files from the first matching dataset
if $VERBOSE; then echo "Finding run ${RUNNUMBER} files from dataset ${ALLDATASETS[0]}"; fi
dasgoclient --query="file dataset=${ALLDATASETS[0]} run=${RUNNUMBER}" > $OUTPUTNAME

# Loop over the remaining datasets and add the files to the file list
for CURRENTDATASET in "${ALLDATASETS[@]:1}"; do
  if $VERBOSE; then echo "Finding run ${RUNNUMBER} files from dataset ${CURRENTDATASET}"; fi
  dasgoclient --query="file dataset=${CURRENTDATASET} run=${RUNNUMBER}" >> $OUTPUTNAME
done

# In verbose mode, tell that things are done
if $VERBOSE; then echo "File list saved to file ${OUTPUTNAME}"; fi
