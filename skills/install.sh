#!/usr/bin/env bash
set -eo pipefail

mkdir -p "$HOME/.copilot/skills"

skills_folder=$(dirname "${BASH_SOURCE[0]}")
skills=$(find "$skills_folder" -type f -name "SKILL.md" -exec dirname {} \;)

echo "Adding symbolic links for all skills in $skills_folder to $HOME/.copilot/skills"

for skill in $skills; do
    skill_name=$(basename "$skill")
    skill_folder=$(realpath "$skill")
    target_folder="$HOME/.copilot/skills/$skill_name"

    # if target folder already exists and is not a symbolic link, remove folder and create symbolic link
    if [ -e "$target_folder" ] && [ ! -L "$target_folder" ]; then
        echo "Warning: Target folder $target_folder already exists and is not a symbolic link."
        echo "Removing folder and creating symbolic link for skill: $skill_name"
        read -rp "Remove? [ctrl-c to cancel] "
        rm -rf "$target_folder"
    fi

    # check if symolic link already exists, if it does, skip installation
    if [ -L "$target_folder" ]; then
        echo "Symbolic link for skill: $skill_name already exists, skipping installation"
        continue
    fi

    echo "Installing skill: $skill_name to $target_folder"
    ln -s "$skill_folder" "$target_folder"
done
