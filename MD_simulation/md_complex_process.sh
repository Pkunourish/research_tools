#!/bin/bash
#

while getopts ':n:c:' opt; do
    case $opt in
        n) num="$OPTARG" ;;
        c) group="$OPTARG" ;;
    esac
done

tpr_file=md-${num}
index_file=index
input_traj=md-${num}
temp_traj=md-${num}_temp
fit_traj=md-${num}_fit
compress_traj=md-${num}_compress
rmsd_output=md-${num}_rmsd
rmsf_output=md-${num}_rmsf
pdb_0=md-${num}_compress
complex_tpr=complex-${num}

source /appsnew/source/gromacs2024.1-cuda12.3.sh

alias gmx='gmx_mpi'

gmx trjconv -s ${tpr_file}.tpr -f ${input_traj}.xtc -o ${temp_traj}.xtc -pbc mol -ur compact -center -n ${index_file}.ndx << EOF
${group}
${group}
EOF
echo "processing pbc..."

gmx trjconv -s ${tpr_file}.tpr -f ${temp_traj}.xtc -o ${fit_traj}.xtc -n ${index_file}.ndx -fit rot+trans << EOF
${group}
${group}
EOF
echo "fitting rot and trans..."

gmx trjconv -s ${tpr_file}.tpr -f ${fit_traj}.xtc -o ${compress_traj}.xtc -n ${index_file}.ndx -dt 250 << EOF
${group}
EOF
echo "compressing trajectory..."

gmx trjconv -s ${tpr_file}.tpr -f ${fit_traj}.xtc -o ${pdb_0}.pdb -n ${index_file}.ndx -dump 0 << EOF
${group}
EOF
echo "converting to pdb..."

rm -f ${temp_traj}.xtc ${fit_traj}.xtc

gmx convert-tpr -s ${tpr_file}.tpr -o ${complex_tpr}.tpr -n ${index_file}.ndx << EOF
${group}
EOF

gmx rms -s ${complex_tpr}.tpr -f ${compress_traj}.xtc -o ${rmsd_output}.xvg  << EOF
Backbone
Backbone
EOF

gmx rmsf -s ${complex_tpr}.tpr -f ${compress_traj}.xtc -o ${rmsf_output}.xvg -res -b 7000 << EOF
Protein
EOF
echo "calculating rmsd and rmsf"

echo "done!"

: << 'COMMENT'
gmx trjconv -s ${complex_tpr}.tpr -f ${compress_traj}.xtc -o pose1.pdb -dump 950000 << EOF
System
EOF
COMMENT
