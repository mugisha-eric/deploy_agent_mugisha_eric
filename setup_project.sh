#!/usr/bin/env bash
Project_Version="" #  variable to store Project Version
Project_Dir="" # variable to store Project Directory

echo "Student Attendance Tracker Setup" # Display message about the setup script

read -p "Type Version of the project: " Project_Version # Get user input for Project Version
Project_Dir="../attendance_tracker_${Project_Version}" # Set Project Directory name based on user input

echo "Creating Project Directory: ${Project_Dir}" # Display message about creating project directory

mkdir -p "${Project_Dir}" # Create the project directory
echo "Project Directory created successfully." # Display success message

echo "Creating project files..." # Display message about creating project files
cp attendance_tracker.py "${Project_Dir}/" # Copy main script to project directory
mkdir -p "${Project_Dir}/helpers" # Create helpers subdirectory
cp assets.csv "${Project_Dir}/helpers/" # Copy helper files to helpers subdirectory
cp config.json "${Project_Dir}/helpers/"

mkdir -p "${Project_Dir}/reports" # Create reports subdirectory
cp reports.log "${Project_Dir}/reports/" # Copy reports log file to reports subdirectory
echo "Project files created successfully." # Display success message

