

resource "aws_security_group" "backstage" {
  name        = var.sg_name
  description = "DSO SG"
  vpc_id      = var.vpc_id  //data.aws_vpc.vpc_name.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    description = "DSO application"
  }

  ingress {
    from_port   = 7007
    to_port     = 7007
    protocol    = "tcp"
    description = "DSO application"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "Backstage ssh"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "allow all egress"
  }

}

