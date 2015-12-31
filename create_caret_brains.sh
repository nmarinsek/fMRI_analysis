#!/bin/sh
chmod a+x create_caret_brains.sh

#  create_caret_brains.sh
#  This script creates caret brains for all of the contrasts of a higher-level FSL analysis
#
#  Created by Nikki Marinsek on 11/28/15.
#
#

# Before running this script make sure to:
# 1. enable caret commands (set environment path in .bash_profile)
# 2. create a new spec file to add the mappings to
spec_file="/Applications/caret/data_files/fmri_mapping_files/MAPPING_PROCEDURES/new_categories_manuscript_contrasts_BOTH_TEMPLATE.spec"

# mapping files
left_coord_file="/Applications/caret/data_files/fmri_mapping_files/MAPPING_PROCEDURES/Human.PALS_B12.LEFT_AVG_B1-12.FIDUCIAL_FLIRT.clean.73730.coord"
right_coord_file="/Applications/caret/data_files/fmri_mapping_files/MAPPING_PROCEDURES/Human.PALS_B12.RIGHT_AVG_B1-12.FIDUCIAL_FLIRT.clean.73730.coord"
left_topo_file="/Applications/caret/data_files/fmri_mapping_files/Human.sphere_6.LEFT_HEM.73730.topo"
right_topo_file="/Applications/caret/data_files/fmri_mapping_files/Human.sphere_6.RIGHT_HEM.73730.topo"
algorithm="METRIC_INTERPOLATED_VOXEL"
scene="/Applications/caret/data_files/fmri_mapping_files/MAPPING_PROCEDURES/PALS_BOTH_TEMPLATE-for-MAPPING.scene"

# window dimensions
wX="512"
wY="512"

# folder with all the high level contrasts
folder="/Users/nikki51490/Documents/Categories_Project/fMRI_exp/fMRI_data/basic_manuscript_contrasts/new_highlevel"

# navigate to the folder with all the high level contrasts
cd ${folder}
mkdir caret_brains
mkdir caret_brains/metric_files


#loop through the contrasts
for contrast in 1 2 3 4 5 6 7 8 9 10
    do

    #------------------------------------  map contrasts to caret surfaces ------------------------------------

    # map the thresholded z-map volume to the caret brain surface -- left hemisphere
    caret_command -volume-map-to-surface \
        ${left_coord_file}          \
        ${left_topo_file}           \
        ""                          \
        ${folder}/caret_brains/metric_files/cope${contrast}_left.metric \
        ${algorithm}                \
        cope${contrast}_output.gfeat/cope1.feat/thresh_zstat1.nii.gz

    # map the thresholded z-map volume to the caret brain surface -- right hemisphere
    caret_command -volume-map-to-surface \
        ${right_coord_file}         \
        ${right_topo_file}          \
        ""                          \
        ${folder}/caret_brains/metric_files/cope${contrast}_right.metric \
        ${algorithm}                \
        cope${contrast}_output.gfeat/cope1.feat/thresh_zstat1.nii.gz

    # change the name of the data column in the metric file
    caret_command -metric-set-column-name ${folder}/caret_brains/metric_files/cope${contrast}_left.metric "1" c${contrast}_left    #LH
    caret_command -metric-set-column-name ${folder}/caret_brains/metric_files/cope${contrast}_right.metric "1" c${contrast}_right   #RH

    # add metric files to the spec file
    caret_command -spec-file-add    \
        ${spec_file}                \
        metric_file                 \
        ${folder}/caret_brains/metric_files/cope${contrast}_left.metric
    caret_command -spec-file-add    \
        ${spec_file}                \
        metric_file                 \
        ${folder}/caret_brains/metric_files/cope${contrast}_right.metric

    #---------------------------------- take pictures of caret brains ------------------------------------------

    # remove spec files that don't exist
    caret_command -spec-file-clean ${spec_file}

    # open the LEFT caret brain in a scene & take a picture of lateral and medial views
    caret_command -scene-create     \
        ${spec_file}                \
        ${scene}                    \
        ${scene}                    \
        ${contrast}_left            \
        -surface-overlay            \
        "PRIMARY"                   \
        "METRIC"                    \
        c${contrast}_left           \
        c${contrast}_left           \
        -window-surface-files       \
        "WINDOW_MAIN"               \
        ${wX}                       \
        ${wY}                       \
        ${left_coord_file}          \
        ${left_topo_file}           \
        "LATERAL"                   \
        -window-surface-files       \
        "WINDOW_2"                  \
        ${wX}                       \
        ${wY}                       \
        ${left_coord_file}          \
        ${left_topo_file}           \
        "MEDIAL"
    caret_command -show-scene       \
        ${spec_file}                \
        ${scene}                    \
        ${contrast}_left            \
        -image-file                 \
        ${folder}/caret_brains/c${contrast}_LH.jpg \
        "1"

    # open the RIGHT caret brain in a scene & take a picture of lateral and medial views
    caret_command -scene-create     \
        ${spec_file}                \
        ${scene}                    \
        ${scene}                    \
        ${contrast}_right           \
        -surface-overlay            \
        "PRIMARY"                   \
        "METRIC"                    \
        c${contrast}_right          \
        c${contrast}_right          \
        -window-surface-files       \
        "WINDOW_MAIN"               \
        ${wX}                       \
        ${wY}                       \
        ${right_coord_file}         \
        ${right_topo_file}          \
        "LATERAL"                   \
        -window-surface-files       \
        "WINDOW_2"                  \
        ${wX}                       \
        ${wY}                       \
        ${right_coord_file}         \
        ${right_topo_file}          \
        "MEDIAL"
    caret_command -show-scene       \
        ${spec_file}                \
        ${scene}                    \
        ${contrast}_right           \
        -image-file                 \
        ${folder}/caret_brains/c${contrast}_RH.jpg \
        "1"

    # make a composite image with the individual caret brain views
    caret_command -image-combine    \
        "2"                         \
        ${folder}/caret_brains/composite_c${contrast}.jpg  \
        ${folder}/caret_brains/c${contrast}_LH.jpg \
        ${folder}/caret_brains/c${contrast}_RH.jpg

done
