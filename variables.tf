variable "environment" {
  description = "VPC Environment"
  type        = string
  default     = "mustard2023"
}

variable "vpc_id" {
  description = "VPC id for Airflow"
  type        = string
  default     = "vpc-07b36320d71a67f27"
}

variable "private_subnet_ids" {
  description = "2 Private Subnet id for Airflow"
  type        = list(string)
  default     = ["subnet-0fea25e449326e702", "subnet-0aadb1900b3014c14"]
}