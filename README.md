# DevOps Labs - Kubernetes Cluster Infrastructure

## Initial Setup

### Configure Terraform Backend

Before running Terraform, you need to configure the S3 backend for state storage:

1. **Copy the backend configuration template**:
   ```bash
   cd terraform
   cp terraform.tfbackend.example terraform.tfbackend
   ```

2. **Edit `terraform.tfbackend`** with your actual values:
   ```hcl
   bucket       = "terraform-remote-backend-bucket-<YOUR_ACCOUNT_ID>"
   key          = "terraform.tfstate"
   region       = "us-east-1"
   use_lockfile = true
   ```

3. **Initialize Terraform with the backend config**:
   ```bash
   terraform init -backend-config=terraform.tfbackend
   ```

   Or if using Docker (see `terraform/DOCKER_SETUP.md`):
   ```bash
   ./tf-docker.sh init -backend-config=terraform.tfbackend
   ```


### Configure Terraform Variables

1. **Copy the variables template**:
   ```bash
   cd terraform
   cp .variables.example.tf variables.tf
   ```

2. **Edit `variables.tf`** with your actual AWS account ID, role ARNs, and other configuration values.


## Setup Kubernetes Access

Setup kubernetes access:

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-cluster --role-arn arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>
```


## Test the cluster

Run test pod with nginx image:

```bash
kubectl run nginx --image=nginx
```


Forward the port to the pod:

```bash
kubectl port-forward nginx 8080:80
```

Access the pod from the browser:

```bash
http://localhost:8080
```


## Push the images to ECR

Login to ECR:
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```


Build and push the images to ECR:
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t <REPOSITORY>:latest --push backend/app
docker buildx build --platform linux/amd64,linux/arm64 -t <REPOSITORY>:latest --push frontend/app
```
