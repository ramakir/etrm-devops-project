# ---------------------------------------------------------
# Amazon Linux 2023 AMI
# ---------------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ---------------------------------------------------------
# Jenkins Controller
# ---------------------------------------------------------

resource "aws_instance" "jenkins_controller" {
  ami           = var.jenkins_ami_id
  instance_type = var.controller_instance_type

  subnet_id = var.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.jenkins_controller.id
  ]

  iam_instance_profile = aws_iam_instance_profile.jenkins_controller.name

  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              set -euxo pipefail

              # -------------------------------------------------
              # System update
              # -------------------------------------------------

              dnf update -y

              # -------------------------------------------------
              # Java 21
              # -------------------------------------------------

              dnf install -y java-21-amazon-corretto

              # -------------------------------------------------
              # Basic administration tools
              # Do NOT install curl because AL2023 provides
              # curl-minimal.
              # -------------------------------------------------

              dnf install -y git wget unzip tar gzip

              # -------------------------------------------------
              # AWS Systems Manager
              # -------------------------------------------------

              dnf install -y amazon-ssm-agent

              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent

              # -------------------------------------------------
              # Jenkins RPM repository
              # Current Jenkins LTS RPM repository
              # -------------------------------------------------

              wget -O /etc/yum.repos.d/jenkins.repo \
                https://pkg.jenkins.io/rpm-stable/jenkins.repo

              # Jenkins 2026 repository signing key
              rpm --import \
                https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

              # -------------------------------------------------
              # Refresh package metadata
              # -------------------------------------------------

              dnf clean all
              dnf makecache

              # -------------------------------------------------
              # Jenkins dependencies
              # -------------------------------------------------

              dnf install -y fontconfig

              # -------------------------------------------------
              # Install Jenkins
              # -------------------------------------------------

              dnf install -y jenkins

              # -------------------------------------------------
              # Start Jenkins
              # -------------------------------------------------

              systemctl daemon-reload
              systemctl enable jenkins
              systemctl start jenkins

              # -------------------------------------------------
              # Verify Jenkins
              # -------------------------------------------------

              systemctl is-active --quiet jenkins
              EOF

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-controller"
    Role = "jenkins-controller"
  }

  depends_on = [
    aws_iam_role_policy_attachment.jenkins_controller_ssm
  ]
}

# ---------------------------------------------------------
# Jenkins Agent
# ---------------------------------------------------------

resource "aws_instance" "jenkins_agent" {
  ami           = var.jenkins_ami_id
  instance_type = var.agent_instance_type

  subnet_id = var.private_subnet_ids[1]

  vpc_security_group_ids = [
    aws_security_group.jenkins_agent.id
  ]

  iam_instance_profile = aws_iam_instance_profile.jenkins_agent.name

  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              set -euxo pipefail

              # -------------------------------------------------
              # System update
              # -------------------------------------------------

              dnf update -y

              # -------------------------------------------------
              # Java 21 - Jenkins Agent runtime
              # -------------------------------------------------

              dnf install -y java-21-amazon-corretto

              # -------------------------------------------------
              # Build/source tools
              # Do NOT install curl because AL2023 provides
              # curl-minimal.
              # -------------------------------------------------

              dnf install -y git wget unzip tar gzip

              # -------------------------------------------------
              # Maven
              # -------------------------------------------------

              dnf install -y maven

              # -------------------------------------------------
              # Docker
              # -------------------------------------------------

              dnf install -y docker

              systemctl enable docker
              systemctl start docker

              # -------------------------------------------------
              # AWS CLI
              # -------------------------------------------------

              dnf install -y awscli

              # -------------------------------------------------
              # Docker permissions
              # Jenkins user will be created later when the
              # Jenkins agent is configured.
              # -------------------------------------------------

              if id jenkins >/dev/null 2>&1; then
                  usermod -aG docker jenkins
              fi

              # -------------------------------------------------
              # Workspace
              # -------------------------------------------------

              mkdir -p /opt/jenkins-agent
              chmod 755 /opt/jenkins-agent

              # -------------------------------------------------
              # Verify required tools
              # -------------------------------------------------

              java -version
              mvn -version
              docker --version
              aws --version
              git --version
              EOF

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-agent"
    Role = "jenkins-agent"
  }

  depends_on = [
    aws_iam_role_policy_attachment.jenkins_agent_ssm,
    aws_iam_role_policy.jenkins_agent_ecr
  ]
}