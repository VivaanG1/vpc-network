variable "environment" {
  description = "Name of Airflow Environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC id for Airflow"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet CIDRs for Airflow"
  type        = list(string)
}