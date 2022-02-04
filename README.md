# Abaqus Jobs Sequence Launcher

The simple Abaqus Jobs Sequence Launcher written in PowerShell runs automatically a sequence of Abaqus jobs (one by one).

The Jobs Sequence Launcher can be run in two modes:

## Run all INP in the directory.

Copy the script to the directory with INP and run it:
```
PS>runAbqJobSeq.ps1
Abaqus Jobs Sequence Launcher ver. 0.1
Created by MWierszycki. Licensed under GPL-2.0-only.
See https://github.com/mwierszycki/abaqus_job_sequence_launcher

All INP files in current directory will be run one by one.
```
Next, launcher will ask for the number of cpus which will be used for all jobs:
```
How many cores to use to run jobs? No of cores [from 1 to 6)]/[Q]uit")
```
Type number of cores or `Q` to stop script.

If the `jobs.txt` file will be found in the directory the script will ask if to use it:
```
The jobs.txt file has been found. Would you use it? [Y]es/[N]o/[Q]uit
```
In the case of `Y`, the script will run as described below. In the case of `N`, script will process all INP file in the directory. Type `Q` to exit.
 
## Run selected INP in the directory.

Copy the script to the directory with INP files. Create a text file `jobs.txt` with a list of INPs and Abaqus job options assigned to each job. Each line of `jobs.txt` file contains the definition of a single job. The first field is the name of the INP file. It's obligatory. The rest of the line can contain any abaqus options (e.g. cpus, user, oldjob, double, etc). See the example below:
```
inp_file_name-1.inp oldjob=old_job_name cpus=4 ask_delete=off 
inp_file_name-2.inp user=user_subroutines.f ask_delete=off 
inp_file_name-3.inp cpus=1
inp_file_name-4.inp globalmodel=global_model_name
...
```
There are a few limitations. First, the input option is used in the script internally so it cannot be defined as an additional option in `jobs.txt` file. Second, the INP file name cannot contain spaces. The script doesn't check the correctness of the list of options. Abaqus Launcher will do this when the job is started. If the incorrect option will be used the script will continue with the next job on the list.

Run the script:
```
PS>runAbqJobSeq.ps1 jobs_file_name.txt
```
Launcher will not ask for the number of cpus which will be used for all jobs. The number of cpus can be defined as a job option.

During execution the script shows the status of finished jobs and the currently running job.

When all jobs are finished the log file with status of all jobs can be saved to the file:
```
The jobs sequence has been finished. Would you like to save log file? [Y]es/[N]o
```
The name of the log file is the same as the name of the file with the list of jobs. If the old job file exists it will be replaced without warning.

To finish, press any key.

Happy running sequence of Abaqus jobs!
