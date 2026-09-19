# ---------------------------------------------------------
# Jenkins Controller IAM Role
# ---------------------------------------------------------

resource "aws_iam_role" "jenkins_controller" {
  name = "${var.project_name}-${var.environment}-jenkins-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-controller-role"
    Role = "jenkins-controller"
  }
}

resource "aws_iam_instance_profile" "jenkins_controller" {
  name = "${var.project_name}-${var.environment}-jenkins-controller-profile"
  role = aws_iam_role.jenkins_controller.name
}

resource "aws_iam_role_policy_attachment" "jenkins_controller_ssm" {
  role       = aws_iam_role.jenkins_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ---------------------------------------------------------
# Jenkins Agent IAM Role
# ---------------------------------------------------------

resource "aws_iam_role" "jenkins_agent" {
  name = "${var.project_name}-${var.environment}-jenkins-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-agent-role"
    Role = "jenkins-agent"
  }
}

resource "aws_iam_instance_profile" "jenkins_agent" {
  name = "${var.project_name}-${var.environment}-jenkins-agent-profile"
  role = aws_iam_role.jenkins_agent.name
}

resource "aws_iam_role_policy_attachment" "jenkins_agent_ssm" {
  role       = aws_iam_role.jenkins_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ---------------------------------------------------------
# Jenkins Agent ECR Permissions
# ---------------------------------------------------------

resource "aws_iam_role_policy" "jenkins_agent_ecr" {
  name = "${var.project_name}-${var.environment}-jenkins-agent-ecr-policy"

  role = aws_iam_role.jenkins_agent.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories"
        ]

        Resource = var.ecr_repository_arn
      }
    ]
  })
}
# ---------------------------------------------------------
# Jenkins Agent EKS Read Access
# ---------------------------------------------------------

resource "aws_iam_role_policy" "jenkins_agent_eks_read" {
  name = "${var.project_name}-${var.environment}-jenkins-agent-eks-read"

  role = aws_iam_role.jenkins_agent.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = "arn:aws:eks:${var.aws_region}:*:cluster/${var.project_name}-${var.environment}-eks"
      }
    ]
  })
}