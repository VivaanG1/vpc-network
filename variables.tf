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

variable "repo_url" {
  description = "Value of the REPO_URL"
  type        = string
}

variable "github_runner_token" {
  description = "Value of the github_runner_token"
  type        = string
}
variable "runner_name" {
  description = "Value of the runner_name"
  type        = string
}