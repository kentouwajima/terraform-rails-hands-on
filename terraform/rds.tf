# 1. DBサブネットグループ (2つのプライベートサブネットを束ねる)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}

# 2. RDSインスタンス本体
resource "aws_db_instance" "main" {
  identifier             = "${var.project}-db"
  allocated_storage      = 20
  storage_type           = "gp3" # 最新の汎用ストレージ
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" # 無料枠対象
  db_name                = "rails_db"    # Rails用に名称変更
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.project}-rds"
  }
}