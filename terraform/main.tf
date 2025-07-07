locals {
  region        = data.aws_region.current.name
  naming_prefix = "tb"
}

module "Networking" {
  source               = "../modules/Networking"
  vpc_cidr_block       = "10.10.0.0/16"
  region               = local.region
  public_subnet_count  = 2
  private_subnet_count = 2
  naming_prefix        = local.naming_prefix
}

module "Compute" {
  source            = "../modules/Compute"
  vpc_id            = module.Networking.vpc_id
  public_subnet_ids = module.Networking.public_subnet_ids
  instance_count    = 1
  ami_id            = data.aws_ami.most_recent_amazon_linux_2023.id
  instance_type     = "t2.micro"
  user_data_file    = file("${path.root}/../scripts/userdata.sh")
  naming_prefix     = local.naming_prefix
  public_ssm_sg_id  = module.Networking.public_ssm_sg_id
}

module "EcsContainer" {
  source                    = "../modules/Container"
  vpc_id                    = module.Networking.vpc_id
  private_subnet_ids        = module.Networking.private_subnet_ids
  ami_id                    = data.aws_ami.most_recent_ecs_optimized.id
  instance_type             = "t3.medium"
  asg_ec2_security_group_id = module.Networking.ec2_asg_sg_id
  naming_prefix             = local.naming_prefix
  ecs_cluster_name          = "nginx-custom-app"
}

module "LoadBalancer" {
  source            = "../modules/LoadBalancing"
  vpc_id            = module.Networking.vpc_id
  public_subnet_ids = module.Networking.public_subnet_ids
  alb_sg_id         = module.Networking.alb_sg_id
  naming_prefix     = local.naming_prefix
}