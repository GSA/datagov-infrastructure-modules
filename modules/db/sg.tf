resource "aws_security_group" "default" {
  name        = "${var.db_name}-${var.env}-db-tf"
  description = "Database security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = [aws_security_group.db_access.id]
  }
}

resource "aws_security_group" "db_access" {
  name        = "${var.db_name}-${var.env}-db-access-tf"
  description = "Allowed access to database"
  vpc_id      = var.vpc_id

  egress {
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

