terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "andreyzp87-state-goit-devops"
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  vpc_name           = "goit-devops-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "goit-devops-django-app"
  scan_on_push = true
}

module "eks" {
  source           = "./modules/eks"
  cluster_name     = "goit-devops-eks-cluster"
  cluster_version  = "1.28"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  node_group_name  = "goit-devops-node-group"
  instance_types   = ["t3.medium"]
  desired_capacity = 2
  max_capacity     = 3
  min_capacity     = 1
}

data "aws_eks_cluster" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "jenkins" {
  source            = "./modules/jenkins"
  kubeconfig        = data.aws_eks_cluster.eks.endpoint
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  github_username   = var.github_username
  github_token      = var.github_token

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "argo_cd" {
  source          = "./modules/argo_cd"
  namespace       = "argocd"
  chart_version   = "5.46.4"
  github_username = var.github_username
  github_token    = var.github_token

  depends_on = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  name                  = "myapp-db"
  use_aurora            = false
  aurora_instance_count = 2

  # --- Aurora-only ---
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  db_name                 = var.postgres_db
  username                = var.postgres_user
  password                = var.postgres_password
  subnet_private_ids      = module.vpc.private_subnet_ids
  subnet_public_ids       = module.vpc.public_subnet_ids
  publicly_accessible     = true
  vpc_id                  = module.vpc.vpc_id
  multi_az                = false
  backup_retention_period = 7
  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}

module "monitoring" {
  source = "./modules/monitoring"

  namespace    = "monitoring"
  cluster_name = module.eks.cluster_name

  # Monitoring configuration
  prometheus_storage_size  = "10Gi"
  grafana_storage_size     = "10Gi"
  grafana_admin_password   = "admin123"
  enable_persistence       = true
  install_separate_grafana = false # Use Grafana from kube-prometheus-stack

  depends_on = [
    module.eks,
    module.jenkins # Ensure storage class is created
  ]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
