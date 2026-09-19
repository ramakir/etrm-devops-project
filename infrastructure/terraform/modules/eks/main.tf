resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Name                                   = "${var.project_name}-${var.environment}-eks"
    "alpha.eksctl.io/cluster-oidc-enabled" = "true"
  }
}
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-${var.environment}-nodes"

  node_role_arn = var.node_role_arn

  subnet_ids = var.private_subnet_ids

  instance_types = var.node_instance_types

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    environment = var.environment
    workload    = "general"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-node"
  }

  depends_on = [
    aws_eks_cluster.this
  ]
}
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.4.0-eksbuild.2"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.this
  ]
}
resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "amazon-cloudwatch-observability"
  addon_version = "v6.6.0-eksbuild.1"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_addon.pod_identity_agent
  ]
}
resource "aws_eks_access_entry" "jenkins_agent" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.jenkins_agent_role_arn
  type          = "STANDARD"

  depends_on = [
    aws_eks_cluster.this
  ]
}

resource "aws_eks_access_policy_association" "jenkins_agent_view" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.jenkins_agent_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.jenkins_agent
  ]
}
resource "aws_vpc_security_group_ingress_rule" "jenkins_agent_to_eks_api" {
  security_group_id            = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  referenced_security_group_id = var.jenkins_agent_security_group_id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow Jenkins agent to access EKS Kubernetes API"
}