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

# need to set protein.pbd file name manually
gmx pdb2gmx -f protein.pdb -o protein.gro -ignh -ter << EOF
1
1
0
0
EOF
gmx editconf -f atp_ini.pdb -o atp.gro
cp protein.gro ./complex.gro

# # get ligand coordinate and insert before last row of complex.gro
# sed -n '3,$p' atp.gro | sed '$d' | xargs -d '\n' -I atp_coordinate sed -i "\$i atp_coordinate" complex.gro
sed -n '3,$p' atp.gro | sed '$d' > atp.txt
sed '$d' complex.gro > tmp
cat atp.txt >> tmp
tail -n 1 complex.gro >> tmp
mv tmp complex.gro
# # get ligand atoms num and get complex atoms num, plus them and replace into 2rd row in complex.gro
expr $(sed -n '3,$p' protein.gro | sed '$d' | grep -c '.') + $(sed -n '3,$p' atp.gro | sed '$d' | grep -c '.') | xargs -d '\n' -I complex_atoms_num sed -i "2s/^.*/  complex_atoms_num/" complex.gro

# # insert ligand into topol.top
sed -i 's/\[ moleculetype ]/; Include ligand parameters\n#include "atp.prm"\n\n&/' topol.top
sed -i 's/; Include water topology/; Include ligand topology\n#include "atp.itp"\n\n&/' topol.top
sed -i '$a atp                 1' topol.top

gmx editconf -f complex.gro -o newbox.gro -bt cubic -d 1.5
gmx solvate -cp newbox.gro -cs spc216.gro -p topol.top -o solv.gro

gmx grompp -f ions.mdp -c solv.gro -p topol.top -o ions.tpr
gmx genion -s ions.tpr -o solv_ions.gro -p topol.top -pname SOD -nname CLA -neutral -conc 0.15 << EOF
15
EOF

gmx grompp -f em.mdp -c solv_ions.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em

gmx make_ndx -f atp.gro -o index_atp.ndx << EOF
0 & ! a H*
q
EOF
gmx genrestr -f atp.gro -n index_atp.ndx -o posre_atp.itp -fc 1000 1000 1000 << EOF
3
EOF
sed -i 's/; Include water topology/; Ligand position restraints\n#ifdef POSRES\n#include "posre_atp.itp"\n#endif\n\n&/' topol.top

gmx make_ndx -f em.gro -o index.ndx << EOF
1 | 13
14 | 15 | 16
q
EOF

gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -n index.ndx -o nvt.tpr
gmx mdrun -deffnm nvt -v
gmx trjconv -s nvt.tpr -f nvt.xtc -o nvt_protein.xtc -n index.ndx << EOF
19
EOF
gmx trjconv -s nvt.tpr -f nvt.xtc -o nvt.pdb -n index.ndx -dump 0 << EOF
19
EOF

gmx grompp -f npt.mdp -c nvt.gro -t nvt.cpt -r nvt.gro -p topol.top -n index.ndx -o npt.tpr -maxwarn 1
gmx mdrun -deffnm npt -v
gmx trjconv -s npt.tpr -f npt.xtc -o npt_protein.xtc -n index.ndx << EOF
19
EOF
gmx trjconv -s npt.tpr -f npt.xtc -o npt.pdb -n index.ndx -dump 0 << EOF
19
EOF
