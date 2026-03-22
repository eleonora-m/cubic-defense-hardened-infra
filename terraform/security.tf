# 1. Public Security Group (Для балансировщика нагрузки или Bastion Host)
resource "aws_security_group" "public_sg" {
  name        = "cubic-defense-public-sg"
  description = "Allow inbound web traffic from the internet"
  
  # Магия Terraform: Мы берем ID сети напрямую из нашего модуля VPC!
  vpc_id      = module.vpc.vpc_id

  # INGRESS: Входящий трафик (Кто может к нам зайти?)
  ingress {
    description = "Allow Secure Web Traffic (HTTPS)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 0.0.0.0/0 означает "Весь интернет"
  }

  # EGRESS: Исходящий трафик (Куда наши сервера могут обращаться?)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 означает "Все протоколы"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cubic-defense-public-sg"
    Tier = "Public"
  }
}

# 2. Private Security Group (Для внутренних серверов приложений / БД)
resource "aws_security_group" "private_sg" {
  name        = "cubic-defense-private-sg"
  description = "Allow inbound traffic ONLY from the Public Security Group"
  vpc_id      = module.vpc.vpc_id

  # INGRESS: Защита уровня Сеньор (Zero Trust)
  ingress {
    description     = "Allow web traffic ONLY from Public SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    # ОБРАТИТЕ ВНИМАНИЕ: Здесь нет IP-адресов! Мы ссылаемся на первую группу.
    security_groups = [aws_security_group.public_sg.id] 
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cubic-defense-private-sg"
    Tier = "Private"
  }
}