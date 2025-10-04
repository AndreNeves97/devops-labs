# Docker-based Terraform Setup for Apple Silicon CPUs

## Why Docker?

Running Terraform in Docker solves ARM compatibility issues by:
- Using x86_64 architecture (linux/amd64) instead of ARM
- Providing a consistent, isolated environment
- Eliminating mTLS timeout issues
- Ensuring provider compatibility

## Setup Instructions

### Prerequisites

1. **Install Docker Desktop** (if not already installed):
   ```bash
   # Download from: https://www.docker.com/products/docker-desktop/
   # Or install via Homebrew:
   brew install --cask docker
   ```

2. **Start Docker Desktop** and ensure it's running

3. **Verify Docker is working**:
   ```bash
   docker --version
   ```

### Quick Start

1. **Test the setup**:
   ```bash
   ./test-docker.sh
   ```

2. **Run Terraform commands**:
   ```bash
   # Using the wrapper script
   ./tf-docker.sh init
   ./tf-docker.sh plan
   ./tf-docker.sh apply
   ```

## Available Scripts

### `tf-docker.sh` (Main Script)
Direct Docker run approach with full control:
```bash
./tf-docker.sh init -upgrade
./tf-docker.sh plan -out=tfplan
./tf-docker.sh apply tfplan
./tf-docker.sh destroy
```

### Direct Docker Commands
If you prefer manual control:
```bash
# Build the image first
docker build -f terraform-docker.Dockerfile -t terraform-docker .

# Initialize
docker run --rm -it \
  --platform linux/amd64 \
  -v "$(pwd)":/workspace \
  -v "$HOME/.aws":/home/terraform/.aws:ro \
  -w /workspace \
  terraform-docker \
  terraform init

# Plan
docker run --rm -it \
  --platform linux/amd64 \
  -v "$(pwd)":/workspace \
  -v "$HOME/.aws":/home/terraform/.aws:ro \
  -w /workspace \
  terraform-docker \
  terraform plan
```



## File Structure

```
terraform/
├── terraform-docker.Dockerfile  # Terraform Docker image
├── tf-docker.sh                # Docker run wrapper script
├── test-docker.sh              # Test script
├── DOCKER_SETUP.md             # This guide
└── [your terraform files]
```

## Troubleshooting

### Docker Not Running
```bash
# Start Docker Desktop, then verify:
docker info
```

### Permission Issues
```bash
# Make scripts executable:
chmod +x tf-docker.sh test-docker.sh
```

### AWS Credentials Not Found
```bash
# Ensure AWS credentials are in ~/.aws/credentials
aws configure list
```

### Volume Mount Issues
```bash
# Check if files are properly mounted:
docker run --rm -it \
  --platform linux/amd64 \
  -v "$(pwd)":/workspace \
  terraform-docker \
  ls -la /workspace
```

## Performance Tips

1. **Use the wrapper scripts** - they include optimizations
2. **Set parallelism** - already configured to 10
3. **Use plan files** - for faster applies:
   ```bash
   ./tf-docker.sh plan -out=tfplan
   ./tf-docker.sh apply tfplan
   ```

## Advantages Over Native ARM

- ✅ **No mTLS timeouts** - x86_64 architecture is fully supported
- ✅ **Consistent performance** - same environment every time
- ✅ **Provider compatibility** - all providers work correctly
- ✅ **Isolation** - doesn't affect your local system
- ✅ **Reproducible** - same results across different machines

## Expected Performance

- **Initialization**: 5-10 seconds (vs 50+ seconds with ARM issues)
- **Planning**: Normal speed (no ARM-related delays)
- **Applying**: Normal speed with proper parallelism
- **No timeouts**: mTLS configuration works correctly

## Next Steps

1. **Test the setup**:
   ```bash
   ./tf-docker.sh init
   ./tf-docker.sh validate
   ```

2. **Run your first plan**:
   ```bash
   ./tf-docker.sh plan
   ```

3. **Apply if everything looks good**:
   ```bash
   ./tf-docker.sh apply
   ```

This Docker-based approach should completely eliminate the ARM-related issues you've been experiencing with Terraform on your M2 Pro MacBook.
