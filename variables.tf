variable "environment" {
  description = "VPC Environment"
  type        = string
  default     = "mustard2023"
}

variable "vpc_id" {
  description = "VPC id for Airflow"
  type        = string
  default     = "vpc-0833b52c46a47ed47"
}

variable "private_subnet_ids" {
  description = "2 Private Subnet id for Airflow"
  type        = list(string)
  default     = ["subnet-066a3993547bf19ea", "subnet-01c366de88e9886cb"]
}