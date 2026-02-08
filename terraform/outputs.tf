output "ec2_public_ip" {
  description = "EC2のパブリックIPアドレス（SSH接続に使用）"
  value       = aws_instance.app_server.public_ip
}