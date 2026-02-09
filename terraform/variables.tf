variable "project" {
  description = "プロジェクト名"
  type        = string
  default     = "terraform-rails-hands-on"
}

variable "db_username" {
  description = "RDS user"
  type        = string
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}