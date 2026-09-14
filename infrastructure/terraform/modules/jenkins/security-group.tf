resource "aws_security_group" "jenkins_controller" {
  name        = "${var.project_name}-${var.environment}-jenkins-controller-sg"
  description = "Security group for Jenkins Controller"
  vpc_id      = var.vpc_id

  ingress {
    description = "Jenkins web UI from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description     = "Jenkins inbound agents"
    from_port       = 50000
    to_port         = 50000
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_agent.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-controller-sg"
    Role = "jenkins-controller"
  }
}

resource "aws_security_group" "jenkins_agent" {
  name        = "${var.project_name}-${var.environment}-jenkins-agent-sg"
  description = "Security group for Jenkins Agent"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow outbound traffic through NAT Gateway"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-agent-sg"
    Role = "jenkins-agent"
  }
}