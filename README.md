# Gillespie_eLife_2024
Analysis code for Gillespie et al, eLife 2024, "Neurofeedback training can modulate task-relevant memory replay rate in rats"
Please contact Anna Gillespie (annagill (at) uw.edu) with any questions about this codebase.

Franklab repos needed:

- for data processing: trodes2ff_shared
- for analysis: filterframework_shared

Context: Data acquired 2017-2020 using trodes1.6.3 and 30-tet DKR drive version for 8 rats in two cohorts: Remy, Gus, Bernard, and Fievel in the neurofeedback cohort and Jaq, Roquefort, Despereaux, Montague in the control cohort. Data was extracted using D. Liu's python extractor to run Trodes export functions, then processed and analysed in Matlab 2020a

Figures were saved in as pdf or eps and formatted in Adobe Illustrator

Raw electrophysiology and behavior data in NWB format for all subjects is available on the DANDI Archive: the control cohort is located at https://dandiarchive.org/dandiset/000115 and the neurofeedback cohort is located at https://dandiarchive.org/dandiset/000629

Saved outputs containing preprocessed data can be used to run analyses and visualization in matlab instead of processing the raw NWB file. These outputs are downloadable from figshare at https://doi.org/10.6084/m9.figshare.24919590.v1

- dfs_rips_vsctrlrats.m -> NFrips_vsctrlrats.mat 
- dfs_rips_vsctrlrats_excltrig.m -> NFrips_vsctrlrats_excltrig.mat
- dfs_rips_timecourse.m -> NFtimecourse_allrats.mat
- dfs_ripsimulation.m -> NFripsimulation.mat
- dfs_ripcontent_vsctrlrats.m -> NFripcontent_vsctrlrats.mat

Code to generate figures:

Figure 1: no data visualizations

Supplementary Figure 1: 
- A: plotrawexampletraces.m, part 2
- B: dfs_rips_vsctrlrats_excltrig.m, part 3
- C: dfs_rips_vsctrlrats.m, part 6
- D: histology, image file upon request
- E: plot_task_params.m, part 1
 
Figure 2: 
- A: plotrawexampletraces.m, part 1
- B: dfs_rips_vsctrlrats.m, part 5
- C & D: dfs_rips_vsctrlrats.m, parts 1, 2, 4
- E: dfs_rips_vsctrlrats.m, part 3

Supplementary Figure 2
- A: dfs_rips_timecourse.m, part 1
- B: dfs_ripsimulation.m, part 1
- C: dfs_rips_vsctrlrats_excltrig.m, part 2
- D: dfs_rips_vsctrlrats_excltrig.m, part 4
- E: dfs_rips_vsctrlrats_excltrig.m, part 1
- F: dfs_rips_vsctrlrats.m, part 9
- G: dfs_rips_vsctrlrats.m, part 10

Figure 3
- A: dfs_rips_vsctrlrats.m, part 7
- B & C: dfs_rips_vsctrlrats.m, part 8

Figure 4
- A, B, C: dfs_plotripcontent.m
- D & E: dfs_ripcontent_vsctrlrats.m, part 1
- F: dfs_ripcontent_vsctrlrats.m, part 2
- G: dfs_ripcontent_vsctrlrats.m, part 3

Supplementary Figure 3:
- A: dfs_ripcontent_vsctrlrats.m, part 4

Figure 5:
- A & B: dfs_ripcontent_vsctrlrats.m, part 5

Supplementary Figure 4:
- A: dfs_ripcontent_vsctrlrats.m, part 5


