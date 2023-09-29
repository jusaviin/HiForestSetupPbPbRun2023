#!/bin/bash

# Move the emap to FileInPath search path
mv emap_2023_newZDC_v3.txt CMSSW_13_2_4/src

# Run the code
cmsRun -j FrameworkJobReport.xml -p PSet.py
