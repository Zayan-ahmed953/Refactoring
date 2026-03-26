resource "aws_instance" "example" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.nano"
  subnet_id = "subnet-01799a347de0a1046"

  tags = {
    Name = "HelloWorrrldd"
  }
}