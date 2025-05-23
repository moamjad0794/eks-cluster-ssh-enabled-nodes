# data "external" "myip" {
#   program = ["bash", "${path.module}/get-my-ip.sh"]
# }

module "eks_cluster" {
  source             = "../modules/eks_cluster"
  cluster_name       = "myekscluster"
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  allowed_cidrs      = [local.my_ip]
  vpc_cidr_block     = module.vpc.vpc_cidr_block
}
