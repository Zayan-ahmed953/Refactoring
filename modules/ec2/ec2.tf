data "aws_iam_instance_profile" "EC2-Default-SSM-AD-Role" {
name = "EC2-Default-SSM-AD-Role"
}
resource "aws_instance" "backstage" {
  ami                    = var.ec2_ami
  count                  = var.ec2_count
  instance_type          = var.instance_type
  iam_instance_profile = data.aws_iam_instance_profile.EC2-Default-SSM-AD-Role.name
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [ aws_security_group.backstage.id ]
  associate_public_ip_address = false

  # root disk
    root_block_device {
      volume_size           = "50"
      volume_type           = "gp2"
      encrypted             = true
      delete_on_termination = true
    }
    # data disk
    ebs_block_device {
      device_name           = "/dev/xvda"
      volume_size           = "200"
      volume_type           = "gp2"
      encrypted             = true
      delete_on_termination = true
    }

 tags = "${merge(module.common.common_tags,{
        Name = "${var.ec2_name}-${count.index}"
        Enviroment = "${var.env}"
        },
    )}"
}





