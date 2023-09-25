# HiForestSetupPbPbRun2023
Instructions on how to setup on run the rapid validation forests for 2023 PbPb run.

## Setup environment:
```bash
cmsrel CMSSW_13_2_4
cd CMSSW_13_2_4/src
cmsenv
git cms-merge-topic CmsHI:forest_CMSSW_13_2_X
git remote add cmshi git@github.com:CmsHI/cmssw.git
scram build -j8
voms-proxy-init --voms cms
```

For production, it is a good idea to create a production branch and commit all the changes every time before running production, so that the exact configuration used for the production can be traced back if needed. 
```bash
git checkout -b rapidValidationForest2023
```

## Test the configuration

To test the configuration, you will first need to obtain a sample input file from the dataset you are running over. Then update this input file to the the configuration file
```bash
vim forest_miniAOD_run3_DATA.py
```
Now you can run the configuration interactively to ensure that it works for your file:
```bash
cmsRun forest_miniAOD_run3_DATA.py
```

## Submit the jobs with crab

To submit the jobs via CRAB, copy the template file from this area to the CMSSW area where you are running the jobs. You will first need to modify the template file according to your needs
```
vim crabForestTemplate.py
### Modify the following lines:
inputList
jobTag
### Check that memory and run time settings are good:
config.JobType.maxMemoryMB
config.JobType.maxJobRuntimeMin
### Write the output somewhere where you have write rights:
config.Site.storageSite
```
Notice that you will need a file list of all the files in the dataset in .txt format for the inputList variable. The jobTag can be whichever name that describes the job you are sending.

Once you have customized the CRAB template file, for documentation purposes, commit the changes note the commit you are using to submit the jobs
```bash
git add -u
git commit -m "Descriptive comment"
git push my-cmssw rapidValidationForest2023:rapidValidationForest2023
```
Then remember the commit hash
```bash
git rev-parse HEAD > gitCommitLog.txt
```

After the bookkeeping is done, submit the jobs.
```bash
crab submit -c crabForestTemplate.py
```

When the jobs are finished, you should document in the Twiki page https://twiki.cern.ch/twiki/bin/view/CMS/HiForest2023 that the forest is done, and for each forest add the git link for the configuration that was used to create the said forest. Example link for a commit looks like this: https://github.com/jusaviin/cmssw/tree/250185e12b917d36fd8d3a51208e5f8311f3ad92.
