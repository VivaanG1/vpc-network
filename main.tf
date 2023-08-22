module "network" {
  source      = "./stacks/network"
  environment = var.environment
}

module "airflow" {
  source             = "./stacks/airflow"
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  environment        = var.environment
}

module "runner" {
  source       = "./stacks/runner"
  github_repos = var.github_repos
}