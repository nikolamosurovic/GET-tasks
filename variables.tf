# Public IP address allowed for SSH access
variable "allowed_ip" {
  description = "Public IP address allowed for SSH access"
  type        = string
  default     = "213.196.99.66/32" # Replace with your current public IP
}

# Hash of the password for PostgreSQL RDS instance
variable "db_password_hash" {
  description = "Hash of the password for PostgreSQL RDS instance"
  type        = string
  default     = "5d41402abc4b2a76b9719d911017c592"
  sensitive   = true
}
