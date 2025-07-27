# GoIT DevOps Infrastructure

A comprehensive DevOps infrastructure project built with Terraform, featuring AWS EKS, RDS, ECR, Jenkins, ArgoCD, Prometheus, Grafana, and a Django application deployment pipeline.

## 🏗️ Architecture Overview

This project deploys a complete cloud-native infrastructure on AWS including:

- **VPC**: Multi-AZ networking with public/private subnets
- **EKS**: Kubernetes cluster with managed node groups
- **RDS**: PostgreSQL database (configurable for Aurora)
- **ECR**: Container registry for Docker images
- **Jenkins**: CI/CD pipeline automation
- **ArgoCD**: GitOps deployment management
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Metrics visualization and dashboards
- **Django App**: Sample application with Helm charts

## 📁 Project Structure

```
goit-devops-tasks/
├── main.tf                     # Main Terraform configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── backend.tf                  # S3 remote state backend
├── charts/                     # Helm charts
│   └── django-app/            # Django application chart
├── docker/                     # Docker configurations
│   └── django/                # Django containerization
└── modules/                    # Terraform modules
    ├── vpc/                   # VPC networking module
    ├── eks/                   # EKS cluster module
    ├── rds/                   # Database module (RDS/Aurora)
    ├── ecr/                   # Container registry module
    ├── jenkins/               # Jenkins CI/CD module
    ├── argo_cd/               # ArgoCD GitOps module
    ├── monitoring/            # Prometheus & Grafana module
    └── s3-backend/            # Terraform state backend
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- kubectl
- Docker
- Helm 3.x

### 1. Clone Repository

```bash
git clone https://github.com/andreyzp87/goit-devops-tasks.git
cd goit-devops-tasks
```

### 2. Configure Variables

Create `terraform.tfvars`:

```hcl
github_username              = "your-github-username"
github_token                 = "your-github-token"
postgres_password            = "your-secure-password"
postgres_db                  = "myapp"
postgres_user                = "postgres"
grafana_admin_password       = "secure-grafana-password"
enable_monitoring_persistence = true
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### 4. Configure kubectl

```bash
aws eks update-kubeconfig --region eu-central-1 --name goit-devops-eks-cluster
```

## 📦 Modules Documentation

### VPC Module

Creates a multi-AZ VPC with public and private subnets, Internet Gateway, and NAT Gateway.

**Usage:**
```hcl
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  vpc_name           = "my-vpc"
}
```

**Outputs:**
- `vpc_id` - VPC identifier
- `public_subnet_ids` - Public subnet IDs
- `private_subnet_ids` - Private subnet IDs
- `internet_gateway_id` - Internet Gateway ID
- `nat_gateway_id` - NAT Gateway ID

### EKS Module

Deploys a managed Kubernetes cluster with worker nodes, OIDC provider, and EBS CSI driver.

**Usage:**
```hcl
module "eks" {
  source           = "./modules/eks"
  cluster_name     = "my-eks-cluster"
  cluster_version  = "1.28"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  node_group_name  = "worker-nodes"
  instance_types   = ["t3.medium"]
  desired_capacity = 2
}
```

**Features:**
- ✅ EKS cluster with managed node groups
- ✅ OIDC provider for IRSA (IAM Roles for Service Accounts)
- ✅ EBS CSI driver for persistent volumes
- ✅ Configurable node scaling

### RDS Module

Universal database module supporting both standard RDS and Aurora clusters.

**Standard RDS:**
```hcl
module "rds" {
  source = "./modules/rds"
  
  name                = "my-database"
  use_aurora         = false
  engine             = "postgres"
  engine_version     = "17.2"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  
  db_name            = "myapp"
  username           = "postgres"
  password           = var.postgres_password
  
  vpc_id             = module.vpc.vpc_id
  subnet_private_ids = module.vpc.private_subnet_ids
  publicly_accessible = false
}
```

