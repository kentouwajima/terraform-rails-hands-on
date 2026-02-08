# 最新の Amazon Linux 2023 AMI を取得
data "aws_ami" "amzn_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# EC2インスタンス
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amzn_linux_2023.id
  instance_type          = "t3.micro"
  key_name               = "kentouwajima"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.public[0].id

  tags = {
    Name = "${var.project}-ec2"
  }
}