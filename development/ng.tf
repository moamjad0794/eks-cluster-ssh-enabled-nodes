# data "external" "myip" {
#   program = ["bash", "${path.module}/get-my-ip.sh"]
# }

module "node_group" {
  source       = "../modules/node_group"
  cluster_name = module.eks_cluster.cluster_name
  subnet_ids   = module.vpc.public_subnet_ids
  key_name     = var.key_name
  vpc_id       = module.vpc.vpc_id
  my_ip        = local.my_ip
}
