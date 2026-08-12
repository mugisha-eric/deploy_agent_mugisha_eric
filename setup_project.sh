#!/usr/bin/env bash

set -u
set -o pipefail

# ---- Required source files (must exist alongside this script) ----
SOURCE_FILES=(attendance_checker.py assets.csv config.json reports.log)

PROJECT_VERSION=""
PROJECT_DIR=""

# ---------------------------------------------------------------------
# cleanup: fires on SIGINT and archives the current project directory 
# then removes it.
# ---------------------------------------------------------------------
cleanup() {
    echo
    echo "Interrupt received."

    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        local archive_name="${PROJECT_DIR}_archive"

        tar -czf "$archive_name" "$PROJECT_DIR" 2>/dev/null

        rm -rf "$PROJECT_DIR"

        echo "Project archived as: $archive_name"
        echo "Incomplete project directory removed."
    else
        echo "Nothing to archive yet."
    fi

    exit 1
}

trap cleanup SIGINT

# ---------------------------------------------------------------------
#    make sure the source files this script depends on
#    actually exist before we start creating anything.
# ---------------------------------------------------------------------
missing=0
for f in "${SOURCE_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: required source file not found: $f"
        missing=1
    fi
done

if [ "$missing" -eq 1 ]; then
    echo "Aborting: place this script in the same folder as the source files and re-run."
    exit 1
fi

echo "Student Attendance Tracker Setup"
echo "================================="

read -r -p "Enter project version/name: " PROJECT_VERSION

if [ -z "$PROJECT_VERSION" ]; then
    echo "ERROR: project version/name cannot be empty."
    exit 1
fi

PROJECT_DIR="attendance_tracker_${PROJECT_VERSION}"

if [ -d "$PROJECT_DIR" ]; then
    echo "ERROR: '$PROJECT_DIR' already exists. Choose a different name or remove it first."
    exit 1
fi

# ---------------------------------------------------------------------
# Making Directory architecture
# ---------------------------------------------------------------------
mkdir -p "$PROJECT_DIR"/Helpers
mkdir -p "$PROJECT_DIR"/reports

cp attendance_checker.py "$PROJECT_DIR/"
cp assets.csv "$PROJECT_DIR/Helpers/"
cp config.json "$PROJECT_DIR/Helpers/"
cp reports.log "$PROJECT_DIR/reports/"

CONFIG_FILE="$PROJECT_DIR/Helpers/config.json"

echo
echo "Base structure created at: $PROJECT_DIR"

# ---------------------------------------------------------------------
# Dynamic configuration (stream editing with sed)
# ---------------------------------------------------------------------
echo
read -r -p "Would you like to change attendance thresholds? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then

    read -r -p "Warning threshold %% (default 75): " warning
    read -r -p "Failure threshold %% (default 50): " failure

    warning=${warning:-75}
    failure=${failure:-50}

    # Validation: must be an integer 0-100
    for pair in "warning:$warning" "failure:$failure"; do
        name="${pair%%:*}"
        val="${pair##*:}"
        if ! [[ "$val" =~ ^[0-9]+$ ]] || [ "$val" -gt 100 ]; then
            echo "ERROR: $name threshold must be a whole number between 0 and 100. Got: '$val'"
            exit 1
        fi
    done

    
    update_threshold() {
        local key="$1" new_val="$2" file="$3"

        if grep -qE "\"${key}\"[[:space:]]*:[[:space:]]*\"[0-9]+%?\"" "$file"; then
            # Quoted value, optionally with a trailing %
            sed -i -E "s/(\"${key}\"[[:space:]]*:[[:space:]]*\")[0-9]+(%?\")/\1${new_val}\2/" "$file"
        elif grep -qE "\"${key}\"[[:space:]]*:[[:space:]]*[0-9]+" "$file"; then
            # Bare numeric value
            sed -i -E "s/(\"${key}\"[[:space:]]*:[[:space:]]*)[0-9]+/\1${new_val}/" "$file"
        else
            echo "WARNING: could not find a '$key' key in $file to update."
            return 1
        fi
    }

    update_threshold "warning" "$warning" "$CONFIG_FILE"
    update_threshold "failure" "$failure" "$CONFIG_FILE"

    echo "Attendance thresholds updated in config.json."
    echo "  Warning threshold: $warning"
    echo "  Failure threshold: $failure"
else
    echo "Keeping default thresholds (Warning 75% / Failure 50%)."
fi

# ---------------------------------------------------------------------
# Checking if python3 is installed and validating directory structure
# ---------------------------------------------------------------------
echo
echo "Checking for python3..."

if python3 --version >/dev/null 2>&1; then
    echo "OK: python3 is installed ($(python3 --version 2>&1))."
else
    echo "WARNING: python3 was not found on this system."
fi

echo
echo "Validating directory structure..."

structure_ok=1
for required in \
    "$PROJECT_DIR/attendance_checker.py" \
    "$PROJECT_DIR/Helpers/assets.csv" \
    "$PROJECT_DIR/Helpers/config.json" \
    "$PROJECT_DIR/reports/reports.log"
do
    if [ ! -f "$required" ]; then
        echo "  MISSING: $required"
        structure_ok=0
    fi
done

echo
if [ "$structure_ok" -eq 1 ]; then
    echo "Directory structure is correct."
    echo "Setup completed successfully."
else
    echo "Directory validation failed — see missing files above."
    exit 1
fi