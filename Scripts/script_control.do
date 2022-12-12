// Directories
global directory "G:\My Drive\BIFYA\Fast-Facts\2022-December"
global command_files "$directory\Command-Files"
global raw_data "$directory\Raw-Data"
global analysis_data "$directory\Analysis-Data"
global output "$directory\Output"

// Visualization Settings
ssc install blindschemes, replace
set scheme plotplain
graph set window fontface "Lato Bold"
