-------------------------------------------------------------------------------------
DATE CREATED: 28 December, 2022
LAST UPDATED: 28 December, 2022
-------------------------------------------------------------------------------------

1. Each folder is numbered in the sequence that it has to be run. For instance, 1_clean_data has files that cleans data, 2_quality_checks has files that
checks the quality of data. For instance, you cannot check quality of data without it being shaped into some usable form. So 1_clean_data has to be run first.
2. The archived folder contains all archived code or folders that won't be used anymore and have become irrelevant for the project. 
It's just kept there if someone wants to refer back to some old code for ideas, reference or to quickly copy paste a task.
3. In each folder, there will always be a 1_master file. This runs all other code in the folder, so you don't need to open each script separately and run
them. Only run the 1_master file if necessary.
4. Folder descriptions:
1_clean_data: scripts to clean data for various tasks such as quality checks, data exploration and final analysis.
2_quality_checks: scripts to check quality of data.
3_explore_data: scripts for some rough work to get hands dirty with data. 
4_analysis_and_output: scripts for final analyses and output (figures and tables) based on what we explored and discussed.
 