**Aurora Cluster:**
```hcl
module "rds" {
  source = "./modules/rds"
  
  name                       = "aurora-cluster"
  use_aurora                = true
  engine_cluster            = "aurora-postgresql"
  engine_version_cluster    = "15.3"
  aurora_instance_count     = 2
  
  # ... other parameters
}
```

### ECR Module

Creates a container registry with lifecycle policies and vulnerability scanning.

**Usage:**
```hcl
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "my-app"
  scan_on_push = true
}
```

### Jenkins Module

Deploys Jenkins with Kubernetes integration and pre-configured pipelines.

**Features:**
- ✅ Jenkins with Kubernetes plugin
- ✅ IRSA for ECR access
- ✅ GitHub integration
- ✅ Pre-configured Job DSL seed job
- ✅ Persistent volume with EBS

**Usage:**
```hcl
module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  github_username   = var.github_username
  github_token      = var.github_token
}
```

### ArgoCD Module

Deploys ArgoCD with GitOps applications and repository configurations.

**Features:**
- ✅ ArgoCD server with LoadBalancer
- ✅ Automatic application deployment
- ✅ GitHub repository integration
- ✅ Self-healing applications

### Monitoring Module

Deploys a complete monitoring stack with Prometheus and Grafana using the kube-prometheus-stack.

**Features:**
- ✅ Prometheus for metrics collection and storage
- ✅ Grafana for visualization and dashboards
- ✅ AlertManager for alerting
- ✅ Node Exporter for node metrics
- ✅ Kube State Metrics for Kubernetes metrics
- ✅ Pre-configured dashboards for Kubernetes monitoring
- ✅ Persistent storage for metrics retention
- ✅ LoadBalancer service for external access

**Usage:**
```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  namespace                = "monitoring"
  cluster_name            = module.eks.cluster_name
  prometheus_storage_size = "50Gi"
  grafana_storage_size    = "10Gi"
  grafana_admin_password  = var.grafana_admin_password
  enable_persistence      = true
  install_separate_grafana = false
}
```

**Configuration Options:**
- `prometheus_storage_size` - Storage size for Prometheus metrics (default: 50Gi)
- `grafana_storage_size` - Storage size for Grafana data (default: 10Gi)
- `enable_persistence` - Enable persistent storage (default: true)
- `install_separate_grafana` - Install standalone Grafana vs integrated (default: false)
- `grafana_admin_password` - Admin password for Grafana access

**Default Dashboards Included:**
- Kubernetes cluster overview
- Node metrics and resource usage
- Pod and container monitoring
- Persistent volume metrics
- Network monitoring
- Application performance metrics

## 🔧 Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `github_username` | GitHub username for repository access | Yes |
| `github_token` | GitHub Personal Access Token | Yes |
| `postgres_password` | Database password | Yes |
| `postgres_db` | Database name | No |
| `postgres_user` | Database username | No |
| `grafana_admin_password` | Grafana admin password | No |
| `enable_monitoring_persistence` | Enable monitoring persistence | No |

### AWS Resources Created

- **VPC**: 1 VPC, 6 subnets (3 public, 3 private), IGW, NAT Gateway
- **EKS**: 1 cluster, 1 node group (2-3 t3.medium instances)
- **RDS**: 1 PostgreSQL instance (or Aurora cluster)
- **ECR**: 1 repository with lifecycle policy
- **IAM**: Multiple roles for EKS, RDS, and service accounts
- **LoadBalancers**: 3 (Jenkins, ArgoCD, Grafana)
- **EBS Volumes**: Multiple for persistent storage (Jenkins, Prometheus, Grafana)

## 📊 Outputs

After deployment, Terraform provides these outputs:

```bash
# Get important endpoints
terraform output eks_cluster_endpoint
terraform output ecr_repository_url
terraform output postgres_endpoint

# Get monitoring information
terraform output prometheus_service
terraform output grafana_service
terraform output grafana_admin_password_command

# Access Jenkins
kubectl get svc -n jenkins

# Access ArgoCD
kubectl get svc -n argocd

# Access Grafana
kubectl get svc -n monitoring
```

