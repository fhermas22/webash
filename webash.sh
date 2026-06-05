#!/bin/bash

set -Eeuo pipefail

# =================================================================
# GLOBAL CONFIGURATION
# =================================================================
# Resolve the real script directory, including npm's symlinked bin path.
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
    script_dir=$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)
    linked_path=$(readlink "$SCRIPT_PATH")

    if [[ "$linked_path" == /* ]]; then
        SCRIPT_PATH="$linked_path"
    else
        SCRIPT_PATH="$script_dir/$linked_path"
    fi
done
SCRIPT_DIR=$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)

# package.json is the preferred version source when the full package is present.
VERSION="2.2.3"
if [ -f "$SCRIPT_DIR/package.json" ]; then
    package_version=$(sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$SCRIPT_DIR/package.json" | head -n 1)

    if [ -n "$package_version" ]; then
        VERSION="$package_version"
    fi
fi

# =================================================================
# TEXT COLORS & STYLES
# =================================================================
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
BOLD='\033[1m'
NEUTRAL='\033[0m'

trap 'echo -e "${RED}Error: command failed on line $LINENO.${NEUTRAL}" >&2' ERR

# =================================================================
# HELPER FUNCTIONS
# =================================================================
fail() {
    echo -e "${RED}Error: $*${NEUTRAL}" >&2
    exit 1
}

is_valid_project_name() {
    local name="$1"
    local name_pattern='^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$'

    [[ "$name" =~ $name_pattern ]]
}

print_project_name_rules() {
    echo -e "${RED}Invalid project name.${NEUTRAL}"
    echo "Use 1-64 characters: letters, numbers, hyphens, and underscores."
    echo "Start with a letter or number. Path separators and dots are not allowed."
}

html_escape() {
    local value="$1"

    value=${value//&/\&amp;}
    value=${value//</\&lt;}
    value=${value//>/\&gt;}
    value=${value//\"/\&quot;}
    value=${value//\'/\&#39;}

    printf '%s' "$value"
}

js_escape_double_quoted() {
    local value="$1"

    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//$'\n'/\\n}
    value=${value//$'\r'/\\r}
    value=${value//$'\t'/\\t}
    value=${value//</\\u003C}
    value=${value//>/\\u003E}
    value=${value//&/\\u0026}

    printf '%s' "$value"
}

# =================================================================
# INITIAL VARIABLES
# =================================================================
# Capture the current working directory path
current_dir=$(pwd)

# =================================================================
# SCRIPT EXECUTION
# =================================================================

# Step 1: Display the stylized CLI branding logo using the global version variable
echo -e "${BLUE}${BOLD} __      __      ___.                 .__     ${NEUTRAL}"
echo -e "${BLUE}${BOLD}/  \    /  \ ____\_ |__ _____    _____|  |__  ${NEUTRAL}"
echo -e "${CYAN}${BOLD}\   \/\/   // __ \| __ \\\\__  \  /  ___/  |  \ ${NEUTRAL}"
echo -e "${CYAN}${BOLD} \        /\  ___/| \_\ \/ __ \_\___ \|   Y  \\ ${NEUTRAL}"
echo -e "${GREEN}${BOLD}  \__/\  /  \___  >___  (____  /____  >___|  /${NEUTRAL}"
echo -e "${GREEN}${BOLD}       \/       \/    \/     \/     \/     \/ ${NEUTRAL} v${VERSION}"
echo -e "${CYAN}------------------------------------------------------------${NEUTRAL}"
echo ""

# Step 2: Perform environment scan and show current location
echo "Scanning environment..."
echo -e "Current working directory: ${BLUE}$current_dir${NEUTRAL}"
echo ""

# Step 3: Interactive prompt - Choose generation target location
target_dir="."
create_subfolder="n"

read -r -p "Do you want to create a dedicated subfolder for this project? (y/N): " location_choice || fail "No deployment mode selected."
location_choice=$(echo "$location_choice" | tr '[:upper:]' '[:lower:]')

if [[ "$location_choice" == "y" || "$location_choice" == "yes" ]]; then
    create_subfolder="y"
    echo ""
    
    # Loop to handle project naming and potential directory conflicts interactively
    while true; do
        read -r -p "Enter your web project name: " project_name || fail "No project name received."
        if [ -z "$project_name" ]; then
            project_name="web_project"
        fi

        if ! is_valid_project_name "$project_name"; then
            print_project_name_rules
            echo ""
            continue
        fi

        target_dir="./$project_name"

        # Check if the directory already exists
        if [[ -e "$target_dir" ]]; then
            echo -e "${YELLOW}Conflict detected: '${project_name}' already exists.${NEUTRAL}"
            read -r -p "Do you want to overwrite it? [y/N]: " overwrite_choice || fail "No overwrite choice received."
            overwrite_choice=$(echo "$overwrite_choice" | tr '[:upper:]' '[:lower:]')
            
            if [[ "$overwrite_choice" == "y" || "$overwrite_choice" == "yes" ]]; then
                echo -e "${RED}Removing existing directory...${NEUTRAL}"
                rm -rf -- "$target_dir"
                break # Conflict resolved by overwrite, exit the loop
            else
                echo -e "${CYAN}Let's pick another name.${NEUTRAL}"
                echo ""
                # Loop continues to ask for a new name
            fi
        else
            break # No conflict, exit the loop
        fi
    done
else
    # Dynamic detection: Use the name of the current folder as project name
    project_name=$(basename "$current_dir")
    echo -e "${YELLOW}Scaffolding will be deployed directly in the current directory.${NEUTRAL}"
fi
echo ""

project_name_html=$(html_escape "$project_name")
project_name_js=$(js_escape_double_quoted "$project_name")

echo "Initializing web project generation..."
echo ""

# Step 4: Create the main project root directory if a subfolder is requested
if [[ "$create_subfolder" == "y" ]]; then
    echo -e "Creating project root directory: ${YELLOW}$target_dir${NEUTRAL}..."
    mkdir -- "$target_dir"
    echo -e "-> ${GREEN}DONE${NEUTRAL}"
    echo ""
fi

# Step 5: Generate the required web architecture scaffolding (assets, src, styles)
echo -e "Generating project subdirectories inside: ${BLUE}$target_dir${NEUTRAL}..."
mkdir -p "$target_dir"/assets "$target_dir"/src "$target_dir"/styles
echo -e "-> ${GREEN}DONE${NEUTRAL}"
echo ""

# =================================================================
# FILE GENERATION & BOILERPLATE INJECTION
# =================================================================

# Step 6: Create and populate the global stylesheet with modern reset and dark theme variables
echo -e "Generating stylesheet: ${YELLOW}$target_dir/styles/style.css${NEUTRAL}..."
cat << EOF > "$target_dir"/styles/style.css
/* =================================================================
   Generated by Webash $VERSION - Core Stylesheet
   ================================================================= */

:root {
    --bg-color: #0f172a;
    --card-bg: #1e293b;
    --text-color: #f8fafc;
    --text-muted: #94a3b8;
    --primary: #38bdf8;
    --success: #4ade80;
}

/* Global Reset */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
    background-color: var(--bg-color);
    color: var(--text-color);
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

.container {
    background-color: var(--card-bg);
    padding: 2.5rem;
    border-radius: 16px;
    box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
    text-align: center;
    max-width: 500px;
    width: 100%;
    border: 1px solid rgba(255, 255, 255, 0.05);
}

h1 {
    color: var(--primary);
    font-size: 2.2rem;
    margin-bottom: 1rem;
}

p {
    color: var(--text-muted);
    font-size: 1.1rem;
    line-height: 1.6;
    margin-bottom: 1.5rem;
}

.badge {
    display: inline-block;
    background-color: rgba(74, 222, 128, 0.1);
    color: var(--success);
    padding: 0.5rem 1rem;
    border-radius: 9999px;
    font-size: 0.9rem;
    font-weight: 600;
}
EOF
echo -e "-> ${GREEN}DONE${NEUTRAL}"
echo ""

# Step 7: Create and populate the main JavaScript file with a DOMContentLoaded listener
echo -e "Generating main script: ${YELLOW}$target_dir/src/main.js${NEUTRAL}..."
cat << EOF > "$target_dir"/src/main.js
/**
 * Main Application Script - Generated by Webash $VERSION
 */

document.addEventListener('DOMContentLoaded', () => {
    const projectName = "$project_name_js";

    console.log('Project "' + projectName + '" successfully initialized!');
    
    // Add initialization logic and interactive code here
});
EOF
echo -e "-> ${GREEN}DONE${NEUTRAL}"
echo ""

# Step 8: Create and populate the index.html file with a structured semantic template
echo -e "Generating main template: ${YELLOW}$target_dir/index.html${NEUTRAL}..."
cat << EOF > "$target_dir"/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$project_name_html | Webash</title>
    <link rel="stylesheet" href="styles/style.css">
</head>
<body>

    <div class="container">
        <h1>$project_name_html</h1>
        <p>Your modern web structure has been successfully generated. Ready to start coding!</p>
        <span class="badge">Powered by Webash v$VERSION</span>
    </div>

    <script src="src/main.js"></script>
</body>
</html>
EOF
echo -e "-> ${GREEN}DONE${NEUTRAL}"
echo ""

# =================================================================
# FINALIZATION & ARCHITECTURE DISPLAY
# =================================================================
echo -e "${CYAN}-----------------------------------------------------------------------${NEUTRAL}"
echo -e "Your project ${BLUE}${BOLD}$project_name${NEUTRAL} has been created successfully!"
echo -e "${CYAN}-----------------------------------------------------------------------${NEUTRAL}"
echo ""

# Step 9: Display output directory tree structure depending on available system binaries
if command -v tree &> /dev/null; then
    tree "$target_dir"
else
    ls -R "$target_dir"
fi
