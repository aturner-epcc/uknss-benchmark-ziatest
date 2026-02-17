#!/bin/bash
#SBATCH --job-name=ziatest
#SBATCH --output=ziatest-%j.out
#SBATCH --exclusive
#SBATCH --nodes=256
#SBATCH --time=00:30:00
#SBATCH --gpus-per-node=4
#SBATCH -x nid010798

#The --nodes option should be updated
#to use the full-system complement of nodes

#The number of NICs(j) per node should be specified here.
tasks_per_node=4 #NICs per node
stride=72 # Stride of tasks between NICs

# Specify any additional Slurm options
srunopts="--hint=nomultithread --distribution=block:block"

total_tasks=$(( SLURM_JOB_NUM_NODES * tasks_per_node ))

#Notice that tasks_per_node is provided as the first argument to ziatest,
#but not within the srun command;
#Ziatest will append the tasks_per_node value to the srun command

./ziatest $tasks_per_node  \
	  "srun $srunopts --ntasks $total_tasks --cpus-per-task $stride --ntasks-per-node "

