#!/bin/bash

# This script performs one-sample t-test of seed based connectivity mapping. 
# Use this code in case you have only one group in your study
# Use this script after 01_seed_subjects_correlation_maps.sh as you need seedlist.txt 
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2018)
# -----------------------------------------------------------

seedlist=seedlist.txt

function seed_group_level_map {
 
    seed=$1
    seed_name=$(basename $seed .nii.gz)

    3dttest++ \
        -setA 03_subject_maps/*_${seed_name}_z.nii.gz \
        -prefix 04_group_level/${seed_name}_results.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[0]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_onesample_mean_diff.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[1]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_onesample_Tstat.nii.gz

rm 04_group_level/${seed_name}_results.nii.gz 

}
export -f seed_group_level_map

# Main starts here

mkdir 04_group_level

while read -r seed;
	do
	seed_group_level_map $seed
	done < $seedlist


exit

