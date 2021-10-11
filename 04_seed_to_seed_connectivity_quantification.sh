#!/bin/bash

# This script calculates functional connectivity (i.e. Pearson's correlation) 
# between one target roi (main_roi.nii.gz) and one or multiple rois. 
#
# Then you can use this code to carry out quantifications of functional connectivity 
# between two brain regions, either part of an atlas or manually drawn. 
# This code also extracts values that can be then fed to repeated measure ANOVA, for 
# example this code has been used to create Figure 2 of Pagani, JNeurosci 2019.
# (Shank3 study https://www.jneurosci.org/content/39/27/5299).
#
# The script outputs Pearson's correlation between regions in a txt file. 
# The target roi must be in the same folder of the other rois, please specify 
# the name of the main rois.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2017)
# -----------------------------------------------------------


path_ts=path/to/ts/ # edit this
path_roi=path/to/rois/ # edit this
main_VOI=path/to/rois/main_roi.nii.gz # edit this


# this extracts the signal from the rois
for roi in $path_roi/* ; do   
for ts in $path_ts/* ; do

    roi_name=$(basename $roi .nii.gz)
    ts_name=$(basename $ts .nii.gz)
    
    fslmeants -i $ts -m $roi \
                | grep -v '^$' \
                | cut -f1 -d' ' \
                > ${roi_name}_${ts_name}_ts.txt
done
done


# this correlates the main VOI with all the other VOIs
for roi in $path_roi/* ; do
for ts in $path_ts/* ; do

    roi_name=$(basename $roi .nii.gz)
    ts_name=$(basename $ts .nii.gz)
    main_VOI_name=$(basename $main_VOI .nii.gz)
    
    1dCorrelate \
		${main_VOI_name}_${ts_name}_ts.txt \
		${roi_name}_${ts_name}_ts.txt \
		>> rm.correlation.txt

done
done

# this keeps only roi names and correlation coefficient from the output of 1dCorrelate
awk 'NR == 1 || NR % 4 == 0' rm.correlation.txt \
	| awk '{print $1,$2,$3}' >> rsfmri_connectivity.txt

rm rm.correlation.txt
rm *_ts.txt

exit
