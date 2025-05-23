import os
import datetime

# --- Configuration ---
# Defaults to the current directory where the script is run
DEFAULT_PROJECT_ROOT = os.getcwd()
DEFAULT_OUTPUT_FILE = "project_snapshot_py.txt"

EXCLUDED_FOLDERS_AND_FILES = [
    # Common VCS
    ".git",
    ".hg",
    ".svn",
    # IDE and editor specific
    ".idea",
    ".vscode",
    # Flutter/Dart specific build/tooling
    ".dart_tool",
    "build",
    # iOS specific
    "ios/Pods",
    "ios/.symlinks",
    "ios/Flutter/App.framework",
    "ios/Flutter/Flutter.framework",
    "ios/Flutter/engine",
    "ios/DerivedData",
    "ios/Runner/Assets.xcassets", # Often contains many images
    "ios/Runner.xcworkspace/xcuserdata",
    # Android specific
    "android/.gradle",
    "android/.idea",
    "android/app/build",
    "android/build",
    "android/key.properties", # Sensitive
    "android/local.properties", # Local paths
    "android/gradlew", # Executable
    "android/gradlew.bat", # Executable
    "android/gradle/wrapper/gradle-wrapper.jar", # Binary
    # Other platform specific build artifacts
    "linux/flutter/ephemeral",
    "macos/flutter/ephemeral",
    "windows/flutter/ephemeral",
    "web/build",
    # Common generated or lock files
    "pubspec.lock",
    "*.iml", ".ipr", ".iws", # IntelliJ
    # Specific files to exclude
    DEFAULT_OUTPUT_FILE # Don't include the output file itself if run multiple times
]

# Exclude file extensions (mostly binary, assets, or irrelevant for code review)
EXCLUDED_EXTENSIONS = [
    # Common binary/asset types
    ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp", # Images
    ".ico",
    ".mp3", ".wav", ".ogg", ".m4a",                  # Audio
    ".mp4", ".mov", ".avi", ".webm",                 # Video
    ".ttf", ".otf", ".woff", ".woff2",                # Fonts
    ".zip", ".gz", ".tar", ".rar", ".7z",             # Archives
    ".a", ".so", ".dll", ".exe", ".obj", ".o", ".dylib", # Compiled binaries
    ".jar", ".class",
    ".keystore", ".jks",                             # Keystores
    ".log",
    ".DS_Store",                                     # macOS
    ".swp", ".swo",                                  # Vim swap files
    # Consider if you want to exclude assets folder content based on extensions
    # or exclude the entire 'assets/' folder by adding it to EXCLUDED_FOLDERS_AND_FILES
]

def should_exclude(path, project_root):
    """Checks if a given path (file or directory) should be excluded."""
    relative_path = os.path.relpath(path, project_root).replace(os.sep, '/')

    # 1. Check against excluded folders and specific files
    for excluded_item in EXCLUDED_FOLDERS_AND_FILES:
        if relative_path.startswith(excluded_item + '/') or relative_path == excluded_item:
            return True

    # 2. If it's a file, check its extension
    if os.path.isfile(path):
        _, ext = os.path.splitext(path)
        if ext.lower() in EXCLUDED_EXTENSIONS:
            return True
    return False

def create_project_snapshot(project_root=DEFAULT_PROJECT_ROOT, output_file_name=DEFAULT_OUTPUT_FILE):
    """
    Walks through the project directory, collects relevant file contents,
    and writes them to a single output file.
    """
    output_file_path = os.path.join(project_root, output_file_name)
    # Add the dynamic output file name to excluded items to prevent self-inclusion
    if output_file_name not in EXCLUDED_FOLDERS_AND_FILES:
        EXCLUDED_FOLDERS_AND_FILES.append(output_file_name)


    print(f"Project Root: {project_root}")
    print(f"Output File: {output_file_path}")

    with open(output_file_path, "w", encoding="utf-8", errors="ignore") as outfile:
        outfile.write("Flutter Project Snapshot (Python Script)\n")
        outfile.write(f"Project Root: {project_root}\n")
        outfile.write(f"Snapshot created on: {datetime.datetime.now().isoformat()}\n")
        outfile.write("=" * 80 + "\n\n")

        for root, dirs, files in os.walk(project_root, topdown=True):
            # --- Directory Exclusion ---
            # Modify dirs in-place to prevent os.walk from traversing into them
            dirs[:] = [d for d in dirs if not should_exclude(os.path.join(root, d), project_root)]

            for filename in files:
                filepath = os.path.join(root, filename)
                if should_exclude(filepath, project_root):
                    continue

                relative_filepath = os.path.relpath(filepath, project_root).replace(os.sep, '/')
                print(f"Processing: {relative_filepath}")

                outfile.write(f"=== FILE: {relative_filepath} ===\n")
                outfile.write("-" * 50 + "\n")
                try:
                    with open(filepath, "r", encoding="utf-8", errors="ignore") as infile:
                        outfile.write(infile.read())
                except Exception as e:
                    outfile.write(f"[Error reading file: {e}]\n")
                outfile.write("\n" + "-" * 50 + "\n")
                outfile.write(f"=== END OF FILE: {relative_filepath} ===\n\n\n")

        outfile.write("=" * 80 + "\n")
        outfile.write("Snapshot Complete.\n")

    print(f"Project snapshot created: {output_file_path}")

if __name__ == "__main__":
    # You can customize the project root and output file name here if needed
    # For example, if your script is not in the project root:
    # current_project_path = r"C:\Users\levndays\Desktop\muscle_up"
    # create_project_snapshot(project_root=current_project_path)

    # By default, uses the directory where the script is run as the project root
    create_project_snapshot()