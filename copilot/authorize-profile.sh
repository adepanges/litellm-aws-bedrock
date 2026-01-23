#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <profile-name>"
  exit 1
fi

PROFILE_NAME="$1"
GITHUB_COPILOT_TOKEN_DIR="copilot/secrets/$PROFILE_NAME" litellm --config copilot/config.yaml
