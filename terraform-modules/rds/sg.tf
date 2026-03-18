resource "aws_security_group" "postgres" {
    name = var.rds_sg
    description = "Allow TLS inbound traffic"
    vpc_id = var.vpc_id

    ingress {
        description = "Mariadb Access from within the VPC"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Allow access to prod postgre rds"
    }
}
