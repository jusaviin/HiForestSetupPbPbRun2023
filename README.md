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

The following recipe will add B/D-finder to the configuration:
```bash
cd $CMSSW_BASE/src
git clone -b 13XX_miniAOD https://github.com/milanchestojanovic/Bfinder.git --depth 1
source Bfinder/test/DnBfinder_to_Forest_132X_miniAOD.sh
scram build -j8
```

For production, it is a good idea to create a production branch and commit all the changes every time before running production, so that the exact configuration used for the production can be traced back if needed. 
```bash
git checkout -b rapidValidationForest2023
```

## Test the configuration

To test the configuration, you will first need to obtain a sample input file from the dataset you are running over. Easy way to get a file list for a dataset of your choice is the following:

```bash
ls /eos/cms/store/group/phys_heavyions/wangj/RECO2023/miniaod_PhysicsHIPhysicsRawPrime0_374322/* > fileListHIPhysicsRawPrime0_run374322.txt
sed -i -e "s#/eos/cms#root://eoscms.cern.ch/#" fileListHIPhysicsRawPrime0_run374322.txt
```

Then update this input file to the the configuration file
```bash
vim forest_miniAOD_run3_DATA.py  # Without D-finder
vim forest_miniAOD_run3_DATA_wDfinder.py  # With D-finder
```
Now you can run the configuration interactively to ensure that it works for your file:
```bash
cmsRun forest_miniAOD_run3_DATA.py  # Without D-finder
cmsRun forest_miniAOD_run3_DATA_wDfinder.py  # With D-finder
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

CRAB likes to create a long structure of unnecessary folders for the output files. It is a good idea to trunkate this structure, since CRAB also has a lenght limit for input files, and a long file structure might cause errors in subsequent job submission. The following command will do the trick:
```bash
eos file rename /eos/cms/store/group/phys_heavyions/jviinika/run3RapidValidation/PbPb2023_run374322_HIExpressRawPrime_withDFinder_2023-09-27/CRAB_UserFiles/crab_PbPb2023_run374322_HIExpressRawPrime_withDFinder_2023-09-27/230928_014852/0000 /eos/cms/store/group/phys_heavyions/jviinika/run3RapidValidation/PbPb2023_run374322_HIExpressRawPrime_withDFinder_2023-09-27/0000
```

## Submit jobs with ZDC emap file

Currently (2023-09-29) the ZDC energy calibration needs to be manually. For this, an energy map configuration file needs to be included in the CRAB jobs. To be able to do this, you will need to copy the files
```
crabForestTemplateWithEmap.py
submitScript.sh
```
to your production area. The difference to the default CRAB configuration is that instead of running the regular python configuration, CRAB will now be configured to run ```submitScript.sh``` instead. Also the emap file will be shipped together with the regular forest files to the CRAB server. The script moves the emap file to location where it can be found by cmsRun, and then executes cmsRun. Using this setup will properly calibrate ZDC digis.

Notice that for local running, you will need to make a copy of the emap file in a location where FileInPath searches for it. This can be achieved in the test folder doing
```bash
cp emap_2023_newZDC_v3.txt ../../../
```

## Helpful scripts

There are a couple of helpful bash scripts included in this directory that can make life easier in certain occasions. If you want to create a forest using prompt reconstruction files for certain run, you can easily create a file list with ```findFilesForRun.sh``` by defining primary dataset and run number. Running it without arguments print usage help.

Another script is for merging all .root files in a specific folder, that can be either local or at CERN EOS. This is called ```addHistograms.sh```. Again, running the script without arguments gives you usage instructions for this script.
