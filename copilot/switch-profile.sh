#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./switch-profile.sh <profile-name>"
    echo "Example: ./switch-profile.sh work-copilot"
    exit 1
fi

PROFILE_NAME=$1
PROFILE_PATH="copilot/secrets/$PROFILE_NAME"

if [ ! -d "$PROFILE_PATH" ]; then
    echo "Creating profile directory: $PROFILE_PATH"
    mkdir -p "$PROFILE_PATH"
fi

# Ensure target directory exists
mkdir -p config/litellm

# Remove existing symlink
rm -rf config/litellm/github_copilot

# Create new symlink
ln -s "../../$PROFILE_PATH" config/litellm/github_copilot

echo "Switched to profile: $PROFILE_NAME"
echo "Symlink: config/litellm/github_copilot → $PROFILE_PATH"
ls -la config/litellm/github_copilot

docker-compose down && docker-compose up -d