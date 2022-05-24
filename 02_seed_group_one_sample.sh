#!/bin/bash

# This script performs one-sample t-test of seed based connectivity mapping.
# Use this code in case you have only one group in your study
# Use this script after 01_seed_subjects_correlation_maps.sh as you need seedlist.txt
#
# NB: When running the script, make sure the seed names in the $path_seeds folder do not contain underscores.
# We have added an extra check that prints an error and kills the script if an underscore in present.
# To double check the script is appropriately grouping your subjects, the subjects in each group are listed
# in ts_list_${seed}.txt files in the 04_groups_log folder.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab,
# Istituto Italiano di Tecnologia, Rovereto
# (2018)
# -----------------------------------------------------------

seedlist=seedlist.txt

function check_seed_name {
  seed=$1
  seed_name=$(basename $seed .nii.gz)
  SUB='_' #offending character

  if [[ "$seed_name" == *"$SUB"* ]]; then
    echo "{$seed_name}: This naming convention is not permitted. Please use a seed name without underscores (_)"
    echo "Error: Aborting script"
    exit 1
  fi
}

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

function check_groups {

   seed=$1
   seed_name=$(basename $seed .nii.gz)

   path_ts=03_subject_maps

   echo $path_ts/*_${seed_name}_z.nii.gz | tr " " "\n" > 04_groups_log/tslist_${seed_name}.txt


}

# Main starts here

mkdir 04_group_level 04_groups_log

while read -r seed;
	do
	check_groups $seed
	done < $seedlist

while read -r seed;
	do
	check_seed_name $seed
	done < $seedlist

while read -r seed;
	do
	seed_group_level_map $seed
	done < $seedlist


exit
