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


## GitOps with ArgoCD

This project uses GitOps methodology with ArgoCD for continuous deployment. The GitOps repository containing Kubernetes manifests is located at: [https://github.com/AndreNeves97/devops-labs-gitops](https://github.com/AndreNeves97/devops-labs-gitops)

### How It Works

1. **Application Changes**: When code changes are pushed to the `main` branch of either the `backend` or `frontend` application, the CI/CD pipeline is triggered.

2. **Image Build & Push**: The pipeline:
   - Builds a new Docker image with the commit SHA as the tag
   - Pushes the image to Amazon ECR

3. **GitOps Manifest Update**: The pipeline automatically:
   - Checks out the GitOps repository
   - Updates the Kustomize manifest with the new image tag
   - Commits and pushes the changes to the GitOps repository

4. **ArgoCD Sync**: ArgoCD, which is synced with the GitOps repository, detects the changes and automatically:
   - Syncs the new image version to the Kubernetes cluster
   - Updates the running deployments with the new container images

### Pipeline Workflow

The CI/CD pipelines (`.github/workflows/backend-pipeline.yml` and similar for frontend) perform the following steps:

1. Checkout application code
2. Configure AWS credentials
3. Login to Amazon ECR
4. Build and push Docker image to ECR (tagged with commit SHA)
5. Checkout GitOps repository
6. Update Kustomize manifest with new image tag:
   ```bash
   kustomize edit set image <REGISTRY>/<REPOSITORY>=<REGISTRY>/<REPOSITORY>:<IMAGE_TAG>
   ```
7. Commit and push changes to GitOps repository

### ArgoCD Setup

ArgoCD should be configured to watch the GitOps repository and automatically sync changes. The ArgoCD application should be configured to:

- **Repository URL**: `https://github.com/AndreNeves97/devops-labs-gitops`
- **Path**: `devops-labs` (or the appropriate path in the repository)
- **Sync Policy**: Auto-sync enabled for automatic deployment


### Benefits of GitOps Approach

- **Version Control**: All Kubernetes manifests are version-controlled in Git
- **Audit Trail**: Every deployment change is tracked through Git commits
- **Rollback Capability**: Easy rollback by reverting Git commits
- **Consistency**: Single source of truth for cluster state
- **Automation**: Automatic synchronization reduces manual intervention
