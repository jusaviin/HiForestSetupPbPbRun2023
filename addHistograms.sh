#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Script for adding all root files from a folder locally or in EOS"
  echo "Usage of the script:"
  echo "$0 [doLocal] [inputFolderName] [baseName]"
  echo "doLocal = True: Merge local files. False: Merge files on CERN EOS"
  echo "inputFolderName = Name of the folder where the root files are"
  echo "baseName = Name given for the output file without .root extension"
  exit
fi

LOCALRUN=$1
INPUTFOLDERNAME=${2%/}
BASENAME=$3

if [ $LOCALRUN = true ]; then
  hadd -ff ${BASENAME}.root `ls ${INPUTFOLDERNAME}/*.root`
else
  hadd -ff ${BASENAME}.root `xrdfs root://eoscms.cern.ch ls -u $INPUTFOLDERNAME | grep '\.root'`
fi
