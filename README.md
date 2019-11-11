# tcd-ultrasound
A tool to extract transcranial Doppler data from M9 ultrasound images.



## Introduction

This tool is designed to extract transcranial Doppler (TCD) data from M9 ultrasound images through the use of optical character recognition (OCR). It is implemented in MATLAB and designed to be used on the University of Michigan's GreatLakes cluster computing resource, which uses the `slurm` scheduler. More information can be found in the [Slurm user guide](https://arc-ts.umich.edu/greatlakes/slurm-user-guide/).

## First-time setup

This section of the tutorial will guide you through logging into GreatLakes for the first time and setting up your environment. There are several ways to interact with GreatLakes, including Cyberduck and PuTTy. This tutorial will use the command-line utitilities `scp` and `ssh`, which can be accessed through a terminal window (such as GitBash on Windows).

**Login to GreatLakes**

```bash
ssh uniqname@greatlakes.arc-ts.umich.edu
```

**Clone this repository**

Navigate to your folder in Hakam's `turbo` storage, and make a copy of this repository so you have access to the code.

```bash
cd /nfs/turbo/umms-tibam/uniqname
git clone https://github.com/bccummings/tcd-ultrasound
```

## Usage

### 1. Upload data

First, the TCD files must be uploaded to greatlakes. Often the most convienient way to do this is through `scp`, though some users may prefer to use file utilities such as CyberDuck. This tutorial will assume that the user is using `scp`.

**Login to GreatLakes**

```bash
ssh uniqname@greatlakes.arc-ts.umich.edu
```

**Make a folder to house the TCD data**

Data will be stored on Hakam's `turbo` storage partition (`/nfs/turbo/umms-tibam/`). Here, you should see several uniqname folders as well as a `shared-data` folder. If you have permissions errors with the `shared-data` folder, contact Brandon (cummingb@med.umich.edu).

There is already a directory with the much ultrasound data under the `tobi-animals/data` folder; add a folder with the requisite date (be sure to replace `YYYY-MM-DD` below). You will also make `mat` and `tcd` folders to house the data in.

```bash
cd /nfs/turbo/umms-tibam/shared-data/tobi-animals/data
mkdir YYYY-MM-DD
cd YYYY-MM-DD
mkdir mat
mkdir tcd
```

**Upload data**

Either exit the `ssh` connection to GreatLakes and return to your local machine (alternatively, open a new terminal window). Use the `scp` command to upload the data to the folder you just made (replacing `path/to/local/tcd/files/` with the directory/external drive you have the ultrasound ifles on).

```bash
scp /path/to/local/tcd/files/ uniqname@greatlakes-xfer.arc-ts.umich.edu:/nfs/turbo/umms-tibam/shared-data/tob-animals/data/YYYY-MM-DD/tcd/
```

### 2. Create batch submission file (sbat)

**Copy the `sbat` file**

The GreatLakes cluster uses a system called `slurm` to schedule resources. Slurm uses files called `sbat` files to communicate with the scheduler. There is a template `sbat` file in this repository named `readtcd.sbat`. 

Make a copy of this file and place it into the folder with the animal TCD and Matlab data.

```bash
cp /nfs/turbo/umms-tibam/uniqname/tcd-ultrasound/readtcd.sbat /nfs/turbo/umms-tibam/shared-data/tobi-animals/data/YYYY-MM-DD/
```

**Edit file contents**

Next, you'll need to adjust some parameters in the `sbat` file. This can be done using Cyberduck, `vim`, or `nano` (e.g. `nano /nfs/turbo/umms-tibam/shared-data/tobi-animals/data/YYYY-MM-DD/readtcd.sbat`). The contents of the raw file are copied below.

```bash
#!/bin/bash
#SBATCH --job-name=tcd_file_conversion
#SBATCH --account=tibam
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=8:00:00
#SBATCH --mem-per-cpu=64GB
#SBATCH --mail-user=uniqname@umich.edu
#SBATCH --mail-type=ALL
#SBATCH --output=%x-%j
   

# I recommend using the following lines to write output to indicate your script is working
if [[ $SLURM_JOB_NODELIST ]] ; then
   echo "Running on"
   scontrol show hostnames $SLURM_JOB_NODELIST
fi

# With SLURM, you can load your modules in the SBATCH script
module load matlab

#  Put your job commands after this line 
matlab -nodisplay -nosplash -nodesktop -r "addpath('/nfs/turbo/umms-tibam/uniqname/tcd-ultrasound'); tcd_driver('./dcm', './mat'); exit;"
```

You'll need to change the `jobname` and `mail-user` fields in the header, and the path to your code in the last line (where it says uniqname). Also double-check that the `sbat` file you are editing is in the corresponding date folder, as this controls what files you convert.

If the files get particularly large, you may also wish to play with the memory settings or walltime.

### 3. Run job

Now, exit the text editor and run your job. This can be done using the `sbatch` command.

```bash
sbatch /nfs/turbo/umms-tibam/shared-data/tobi-animals/data/YYYY-MM-DD/readtcd.sbat
```

You should get a message with something like `Job submitted to ....` and a file called `jobname-XXXXXXX` should pop up. 

### 4. Troubleshoot

There are a few ways to troubleshoot your job. The first is to check the contents of the jobname file (e.g. `cat jobname-XXXXXXX`) which will either display a MATLAB banner and something along the lines of `File ./mat/YYYY-MM-DD_XXX completed successfully`, or will contain an error message.

You can also check the status of your job by using `squeue -u uniqname`. 



