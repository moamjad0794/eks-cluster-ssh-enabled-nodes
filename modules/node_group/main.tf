# Node Group Security Group to allow SSH from Bastion
resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "Allow SSH from bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [var.my_ip]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-nodes-sg"
  }
}

data "aws_ssm_parameter" "eks_ami_al2" {
  name = "/aws/service/eks/optimized-ami/1.29/amazon-linux-2/recommended/image_id"
}


data "aws_ami" "eks_worker" {
  most_recent = false
  owners      = ["602401143452"]

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.eks_ami_al2.value]
  }
}


# Create Launch Template with SSH key and security group
resource "aws_launch_template" "lt" {
  name_prefix   = "eks-node-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = "t3.small"
  key_name      = var.key_name

user_data = base64encode(<<-EOT
  #!/bin/bash
  /etc/eks/bootstrap.sh myekscluster
EOT
)



  vpc_security_group_ids = [aws_security_group.eks_nodes_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-node"
    }
  }

  tags = {
  Name = "eks-launch-template"
}

}

# IAM Role for Node Group
resource "aws_iam_role" "node_role" {
  name = "eksNodeGroupRole"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "worker_node_policies" {
  count      = length(var.worker_node_policies)
  role       = aws_iam_role.node_role.name
  policy_arn = var.worker_node_policies[count.index]
}

# EKS Node Group using Launch Template
resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"   # AWS Special keyword telling to use a latest image does not behave like shell in terraform used for AWS
  }

  depends_on = [aws_iam_role_policy_attachment.worker_node_policies]
}
