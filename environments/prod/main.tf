resource "aws_instance" "example" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.nano"
  subnet_id = "subnet-07ccb110c0067e339"

  tags = {
    Name = "HelloWorrldd"
  }
}