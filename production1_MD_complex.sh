#!/bin/bash    
#SBATCH -J mdrun
#SBATCH -o mdrun_%j.out
#SBATCH -e mdrun_%j.err
#SBATCH -p gpu_4l
#SBATCH -A lhlai_g1
#SBATCH -q lhlaig4c
#SBATCH -N 1
#SBATCH -c 7
#SBATCH --gres=gpu:1
#SBATCH --no-requeue

source /appsnew/source/gromacs2024.1-cuda12.3.sh

alias gmx='gmx_mpi'

gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -n index.ndx -o md-1.tpr -maxwarn 1
gmx mdrun -deffnm md-1 -v -pin on -pmefft gpu -bonded gpu -pme gpu -nb gpu