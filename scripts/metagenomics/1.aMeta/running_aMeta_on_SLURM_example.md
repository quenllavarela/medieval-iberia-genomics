# Running aMeta on a Slurm cluster

## Start a persistent terminal session

I recommend running aMeta inside a terminal multiplexer such as `tmux` or `screen` so the session does not die if you lose your connection.

```bash
module load tmux
tmux new -s ameta_session
```

## Activate the aMeta conda environment

More details on how to create this environment are available on the aMeta GitHub page.

```bash
conda activate aMeta
```

Make sure you are in the main aMeta folder before running the next commands.

## Dry run the pipeline

First do a dry run to check that Snakemake understands the workflow and DAG correctly without running any jobs.

```bash
snakemake --snakefile workflow/Snakefile --use-conda -j 500 --profile slurm_profile --rerun-incomplete --rerun-triggers mtime --keep-going -n
```

The `-n` flag tells Snakemake to perform a dry run. It prints which jobs would be executed but does not submit anything to Slurm.

## Run the pipeline

If the dry run looks correct you can remove `-n` and start the full run.

```bash
snakemake --snakefile workflow/Snakefile --use-conda -j 500 --profile slurm_profile --rerun-incomplete --rerun-triggers mtime --keep-going
```

### Short description of the main flags

- `--snakefile workflow/Snakefile`  
  Path to the main Snakefile. The Snakefile is provided within aMeta in `workflow/Snakefile`.

- `--use-conda`  
  Uses the conda environments defined in the aMeta workflow. You can also point Snakemake to an environment file that matches the modules available on your cluster. More details are available on the aMeta GitHub page.

- `-j 500`  
  Maximum number of jobs that Snakemake is allowed to submit to the Slurm queue at once. Here we limit it to 500 out of respect for other users. You can adjust this based on your cluster policies.

- `--profile slurm_profile`  
  Uses a Snakemake profile created for Slurm (for example with the Slurm cookiecutter). You need to adapt this profile to your own cluster. The profile used on Dardel is provided here as an example.

- `--rerun-incomplete`  
  Reruns any jobs that were previously left in an incomplete state.

- `--rerun-triggers mtime`  
  Reruns jobs if the modification time of an input is newer than the output.

- `--keep-going`  
  Continues running independent jobs even if some jobs fail. This lets you inspect most results and later fix only the remaining failed rules by adjusting memory or time in the profile.

