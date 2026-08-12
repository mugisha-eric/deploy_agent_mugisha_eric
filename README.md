# Attendance Tracker — Project Factory

A shell script that automates the bootstrapping of a Student Attendance
Tracker workspace: it builds the folder structure, copies the source
files into place, lets you configure attendance thresholds on the fly,
and cleans up gracefully (with an archive) if you cancel mid-run.

## Video Walkthrough
[Watch the walkthrough video](https://youtu.be/frNUjAhxRDw)

[![Watch the video](https://img.youtube.com/vi/frNUjAhxRDw/maxresdefault.jpg)](https://www.youtube.com/watch?v=frNUjAhxRDw)

The video covers:
- The overall approach to the script
- How the directory structure is generated
- How `sed` is used to edit `config.json` in place
- How the `trap`/archive/cleanup logic works
- A live demo, including cancelling the script with `Ctrl+C`

## Requirements

- A Unix-like shell environment (Linux, macOS, or WSL on Windows)
- `bash`
- Core GNU utilities: `sed`, `tar`, `grep`, `mkdir`, `cp`, `rm`
- `python3` (optional — the script checks for it and warns if missing,
  but will still complete setup without it)

## Project Structure (before running)

Place `setup_project.sh` in the same folder as the four source files:

```
.
├── setup_project.sh
├── attendance_checker.py
├── assets.csv
├── config.json
└── reports.log
```

## What Gets Created

Running the script builds this structure (using whatever name you
enter as `{input}`):

```
attendance_tracker_{input}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
```

## How to Run

1. Make the script executable (first time only):

   ```bash
   chmod +x setup_project.sh
   ```

2. Run it:

   ```bash
   ./setup_project.sh
   ```

3. Follow the prompts:

   | Prompt | What to enter |
   |---|---|
   | `Enter project version/name:` | Any identifier, e.g. `class2025` → creates `attendance_tracker_class2025/` |
   | `Would you like to change attendance thresholds? (y/n):` | `y` to customize, `n` to keep defaults (Warning 75% / Failure 50%) |
   | `Warning threshold %:` | A whole number 0–100 (press Enter for default) |
   | `Failure threshold %:` | A whole number 0–100 (press Enter for default) |

4. The script then:
   - Checks whether `python3` is installed and prints a success/warning message
   - Validates that all expected files exist in the new project directory
   - Prints `Setup completed successfully.` if everything checks out

## Triggering the Archive Feature

The archive feature is tied to the **`SIGINT` signal trap** — it fires
if you interrupt the script while it's running.

To see it in action:

1. Start the script: `./setup_project.sh`
2. While it's running (e.g. right after entering the project name, or
   while it's waiting at a `read` prompt), press **`Ctrl+C`**.
3. The script will:
   - Print `Interrupt received.`
   - Compress whatever has been created so far into
     `attendance_tracker_{input}_archive` (a gzip archive, even though
     it doesn't carry a `.tar.gz` extension in its name)
   - Delete the incomplete `attendance_tracker_{input}/` directory
   - Exit

You can inspect the resulting archive with:

```bash
tar -tzf attendance_tracker_{input}_archive
```

or extract it with:

```bash
tar -xzf attendance_tracker_{input}_archive
```

## Notes

- If a directory named `attendance_tracker_{input}` already exists,
  the script will refuse to overwrite it — choose a different name or
  remove the old one first.
- Threshold input is validated as a whole number between 0 and 100;
  anything else is rejected before it reaches `sed`, to avoid
  corrupting `config.json`.
- If any of the four required source files are missing from the
  script's folder, setup aborts before creating any directories.