## 🔒 Security Best Practices

- ✅ Private subnets for database and worker nodes
- ✅ Security groups with minimal required access
- ✅ IAM roles with least privilege
- ✅ Encrypted S3 state backend
- ✅ ECR vulnerability scanning
- ✅ Secrets stored securely in Kubernetes
- ✅ Monitoring data retention policies
- ✅ Secure Grafana authentication

## 📋 Common Tasks

### Access Jenkins

```bash
# Get Jenkins LoadBalancer URL
kubectl get svc -n jenkins jenkins

# Get initial admin password
kubectl get secret -n jenkins jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d
```

### Access ArgoCD

```bash
# Get ArgoCD server URL
kubectl get svc -n argocd argo-cd-argocd-server

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

### Access Grafana

```bash
# Get Grafana LoadBalancer URL
kubectl get svc -n monitoring prometheus-grafana

# Get Grafana admin password
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode

# Alternative: Use terraform output
terraform output grafana_admin_password_command
```

### Access Prometheus

```bash
# Get Prometheus service
kubectl get svc -n monitoring prometheus

# Port forward to access Prometheus UI locally
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Access at http://localhost:9090
```

### Monitoring Setup

**Default Grafana Dashboards:**
- **Kubernetes / Compute Resources / Cluster** - Overall cluster resource usage
- **Kubernetes / Compute Resources / Namespace (Pods)** - Per-namespace pod metrics
- **Kubernetes / Compute Resources / Node (Pods)** - Per-node resource utilization
- **Node Exporter / Nodes** - Detailed node system metrics

**Custom Metrics and Alerts:**
1. Access Grafana dashboard
2. Navigate to "+" → "Dashboard" to create custom dashboards
3. Use PromQL queries to create custom metrics
4. Set up alerts in AlertManager configuration

**Prometheus Targets:**
- Kubernetes API server
- Node exporters on all nodes
- Kube-state-metrics
- Application metrics (if configured)

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy

# Note: Some resources may need manual cleanup:
# - ECR images
# - EBS volumes (if persistent)
# - LoadBalancer-created AWS resources
# - Prometheus metrics data
# - Grafana dashboards and configurations
```

## 🛠️ Troubleshooting

### Common Issues

1. **EKS cluster access denied**
   ```bash
   aws eks update-kubeconfig --region eu-central-1 --name goit-devops-eks-cluster
   ```

2. **Jenkins pods stuck in Pending**
   - Check if EBS CSI driver is installed
   - Verify storage class exists

3. **ArgoCD can't access repository**
   - Verify GitHub token permissions
   - Check repository URL and credentials

4. **Database connection failed**
   - Verify security group rules
   - Check if database is in correct subnet group

5. **Prometheus/Grafana pods not starting**
   - Check if persistent volumes are properly created
   - Verify storage class configuration
   - Check resource limits and node capacity

6. **Grafana dashboard not loading**
   - Verify Prometheus datasource configuration
   - Check network connectivity between Grafana and Prometheus
   - Validate service discovery settings

7. **Missing metrics in Prometheus**
   - Check target discovery in Prometheus UI
   - Verify service monitors and pod monitors
   - Check network policies and security groups

### Useful Commands

```bash
# Check EKS cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Check monitoring stack
kubectl get pods -n monitoring
kubectl get pv,pvc -n monitoring

# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Then visit http://localhost:9090/targets

# Check Grafana datasources
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Then visit http://localhost:3000

# Check Terraform state
terraform state list
terraform state show module.eks.aws_eks_cluster.eks

# Debug ArgoCD applications
kubectl get applications -n argocd
kubectl describe application django-app -n argocd

# Monitor resource usage
kubectl top nodes
kubectl top pods --all-namespaces
```

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Kube-Prometheus-Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.