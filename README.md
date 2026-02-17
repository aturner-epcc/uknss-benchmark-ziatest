# UK-NSS Ziatest benchmark

Ziatest is intended to provide a realistic assessment of
both launch and wireup requirements of MPI applications.
Accordingly, it exercises both the launch system of the environment
and the interconnect subsystem in a specified pattern.

Specifically, the test consists of the following steps:

1. record a time stamp for when the test started -
   this is passed to rank=0 upon launch

2. launch a 100MB executable on a specified number of processes on each node

3. each process executes MPI_Init

4. each process on an odd-numbered node
   (designated the "originator" for purposes of this description)
   sends a one-byte message to the process with the same local rank
   on the even-numbered node above it -
   i.e., a process on node N sends to a process on node N+1, where N is odd.

5. the receiving process answers the message with a one-byte message
   sent back to the original sender. In other words, the test identifies
   pairs of nodes, and then the processes with the same local rank on each
   pair of nodes exchange a one-byte message.

6. each originator records the time that the reply is received,
   and then enters a call to MPI_Gather.
   This allows all the time stamps to be collected by the rank=0 process

7. once all the times stamps have been collected,
   the rank=0 process searches them to find the latest time.
   This marks the ending time of the benchmark.
   The start time is then subtracted from this
   to generate the final time to execute the benchmark.

Thus, the benchmark seeks to measure
not just the time required to spawn processes on remote nodes,
but also the time required by the interconnect
to form inter-process connections capable of communicating.

## Status

Stable

## Maintainers

- @aturner-epcc ([https://github.com/aturner-epcc](https://github.com/aturner-epcc))

## Overview

### Software

- Ziatest

### Architectures

- CPU: x86, Arm
- GPU: N/A

### Languages and programming models

- Programming languages: C
- Parallel models: N/A
- Accelerator offload models: N/A

## Building the benchmark

**Important:** All results submitted should be based on the version of
the ziatest software included in this repository.

Any modifications made to the source code and build/installation files must be 
shared as part of the bidder submission.

### Permitted modifications

The only permitted modifications allowed are those that
modify the source code or build/installation files to resolve unavoidable compilation or
runtime errors.

### Manual build

Ziatest has no software prerequisites besides a  MPI library.
This test is included in the OpenMPI developers code base
and was distributed in the OpenMPI 1.5.0 release,
but there is no dependence on OpenMPI;
other MPI implementations can be used with little or no modification.

To install the benchmark, you will need to compile both the ziatest.c and
ziaprobe.c programs. A very simple Makefile is provided.
The ziatest.c program obtains the initial time stamp,
and then executes the "mpirun" (or equivalent) command
to initiate the actual benchmark (`./ziaprobe`).

## Running the benchmark

### Required Tests

The purpose of Ziatest is to measure the time needed to launch full-system jobs,
and should be run using at least 99% of the compute nodes,
and at least 1 MPI rank per NIC.

### Benchmark execution

With the code compiled, use the command:
```
./ziatest <N> "<mpirun_command> <mpirun_options> "
```
where `N` is the number of processes to be launched on each node,
and `mpirun_command` is the command used to launch parallel jobs (e.g. mpirun),
and `mpirun_options` describes the distribution of processes among nodes.
The syntax for `mpirun_options` differs between MPI implmentations
(or resource managers) and should be modified as needed.

The [run_ziatest.sh](run_ziatest.sh) script demonstrates use of
the Slurm `srun` command to launch 4 MPI processes per node on 256 nodes
(1024 MPI processes total). A simplified form of the `srun` command from
the script is:

```
./ziatest 4  \
   "srun --ntasks 1024 --cpus-per-task 72 --ntasks-per-node "
```

Notice that tasks_per_node is provided as the first argument to `ziatest`,
but not within the `srun` command;
`ziatest` appends the tasks_per_node value to the `srun` command.
Thus, the option that sets the number of tasks per node
(i.e. `--ntasks-per-node`) should be listed last in `mpirun_options`.

There is no requirement that there be an even number of nodes.
In the case of an odd number of nodes, the test will automatically "wrap"
the test by requiring the last node to communicate with node=0.
Note that this can invoke a penalty in performance as the processes on
node=0 will have to respond twice to messages. Thus, the test does tend
to favor even numbers of nodes. The required behavior is to launch
a constant number of processes on each node.

The output will appear in the following format:

```
srun --hint=nomultithread --distribution=block:block --ntasks 1024 --cpus-per-task 72 --ntasks-per-node  4 ./ziaprobe 1771328648 32530 4

Time test was completed in   0:13 min:sec
Slowest rank: 217
```

The command used to launch `ziaprobe` is printed,
followed by the time required to execute the test,
then the rank that reported the slowest time.
The time will be in `milliseconds` if the test tool less than 1 second to execute,
or `min:sec` if the test took longer than 1 second.
The slowest rank information is provided
in the hopes it may prove of some diagnostic value.

Example output from the [IsambardAI](https://docs.isambard.ac.uk/specs/#system-specifications-isambard-ai-phase-2) system is provided in
the [example-output](./example-output/) directory.

## Reporting Results

The primary figure of merit is the test completion time reported by the ziatest
software.

The bidder should provide:

- Details of any changes made to the ziatest source code
  and modifications to any build files (e.g. configure scripts, makefiles)
- Details of the build process for the ziatest software 
- Details on how the benchmarks were run, including any batch job submission
  scripts
- All output from the benchmark, including the test completion time reported
  by ziatest

## Copyright

Copyright (c) 2008 Los Alamos National Security, LLC.  All rights reserved.<br>
Modified by Sue Kelly, Sandia National Laboratories, January 2010, January 2012.<br>
Modified by Brian Austin, Lawerence Berkeley National Laboratory, April 2023.

