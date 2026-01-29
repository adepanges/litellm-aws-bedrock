# GitHub Copilot with Multiple Profiles

This guide explains how to authorize GitHub Copilot credentials and manage multiple profiles using symlinks.

## Overview

LiteLLM supports multiple GitHub Copilot profiles by storing credentials in separate directories and using symlinks to switch between them. This is useful for:

- **Work vs Personal**: Separate corporate and personal GitHub Copilot subscriptions
- **Multiple Organizations**: Different profiles for different clients or teams

## Directory Structure

```
project/
├── config/
│   └── litellm/
│       └── github_copilot → ../../copilot/secrets/work-copilot  # Symlink
└── copilot/
    ├── secrets/
    │   ├── work-copilot/
    │   │   ├── access-token
    │   │   └── api-key.json
    │   └── personal-copilot/
    │       ├── access-token
    │       └── api-key.json
    └── switch-profile.sh
```

## Setup

### Create a New Profile

To create and authenticate a new profile:

```bash
./copilot/authorize-profile.sh work-copilot
```

You'll see:
```
Please visit: https://github.com/login/device
Enter code: XXXX-XXXX
```

Visit the URL, enter the code, and authorize. Credentials will be saved in the profile directory. The directory is created automatically.

### Activate a Profile

Use the provided script to switch between profiles:

```bash
./copilot/switch-profile.sh work-copilot
```

The script will:
1. Create the profile directory if it doesn't exist
2. Update the symlink to point to the specified profile
3. Restart the Docker container

### Check Current Profile

```bash
readlink config/litellm/github_copilot
```

## Troubleshooting

### Re-authenticate a Profile

```bash
# Delete credentials for current profile
CURRENT_PROFILE=$(readlink config/litellm/github_copilot)
rm -f "$CURRENT_PROFILE"/access-token "$CURRENT_PROFILE"/api-key.json

# Restart to authenticate again
docker-compose restart
```

### Token Expired

LiteLLM automatically refreshes tokens. If issues persist:

```bash
CURRENT_PROFILE=$(readlink config/litellm/github_copilot)
rm -f "$CURRENT_PROFILE"/api-key.json
docker-compose restart
```
