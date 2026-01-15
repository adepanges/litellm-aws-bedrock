# LiteLLM for AWS Bedrock

A Docker-based LiteLLM proxy server configured for AWS Bedrock with Claude models. This setup provides an OpenAI-compatible API endpoint for accessing Claude models via AWS Bedrock.

## Features

- 🚀 OpenAI-compatible API for AWS Bedrock Claude models
- 🔐 Secure authentication with master key and virtual keys
- 🐳 Docker Compose setup with PostgreSQL and Redis
- 📊 Built-in UI for key management and usage tracking
- 🔧 Host AWS credentials mounting for secure authentication
- ⚡ Response caching with Redis
- 💾 Persistent storage for logs and metrics

## Prerequisites

- Docker and Docker Compose
- AWS CLI configured with Bedrock access
- AWS Profile with appropriate Bedrock permissions

## Project Structure

```
.
├── docker-compose.yml    # Main orchestration file
├── Dockerfile           # Custom LiteLLM image with boto3
├── config/
│   ├── .env            # Environment variables
│   └── config.yaml     # LiteLLM configuration
└── README.md           # This file
```

## Quick Start

### 1. Configure AWS Profile

Ensure your AWS profile is configured on the host machine:

```bash
aws configure --profile BedrockAde
```

### 2. Configure Environment

Edit [config/.env](config/.env) with your settings:

```env
MASTER_KEY=sk-1234567890abcdef1234567890abcdef

UI_USERNAME=admin
UI_PASSWORD=zeromind

# AWS Profile to use (optional - will use 'default' if not set)
AWS_PROFILE=BedrockAde

# AWS Region configuration
AWS_DEFAULT_REGION=us-east-1
AWS_REGION_NAME=us-east-1
```

### 3. Start the Services

```bash
docker-compose up -d
```

### 4. Access the UI

Open your browser to `http://localhost:4000`

- **Username:** `admin` (from [config/.env](config/.env))
- **Password:** `zeromind` (from [config/.env](config/.env))

## Configuration

### Model List

The following Claude models are configured in [config/config.yaml](config/config.yaml):

| Model Name | Bedrock Model ID |
|------------|------------------|
| `aws-bedrock:claude-opus-4-5` | us.anthropic.claude-opus-4-5-20251101-v1:0 |
| `aws-bedrock:claude-sonnet-4-5` | us.anthropic.claude-sonnet-4-5-20250929-v1:0 |
| `aws-bedrock:claude-haiku-4-5` | us.anthropic.claude-haiku-4-5-20251001-v1:0 |

### Docker Services

| Service | Description | Port |
|---------|-------------|------|
| litellm | Main proxy server | 4000 |
| postgres | Database for logs and metrics | 5432 |
| redis | Cache for responses | 6379 |

## Usage with Claude Code

### Setting up Claude Code to use Bedrock via LiteLLM

Create or edit your Claude Code `settings.json`:

**Linux/macOS/WSL:** `~/.claude/settings.json`

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "{LITELLM_VIRTUAL_KEY}",
    "ANTHROPIC_BEDROCK_BASE_URL": "http://0.0.0.0:4000/bedrock",
    "CLAUDE_CODE_USE_BEDROCK": "true",
    "CLAUDE_CODE_SKIP_BEDROCK_AUTH": "true",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "aws-bedrock:claude-sonnet-4-5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "aws-bedrock:claude-sonnet-4-5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "aws-bedrock:claude-opus-4-5",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "true"
  }
}
```

**Important:** Replace `{LITELLM_VIRTUAL_KEY}` with a virtual key generated from the LiteLLM UI.

### Generating Virtual Keys

1. Access the UI at `http://localhost:4000`
2. Login with your credentials
3. Navigate to **Key Management**
4. Create a new virtual key with:
   - **Models:** Select `aws-bedrock:*` or specific models
   - **Max Budget:** Set your desired budget limit
   - **Duration:** Set key expiration (optional)
5. Copy the generated key to your Claude Code `settings.json`

### Switching Profiles (Optional)

If you need to switch between different settings (e.g., work vs personal), you can use a tool like `cctx` or create multiple settings files:

```bash
# Example with symlinks
ln -s ~/.config/claude-code/settings-work.json ~/.config/claude-code/settings.json
ln -s ~/.config/claude-code/settings-personal.json ~/.config/claude-code/settings.json
```

## API Usage

Once running, the proxy provides an OpenAI-compatible API:

```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer YOUR_MASTER_KEY_OR_VIRTUAL_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "aws-bedrock:claude-sonnet-4-5",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## AWS Credentials

The Docker container mounts your host's AWS credentials:

```yaml
volumes:
  - ${HOME}/.aws:/root/.aws:ro
```

This ensures:
- The container uses your configured AWS profile
- Credentials are read-only (`:ro`) for security
- No secrets are stored in the container

## Maintenance

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f litellm
```

### Stop Services

```bash
docker-compose down
```

### Update LiteLLM

```bash
docker-compose build --no-cache
docker-compose up -d
```

### Clear Database/Cache

```bash
docker-compose down -v
docker-compose up -d
```

**Warning:** This will delete all usage logs and cached data.

## Troubleshooting

### AWS Credentials Not Working

1. Verify your AWS profile is configured:
   ```bash
   aws sts get-caller-identity --profile BedrockAde
   ```

2. Check that the profile name matches [config/.env](config/.env)

3. Ensure Bedrock is enabled in your AWS region

### Connection Refused

1. Verify all services are running:
   ```bash
   docker-compose ps
   ```

2. Check port 4000 is not in use by another application

### Virtual Key Not Working

1. Ensure the key has the correct models enabled
2. Check the key hasn't expired
3. Verify the budget hasn't been exceeded

## License

This project uses LiteLLM under its respective license. See [LiteLLM documentation](https://docs.litellm.ai/) for more information.

## Resources

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Claude Code Documentation](https://github.com/anthropics/claude-code)
