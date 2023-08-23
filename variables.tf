variable "environment" {
  description = "VPC Environment"
  type        = string
  default     = "yellow-mustard2023"
}

variable "vpc_id" {
  description = "VPC id for Airflow"
  type        = string
  default     = "vpc-063ff1e11d533d583"
}

variable "private_subnet_ids" {
  description = "2 Private Subnet id for Airflow"
  type        = list(string)
  default     = ["subnet-0dcdd8c51fdf5f08f", "subnet-07c7c5cd7df130343"]
}