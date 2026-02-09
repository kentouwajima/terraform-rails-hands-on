output "ec2_public_ip" {
  description = "EC2のパブリックIPアドレス"
  value       = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  description = "RDSの接続用エンドポイント"
  value       = aws_db_instance.main.endpoint
}
