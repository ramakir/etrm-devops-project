data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

module "vpc" {
  source = "../../modules/vpc"

  project_name = "etrm"
  environment  = "dev"

  vpc_cidr = "10.10.0.0/16"

  availability_zones = [
    "ap-south-1a",
    "ap-south-1b"
  ]

  public_subnet_cidrs = [
    "10.10.1.0/24",
    "10.10.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.10.11.0/24",
    "10.10.12.0/24"
  ]

  enable_nat_gateway = true
}

module "iam" {
  source = "../../modules/iam"

  project_name = "etrm"
  environment  = "dev"
}

module "eks" {
  source = "../../modules/eks"

  project_name    = "etrm"
  environment     = "dev"
  cluster_name    = "etrm-dev-eks"
  cluster_version = "1.33"

  vpc_id = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_role_arn                = module.iam.eks_cluster_role_arn
  node_role_arn                   = module.iam.eks_node_role_arn
  jenkins_agent_role_arn          = module.jenkins.jenkins_agent_role_arn
  jenkins_agent_security_group_id = "sg-098e52b60b77c74a9"
}

module "rds" {
  source = "../../modules/rds"

  project_name = "etrm"
  environment  = "dev"

  vpc_id = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnet_ids

  db_name     = "etrm"
  db_username = "etrmuser"

  db_password = var.db_password

  db_instance_class = "db.t3.micro"

  eks_security_group_id = module.eks.cluster_security_group_id
}
module "irsa" {
  source = "../../modules/irsa"

  project_name = "etrm"
  environment  = "dev"

  oidc_issuer_url = module.eks.cluster_oidc_issuer_url

  rds_resource_id = module.rds.db_resource_id

  db_username = "etrmapp"

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region
}
module "alb_controller" {
  source = "../../modules/alb-controller"

  project_name = "etrm"
  environment  = "dev"

  cluster_name = module.eks.cluster_name

  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region

  vpc_id = module.vpc.vpc_id

  depends_on = [
    module.eks,
    module.irsa
  ]
}
module "metrics_server" {
  source = "../../modules/metrics-server"

  depends_on = [
    module.eks
  ]
}
module "jenkins" {
  source = "../../modules/jenkins"

  project_name = "etrm"
  environment  = "dev"

  vpc_id = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnet_ids

  controller_instance_type = "t3.medium"
  agent_instance_type      = "t3.medium"

  aws_region = var.aws_region

  ecr_repository_arn = module.ecr.repository_arn

  jenkins_ami_id = "ami-07f35208dba26f009"
}
module "ecr" {
  source = "../../modules/ecr"

  project_name    = "etrm"
  environment     = "dev"
  repository_name = "etrm/trade-service"
}
module "argocd" {
  source = "../../modules/argocd"

  depends_on = [
    module.eks
  ]
}
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name = "etrm"
  environment  = "dev"
  cluster_name = "etrm-dev-eks"
  alarm_email  = var.alarm_email

  depends_on = [module.eks]
}


