data "tls_certificate" "eks_oidc" {
  url = var.oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = var.oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-oidc"
  }
}

locals {
  oidc_issuer_hostpath = replace(var.oidc_issuer_url, "https://", "")
}

resource "aws_iam_role" "trade_service" {
  name = "${var.project_name}-${var.environment}-trade-service-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.oidc_issuer_hostpath}:aud" = "sts.amazonaws.com"

            "${local.oidc_issuer_hostpath}:sub" = "system:serviceaccount:etrm:trade-service"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-trade-service-irsa"
  }
}

resource "aws_iam_role_policy" "trade_service_rds" {
  name = "${var.project_name}-${var.environment}-trade-service-rds-connect"

  role = aws_iam_role.trade_service.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "rds-db:connect"
        ]

        Resource = "arn:aws:rds-db:${var.aws_region}:${var.aws_account_id}:dbuser:${var.rds_resource_id}/${var.db_username}"
      }
    ]
  })
}