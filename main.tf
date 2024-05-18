module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones = var.availability_zones
}

module "ecr" {
  source = "./modules/ecr"
  ecr_repo_name = var.ecr_repo_name
}

module "ecs" {
  depends_on = [module.vpc, module.ecr]
  source = "./modules/ecs"
  cluster_name = var.cluster_name
  container_name = var.container_name
  app_service = var.app_service
  family_name = var.family_name
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  ecr_repository_url = module.ecr.repository_url
}