# AWS Infrastructure with Terraform

This project contains Terraform configuration files to create and manage AWS infrastructure including S3 for state storage, VPC networking, and ECR for Docker images.

## Project Structure

```
lesson-5/
│
├── main.tf                  # Main file for module connections
├── backend.tf               # Backend configuration for state files (S3 + DynamoDB)
├── outputs.tf               # General resource outputs
│
├── modules/                 # Directory with all modules
│   │
│   ├── s3-backend/          # Module for S3 and DynamoDB
│   │   ├── s3.tf            # S3 bucket creation
│   │   ├── dynamodb.tf      # DynamoDB creation
│   │   ├── variables.tf     # Variables for S3
│   │   └── outputs.tf       # Output information about S3 and DynamoDB
│   │
│   ├── vpc/                 # Module for VPC
│   │   ├── vpc.tf           # VPC, subnets, Internet Gateway creation
│   │   ├── routes.tf        # Routing configuration
│   │   ├── variables.tf     # Variables for VPC
│   │   └── outputs.tf       # Output information about VPC
│   │
│   └── ecr/                 # Module for ECR
│       ├── ecr.tf           # ECR repository creation
│       ├── variables.tf     # Variables for ECR
│       └── outputs.tf       # Output ECR repository URL
│
└── README.md                # Project documentation
```

## Module Descriptions

### 1. S3 Backend Module

This module creates:
- An S3 bucket for storing Terraform state files with versioning enabled
- A DynamoDB table for state locking to prevent concurrent modifications

### 2. VPC Module

This module creates a complete networking setup:
- VPC with specified CIDR block
- 3 public subnets (with internet access)
- 3 private subnets (with NAT gateway)
- Internet Gateway for public subnets
- NAT Gateway for private subnets
- Route tables and associations

### 3. ECR Module

This module creates:
- An Elastic Container Registry (ECR) repository for Docker images
- Image scanning configuration
- Lifecycle policy to manage image versions

## Usage

### Step 1: Create S3 Backend Infrastructure First

Since the S3 bucket and DynamoDB table need to exist before they can be used as a backend, follow these steps:

1. Comment out the backend configuration in `backend.tf`:
```terraform
# Comment out this section
# terraform {
#   backend "s3" {
#     bucket         = "tf-state-goit-devops"
#     key            = "lesson-5/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
```

2. Initialize Terraform with local state:
```bash
terraform init
```

3. Apply only the S3 backend module:
```bash
terraform apply -target=module.s3_backend
```

4. After the S3 bucket and DynamoDB table are created, uncomment the backend configuration in `backend.tf`

5. Reinitialize Terraform to migrate the state to S3:
```bash
terraform init -migrate-state
```

6. Confirm the migration when prompted

### Step 2: Deploy the Complete Infrastructure

Once the backend is set up:

```bash
terraform plan
terraform apply
```

### Destroying Resources

To destroy all resources:

```bash
terraform destroy
```

Note: If you need to destroy the S3 bucket and DynamoDB table last, you'll need to move the state back to local first:

1. Comment out the S3 backend configuration in `backend.tf`
2. Run `terraform init -migrate-state` to migrate back to local state
3. Run `terraform destroy`

## Important Variables

- `bucket_name`: Name for your S3 state bucket
- `vpc_cidr_block`: CIDR block for your VPC
- `ecr_name`: Name for your ECR repository

