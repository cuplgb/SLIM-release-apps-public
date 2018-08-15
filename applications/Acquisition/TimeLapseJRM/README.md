#  Joint recovery method for time-lapse seismic data

## DESCRIPTION 

This package is an application for time-lapse data acquired via
randomized sampling schemes, and a joint recovery method based on
sparse inversion (via L1 minimization).
 
 
## ON-LINE DOCUMENTATION

https://www.slim.eos.ubc.ca/SoftwareDemos/applications/Acquisition/TimelapseJRM


## COPYRIGHT

You may use this code only under the conditions and terms of the
license contained in the files LICENSE or COPYING provided with this
source code. If you do not agree to these terms you may not use this
software.
 

## PREREQUISITES

All prerequisites, except for MATLAB, are provided in the software
release repositories and should be installed as necessary before using
any of SINBAD's software.
 

## INSTALLATION

Follow the instructions in the INSTALLATION file (located in the root
directory of this software release) to install all 3-rd party software
(except for MATLAB) and SINBAD's software.

	 
## DOCUMENTATION

Examples in .html format are included in the ./doc directory for two
randomized sampling schemes: [1] Random missing shots; [2]
Time-jittered (OBC) marine acquisition.
  
 
## RUNNING

Start matlab from this directory or run startup.m to set the correct
paths. The scripts that produced the results can be found in ./scripts
directory.
 
### Preparing shell environment

You must setup your shell environment according to the steps listed in
the README located in home directory of the software release.

### Downloading data

To run the examples, first download the data from
ftp://ftp.slim.gatech.edu/data/SoftwareRelease/Acquisition/TimeLapseJRM/data,
by typing `scons' in the ./data directory.

[1] Random missing shots: this example uses the time-lapse-data.mat
data from the ./data directory.

[2] Time-jittered (OBC) marine acquisition: this example uses the
data_4D.mat data from the ./data directory.
 
### Running applications/demos
    
[1] Random missing shots: pre-run results can be downloaded from
ftp://ftp.slim.gatech.edu/data/SoftwareRelease/Acquisition/TimeLapseJRM/results/MissShots_OneReceiverGather,
by typing `scons' in the ./results/MissShots_OneReceiverGather
directory. Implementation of the example can be run by following the instructions in the README.md file
in the ./scripts/MissShots_OneReceiverGather directory.

[2] Time-jittered (OBC) marine acquisition: specific instructions for
this example can be found in the README.md file in the
./scripts/TimeJitteredMarineAcq_OneReceiverGather directory. Pre-run
results can be downloaded from
ftp://ftp.slim.gatech.edu/data/SoftwareRelease/Acquisition/TimeLapseJRM/results/TimeJitteredMarineAcq_OneReceiverGather,
by typing `scons' in the
./results/TimeJitteredMarineAcq_OneReceiverGather directory.

#### Data adaptation
    
Time-jittered (OBC) marine acquisition: to run the algorithm on your
own data, see the instructions in the README.md file in the
./scripts/TimeJitteredMarineAcq_OneReceiverGather directory.

 
## SUPPORT
  
You may contact developers of SINBAD software by means of:

### GitHub issue tracker

Submit issue at [SLIM-release-apps issues](https://github.com/SINBADconsortium/SLIM-release-apps/issues).

###  Direct mail

Contact [SLIM administrator](mailto:softadmin@slimweb.eos.ubc.ca) with
any questions related to the SINBAD software release.

 
## REFERENCES

[1] Felix Oghenekohwo, Ernie Esser, and Felix J. Herrmann
[2014]. "Time-lapse seismic without repetition: reaping the benefits
from randomized sampling and joint recovery." Presented at the 76th
EAGE Conference and Exhibition, doi:
10.3997/2214-4609.20141478. Available at
https://www.slim.eos.ubc.ca/content/time-lapse-seismic-without-repetition-reaping-benefits-randomized-sampling-and-joint-recover.
	 
[2] Haneet Wason, Felix Oghenekohwo, and Felix J. Herrmann
[2014]. "Randomization and repeatability in time-lapse marine
acquisition." EAGE Workshop on Land and Ocean Bottom; Broadband Full
Azimuth Seismic Surveys, Spain. Available at
https://www.slim.eos.ubc.ca/content/randomization-and-repeatability-time-lapse-marine-acquisition-0.
	 
[3] Haneet Wason, Felix Oghenekohwo, and Felix J. Herrmann
[2014]. "Randomization and repeatability in time-lapse marine
acquisition." SEG Technical Program Expanded Abstracts,
pp. 46-51. Available at
https://www.slim.eos.ubc.ca/content/randomization-and-repeatability-time-lapse-marine-acquisition.

