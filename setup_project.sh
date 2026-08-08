#!/usr/bin/env bash

PROJECT_VERSION=""
PROJECT_DIR=""

cleanup() {
    echo
    echo "Interrupt received."

    if [ -d "$PROJECT_DIR" ]; then
        ARCHIVE_NAME="${PROJECT_DIR}_archive.tar.gz"

        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR"

        rm -rf "$PROJECT_DIR"

        echo "Project archived as $ARCHIVE_NAME"
        echo "Incomplete project removed."
    fi

    exit 1
}

trap cleanup SIGINT

echo "Student Attendance Tracker Setup"

read -p "Enter project version: " PROJECT_VERSION

PROJECT_DIR="attendance_tracker_${PROJECT_VERSION}"

mkdir -p "$PROJECT_DIR"/Helpers
mkdir -p "$PROJECT_DIR"/reports

cp attendance_checker.py "$PROJECT_DIR/"
cp assets.csv "$PROJECT_DIR/Helpers/"
cp config.json "$PROJECT_DIR/Helpers/"
cp reports.log "$PROJECT_DIR/reports/"

echo
read -p "Would you like to change attendance thresholds? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then

    read -p "Warning threshold (default 75): " warning
    read -p "Failure threshold (default 50): " failure

    warning=${warning:-75}
    failure=${failure:-50}

    sed -i "s/\"warning\"[[:space:]]*:[[:space:]]*[0-9]*/\"warning\": $warning/" \
    "$PROJECT_DIR/Helpers/config.json"

    sed -i "s/\"failure\"[[:space:]]*:[[:space:]]*[0-9]*/\"failure\": $failure/" \
    "$PROJECT_DIR/Helpers/config.json"

    echo "Attendance thresholds updated in config.json."
    echo "Warning threshold: $warning"
    echo "Failure threshold: $failure"

fi

echo
echo "Checking Python..."

if python3 --version >/dev/null 2>&1
then
    echo "Python3 is installed."
else
    echo "WARNING: Python3 not found."
fi

echo
echo "Validating directory structure..."

if [ -f "$PROJECT_DIR/attendance_checker.py" ] &&
   [ -f "$PROJECT_DIR/Helpers/assets.csv" ] &&
   [ -f "$PROJECT_DIR/Helpers/config.json" ] &&
   [ -f "$PROJECT_DIR/reports/reports.log" ]
then
    echo "Directory structure is correct."
else
    echo "Directory validation failed."
fi

echo
echo "Setup completed successfully."