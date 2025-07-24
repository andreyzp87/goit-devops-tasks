variable "bucket_name" {
  description = "The name of the S3 bucket used to store Terraform state files"
  type        = string
}

variable "table_name" {
  description = "The name of the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "terraform-locks"
}
