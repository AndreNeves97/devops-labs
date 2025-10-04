# Use official Terraform image with x86_64 architecture
FROM hashicorp/terraform:1.13.3

# Install additional tools
RUN apk add --no-cache \
    curl \
    jq \
    bash \
    git \
    aws-cli

# Set working directory
WORKDIR /workspace

# Create terraform user
RUN adduser -D -s /bin/bash terraform

# Switch to terraform user
USER terraform

# Set environment variables for better performance
ENV TF_IN_AUTOMATION=false
ENV TF_LOG=INFO
ENV TF_LOG_PATH=/workspace/terraform.log

# Default command
CMD ["--help"]
