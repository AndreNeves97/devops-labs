#!/bin/bash

# Docker-based Terraform wrapper script for M2 Pro MacBook
# This script runs Terraform commands in a Docker container to avoid ARM issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker Desktop first."
        exit 1
    fi
}

# Build the Docker image if it doesn't exist
build_image() {
    if ! docker images | grep -q "terraform-docker"; then
        print_status "Building Terraform Docker image..."
        docker build -f terraform-docker.Dockerfile -t terraform-docker .
        print_success "Docker image built successfully"
    fi
}

# Run Terraform command in Docker
run_terraform() {
    local cmd="$*"
    
    print_status "Running: terraform $cmd"
    print_status "Using x86_64 architecture to avoid ARM issues"
    
    docker run --rm -it \
        -v "$(pwd)":/workspace \
        -v "$HOME/.aws":/home/terraform/.aws:ro \
        -v "$HOME/.ssh":/home/terraform/.ssh:ro \
        -v "$HOME/.kube":/home/terraform/.kube:ro \
        -w /workspace \
        -e AWS_PROFILE="${AWS_PROFILE:-default}" \
        -e TF_IN_AUTOMATION=false \
        -e TF_LOG=INFO \
        -e TF_LOG_PATH=/workspace/terraform.log \
        terraform-docker \
        $cmd
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <terraform-command>"
        echo ""
        echo "Examples:"
        echo "  $0 init"
        echo "  $0 init -upgrade"
        echo "  $0 plan"
        echo "  $0 apply"
        echo "  $0 destroy"
        echo "  $0 validate"
        echo "  $0 fmt"
        echo ""
        exit 1
    fi


    check_docker
    build_image

    if [ "$1" == "init" ]; then
      # Check if backend-config is provided
      if echo "$*" | grep -q "backend-config"; then
        print_status "Initializing with backend configuration file..."
        rm -rf .terraform .terraform.tfstate.lock.info .terraform.lock.hcl terraform.log terraform.tfstate
        run_terraform init --upgrade "${@:2}"
      else
        print_warning "No backend-config specified. Using default backend configuration."
        print_status "To use a backend config file, run: $0 init -backend-config=terraform.tfbackend"
        rm -rf .terraform .terraform.tfstate.lock.info .terraform.lock.hcl terraform.log terraform.tfstate
        run_terraform init --upgrade --reconfigure
      fi
    else
      run_terraform "$@"
    fi
}

# Run main function with all arguments
main "$@"
