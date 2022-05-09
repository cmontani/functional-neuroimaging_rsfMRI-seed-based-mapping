#!/bin/bash

# This script performs one-sample t-tests, unpaired t-test of 
# seed based connectivity maps. this code also outputs mean connectivity
# (pearson's correlation) maps for each group.
# Use this script after 01_seed_subjects_correlation_maps.sh
# groupA and groupB are the group names contained in the filenames.
# seedlist.txt has been already produced with 01_seed_subjects_correlation_maps.sh
#
#
# NB: When running the script, make sure the seeds in the $path_seeds folder do not share a suffix after an underscore 
# (e.g., if you have hippocampus_bilateral and insula_bilateral in the same folder, change either of those so that the names do not match). 
# The script might otherwise group the maps resulting from each seed together erroneously. Best practice in this case would be to avoid using 
# underscores for seed names, but rather give one word names i.e. insulabilateral instead of insula_bilateral.
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

    groupA=KO #edit this
    groupB=WT #edit this
    
    3dttest++ \
        -setA 03_subject_maps/*_${groupA}_*_${seed_name}_z.nii.gz \
        -setB 03_subject_maps/*_${groupB}_*_${seed_name}_z.nii.gz \
        -prefix 04_group_level/${seed_name}_results.nii.gz #-paired

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[0]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_group_mean_diff.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[1]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_group_Tstat.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[2]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_${groupA}_mean.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[3]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_${groupA}_Tstat.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[4]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_${groupB}_mean.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[5]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_${groupB}_Tstat.nii.gz

    rm 04_group_level/${seed_name}_results.nii.gz 

}
export -f seed_group_level_map

# Main starts here

mkdir 04_group_level

while read -r seed;
	do
	seed_group_level_map $seed
	done < $seedlist



